enum UserRole {
  client('Client', 'Khách hàng'),
  pt('PT', 'PT');

  final String dbValue;
  final String displayName;

  const UserRole(this.dbValue, this.displayName);


   static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) =>
          e.dbValue.toLowerCase() == value.toLowerCase(), 
      orElse: () => UserRole.client,
    );
  }
}