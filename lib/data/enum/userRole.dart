enum UserRole {
  client('client', 'Khách hàng'),
  pt('pt', 'PT');

  final String dbValue;
  final String displayName;

  const UserRole(this.dbValue, this.displayName);
}