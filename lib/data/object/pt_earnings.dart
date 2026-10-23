import 'package:ontrain/data/enum/earningsStatus.dart';

class PTEarnings {
  final String? id;
  final String ptId;
  final String bookingId;
  final String? paymentId;
  final int amountCents;
  final int platformCommissionPercent;
  final int platformCommissionFixedCents;
  final int platformCommissionCents;
  final int netAmountCents;
  final bool isReleased;
  final String? payoutId;
  final DateTime? createdAt;
  final DateTime? releasedAt;

  PTEarnings({
    this.id,
    required this.ptId,
    required this.bookingId,
    this.paymentId,
    required this.amountCents,
    required this.platformCommissionPercent,
    required this.platformCommissionFixedCents,
    required this.platformCommissionCents,
    required this.netAmountCents,
    this.isReleased = false,
    this.payoutId,
    this.createdAt,
    this.releasedAt,
  });

  /// UI-only status derived from the live schema columns.
  ///
  /// `pt_earnings` has no status column: an earning is pending until
  /// `is_released` is true, available until it is linked to a payout, and
  /// paid out once `payout_id` is set.
  EarningsStatus get status {
    if (!isReleased) return EarningsStatus.pending;
    return payoutId == null ? EarningsStatus.released : EarningsStatus.paidOut;
  }

  factory PTEarnings.fromMap(Map<String, dynamic> map) {
    return PTEarnings(
      id: map['id'] as String?,
      ptId: map['pt_id'] as String,
      bookingId: map['booking_id'] as String,
      paymentId: map['payment_id'] as String?,
      amountCents: map['gross_amount_cents'] as int? ?? 0,
      platformCommissionPercent:
          (map['platform_commission_percent'] as num?)?.toInt() ?? 0,
      platformCommissionFixedCents:
          map['platform_commission_fixed_cents'] as int? ?? 0,
      platformCommissionCents: map['platform_commission_cents'] as int? ?? 0,
      netAmountCents: map['net_amount_cents'] as int? ?? 0,
      isReleased: map['is_released'] as bool? ?? false,
      payoutId: map['payout_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      releasedAt: map['released_at'] != null
          ? DateTime.parse(map['released_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pt_id': ptId,
      'booking_id': bookingId,
      'payment_id': paymentId,
      'gross_amount_cents': amountCents,
      'platform_commission_percent': platformCommissionPercent,
      'platform_commission_fixed_cents': platformCommissionFixedCents,
      'platform_commission_cents': platformCommissionCents,
      'net_amount_cents': netAmountCents,
      'is_released': isReleased,
      'payout_id': payoutId,
      'created_at': createdAt?.toIso8601String(),
      'released_at': releasedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map.remove('released_at');
    return map;
  }

  PTEarnings copyWith({
    String? id,
    String? ptId,
    String? bookingId,
    String? paymentId,
    int? amountCents,
    int? platformCommissionPercent,
    int? platformCommissionFixedCents,
    int? platformCommissionCents,
    int? netAmountCents,
    bool? isReleased,
    String? payoutId,
    DateTime? createdAt,
    DateTime? releasedAt,
  }) {
    return PTEarnings(
      id: id ?? this.id,
      ptId: ptId ?? this.ptId,
      bookingId: bookingId ?? this.bookingId,
      paymentId: paymentId ?? this.paymentId,
      amountCents: amountCents ?? this.amountCents,
      platformCommissionPercent:
          platformCommissionPercent ?? this.platformCommissionPercent,
      platformCommissionFixedCents:
          platformCommissionFixedCents ?? this.platformCommissionFixedCents,
      platformCommissionCents:
          platformCommissionCents ?? this.platformCommissionCents,
      netAmountCents: netAmountCents ?? this.netAmountCents,
      isReleased: isReleased ?? this.isReleased,
      payoutId: payoutId ?? this.payoutId,
      createdAt: createdAt ?? this.createdAt,
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }

  @override
  String toString() {
    return 'PTEarnings(id: $id, ptId: $ptId, amountCents: $amountCents, status: ${status.dbValue})';
  }
}
