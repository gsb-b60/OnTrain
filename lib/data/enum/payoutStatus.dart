enum PayoutStatus {
  requested('requested', 'Đã yêu cầu'),
  processing('processing', 'Đang xử lý'),
  completed('completed', 'Hoàn tất'),
  failed('failed', 'Thất bại');

  final String dbValue;
  final String displayName;

  const PayoutStatus(this.dbValue, this.displayName);

  static PayoutStatus fromString(String value) {
    return PayoutStatus.values.firstWhere(
      (e) => e.dbValue == value.toLowerCase(),
      orElse: () => PayoutStatus.requested,
    );
  }
}