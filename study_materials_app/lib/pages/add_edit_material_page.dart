import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database.dart';
import '../providers/material_provider.dart';
import '../struct/material_meta.dart';
import '../services/cloud_sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/share_document_dialog.dart';
import '../widgets/interactive_location_map_widget.dart';

class AddEditMaterialPage extends StatefulWidget {
  final StudyMaterial? material;

  const AddEditMaterialPage({Key? key, this.material}) : super(key: key);

  @override
  State<AddEditMaterialPage> createState() => _AddEditMaterialPageState();
}

class _AddEditMaterialPageState extends State<AddEditMaterialPage> {
  late String _selectedType;
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _urlController;
  late TextEditingController _tagInputController;
  late TextEditingController _locationNameController;
  late TextEditingController _shelfCodeController;

  late String _selectedSubject;
  DateTime? _selectedDeadline;
  bool _isCompleted = false;
  bool _isFavorite = false;

  // Thuộc tính nâng cao: Tag & Vị trí vật lý & Mượn trả
  List<String> _tags = [];
  bool _isPhysical = false;
  bool _isAvailableForBorrow = true;
  double? _latitude;
  double? _longitude;

  final List<String> _subjects = [
    'Phát triển ứng dụng di động (Flutter)',
    'Kiến trúc hệ thống phần mềm',
    'Lập trình Web nâng cao',
    'Cơ sở dữ liệu phân tán',
    'Mạng máy tính & An toàn thông tin',
  ];

  final List<String> _suggestedTags = [
    '#Flutter',
    '#MobileApp',
    '#Firebase',
    '#Supabase',
    '#CSDL',
    '#CleanArchitecture',
    '#PostgreSQL',
    '#AI',
    '#Dart',
    '#DoAnTotNghiep',
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.material;
    _selectedType = m?.type ?? 'Bài giảng';
    _titleController = TextEditingController(text: m?.title ?? '');
    _urlController = TextEditingController(text: m?.url ?? '');
    _tagInputController = TextEditingController();

    final meta = MaterialMeta.fromRaw(m?.description);
    _selectedSubject = _subjects.contains(meta.subject) ? meta.subject : _subjects.first;
    _notesController = TextEditingController(text: meta.notes);
    _isCompleted = meta.isCompleted;
    _isFavorite = meta.isFavorite;
    _tags = List.from(meta.tags);
    _isPhysical = meta.isPhysical;
    _isAvailableForBorrow = meta.isAvailableForBorrow;
    _latitude = meta.latitude;
    _longitude = meta.longitude;
    _locationNameController = TextEditingController(text: meta.locationName ?? '');
    _shelfCodeController = TextEditingController(text: meta.shelfCode ?? '');

    if (meta.deadline != null && meta.deadline!.isNotEmpty) {
      try {
        _selectedDeadline = DateTime.parse(meta.deadline!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _urlController.dispose();
    _tagInputController.dispose();
    _locationNameController.dispose();
    _shelfCodeController.dispose();
    super.dispose();
  }

  void _addTag(String rawTag) {
    String tag = rawTag.trim();
    if (tag.isEmpty) return;
    if (!tag.startsWith('#')) {
      tag = '#$tag';
    }
    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề tài liệu!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final meta = MaterialMeta(
      subject: _selectedSubject,
      deadline: _selectedDeadline != null
          ? '${_selectedDeadline!.year}-${_selectedDeadline!.month.toString().padLeft(2, '0')}-${_selectedDeadline!.day.toString().padLeft(2, '0')}'
          : null,
      notes: _notesController.text.trim(),
      isCompleted: _isCompleted,
      isFavorite: _isFavorite,
      tags: _tags,
      isPhysical: _isPhysical,
      locationName: _isPhysical && _locationNameController.text.trim().isNotEmpty
          ? _locationNameController.text.trim()
          : null,
      shelfCode: _isPhysical && _shelfCodeController.text.trim().isNotEmpty
          ? _shelfCodeController.text.trim()
          : null,
      latitude: _isPhysical ? _latitude : null,
      longitude: _isPhysical ? _longitude : null,
      isAvailableForBorrow: _isAvailableForBorrow,
    );

    final provider = Provider.of<MaterialProvider>(context, listen: false);
    final rawDesc = meta.toRaw();
    final url = _urlController.text.trim();

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);

    if (widget.material == null) {
      provider.addMaterial(title, rawDesc, _selectedType, url);
      // Tự động đồng bộ lên Firestore đám mây
      CloudSyncService.syncMaterialToCloud(
        title: title,
        type: _selectedType,
        description: rawDesc,
        url: url,
      ).then((success) {
        if (success) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('✓ Đã đồng bộ tài liệu lên Firebase Cloud Firestore thành công!'),
              backgroundColor: Colors.teal,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    } else {
      provider.updateMaterial(widget.material!, title, rawDesc, _selectedType, url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.material != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Chỉnh sửa tài liệu' : 'Thêm tài liệu mới',
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.share, color: Color(0xFF10B981)),
              tooltip: 'Chia sẻ tài liệu',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => ShareDocumentDialog(
                    documentId: widget.material!.id.toString(),
                    documentTitle: widget.material!.title,
                    ownerEmail: FirebaseAuth.instance.currentUser?.email ?? 'phamanhh25@gmail.com',
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.amber : const Color(0xFF64748B),
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loại tài liệu
                    const Text(
                      'Loại tài liệu',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Segmented Buttons
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _buildTypeTab('Bài giảng', '📖 Bài giảng', const Color(0xFF1E88E5)),
                          _buildTypeTab('Bài tập', '📑 Bài tập', const Color(0xFFE65100)),
                          _buildTypeTab('Tài liệu tham khảo', '📗 Tham khảo', const Color(0xFF2E7D32)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Card 1: Tiêu đề tài liệu
                    _buildFieldCard(
                      leading: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'T',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      label: 'Tiêu đề tài liệu *',
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Nhập tiêu đề tài liệu...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 2: Môn học / Học phần
                    _buildFieldCard(
                      leading: const Icon(Icons.school, color: Color(0xFF1E88E5), size: 24),
                      label: 'Môn học / Học phần *',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSubject,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                          items: _subjects.map((s) {
                            return DropdownMenuItem<String>(
                              value: s,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1E88E5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      s,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSubject = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 3: Phân loại bằng Tag (Tags Management)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.label, color: Color(0xFF1E88E5), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Thẻ phân loại (Tags)',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Hiển thị các tag đã gắn
                          if (_tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _tags.map((t) {
                                return Chip(
                                  label: Text(t),
                                  backgroundColor: const Color(0xFF1E88E5).withOpacity(0.12),
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF1E88E5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF1E88E5)),
                                  onDeleted: () => _removeTag(t),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Nhập thêm tag
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagInputController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập thẻ mới (vd: #Flutter, #AI)...',
                                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onSubmitted: _addTag,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _addTag(_tagInputController.text),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Thêm tag', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Gợi ý tag nhanh
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _suggestedTags.map((st) {
                              final isAdded = _tags.contains(st);
                              return ActionChip(
                                label: Text(st),
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: isAdded ? Colors.grey : const Color(0xFF475569),
                                ),
                                backgroundColor: isAdded ? Colors.grey.shade200 : const Color(0xFFF1F5F9),
                                onPressed: isAdded ? null : () => _addTag(st),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 4: Định dạng tài liệu (Vật lý / Bản in vs Bản kỹ thuật số)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.inventory_2, color: Color(0xFF10B981), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tài liệu vật lý / Bản cứng',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isPhysical,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (val) => setState(() => _isPhysical = val),
                              ),
                            ],
                          ),
                          const Text(
                            'Bật nếu tài liệu là sách giáo trình, luận văn in tại Thư viện hoặc Phòng Lab',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),

                          if (_isPhysical) ...[
                            const Divider(height: 20),
                            const Text(
                              'Vị trí vật lý & Kệ tài liệu:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 8),

                            // Các vị trí mẫu sẵn
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: InteractiveLocationMapWidget.presets.map((preset) {
                                final isSelected = _shelfCodeController.text == preset.shelf;
                                return ChoiceChip(
                                  selected: isSelected,
                                  label: Text('${preset.name} (${preset.shelf})'),
                                  selectedColor: const Color(0xFF10B981),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() {
                                        _locationNameController.text = preset.name;
                                        _shelfCodeController.text = preset.shelf;
                                        _latitude = preset.latitude;
                                        _longitude = preset.longitude;
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),

                            TextField(
                              controller: _locationNameController,
                              decoration: InputDecoration(
                                labelText: 'Tên vị trí (vd: Thư viện Tầng 2, Lab 402)',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _shelfCodeController,
                              decoration: InputDecoration(
                                labelText: 'Mã kệ / Số tủ (vd: KỆ-A04-T2)',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 5: Hạn nộp / Deadline
                    InkWell(
                      onTap: _pickDeadline,
                      borderRadius: BorderRadius.circular(14),
                      child: _buildFieldCard(
                        leading: const Icon(Icons.calendar_month_outlined, color: Color(0xFF1E88E5), size: 24),
                        label: 'Hạn nộp / Deadline',
                        trailing: _selectedDeadline != null
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                                onPressed: () => setState(() => _selectedDeadline = null),
                              )
                            : null,
                        child: Text(
                          _selectedDeadline != null
                              ? '${_selectedDeadline!.day.toString().padLeft(2, '0')}/${_selectedDeadline!.month.toString().padLeft(2, '0')}/${_selectedDeadline!.year}'
                              : 'Chưa đặt hạn nộp (Không bắt buộc)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedDeadline != null ? FontWeight.w600 : FontWeight.normal,
                            color: _selectedDeadline != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 6: Ghi chú / Tóm tắt nội dung
                    _buildFieldCard(
                      leading: const Icon(Icons.notes, color: Color(0xFF1E88E5), size: 24),
                      label: 'Ghi chú / Tóm tắt nội dung',
                      child: TextField(
                        controller: _notesController,
                        maxLines: 3,
                        minLines: 1,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Nhập ghi chú tóm tắt nội dung...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 7: Liên kết tài liệu (URL)
                    _buildFieldCard(
                      leading: const Icon(Icons.link, color: Color(0xFF1E88E5), size: 24),
                      label: 'Liên kết tệp đám mây (URL)',
                      child: TextField(
                        controller: _urlController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'https://...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 8: Cho phép mượn & Đã hoàn thành (Toggle Switches)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cho phép người khác mượn',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      'Người dùng khác có thể gửi yêu cầu mượn tài liệu này',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isAvailableForBorrow,
                                activeColor: const Color(0xFF1E88E5),
                                onChanged: (val) => setState(() => _isAvailableForBorrow = val),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Đã hoàn thành',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      'Đánh dấu đã đọc xong bài giảng hoặc đã nộp bài tập',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isCompleted,
                                activeColor: const Color(0xFF1E88E5),
                                onChanged: (val) => setState(() => _isCompleted = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check, color: Colors.white, size: 22),
                  label: Text(
                    isEdit ? 'Lưu thay đổi' : 'Thêm tài liệu mới',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(String type, String label, Color activeAccent) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldCard({
    required Widget leading,
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                child,
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
