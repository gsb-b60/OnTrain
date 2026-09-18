enum SessionState {
  booked('booked', 'Đã đặt'),
  completed('completed', 'Hoàn thành'),
  canceled('canceled', 'Đã hủy');

  final String dbValue;
  final String displayName;

  const SessionState(this.dbValue, this.displayName);

  static SessionState fromString(String value) {
    return SessionState.values.firstWhere(
      (e) => e.dbValue == value.toLowerCase(),
      orElse: () => SessionState.booked,
    );
  }
}