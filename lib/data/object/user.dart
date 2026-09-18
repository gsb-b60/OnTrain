import 'package:ontrain/data/enum/userRole.dart';

class UserData {
  final String? id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final UserRole role;
  final String timezone;
  final String locale;
  final bool isVerified;
  final String? verificationDocumentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;
  final DateTime? deletedAt;

  UserData({
    this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phone,
    this.dateOfBirth,
    this.gender,
    required this.role,
    this.timezone = 'UTC',
    this.locale = 'en',
    this.isVerified = false,
    this.verificationDocumentUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
    this.deletedAt,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] as String?,
      email: map['email'] as String,
      fullName: map['full_name'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'] as String)
          : null,
      gender: map['gender'] as String?,
      role: UserRole.fromString(map['role'] as String? ?? 'client'),
      timezone: map['timezone'] as String? ?? 'UTC',
      locale: map['locale'] as String? ?? 'en',
      isVerified: map['is_verified'] as bool? ?? false,
      verificationDocumentUrl: map['verification_document_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastActiveAt: map['last_active_at'] != null
          ? DateTime.parse(map['last_active_at'] as String)
          : null,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'role': role.dbValue,
      'timezone': timezone,
      'locale': locale,
      'is_verified': isVerified,
      'verification_document_url': verificationDocumentUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map.remove('updated_at');
    map.remove('last_active_at');
    map.remove('deleted_at');
    return map;
  }

  UserData copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    UserRole? role,
    String? timezone,
    String? locale,
    bool? isVerified,
    String? verificationDocumentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    DateTime? deletedAt,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      isVerified: isVerified ?? this.isVerified,
      verificationDocumentUrl: verificationDocumentUrl ?? this.verificationDocumentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() {
    return 'UserData('
        'id: $id, '
        'email: $email, '
        'fullName: $fullName, '
        'role: ${role.dbValue}, '
        'isVerified: $isVerified, '
        'deletedAt: $deletedAt'
        ')';
  }

  // Backward compatibility getter for existing UI code
  String get name => fullName;
}