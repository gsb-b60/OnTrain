enum CancelReason {
  rescheduling('rescheduling', 'Đổi lịch'),
  unexpectedWork('unexpected_work', 'Việc đột xuất'),
  weather('weather', 'Thời tiết xấu'),
  others('others', 'Lý do khác');

  final String dbValue;
  final String displayName;

  const CancelReason(this.dbValue, this.displayName);

  static CancelReason fromString(String value) {
    return CancelReason.values.firstWhere(
      (e) => e.dbValue == value.toLowerCase(),
      orElse: () => CancelReason.others,
    );
  }
}