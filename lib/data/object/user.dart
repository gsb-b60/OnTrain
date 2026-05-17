import 'package:ontrain/data/enum/userRole.dart';

class UserData {
  final String? id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  UserData({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });


   factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] as String?,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.fromString(map['role']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  /// 🔥 TO MAP (App → Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.dbValue, // enum → string
      'created_at': createdAt.toIso8601String(),
    };
  }
}