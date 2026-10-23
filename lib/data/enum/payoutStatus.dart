enum PayoutStatus {
  pending('pending', 'Chờ xử lý'),
  processing('processing', 'Đang xử lý'),
  completed('completed', 'Hoàn tất'),
  failed('failed', 'Thất bại'),
  cancelled('cancelled', 'Đã hủy');

  final String dbValue;
  final String displayName;

  const PayoutStatus(this.dbValue, this.displayName);

  static PayoutStatus fromString(String value) {
    return PayoutStatus.values.firstWhere(
      (e) => e.dbValue == value.toLowerCase(),
      orElse: () => PayoutStatus.pending,
    );
  }
}
