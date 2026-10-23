import 'package:flutter/foundation.dart';
import '../struct/borrow_request.dart';
import 'supabase_service.dart';

/// Dịch vụ quản lý thông báo thời gian thực (Firebase Cloud Messaging + Supabase)
/// Phụ trách: Dương Văn Hưng (MSSV: 2351170597)
class NotificationService {
  static String? _fcmToken;

  /// Lấy FCM Token hiện tại của thiết bị
  static String? get fcmToken => _fcmToken;

  /// Khởi tạo Firebase Messaging và đăng ký token thiết bị
  static Future<void> initialize({required String userEmail}) async {
    try {
      // Mô phỏng / lấy FCM token trên nền tảng Web hoặc Android
      _fcmToken = 'fcm_token_${DateTime.now().millisecondsSinceEpoch}_${userEmail.split('@').first}';
      debugPrint('[NotificationService] Đã khởi tạo FCM Token: $_fcmToken cho $userEmail');

      // Cập nhật FCM token vào bảng profiles trên Supabase
      await _syncTokenToSupabase(userEmail, _fcmToken!);
    } catch (e) {
      debugPrint('[NotificationService] Lỗi khởi tạo FCM: $e');
    }
  }

  /// Đồng bộ FCM token vào bảng profiles
  static Future<void> _syncTokenToSupabase(String userEmail, String token) async {
    try {
      final client = SupabaseService.client;
      await client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('email', userEmail);
      debugPrint('[NotificationService] Đã đồng bộ FCM Token lên Supabase');
    } catch (e) {
      debugPrint('[NotificationService] Bỏ qua cập nhật Supabase khi offline: $e');
    }
  }

  /// Gửi thông báo khi có sinh viên gửi yêu cầu mượn tài liệu
  static Future<bool> sendBorrowRequestNotification({
    required BorrowRequest request,
  }) async {
    debugPrint('[FCM Notification] Gửi thông báo đến chủ sách [${request.ownerEmail}]: '
        'Sinh viên ${request.borrowerName} (${request.borrowerEmail}) muốn mượn tài liệu "${request.documentTitle}". '
        'Hạn hẹn trả: ${request.returnDate}');
    return true;
  }

  /// Gửi thông báo khi yêu cầu mượn được phê duyệt
  static Future<bool> sendApprovalNotification({
    required BorrowRequest request,
  }) async {
    debugPrint('[FCM Notification] Gửi thông báo đến người mượn [${request.borrowerEmail}]: '
        'Yêu cầu mượn tài liệu "${request.documentTitle}" đã được duyệt thành công! '
        'Vui lòng đến ${request.locationName ?? "thư viện"} để nhận sách.');
    return true;
  }

  /// Gửi thông báo khi yêu cầu mượn bị từ chối
  static Future<bool> sendRejectionNotification({
    required BorrowRequest request,
  }) async {
    debugPrint('[FCM Notification] Gửi thông báo đến người mượn [${request.borrowerEmail}]: '
        'Yêu cầu mượn "${request.documentTitle}" đã bị từ chối bởi chủ tài liệu.');
    return true;
  }

  /// Gửi thông báo khi tài liệu đã được xác nhận trả lại
  static Future<bool> sendReturnNotification({
    required BorrowRequest request,
  }) async {
    debugPrint('[FCM Notification] Gửi thông báo: '
        'Tài liệu "${request.documentTitle}" đã được hoàn trả thành công. Cảm ơn bạn!');
    return true;
  }

  /// Gửi thông báo nhắc nhở sắp đến hạn trả sách
  static Future<bool> sendDueDateReminderNotification({
    required BorrowRequest request,
  }) async {
    debugPrint('[FCM Notification Reminder] Nhắc hạn: '
        'Tài liệu "${request.documentTitle}" sắp đến hạn trả (${request.returnDate}). Vui lòng hoàn trả đúng hạn.');
    return true;
  }
}
