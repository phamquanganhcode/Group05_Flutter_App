import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../struct/material_meta.dart';
import '../struct/borrow_request.dart';
import '../struct/user_profile.dart';
import '../services/recommendation_service.dart';
import '../services/supabase_service.dart';
import '../services/cloud_sync_service.dart';

class MaterialProvider with ChangeNotifier {
  final AppDatabase _db;
  List<StudyMaterial> _materials = [];
  List<StudyMaterial> _filteredMaterials = [];
  String _searchQuery = '';
  final Set<String> _selectedTags = {};
  String _selectedFilter = 'Tất cả';

  // Hồ sơ người dùng hiện tại & Quản lý sở thích
  UserProfile _userProfile = UserProfile(
    id: 'uid_user1_phamanh',
    email: 'phamanhh25@gmail.com',
    displayName: 'Phạm Quang Anh (MSSV: 2351170573)',
    interests: ['#Flutter', '#MobileApp', '#Firebase', '#Supabase', '#KienTrucPhanMem'],
    preferredSubjects: [
      'Phát triển ứng dụng di động (Flutter)',
      'Kiến trúc hệ thống phần mềm',
    ],
    department: 'Khoa Công nghệ Thông tin - 65KTPM',
    currentLocationName: 'Thư viện Trung tâm - Tầng 2',
    latitude: 21.028511,
    longitude: 105.854167,
  );

  // Danh sách yêu cầu mượn tài liệu
  List<BorrowRequest> _borrowRequests = [];

  MaterialProvider(this._db) {
    _loadMaterials();
    _initDemoBorrowRequests();
  }

  List<StudyMaterial> get materials =>
      _filteredMaterials.isEmpty && _searchQuery.isEmpty && _selectedTags.isEmpty && _selectedFilter == 'Tất cả'
          ? _materials
          : _filteredMaterials;

  List<StudyMaterial> get allRawMaterials => _materials;
  Set<String> get selectedTags => _selectedTags;
  String get selectedFilter => _selectedFilter;
  UserProfile get userProfile => _userProfile;
  List<BorrowRequest> get borrowRequests => _borrowRequests;

  /// Danh sách các yêu cầu mượn tôi đã gửi đi
  List<BorrowRequest> get myOutgoingRequests => _borrowRequests
      .where((r) => r.borrowerEmail.toLowerCase() == _userProfile.email.toLowerCase())
      .toList();

  /// Danh sách các yêu cầu mượn gửi đến tài liệu của tôi (cần tôi duyệt)
  List<BorrowRequest> get incomingRequestsToApprove => _borrowRequests
      .where((r) => r.ownerEmail.toLowerCase() == _userProfile.email.toLowerCase())
      .toList();

  /// Tập hợp toàn bộ các Tag có trong hệ thống
  List<String> get allUniqueTags {
    final Set<String> tags = {};
    for (final m in _materials) {
      final meta = MaterialMeta.fromRaw(m.description);
      tags.addAll(meta.tags);
    }
    return tags.toList()..sort();
  }

  /// Danh sách tài liệu vật lý có vị trí định vị
  List<StudyMaterial> get physicalMaterialsWithLocation {
    return _materials.where((m) {
      final meta = MaterialMeta.fromRaw(m.description);
      return meta.isPhysical && meta.latitude != null && meta.longitude != null;
    }).toList();
  }

  /// Kết quả thuật toán gợi ý tài liệu thông minh
  List<RecommendationResult> get recommendations {
    return RecommendationService.getRecommendations(
      allMaterials: _materials,
      userProfile: _userProfile,
      limit: 10,
    );
  }

  Future<void> _loadMaterials() async {
    _materials = await _db.select(_db.studyMaterials).get();
    if (_materials.isEmpty) {
      await _seedDemoData();
      _materials = await _db.select(_db.studyMaterials).get();
    }
    _applyFilterAndSearch();
    notifyListeners();
  }

  Future<void> _seedDemoData() async {
    final demoItems = [
      {
        'title': 'Giáo trình Lập trình Thiết bị Di động với Flutter (Bản cứng)',
        'type': 'Bài giảng',
        'meta': MaterialMeta(
          subject: 'Phát triển ứng dụng di động (Flutter)',
          deadline: null,
          notes: 'Sách in màu bìa cứng, chuyên sâu về Provider, Drift ORM và Hybrid Cloud Architecture.',
          isCompleted: true,
          isFavorite: true,
          tags: ['#Flutter', '#MobileApp', '#Provider', '#DriftORM'],
          isPhysical: true,
          locationName: 'Thư viện Trung tâm - Tầng 2, Kệ A04',
          shelfCode: 'KỆ-A04-T2',
          latitude: 21.028511,
          longitude: 105.854167,
          isAvailableForBorrow: true,
          borrowStatus: 'AVAILABLE',
          ownerEmail: 'thuvien@test.edu.vn',
          ownerName: 'Thư viện ĐHQG',
          viewCount: 45,
        ),
        'url': 'https://flutter.dev',
      },
      {
        'title': 'Đồ án Mẫu: Hệ thống Quản lý Tài liệu Cloud DMS (Hybrid)',
        'type': 'Bài tập',
        'meta': MaterialMeta(
          subject: 'Phát triển ứng dụng di động (Flutter)',
          deadline: '2026-11-15',
          notes: 'Source code mẫu và thuyết minh đồ án kết hợp Firebase Authentication và Supabase RLS.',
          isCompleted: false,
          isFavorite: true,
          tags: ['#Flutter', '#Firebase', '#Supabase', '#KienTrucPhanMem', '#CSDL'],
          isPhysical: false,
          locationName: null,
          isAvailableForBorrow: true,
          borrowStatus: 'AVAILABLE',
          ownerEmail: 'phamanhh25@gmail.com',
          ownerName: 'Phạm Quang Anh (MSSV: 2351170573)',
          viewCount: 82,
        ),
        'url': 'https://github.com/flutter/samples',
      },
      {
        'title': 'Sách gốc: Clean Architecture & Clean Code in Dart (Bản in)',
        'type': 'Tài liệu tham khảo',
        'meta': MaterialMeta(
          subject: 'Kiến trúc hệ thống phần mềm',
          deadline: null,
          notes: 'Bản in tiếng Anh Robert C. Martin, lưu tại phòng Lab phần mềm để sinh viên mượn nghiên cứu.',
          isCompleted: false,
          isFavorite: true,
          tags: ['#CleanArchitecture', '#Dart', '#DesignPattern', '#Refactoring'],
          isPhysical: true,
          locationName: 'Phòng Thí nghiệm Phần mềm Lab 402 - Tủ Kỹ thuật',
          shelfCode: 'LAB402-TU-B',
          latitude: 21.028920,
          longitude: 105.854510,
          isAvailableForBorrow: true,
          borrowStatus: 'BORROWED',
          borrowerEmail: 'binhan.group05@gmail.com',
          borrowerName: 'Nguyễn Phúc Bình An',
          borrowDueDate: '2026-11-05',
          ownerEmail: 'phamanhh25@gmail.com',
          ownerName: 'Phạm Quang Anh',
          viewCount: 38,
        ),
        'url': 'https://dart.dev/guides/language',
      },
      {
        'title': 'Slide Chương 4: Cơ sở dữ liệu phân tán & Row Level Security',
        'type': 'Bài giảng',
        'meta': MaterialMeta(
          subject: 'Cơ sở dữ liệu phân tán',
          deadline: null,
          notes: 'Bài giảng lý thuyết và bài tập thực hành thiết lập Policy RLS trên PostgreSQL Supabase.',
          isCompleted: true,
          isFavorite: false,
          tags: ['#CSDL', '#PostgreSQL', '#Supabase', '#Security', '#RLS'],
          isPhysical: false,
          isAvailableForBorrow: true,
          borrowStatus: 'AVAILABLE',
          ownerEmail: 'namkhanh.group05@gmail.com',
          ownerName: 'Ngô Đức Nam Khánh',
          viewCount: 19,
        ),
        'url': 'https://supabase.com/docs/guides/auth/row-level-security',
      },
      {
        'title': 'Tài liệu thực hành: Tích hợp Bản đồ & Vị trí trong Flutter',
        'type': 'Tài liệu tham khảo',
        'meta': MaterialMeta(
          subject: 'Phát triển ứng dụng di động (Flutter)',
          deadline: '2026-11-20',
          notes: 'Hướng dẫn sử dụng Geolocation, tính khoảng cách Haversine và hiển thị sơ đồ khuôn viên.',
          isCompleted: false,
          isFavorite: true,
          tags: ['#Flutter', '#MobileApp', '#Location', '#Map', '#Haversine'],
          isPhysical: true,
          locationName: 'Văn phòng Bộ môn KTPM - Kệ 01',
          shelfCode: 'BM-KTPM-KE01',
          latitude: 21.028200,
          longitude: 105.853900,
          isAvailableForBorrow: true,
          borrowStatus: 'AVAILABLE',
          ownerEmail: 'phamanhh25@gmail.com',
          ownerName: 'Phạm Quang Anh',
          viewCount: 27,
        ),
        'url': 'https://flutter.dev/docs',
      },
    ];

    for (final item in demoItems) {
      final meta = item['meta'] as MaterialMeta;
      await _db.into(_db.studyMaterials).insert(
        StudyMaterialsCompanion(
          title: drift.Value(item['title'] as String),
          description: drift.Value(meta.toRaw()),
          type: drift.Value(item['type'] as String),
          url: drift.Value(item['url'] as String),
          createdAt: drift.Value(DateTime.now()),
        ),
      );
    }
  }

  void _initDemoBorrowRequests() {
    _borrowRequests = [
      BorrowRequest(
        id: 'req_001',
        documentId: '3',
        documentTitle: 'Sách gốc: Clean Architecture & Clean Code in Dart (Bản in)',
        borrowerId: 'uid_user2_binhan',
        borrowerEmail: 'binhan.group05@gmail.com',
        borrowerName: 'Nguyễn Phúc Bình An',
        ownerId: 'uid_user1_phamanh',
        ownerEmail: 'phamanhh25@gmail.com',
        requestDate: '2026-10-20',
        returnDate: '2026-11-05',
        status: 'APPROVED',
        notes: 'Mượn sách để ôn thi phần Clean Architecture và Refactoring mã nguồn.',
        locationName: 'Phòng Thí nghiệm Phần mềm Lab 402 - Tủ Kỹ thuật',
        shelfCode: 'LAB402-TU-B',
      ),
      BorrowRequest(
        id: 'req_002',
        documentId: '1',
        documentTitle: 'Giáo trình Lập trình Thiết bị Di động với Flutter (Bản cứng)',
        borrowerId: 'uid_user1_phamanh',
        borrowerEmail: 'phamanhh25@gmail.com',
        borrowerName: 'Phạm Quang Anh (MSSV: 2351170573)',
        ownerId: 'uid_thuvien',
        ownerEmail: 'thuvien@test.edu.vn',
        requestDate: '2026-10-22',
        returnDate: '2026-11-10',
        status: 'PENDING',
        notes: 'Đang chờ thủ thư duyệt để nhận sách tại Tầng 2 Thư viện Trung tâm.',
        locationName: 'Thư viện Trung tâm - Tầng 2, Kệ A04',
        shelfCode: 'KỆ-A04-T2',
      ),
    ];
  }

  void _applyFilterAndSearch() {
    _filteredMaterials = _materials.where((m) {
      final meta = MaterialMeta.fromRaw(m.description);

      // 1. Lọc theo trạng thái / loại
      if (_selectedFilter == 'Đã xong' && !meta.isCompleted) return false;
      if (_selectedFilter == 'Yêu thích' && !meta.isFavorite) return false;
      if (_selectedFilter == 'Tài liệu vật lý' && !meta.isPhysical) return false;
      if (_selectedFilter == 'Đang mượn' && meta.borrowStatus != 'BORROWED') return false;
      if (_selectedFilter != 'Tất cả' &&
          _selectedFilter != 'Đã xong' &&
          _selectedFilter != 'Yêu thích' &&
          _selectedFilter != 'Tài liệu vật lý' &&
          _selectedFilter != 'Đang mượn' &&
          m.type != _selectedFilter) {
        return false;
      }

      // 2. Lọc theo Tag đã chọn
      if (_selectedTags.isNotEmpty) {
        final docTags = meta.tags.map((t) => t.toLowerCase()).toSet();
        final matchesAnyTag = _selectedTags.any((st) => docTags.contains(st.toLowerCase()));
        if (!matchesAnyTag) return false;
      }

      // 3. Tìm kiếm theo từ khóa
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final inTitle = m.title.toLowerCase().contains(q);
        final inType = m.type.toLowerCase().contains(q);
        final inSubject = meta.subject.toLowerCase().contains(q);
        final inNotes = meta.notes.toLowerCase().contains(q);
        final inLocation = (meta.locationName ?? '').toLowerCase().contains(q);
        final inTags = meta.tags.any((t) => t.toLowerCase().contains(q));
        if (!inTitle && !inType && !inSubject && !inNotes && !inLocation && !inTags) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilterAndSearch();
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilterAndSearch();
    notifyListeners();
  }

  void toggleTagFilter(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    _applyFilterAndSearch();
    notifyListeners();
  }

  void clearTagFilters() {
    _selectedTags.clear();
    _applyFilterAndSearch();
    notifyListeners();
  }

  Future<void> addMaterial(
    String title,
    String description,
    String type,
    String url,
  ) async {
    final newMaterial = StudyMaterialsCompanion(
      title: drift.Value(title),
      description: drift.Value(description),
      type: drift.Value(type),
      url: drift.Value(url),
      createdAt: drift.Value(DateTime.now()),
    );
    await _db.into(_db.studyMaterials).insert(newMaterial);
    await _loadMaterials();
  }

  Future<void> updateMaterial(
    StudyMaterial material,
    String newTitle,
    String newDesc,
    String newType,
    String newUrl,
  ) async {
    final updatedMaterial = material.copyWith(
      title: newTitle,
      description: drift.Value(newDesc),
      type: newType,
      url: drift.Value(newUrl),
    );
    await _db.update(_db.studyMaterials).replace(updatedMaterial);
    await _loadMaterials();
  }

  Future<void> deleteMaterial(StudyMaterial material) async {
    await _db.delete(_db.studyMaterials).delete(material);
    await _loadMaterials();
  }

  /// Cập nhật sở thích học tập của người dùng (Tags & Môn học)
  void updateUserProfile({
    required List<String> interests,
    required List<String> preferredSubjects,
    String? currentLocationName,
    double? latitude,
    double? longitude,
  }) {
    _userProfile = _userProfile.copyWith(
      interests: interests,
      preferredSubjects: preferredSubjects,
      currentLocationName: currentLocationName,
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();
  }

  /// ==============================================================================
  /// QUẢN LÝ MƯỢN TRẢ TÀI LIỆU (BORROW & LEND ACTIONS)
  /// ==============================================================================

  /// Gửi yêu cầu mượn tài liệu mới
  Future<bool> sendBorrowRequest({
    required StudyMaterial material,
    required String returnDate,
    required String notes,
  }) async {
    final meta = MaterialMeta.fromRaw(material.description);
    final req = BorrowRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      documentId: material.id.toString(),
      documentTitle: material.title,
      borrowerId: _userProfile.id,
      borrowerEmail: _userProfile.email,
      borrowerName: _userProfile.displayName,
      ownerId: meta.ownerId ?? 'uid_owner',
      ownerEmail: meta.ownerEmail ?? 'owner@test.edu.vn',
      requestDate: DateTime.now().toString().split(' ').first,
      returnDate: returnDate,
      status: 'PENDING',
      notes: notes,
      locationName: meta.locationName,
      shelfCode: meta.shelfCode,
    );

    _borrowRequests.insert(0, req);

    // Đồng bộ lên Cloud (Firebase & Supabase)
    await CloudSyncService.syncBorrowRequestToCloud(req);
    await SupabaseService.createBorrowRequest(req);

    notifyListeners();
    return true;
  }

  /// Phê duyệt yêu cầu mượn (Dành cho Chủ sở hữu / Thủ thư)
  Future<bool> approveBorrowRequest(BorrowRequest req) async {
    final index = _borrowRequests.indexWhere((r) => r.id == req.id);
    if (index != -1) {
      _borrowRequests[index] = _borrowRequests[index].copyWith(status: 'APPROVED');
    }

    // Cập nhật trạng thái của tài liệu tương ứng thành 'BORROWED'
    final docId = int.tryParse(req.documentId);
    if (docId != null) {
      final docIndex = _materials.indexWhere((m) => m.id == docId);
      if (docIndex != -1) {
        final doc = _materials[docIndex];
        final meta = MaterialMeta.fromRaw(doc.description).copyWith(
          borrowStatus: 'BORROWED',
          borrowerEmail: req.borrowerEmail,
          borrowerName: req.borrowerName,
          borrowDueDate: req.returnDate,
        );
        await updateMaterial(doc, doc.title, meta.toRaw(), doc.type, doc.url ?? '');
      }
    }

    await CloudSyncService.updateBorrowStatusOnCloud(req.id, 'APPROVED');
    await SupabaseService.updateBorrowRequestStatus(req.id, 'APPROVED');

    notifyListeners();
    return true;
  }

  /// Từ chối yêu cầu mượn
  Future<bool> rejectBorrowRequest(BorrowRequest req) async {
    final index = _borrowRequests.indexWhere((r) => r.id == req.id);
    if (index != -1) {
      _borrowRequests[index] = _borrowRequests[index].copyWith(status: 'REJECTED');
    }

    await CloudSyncService.updateBorrowStatusOnCloud(req.id, 'REJECTED');
    await SupabaseService.updateBorrowRequestStatus(req.id, 'REJECTED');

    notifyListeners();
    return true;
  }

  /// Xác nhận đã trả tài liệu (Chuyển trạng thái về AVAILABLE)
  Future<bool> returnBorrowedDocument(BorrowRequest req) async {
    final index = _borrowRequests.indexWhere((r) => r.id == req.id);
    if (index != -1) {
      _borrowRequests[index] = _borrowRequests[index].copyWith(status: 'RETURNED');
    }

    final docId = int.tryParse(req.documentId);
    if (docId != null) {
      final docIndex = _materials.indexWhere((m) => m.id == docId);
      if (docIndex != -1) {
        final doc = _materials[docIndex];
        final meta = MaterialMeta.fromRaw(doc.description).copyWith(
          borrowStatus: 'AVAILABLE',
          borrowerEmail: null,
          borrowerName: null,
          borrowDueDate: null,
        );
        await updateMaterial(doc, doc.title, meta.toRaw(), doc.type, doc.url ?? '');
      }
    }

    await CloudSyncService.updateBorrowStatusOnCloud(req.id, 'RETURNED');
    await SupabaseService.updateBorrowRequestStatus(req.id, 'RETURNED');

    notifyListeners();
    return true;
  }
}
