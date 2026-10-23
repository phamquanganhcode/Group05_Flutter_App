class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final List<String> interests;
  final List<String> preferredSubjects;
  final String department;
  final String currentLocationName;
  final double? latitude;
  final double? longitude;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.interests = const ['#Flutter', '#MobileApp', '#Firebase', '#Supabase', '#CSDL'],
    this.preferredSubjects = const [
      'Phát triển ứng dụng di động (Flutter)',
      'Kiến trúc hệ thống phần mềm',
    ],
    this.department = 'Khoa Công nghệ Thông tin - 65KTPM',
    this.currentLocationName = 'Thư viện Trung tâm - Tầng 2',
    this.latitude = 21.028511,
    this.longitude = 105.854167,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    List<String> parsedInterests = [];
    if (map['interests'] != null && map['interests'] is List) {
      parsedInterests = (map['interests'] as List).map((e) => e.toString()).toList();
    } else {
      parsedInterests = ['#Flutter', '#MobileApp', '#Firebase', '#Supabase', '#CSDL'];
    }

    List<String> parsedSubjects = [];
    if (map['preferred_subjects'] != null && map['preferred_subjects'] is List) {
      parsedSubjects = (map['preferred_subjects'] as List).map((e) => e.toString()).toList();
    } else {
      parsedSubjects = ['Phát triển ứng dụng di động (Flutter)', 'Kiến trúc hệ thống phần mềm'];
    }

    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['display_name'] ?? map['displayName'] ?? 'Sinh viên KTPM',
      avatarUrl: map['avatar_url'] ?? map['avatarUrl'],
      interests: parsedInterests,
      preferredSubjects: parsedSubjects,
      department: map['department'] ?? 'Khoa Công nghệ Thông tin - 65KTPM',
      currentLocationName: map['current_location_name'] ?? 'Thư viện Trung tâm - Tầng 2',
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : 21.028511,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : 105.854167,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'interests': interests,
      'preferred_subjects': preferredSubjects,
      'department': department,
      'current_location_name': currentLocationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    List<String>? interests,
    List<String>? preferredSubjects,
    String? department,
    String? currentLocationName,
    double? latitude,
    double? longitude,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      interests: interests ?? this.interests,
      preferredSubjects: preferredSubjects ?? this.preferredSubjects,
      department: department ?? this.department,
      currentLocationName: currentLocationName ?? this.currentLocationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
