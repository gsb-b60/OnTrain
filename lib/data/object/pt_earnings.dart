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
  final EarningsStatus status;
  final DateTime? createdAt;
  final DateTime? releasedAt;
  final DateTime? paidOutAt;

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
    this.status = EarningsStatus.pending,
    this.createdAt,
    this.releasedAt,
    this.paidOutAt,
  });

  factory PTEarnings.fromMap(Map<String, dynamic> map) {
    return PTEarnings(
      id: map['id'] as String?,
      ptId: map['pt_id'] as String,
      bookingId: map['booking_id'] as String,
      paymentId: map['payment_id'] as String?,
      amountCents: map['gross_amount_cents'] as int,
      platformCommissionPercent:
          (map['platform_commission_percent'] as num?)?.toInt() ?? 0,
      platformCommissionFixedCents:
          map['platform_commission_fixed_cents'] as int? ?? 0,
      platformCommissionCents:
          map['platform_commission_cents'] as int? ?? 0,
      netAmountCents: map['net_amount_cents'] as int? ?? 0,
      status: EarningsStatus.fromString(map['status'] as String? ?? 'pending'),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      releasedAt: map['released_at'] != null
          ? DateTime.parse(map['released_at'] as String)
          : null,
      paidOutAt: map['paid_out_at'] != null
          ? DateTime.parse(map['paid_out_at'] as String)
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
      'status': status.dbValue,
      'created_at': createdAt?.toIso8601String(),
      'released_at': releasedAt?.toIso8601String(),
      'paid_out_at': paidOutAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map.remove('released_at');
    map.remove('paid_out_at');
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
    EarningsStatus? status,
    DateTime? createdAt,
    DateTime? releasedAt,
    DateTime? paidOutAt,
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
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      releasedAt: releasedAt ?? this.releasedAt,
      paidOutAt: paidOutAt ?? this.paidOutAt,
    );
  }

  @override
  String toString() {
    return 'PTEarnings(id: $id, ptId: $ptId, amountCents: $amountCents, status: ${status.dbValue})';
  }
}