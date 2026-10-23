import 'dart:math';
import '../database/database.dart';
import '../struct/material_meta.dart';
import '../struct/user_profile.dart';

class RecommendationResult {
  final StudyMaterial material;
  final MaterialMeta meta;
  final double score; // 0.0 - 1.0
  final int matchPercentage; // 0 - 100%
  final List<String> matchedTags;
  final String primaryReason;
  final double? distanceInMeters;

  RecommendationResult({
    required this.material,
    required this.meta,
    required this.score,
    required this.matchPercentage,
    required this.matchedTags,
    required this.primaryReason,
    this.distanceInMeters,
  });
}

class RecommendationService {
  /// Tính khoảng cách Haversine giữa 2 điểm tọa độ (trả về mét)
  static double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // mét
    final double dLat = (lat2 - lat1) * (pi / 180.0);
    final double dLon = (lon2 - lon1) * (pi / 180.0);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) *
            cos(lat2 * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Thuật toán gợi ý tài liệu kết hợp Content-Based Filtering & Location Proximity
  static List<RecommendationResult> getRecommendations({
    required List<StudyMaterial> allMaterials,
    required UserProfile userProfile,
    int limit = 10,
  }) {
    if (allMaterials.isEmpty) return [];

    final normalizedUserInterests = userProfile.interests
        .map((t) => t.replaceAll('#', '').trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    final List<RecommendationResult> results = [];

    for (final doc in allMaterials) {
      final meta = MaterialMeta.fromRaw(doc.description);
      final docTags = meta.tags
          .map((t) => t.replaceAll('#', '').trim().toLowerCase())
          .where((t) => t.isNotEmpty)
          .toSet();

      // 1. Tag Jaccard Similarity
      final intersection = normalizedUserInterests.intersection(docTags);
      final union = normalizedUserInterests.union(docTags);
      final double tagScore = union.isEmpty ? 0.0 : (intersection.length / union.length);

      // 2. Subject Match
      final bool subjectMatch = userProfile.preferredSubjects.any(
        (s) => s.toLowerCase().contains(meta.subject.toLowerCase()) ||
            meta.subject.toLowerCase().contains(s.toLowerCase()),
      );
      final double subjectScore = subjectMatch ? 0.30 : 0.0;

      // 3. Location Proximity Score (đặc biệt cho tài liệu vật lý/sách trên kệ)
      double locationScore = 0.0;
      double? distanceMeters;
      if (meta.isPhysical &&
          meta.latitude != null &&
          meta.longitude != null &&
          userProfile.latitude != null &&
          userProfile.longitude != null) {
        distanceMeters = calculateDistanceMeters(
          userProfile.latitude!,
          userProfile.longitude!,
          meta.latitude!,
          meta.longitude!,
        );

        // Nếu ở trong bán kính 2km (khuôn viên trường/thư viện), tăng điểm
        if (distanceMeters <= 2000) {
          locationScore = (1.0 - (distanceMeters / 2000)).clamp(0.0, 1.0) * 0.20;
        }
      }

      // 4. Popularity / Quality Score
      double popularityScore = 0.0;
      if (meta.isFavorite) popularityScore += 0.10;
      if (meta.isCompleted) popularityScore += 0.05;
      if (meta.viewCount > 5) popularityScore += 0.05;

      // Tổng hợp điểm số (Trọng số: Tag 45%, Subject 30%, Location 15%, Popularity 10%)
      double totalScore = (tagScore * 1.5) + subjectScore + locationScore + popularityScore;
      totalScore = totalScore.clamp(0.05, 1.0); // Baseline tối thiểu 5%

      // Xây dựng lý do gợi ý (Explainable AI)
      final List<String> reasons = [];
      if (intersection.isNotEmpty) {
        final originalMatched = meta.tags
            .where((t) => intersection.contains(t.replaceAll('#', '').trim().toLowerCase()))
            .toList();
        reasons.add('Khớp ${originalMatched.length} tag: ${originalMatched.join(', ')}');
      }
      if (subjectMatch) {
        reasons.add('Cùng môn học: ${meta.subject}');
      }
      if (distanceMeters != null && distanceMeters <= 500) {
        reasons.add('Gần bạn (${distanceMeters.toStringAsFixed(0)}m tại ${meta.locationName ?? "Thư viện"})');
      } else if (meta.isPhysical && meta.locationName != null) {
        reasons.add('Có sẵn tại: ${meta.locationName}');
      }
      if (meta.isFavorite) {
        reasons.add('Tài liệu được yêu thích');
      }

      final String primaryReason = reasons.isNotEmpty
          ? reasons.join(' • ')
          : 'Tài liệu liên quan đến chương trình Kỹ thuật Phần mềm';

      final int matchPercentage = (totalScore * 100).round().clamp(10, 99);

      results.add(
        RecommendationResult(
          material: doc,
          meta: meta,
          score: totalScore,
          matchPercentage: matchPercentage,
          matchedTags: intersection.toList(),
          primaryReason: primaryReason,
          distanceInMeters: distanceMeters,
        ),
      );
    }

    // Sắp xếp giảm dần theo điểm số gợi ý
    results.sort((a, b) => b.score.compareTo(a.score));

    return results.take(limit).toList();
  }
}
