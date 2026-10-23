import 'dart:convert';

class MaterialMeta {
  final String subject;
  final String? deadline;
  final String notes;
  final bool isCompleted;
  final bool isFavorite;
  final List<String> tags;
  final String? locationName;
  final String? shelfCode;
  final double? latitude;
  final double? longitude;
  final bool isPhysical;
  final bool isAvailableForBorrow;
  final String borrowStatus; // 'AVAILABLE', 'REQUESTED', 'BORROWED', 'RETURNED'
  final String? borrowerEmail;
  final String? borrowerName;
  final String? borrowDueDate;
  final String? ownerEmail;
  final String? ownerName;
  final String? ownerId;
  final int viewCount;

  MaterialMeta({
    this.subject = 'Phát triển ứng dụng di động (Flutter)',
    this.deadline,
    this.notes = '',
    this.isCompleted = false,
    this.isFavorite = false,
    this.tags = const [],
    this.locationName,
    this.shelfCode,
    this.latitude,
    this.longitude,
    this.isPhysical = false,
    this.isAvailableForBorrow = true,
    this.borrowStatus = 'AVAILABLE',
    this.borrowerEmail,
    this.borrowerName,
    this.borrowDueDate,
    this.ownerEmail,
    this.ownerName,
    this.ownerId,
    this.viewCount = 0,
  });

  factory MaterialMeta.fromRaw(String? raw) {
    if (raw == null || raw.trim().isEmpty) return MaterialMeta();
    try {
      if (raw.trim().startsWith('{') && raw.trim().endsWith('}')) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        List<String> parsedTags = [];
        if (map['tags'] != null && map['tags'] is List) {
          parsedTags = (map['tags'] as List).map((e) => e.toString()).toList();
        }

        return MaterialMeta(
          subject: map['subject'] ?? 'Phát triển ứng dụng di động (Flutter)',
          deadline: map['deadline'],
          notes: map['notes'] ?? '',
          isCompleted: map['isCompleted'] ?? false,
          isFavorite: map['isFavorite'] ?? false,
          tags: parsedTags,
          locationName: map['locationName'],
          shelfCode: map['shelfCode'],
          latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
          longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
          isPhysical: map['isPhysical'] ?? false,
          isAvailableForBorrow: map['isAvailableForBorrow'] ?? true,
          borrowStatus: map['borrowStatus'] ?? 'AVAILABLE',
          borrowerEmail: map['borrowerEmail'],
          borrowerName: map['borrowerName'],
          borrowDueDate: map['borrowDueDate'],
          ownerEmail: map['ownerEmail'],
          ownerName: map['ownerName'],
          ownerId: map['ownerId'],
          viewCount: map['viewCount'] ?? 0,
        );
      }
    } catch (_) {}
    return MaterialMeta(notes: raw);
  }

  String toRaw() {
    return jsonEncode({
      'subject': subject,
      'deadline': deadline,
      'notes': notes,
      'isCompleted': isCompleted,
      'isFavorite': isFavorite,
      'tags': tags,
      'locationName': locationName,
      'shelfCode': shelfCode,
      'latitude': latitude,
      'longitude': longitude,
      'isPhysical': isPhysical,
      'isAvailableForBorrow': isAvailableForBorrow,
      'borrowStatus': borrowStatus,
      'borrowerEmail': borrowerEmail,
      'borrowerName': borrowerName,
      'borrowDueDate': borrowDueDate,
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
      'ownerId': ownerId,
      'viewCount': viewCount,
    });
  }

  MaterialMeta copyWith({
    String? subject,
    String? deadline,
    String? notes,
    bool? isCompleted,
    bool? isFavorite,
    List<String>? tags,
    String? locationName,
    String? shelfCode,
    double? latitude,
    double? longitude,
    bool? isPhysical,
    bool? isAvailableForBorrow,
    String? borrowStatus,
    String? borrowerEmail,
    String? borrowerName,
    String? borrowDueDate,
    String? ownerEmail,
    String? ownerName,
    String? ownerId,
    int? viewCount,
  }) {
    return MaterialMeta(
      subject: subject ?? this.subject,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      locationName: locationName ?? this.locationName,
      shelfCode: shelfCode ?? this.shelfCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPhysical: isPhysical ?? this.isPhysical,
      isAvailableForBorrow: isAvailableForBorrow ?? this.isAvailableForBorrow,
      borrowStatus: borrowStatus ?? this.borrowStatus,
      borrowerEmail: borrowerEmail ?? this.borrowerEmail,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowDueDate: borrowDueDate ?? this.borrowDueDate,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerName: ownerName ?? this.ownerName,
      ownerId: ownerId ?? this.ownerId,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
