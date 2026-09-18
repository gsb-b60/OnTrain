enum BookingStatus {
  pending('pending', 'Chờ xác nhận'),
  confirmed('confirmed', 'Đã xác nhận'),
  inProgress('in_progress', 'Đang diễn ra'),
  completed('completed', 'Hoàn thành'),
  cancelledByClient('cancelled_by_client', 'Khách hủy'),
  cancelledByPt('cancelled_by_pt', 'PT hủy'),
  noShowClient('no_show_client', 'Khách không đến'),
  noShowPt('no_show_pt', 'PT không đến'),
  refunded('refunded', 'Đã hoàn tiền'),
  disputed('disputed', 'Tranh chấp'),
  expired('expired', 'Hết hạn');

  final String dbValue;
  final String displayName;

  const BookingStatus(this.dbValue, this.displayName);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.dbValue == value.toLowerCase(),
      orElse: () => BookingStatus.pending,
    );
  }
}