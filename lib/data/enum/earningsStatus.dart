enum EarningsStatus {
  pending('pending', 'Chờ giải ngân'),
  released('released', 'Đã giải ngân'),
  paidOut('paid_out', 'Đã trả');

  final String dbValue;
  final String displayName;

  const EarningsStatus(this.dbValue, this.displayName);

  static EarningsStatus fromString(String value) {
    return EarningsStatus.values.firstWhere(
      (e) => e.dbValue == value.toLowerCase(),
      orElse: () => EarningsStatus.pending,
    );
  }
}