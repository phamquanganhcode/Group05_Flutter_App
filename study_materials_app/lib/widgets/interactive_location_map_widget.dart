import 'package:flutter/material.dart';
import '../database/database.dart';
import '../struct/material_meta.dart';
import '../services/recommendation_service.dart';

class LocationPreset {
  final String name;
  final String shelf;
  final double latitude;
  final double longitude;
  final IconData icon;
  final Color color;

  const LocationPreset({
    required this.name,
    required this.shelf,
    required this.latitude,
    required this.longitude,
    required this.icon,
    required this.color,
  });
}

class InteractiveLocationMapWidget extends StatefulWidget {
  final List<StudyMaterial> materials;
  final double userLat;
  final double userLng;
  final Function(StudyMaterial material)? onSelectMaterial;
  final Function(LocationPreset preset)? onPickLocation;
  final bool isPickerMode;

  const InteractiveLocationMapWidget({
    Key? key,
    required this.materials,
    this.userLat = 21.028511,
    this.userLng = 105.854167,
    this.onSelectMaterial,
    this.onPickLocation,
    this.isPickerMode = false,
  }) : super(key: key);

  static const List<LocationPreset> presets = [
    LocationPreset(
      name: 'Thư viện Trung tâm - Tầng 2, Kệ A04',
      shelf: 'KỆ-A04-T2',
      latitude: 21.028511,
      longitude: 105.854167,
      icon: Icons.local_library,
      color: Color(0xFF1E88E5),
    ),
    LocationPreset(
      name: 'Phòng Thí nghiệm Lab 402 - Tủ Kỹ thuật',
      shelf: 'LAB402-TU-B',
      latitude: 21.028920,
      longitude: 105.854510,
      icon: Icons.biotech,
      color: Color(0xFF10B981),
    ),
    LocationPreset(
      name: 'Văn phòng Bộ môn KTPM - Kệ 01',
      shelf: 'BM-KTPM-KE01',
      latitude: 21.028200,
      longitude: 105.853900,
      icon: Icons.account_balance,
      color: Color(0xFF8B5CF6),
    ),
    LocationPreset(
      name: 'Giảng đường H1 - Phòng 301',
      shelf: 'H1-P301',
      latitude: 21.029100,
      longitude: 105.853500,
      icon: Icons.school,
      color: Color(0xFFF59E0B),
    ),
  ];

  @override
  State<InteractiveLocationMapWidget> createState() => _InteractiveLocationMapWidgetState();
}

class _InteractiveLocationMapWidgetState extends State<InteractiveLocationMapWidget> {
  StudyMaterial? _selectedMaterial;
  LocationPreset? _selectedPreset;

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách tài liệu có định vị
    final physicalDocs = widget.materials.where((m) {
      final meta = MaterialMeta.fromRaw(m.description);
      return meta.isPhysical && meta.latitude != null && meta.longitude != null;
    }).toList();

    return Column(
      children: [
        // Bản đồ mô phỏng khuôn viên trực quan (Interactive Vector Canvas)
        Container(
          height: widget.isPickerMode ? 260 : 340,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: const Color(0xFF334155), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Bản đồ nền vector & Lưới tọa độ
                CustomPaint(
                  size: Size.infinite,
                  painter: _CampusMapPainter(
                    userLat: widget.userLat,
                    userLng: widget.userLng,
                  ),
                ),

                // Vị trí người dùng (Blinking Blue Dot)
                Positioned(
                  left: 60,
                  top: 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E88E5).withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.my_location, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Bạn đang ở đây',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Các điểm ghim (Pins) tài liệu vật lý
                ...physicalDocs.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final doc = entry.value;
                  final meta = MaterialMeta.fromRaw(doc.description);

                  // Vị trí mẫu trên Canvas tương quan tọa độ
                  final double left = 60.0 + ((idx + 1) * 65.0) % 240;
                  final double top = 120.0 + ((idx * 55.0) % 150);

                  final isSelected = _selectedMaterial?.id == doc.id;

                  return Positioned(
                    left: left,
                    top: top,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMaterial = doc;
                          _selectedPreset = null;
                        });
                        if (widget.onSelectMaterial != null) {
                          widget.onSelectMaterial!(doc);
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isSelected ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                                      .withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.menu_book, color: Colors.white, size: 18),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              meta.shelfCode ?? 'Kệ tài liệu',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // HUD Bar trên cùng hiển thị GPS Status
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF475569)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.satellite_alt, color: Color(0xFF10B981), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'GPS Live: ${widget.userLat.toStringAsFixed(4)}, ${widget.userLng.toStringAsFixed(4)}',
                          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Thẻ thông tin tài liệu / vị trí đang chọn
        if (_selectedMaterial != null) ...[
          _buildSelectedMaterialCard(_selectedMaterial!),
        ],

        // Nếu ở chế độ chọn vị trí (Picker mode khi tạo/sửa tài liệu)
        if (widget.isPickerMode) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn vị trí vật lý trong khuôn viên trường:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: InteractiveLocationMapWidget.presets.map((p) {
                    final isChosen = _selectedPreset?.shelf == p.shelf;
                    return ChoiceChip(
                      selected: isChosen,
                      avatar: Icon(p.icon, size: 16, color: isChosen ? Colors.white : p.color),
                      label: Text('${p.name} (${p.shelf})'),
                      selectedColor: const Color(0xFF1E88E5),
                      labelStyle: TextStyle(
                        color: isChosen ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedPreset = val ? p : null;
                        });
                        if (val && widget.onPickLocation != null) {
                          widget.onPickLocation!(p);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedMaterialCard(StudyMaterial material) {
    final meta = MaterialMeta.fromRaw(material.description);
    double? dist;
    if (meta.latitude != null && meta.longitude != null) {
      dist = RecommendationService.calculateDistanceMeters(
        widget.userLat,
        widget.userLng,
        meta.latitude!,
        meta.longitude!,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.place, color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta.locationName ?? 'Vị trí chưa xác định',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (dist != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dist < 1000 ? '${dist.toStringAsFixed(0)} m' : '${(dist / 1000).toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(
                backgroundColor: const Color(0xFFF1F5F9),
                avatar: const Icon(Icons.shelves, size: 16, color: Color(0xFF475569)),
                label: Text(
                  meta.shelfCode ?? 'Kệ A04',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                backgroundColor: meta.borrowStatus == 'AVAILABLE'
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEF3C7),
                label: Text(
                  meta.borrowStatus == 'AVAILABLE' ? 'Có sẵn để mượn' : 'Đang được mượn',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: meta.borrowStatus == 'AVAILABLE' ? const Color(0xFF166534) : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vẽ bản đồ sơ đồ khuôn viên trường & Thư viện
class _CampusMapPainter extends CustomPainter {
  final double userLat;
  final double userLng;

  _CampusMapPainter({required this.userLat, required this.userLng});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    // Vẽ lưới tọa độ
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vẽ các khối tòa nhà khuôn viên
    final buildingPaint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final roadPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    // Tuyến đường nội bộ trường
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), roadPaint);

    // Tòa Thư viện Trung tâm
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(30, 40, 110, 80), const Radius.circular(8)),
      buildingPaint,
    );

    // Tòa Nhà H1 (Giảng đường)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 130, 40, 100, 80), const Radius.circular(8)),
      buildingPaint,
    );

    // Nhà Lab & Bộ môn KTPM
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(30, size.height - 100, 120, 70), const Radius.circular(8)),
      buildingPaint,
    );

    // Nhãn tòa nhà
    _drawText(canvas, 'Thư viện ĐHQG', const Offset(40, 75));
    _drawText(canvas, 'Nhà Giảng Đường H1', Offset(size.width - 125, 75));
    _drawText(canvas, 'Lab 402 / KTPM', Offset(40, size.height - 70));
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
