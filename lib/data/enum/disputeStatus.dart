enum DisputeStatus {
  open('open', 'Đang mở'),
  resolvedClient('resolved_client', 'Quyết định cho khách'),
  resolvedPt('resolved_pt', 'Quyết định cho PT'),
  resolvedSplit('resolved_split', 'Chia sẻ'),
  refunded('refunded', 'Đã hoàn tiền');

  final String dbValue;
  final String displayName;

  const DisputeStatus(this.dbValue, this.displayName);

  static DisputeStatus fromString(String value) {
    return DisputeStatus.values.firstWhere(
      (e) => e.dbValue == value.toLowerCase(),
      orElse: () => DisputeStatus.open,
    );
  }
}