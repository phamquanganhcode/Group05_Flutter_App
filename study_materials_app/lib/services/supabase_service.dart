import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../struct/borrow_request.dart';
import '../struct/user_profile.dart';

class SupabaseService {
  static SupabaseClient? _client;

  // Cấu hình kết nối Supabase (Project URL và Anon Key)
  static const String supabaseUrl = 'https://xyzcompany.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_for_dms_app';

  /// Khởi tạo Supabase client
  static Future<void> initialize({String? url, String? anonKey}) async {
    try {
      await Supabase.initialize(
        url: url ?? supabaseUrl,
        anonKey: anonKey ?? supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      debugPrint('[SupabaseService] Khởi tạo Supabase thành công!');
    } catch (e) {
      debugPrint('[SupabaseService] Lưu ý cấu hình Supabase URL: $e');
    }
  }

  static SupabaseClient? get client => _client;

  /// 1. Đồng bộ Hồ sơ Người dùng (Profile) từ Firebase sang Supabase kèm theo Tag sở thích
  static Future<void> syncUserProfile(fb.User user, [UserProfile? profile]) async {
    if (_client == null) return;
    try {
      final data = <String, dynamic>{
        'id': user.uid,
        'email': user.email,
        'display_name': user.displayName ?? user.email?.split('@').first ?? 'Sinh viên',
        'avatar_url': user.photoURL,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (profile != null) {
        data['interests'] = profile.interests;
        data['preferred_subjects'] = profile.preferredSubjects;
        data['department'] = profile.department;
        data['current_location_name'] = profile.currentLocationName;
        data['latitude'] = profile.latitude;
        data['longitude'] = profile.longitude;
      }
      await _client!.from('profiles').upsert(data);
      debugPrint('[SupabaseService] Đã đồng bộ profile người dùng: ${user.email}');
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi đồng bộ profile: $e');
    }
  }

  /// 2. Lấy thông tin UserProfile từ Supabase
  static Future<UserProfile?> getUserProfile(String userId, String userEmail) async {
    if (_client == null) return null;
    try {
      final res = await _client!.from('profiles').select().eq('id', userId).maybeSingle();
      if (res != null) {
        return UserProfile.fromMap(res);
      }
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi lấy profile: $e');
    }
    return null;
  }

  /// 3. Lấy danh sách tài liệu mà người dùng có quyền truy cập
  static Future<List<Map<String, dynamic>>> getAccessibleDocuments(String userEmail, String userId) async {
    if (_client == null) return [];
    try {
      final sharedRecords = await _client!
          .from('document_permissions')
          .select('document_id, permission_type')
          .eq('shared_with_email', userEmail);

      final sharedDocIds = (sharedRecords as List)
          .map((r) => r['document_id'] as String)
          .toList();

      var query = _client!.from('documents').select();
      if (sharedDocIds.isNotEmpty) {
        query = query.or('owner_id.eq.$userId,id.in.(${sharedDocIds.join(",")})');
      } else {
        query = query.eq('owner_id', userId);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi tải tài liệu: $e');
      return [];
    }
  }

  /// 4. Thêm tài liệu mới vào Supabase với đầy đủ Tag và Vị trí vật lý
  static Future<Map<String, dynamic>?> createDocument({
    required String title,
    required String description,
    required String type,
    required String subject,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    required fb.User owner,
    List<String> tags = const [],
    String? locationName,
    String? shelfCode,
    double? latitude,
    double? longitude,
    bool isPhysical = false,
  }) async {
    if (_client == null) return null;
    try {
      final docData = {
        'title': title,
        'description': description,
        'type': type,
        'subject': subject,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
        'owner_id': owner.uid,
        'owner_email': owner.email,
        'tags': tags,
        'location_name': locationName,
        'shelf_code': shelfCode,
        'latitude': latitude,
        'longitude': longitude,
        'is_physical': isPhysical,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client!.from('documents').insert(docData).select().single();
      return response;
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi tạo tài liệu: $e');
      return null;
    }
  }

  /// 5. Cập nhật thông tin tài liệu
  static Future<bool> updateDocument({
    required String documentId,
    required String title,
    required String description,
    required String type,
    required String subject,
    List<String>? tags,
    String? locationName,
    String? shelfCode,
    double? latitude,
    double? longitude,
    bool? isPhysical,
    bool? isCompleted,
    bool? isFavorite,
  }) async {
    if (_client == null) return false;
    try {
      final updateData = <String, dynamic>{
        'title': title,
        'description': description,
        'type': type,
        'subject': subject,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (tags != null) updateData['tags'] = tags;
      if (locationName != null) updateData['location_name'] = locationName;
      if (shelfCode != null) updateData['shelf_code'] = shelfCode;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (isPhysical != null) updateData['is_physical'] = isPhysical;
      if (isCompleted != null) updateData['is_completed'] = isCompleted;
      if (isFavorite != null) updateData['is_favorite'] = isFavorite;

      await _client!.from('documents').update(updateData).eq('id', documentId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi cập nhật tài liệu: $e');
      return false;
    }
  }

  /// 6. Xóa tài liệu (Chỉ dành cho Owner)
  static Future<bool> deleteDocument(String documentId, String userId) async {
    if (_client == null) return false;
    try {
      await _client!.from('documents').delete().eq('id', documentId).eq('owner_id', userId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi xóa tài liệu: $e');
      return false;
    }
  }

  /// 7. CHIA SẺ TÀI LIỆU: Cấp quyền VIEW / EDIT
  static Future<bool> shareDocument({
    required String documentId,
    required String targetEmail,
    required String permissionType,
  }) async {
    if (_client == null) return false;
    try {
      await _client!.from('document_permissions').upsert({
        'document_id': documentId,
        'shared_with_email': targetEmail.trim().toLowerCase(),
        'permission_type': permissionType,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('[SupabaseService] Đã chia sẻ tài liệu $documentId cho $targetEmail ($permissionType)');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi chia sẻ tài liệu: $e');
      return false;
    }
  }

  /// 8. Lấy danh sách các quyền chia sẻ của tài liệu
  static Future<List<Map<String, dynamic>>> getDocumentPermissions(String documentId) async {
    if (_client == null) return [];
    try {
      final response = await _client!
          .from('document_permissions')
          .select()
          .eq('document_id', documentId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi lấy danh sách quyền: $e');
      return [];
    }
  }

  /// 9. Thu hồi quyền chia sẻ
  static Future<bool> revokePermission(String permissionId) async {
    if (_client == null) return false;
    try {
      await _client!.from('document_permissions').delete().eq('id', permissionId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi thu hồi quyền: $e');
      return false;
    }
  }

  /// ==============================================================================
  /// 10. NGHIỆP VỤ MƯỢN TRẢ TÀI LIỆU (BORROW & LEND LIFECYCLE)
  /// ==============================================================================

  /// Gửi yêu cầu mượn tài liệu
  static Future<bool> createBorrowRequest(BorrowRequest request) async {
    if (_client == null) return false;
    try {
      await _client!.from('borrow_requests').insert(request.toMap());
      debugPrint('[SupabaseService] Đã tạo yêu cầu mượn: ${request.documentTitle} của ${request.borrowerEmail}');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi tạo yêu cầu mượn: $e');
      return false;
    }
  }

  /// Lấy danh sách các yêu cầu mượn mà người dùng đã gửi đi
  static Future<List<BorrowRequest>> getMyBorrowRequests(String borrowerEmail) async {
    if (_client == null) return [];
    try {
      final res = await _client!
          .from('borrow_requests')
          .select()
          .eq('borrower_email', borrowerEmail.trim().toLowerCase())
          .order('created_at', ascending: false);
      return (res as List).map((r) => BorrowRequest.fromMap(r)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi lấy danh sách mượn của tôi: $e');
      return [];
    }
  }

  /// Lấy danh sách các yêu cầu mượn gửi đến tài liệu của người dùng này (để duyệt/từ chối)
  static Future<List<BorrowRequest>> getIncomingBorrowRequests(String ownerEmail) async {
    if (_client == null) return [];
    try {
      final res = await _client!
          .from('borrow_requests')
          .select()
          .eq('owner_email', ownerEmail.trim().toLowerCase())
          .order('created_at', ascending: false);
      return (res as List).map((r) => BorrowRequest.fromMap(r)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi lấy yêu cầu mượn gửi đến tôi: $e');
      return [];
    }
  }

  /// Cập nhật trạng thái yêu cầu mượn ('APPROVED', 'REJECTED', 'RETURNED')
  static Future<bool> updateBorrowRequestStatus(String requestId, String status) async {
    if (_client == null) return false;
    try {
      await _client!
          .from('borrow_requests')
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', requestId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi cập nhật trạng thái mượn: $e');
      return false;
    }
  }
}
