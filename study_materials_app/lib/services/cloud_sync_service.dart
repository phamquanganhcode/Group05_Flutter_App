import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../struct/borrow_request.dart';

class CloudSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _materialsCollection =
      _firestore.collection('study_materials');
  static final CollectionReference _borrowCollection =
      _firestore.collection('borrow_requests');

  /// Đồng bộ một tài liệu lên Cloud Firestore
  static Future<bool> syncMaterialToCloud({
    required String title,
    required String type,
    required String? description,
    required String? url,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'tester_2351170573';
    final userEmail = user?.email ?? 'quanganh.2351170573@test.edu.vn';
    final userName = user?.displayName ?? 'Phạm Quang Anh (MSSV: 2351170573)';

    try {
      await _materialsCollection.add({
        'title': title,
        'type': type,
        'description': description,
        'url': url,
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('[CloudSyncService] Firebase error: $e');
      return false;
    }
  }

  /// Lắng nghe Stream danh sách tài liệu từ Cloud
  static Stream<QuerySnapshot> streamUserMaterials() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _materialsCollection
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  /// Đồng bộ yêu cầu mượn lên Firestore
  static Future<bool> syncBorrowRequestToCloud(BorrowRequest request) async {
    try {
      await _borrowCollection.doc(request.id).set({
        ...request.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('[CloudSyncService] Lỗi đồng bộ yêu cầu mượn: $e');
      return false;
    }
  }

  /// Cập nhật trạng thái yêu cầu mượn trên Firestore
  static Future<bool> updateBorrowStatusOnCloud(String requestId, String status) async {
    try {
      await _borrowCollection.doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('[CloudSyncService] Lỗi cập nhật status Firestore: $e');
      return false;
    }
  }
}
