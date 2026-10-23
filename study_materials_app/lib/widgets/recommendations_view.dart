import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/material_provider.dart';
import '../services/recommendation_service.dart';
import 'borrow_request_dialog.dart';

class RecommendationsView extends StatelessWidget {
  final Function(dynamic material)? onOpenMaterial;

  const RecommendationsView({Key? key, this.onOpenMaterial}) : super(key: key);

  void _showInterestsDialog(BuildContext context, MaterialProvider provider) {
    final currentInterests = List<String>.from(provider.userProfile.interests);
    final availableTags = [
      '#Flutter',
      '#MobileApp',
      '#Firebase',
      '#Supabase',
      '#CSDL',
      '#PostgreSQL',
      '#CleanArchitecture',
      '#Dart',
      '#DesignPattern',
      '#Location',
      '#Map',
      '#AI',
      '#CloudDMS',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.tune, color: Color(0xFF1E88E5)),
                  SizedBox(width: 10),
                  Text('Tùy chỉnh sở thích học tập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thuật toán sẽ tự động tính toán lại mức độ tương đồng Jaccard và gợi ý tài liệu chính xác hơn:',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableTags.map((tag) {
                        final isSelected = currentInterests.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1E88E5),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            setStateModal(() {
                              if (val) {
                                currentInterests.add(tag);
                              } else {
                                currentInterests.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.updateUserProfile(
                      interests: currentInterests,
                      preferredSubjects: provider.userProfile.preferredSubjects,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Đã cập nhật sở thích! Danh sách gợi ý đã được làm mới.'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
                  child: const Text('Lưu & Áp dụng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MaterialProvider>(context);
    final recommendations = provider.recommendations;

    return Column(
      children: [
        // Thanh banner thuật toán AI Recommendation
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Smart Recommendation Engine',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gợi ý theo độ tương đồng Jaccard (${provider.userProfile.interests.length} tags) & Vị trí gần bạn',
                      style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showInterestsDialog(context, provider),
                icon: const Icon(Icons.tune, size: 14),
                label: const Text('Đổi sở thích', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),

        // Danh sách các tài liệu được gợi ý
        Expanded(
          child: recommendations.isEmpty
              ? const Center(
                  child: Text('Chưa có gợi ý phù hợp. Hãy thêm tài liệu hoặc bổ sung tag sở thích!'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: recommendations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rec = recommendations[index];
                    return _buildRecommendationCard(context, provider, rec);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    MaterialProvider provider,
    RecommendationResult rec,
  ) {
    final doc = rec.material;
    final meta = rec.meta;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rec.matchPercentage >= 75 ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
          width: rec.matchPercentage >= 75 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Match Percentage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: rec.matchPercentage >= 80
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insights,
                      size: 15,
                      color: rec.matchPercentage >= 80
                          ? const Color(0xFF15803D)
                          : const Color(0xFF1D4ED8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rec.matchPercentage}% Phù hợp',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: rec.matchPercentage >= 80
                            ? const Color(0xFF15803D)
                            : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (meta.isPhysical)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.inventory_2, size: 13, color: Color(0xFF92400E)),
                      SizedBox(width: 4),
                      Text('Bản in vật lý', style: TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Tiêu đề tài liệu
          Text(
            doc.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),

          // Lý do gợi ý (Explainable AI)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, size: 16, color: Color(0xFF6366F1)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rec.primaryReason,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Danh sách các tag của tài liệu
          if (meta.tags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: meta.tags.map((t) {
                final isMatched = rec.matchedTags.contains(t.replaceAll('#', '').toLowerCase());
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isMatched ? const Color(0xFF1E88E5) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isMatched ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Footer & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Môn: ${meta.subject}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => BorrowRequestDialog(material: doc),
                  );
                },
                icon: const Icon(Icons.handshake, size: 15),
                label: const Text('Mượn tài liệu', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
