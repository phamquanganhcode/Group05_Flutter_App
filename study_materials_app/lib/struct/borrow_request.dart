class BorrowRequest {
  final String id;
  final String documentId;
  final String documentTitle;
  final String borrowerId;
  final String borrowerEmail;
  final String borrowerName;
  final String ownerId;
  final String ownerEmail;
  final String requestDate;
  final String returnDate;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED', 'RETURNED'
  final String notes;
  final String? locationName;
  final String? shelfCode;
  final DateTime createdAt;

  BorrowRequest({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.borrowerId,
    required this.borrowerEmail,
    required this.borrowerName,
    required this.ownerId,
    required this.ownerEmail,
    required this.requestDate,
    required this.returnDate,
    this.status = 'PENDING',
    this.notes = '',
    this.locationName,
    this.shelfCode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BorrowRequest.fromMap(Map<String, dynamic> map) {
    return BorrowRequest(
      id: map['id']?.toString() ?? '',
      documentId: map['document_id']?.toString() ?? map['documentId']?.toString() ?? '',
      documentTitle: map['document_title'] ?? map['documentTitle'] ?? '',
      borrowerId: map['borrower_id'] ?? map['borrowerId'] ?? '',
      borrowerEmail: map['borrower_email'] ?? map['borrowerEmail'] ?? '',
      borrowerName: map['borrower_name'] ?? map['borrowerName'] ?? 'Sinh viên',
      ownerId: map['owner_id'] ?? map['ownerId'] ?? '',
      ownerEmail: map['owner_email'] ?? map['ownerEmail'] ?? '',
      requestDate: map['request_date'] ?? map['requestDate'] ?? '',
      returnDate: map['return_date'] ?? map['returnDate'] ?? '',
      status: map['status'] ?? 'PENDING',
      notes: map['notes'] ?? '',
      locationName: map['location_name'] ?? map['locationName'],
      shelfCode: map['shelf_code'] ?? map['shelfCode'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'document_title': documentTitle,
      'borrower_id': borrowerId,
      'borrower_email': borrowerEmail,
      'borrower_name': borrowerName,
      'owner_id': ownerId,
      'owner_email': ownerEmail,
      'request_date': requestDate,
      'return_date': returnDate,
      'status': status,
      'notes': notes,
      'location_name': locationName,
      'shelf_code': shelfCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BorrowRequest copyWith({
    String? id,
    String? documentId,
    String? documentTitle,
    String? borrowerId,
    String? borrowerEmail,
    String? borrowerName,
    String? ownerId,
    String? ownerEmail,
    String? requestDate,
    String? returnDate,
    String? status,
    String? notes,
    String? locationName,
    String? shelfCode,
    DateTime? createdAt,
  }) {
    return BorrowRequest(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      borrowerId: borrowerId ?? this.borrowerId,
      borrowerEmail: borrowerEmail ?? this.borrowerEmail,
      borrowerName: borrowerName ?? this.borrowerName,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      requestDate: requestDate ?? this.requestDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      locationName: locationName ?? this.locationName,
      shelfCode: shelfCode ?? this.shelfCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
