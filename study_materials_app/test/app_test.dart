import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:study_materials_app/database/database.dart';
import 'package:study_materials_app/struct/material_meta.dart';
import 'package:study_materials_app/struct/borrow_request.dart';
import 'package:study_materials_app/struct/user_profile.dart';
import 'package:study_materials_app/providers/material_provider.dart';
import 'package:study_materials_app/services/recommendation_service.dart';

void main() {
  group('1. Kiểm thử mô hình dữ liệu MaterialMeta (Metadata nâng cao)', () {
    test('Khởi tạo và chuyển đổi sang JSON (toRaw/fromRaw) bảo toàn Tags và Vị trí', () {
      final meta = MaterialMeta(
        subject: 'Phát triển ứng dụng di động (Flutter)',
        deadline: '2026-10-15',
        notes: 'Bài tập lớn TH1: Cloud DMS',
        isCompleted: false,
        isFavorite: true,
        tags: ['#Flutter', '#MobileApp', '#Firebase', '#Supabase'],
        isPhysical: true,
        locationName: 'Thư viện Trung tâm - Tầng 2, Kệ A04',
        shelfCode: 'KỆ-A04-T2',
        latitude: 21.028511,
        longitude: 105.854167,
        isAvailableForBorrow: true,
        borrowStatus: 'AVAILABLE',
      );

      final raw = meta.toRaw();
      expect(raw, contains('#Flutter'));
      expect(raw, contains('KỆ-A04-T2'));
      expect(raw, contains('21.028511'));

      final parsed = MaterialMeta.fromRaw(raw);
      expect(parsed.subject, 'Phát triển ứng dụng di động (Flutter)');
      expect(parsed.tags.length, 4);
      expect(parsed.tags.contains('#Firebase'), true);
      expect(parsed.isPhysical, true);
      expect(parsed.locationName, 'Thư viện Trung tâm - Tầng 2, Kệ A04');
      expect(parsed.shelfCode, 'KỆ-A04-T2');
      expect(parsed.latitude, 21.028511);
      expect(parsed.borrowStatus, 'AVAILABLE');
    });

    test('Xử lý an toàn khi chuỗi raw rỗng hoặc null', () {
      final emptyMeta = MaterialMeta.fromRaw(null);
      expect(emptyMeta.subject, 'Phát triển ứng dụng di động (Flutter)');
      expect(emptyMeta.tags.isEmpty, true);
      expect(emptyMeta.isPhysical, false);
      expect(emptyMeta.isCompleted, false);
    });
  });

  group('2. Kiểm thử Cơ sở dữ liệu Cục bộ (Drift Database)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Thêm tài liệu mới và truy vấn danh sách', () async {
      final meta = MaterialMeta(
        subject: 'Kiến trúc hệ thống phần mềm',
        notes: 'Tài liệu tích hợp Firebase & Supabase',
        tags: ['#KienTrucPhanMem', '#HybridCloud'],
      );

      final id = await db.into(db.studyMaterials).insert(
        StudyMaterialsCompanion(
          title: const Value('Slide Chương 1: Cloud Integration'),
          type: const Value('Bài giảng'),
          description: Value(meta.toRaw()),
          url: const Value('https://console.firebase.google.com'),
        ),
      );

      expect(id, isNonNegative);

      final all = await db.select(db.studyMaterials).get();
      expect(all.length, 1);
      expect(all.first.title, 'Slide Chương 1: Cloud Integration');
      expect(all.first.type, 'Bài giảng');
    });

    test('Cập nhật và Xóa tài liệu', () async {
      final id = await db.into(db.studyMaterials).insert(
        StudyMaterialsCompanion(
          title: const Value('Đề cương ôn thi'),
          type: const Value('Tài liệu tham khảo'),
        ),
      );

      final item = (await db.select(db.studyMaterials).get()).first;
      expect(item.id, id);

      // Cập nhật
      await db.update(db.studyMaterials).replace(
        item.copyWith(title: 'Đề cương ôn tập cuối kỳ'),
      );

      final updated = (await db.select(db.studyMaterials).get()).first;
      expect(updated.title, 'Đề cương ôn tập cuối kỳ');

      // Xóa
      await db.delete(db.studyMaterials).delete(updated);
      final afterDelete = await db.select(db.studyMaterials).get();
      expect(afterDelete.isEmpty, true);
    });
  });

  group('3. Kiểm thử MaterialProvider (State Management & Tag Filters)', () {
    late AppDatabase db;
    late MaterialProvider provider;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      provider = MaterialProvider(db);
      await Future.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() async {
      await db.close();
    });

    test('Seed sẵn 5 tài liệu demo và thêm mới 1 tài liệu', () async {
      final meta = MaterialMeta(
        subject: 'Cơ sở dữ liệu phân tán',
        notes: 'Bài tập lớn nhóm 65KTPM',
        tags: ['#CSDL', '#PostgreSQL'],
      );

      await provider.addMaterial(
        'Báo cáo Tiến độ Đồ án',
        meta.toRaw(),
        'Bài tập',
        'https://drive.google.com',
      );

      await Future.delayed(const Duration(milliseconds: 50));
      // Ban đầu có 5 mục demo mẫu + 1 mục mới thêm = 6 mục
      expect(provider.allRawMaterials.length, 6);
      expect(provider.allRawMaterials.any((m) => m.title == 'Báo cáo Tiến độ Đồ án'), true);
    });

    test('Lọc theo Tag (Multi-tag filtering)', () async {
      provider.toggleTagFilter('#Flutter');
      final filtered = provider.materials;
      // Tất cả tài liệu kết quả phải chứa tag #Flutter
      expect(filtered.isNotEmpty, true);
      for (final m in filtered) {
        final meta = MaterialMeta.fromRaw(m.description);
        expect(meta.tags.any((t) => t.toLowerCase() == '#flutter'), true);
      }

      provider.clearTagFilters();
      expect(provider.selectedTags.isEmpty, true);
    });
  });

  group('4. Kiểm thử Tính khoảng cách & Vị trí Vật lý (Location & Haversine)', () {
    test('Tính khoảng cách Haversine giữa 2 tọa độ khuôn viên trường', () {
      // Tọa độ Thư viện Trung tâm (21.028511, 105.854167)
      // Tọa độ Lab 402 (21.028920, 105.854510)
      final dist = RecommendationService.calculateDistanceMeters(
        21.028511,
        105.854167,
        21.028920,
        105.854510,
      );

      // Khoảng cách thực tế trong khuôn viên khoảng 50 - 150 mét
      expect(dist, greaterThan(30.0));
      expect(dist, lessThan(200.0));
    });
  });

  group('5. Kiểm thử Luồng nghiệp vụ Mượn & Trả tài liệu (Borrow & Lend Lifecycle)', () {
    late AppDatabase db;
    late MaterialProvider provider;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      provider = MaterialProvider(db);
      await Future.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() async {
      await db.close();
    });

    test('Gửi yêu cầu mượn -> Phê duyệt -> Trả tài liệu', () async {
      final doc = provider.allRawMaterials.first;

      // 1. Gửi yêu cầu mượn
      final requested = await provider.sendBorrowRequest(
        material: doc,
        returnDate: '2026-11-20',
        notes: 'Mượn tài liệu để chuẩn bị thi cuối kỳ',
      );
      expect(requested, true);

      final myReqs = provider.myOutgoingRequests;
      expect(myReqs.isNotEmpty, true);
      final firstReq = myReqs.first;
      expect(firstReq.status, 'PENDING');
      expect(firstReq.documentTitle, doc.title);

      // 2. Phê duyệt yêu cầu mượn
      await provider.approveBorrowRequest(firstReq);
      final approvedReq = provider.borrowRequests.firstWhere((r) => r.id == firstReq.id);
      expect(approvedReq.status, 'APPROVED');

      // 3. Trả lại tài liệu
      await provider.returnBorrowedDocument(approvedReq);
      final returnedReq = provider.borrowRequests.firstWhere((r) => r.id == firstReq.id);
      expect(returnedReq.status, 'RETURNED');
    });
  });

  group('6. Kiểm thử Thuật toán Gợi ý Tài liệu Thông minh (Smart Recommendation Engine)', () {
    test('Gợi ý theo độ tương đồng Jaccard và giải thích AI', () {
      final user = UserProfile(
        id: 'user_test',
        email: 'test@student.edu.vn',
        displayName: 'Nguyễn Văn Test',
        interests: ['#Flutter', '#MobileApp', '#Firebase'],
        preferredSubjects: ['Phát triển ứng dụng di động (Flutter)'],
        latitude: 21.028511,
        longitude: 105.854167,
      );

      final docHighMatch = StudyMaterial(
        id: 1,
        title: 'Lập trình Flutter Chuyên Sâu',
        type: 'Bài giảng',
        description: MaterialMeta(
          subject: 'Phát triển ứng dụng di động (Flutter)',
          tags: ['#Flutter', '#MobileApp', '#Firebase'],
          isFavorite: true,
        ).toRaw(),
        url: 'https://flutter.dev',
        createdAt: DateTime.now(),
      );

      final docLowMatch = StudyMaterial(
        id: 2,
        title: 'Mạng máy tính cơ bản',
        type: 'Bài giảng',
        description: MaterialMeta(
          subject: 'Mạng máy tính',
          tags: ['#Network', '#Cisco'],
        ).toRaw(),
        url: null,
        createdAt: DateTime.now(),
      );

      final recommendations = RecommendationService.getRecommendations(
        allMaterials: [docLowMatch, docHighMatch],
        userProfile: user,
      );

      expect(recommendations.isNotEmpty, true);
      // Tài liệu High Match phải được xếp hạng đầu tiên
      expect(recommendations.first.material.id, 1);
      expect(recommendations.first.matchPercentage, greaterThan(70));
      expect(recommendations.first.primaryReason, contains('Khớp'));
      expect(recommendations.first.primaryReason, contains('#Flutter'));
    });
  });
}
