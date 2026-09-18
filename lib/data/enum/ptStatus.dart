enum PTStatus {
  draft('draft', 'Nháp'),
  pendingReview('pending_review', 'Chờ duyệt'),
  active('active', 'Đang hoạt động'),
  suspended('suspended', 'Tạm khóa'),
  rejected('rejected', 'Từ chối');

  final String dbValue;
  final String displayName;

  const PTStatus(this.dbValue, this.displayName);

  static PTStatus fromString(String value) {
    return PTStatus.values.firstWhere(
      (e) => e.dbValue == value.toLowerCase(),
      orElse: () => PTStatus.draft,
    );
  }
}