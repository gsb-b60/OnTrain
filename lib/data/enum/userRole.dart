enum UserRole {
  client('client', 'Khách hàng'),
  pt('pt', 'PT'),
  admin('admin', 'Quản trị');

  final String dbValue;
  final String displayName;

  const UserRole(this.dbValue, this.displayName);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.dbValue == value.toLowerCase(),
      orElse: () => UserRole.client,
    );
  }
}