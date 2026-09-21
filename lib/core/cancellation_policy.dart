class CancellationPolicy {
  final int freeUntilHoursBefore;
  final int lateFeePercent;
  final int noShowFeePercent;

  const CancellationPolicy({
    required this.freeUntilHoursBefore,
    required this.lateFeePercent,
    required this.noShowFeePercent,
  });

  factory CancellationPolicy.fromSettings(Map<String, dynamic> settings) {
    final policy = settings['cancellation_policy'] as Map<String, dynamic>?;
    return CancellationPolicy(
      freeUntilHoursBefore: policy?['free_until_hours_before'] as int? ?? 24,
      lateFeePercent: policy?['late_fee_percent'] as int? ?? 50,
      noShowFeePercent: policy?['no_show_fee_percent'] as int? ?? 100,
    );
  }

  /// Returns (feeCents, reasonCode)
  (int, String) calculateFee({
    required int priceCents,
    required DateTime sessionStart,
    required DateTime cancelledAt,
    required String cancelledBy, // 'client' | 'pt' | 'admin'
    bool isNoShow = false,
  }) {
    if (cancelledBy == 'admin') {
      return (0, 'admin_cancel');
    }
    if (isNoShow) {
      return (
        (priceCents * noShowFeePercent / 100).round(),
        'no_show',
      );
    }
    final hoursBefore = sessionStart.difference(cancelledAt).inHours;
    if (hoursBefore >= freeUntilHoursBefore) {
      return (0, 'free_cancel');
    }
    return (
      (priceCents * lateFeePercent / 100).round(),
      'late_cancel',
    );
  }
}