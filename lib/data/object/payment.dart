import 'package:ontrain/data/enum/paymentStatus.dart';

class Payment {
  final String? id;
  final String bookingId;
  final String clientId;
  final int amountCents;
  final int platformCommissionCents;
  final int ptAmountCents;
  final String paymentMethod;
  final PaymentStatus status;
  final String? externalPaymentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? releasedAt;
  final DateTime? refundedAt;

  Payment({
    this.id,
    required this.bookingId,
    required this.clientId,
    required this.amountCents,
    required this.platformCommissionCents,
    required this.ptAmountCents,
    required this.paymentMethod,
    this.status = PaymentStatus.pending,
    this.externalPaymentId,
    this.createdAt,
    this.updatedAt,
    this.releasedAt,
    this.refundedAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String?,
      bookingId: map['booking_id'] as String,
      clientId: map['client_id'] as String,
      amountCents: map['amount_cents'] as int,
      platformCommissionCents: map['platform_commission_cents'] as int,
      ptAmountCents: map['pt_amount_cents'] as int,
      paymentMethod: map['payment_method'] as String? ?? 'stripe',
      status: PaymentStatus.fromString(map['status'] as String? ?? 'pending'),
      externalPaymentId: map['external_payment_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      releasedAt: map['released_at'] != null
          ? DateTime.parse(map['released_at'] as String)
          : null,
      refundedAt: map['refunded_at'] != null
          ? DateTime.parse(map['refunded_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'client_id': clientId,
      'amount_cents': amountCents,
      'platform_commission_cents': platformCommissionCents,
      'pt_amount_cents': ptAmountCents,
      'payment_method': paymentMethod,
      'status': status.dbValue,
      'external_payment_id': externalPaymentId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'released_at': releasedAt?.toIso8601String(),
      'refunded_at': refundedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map.remove('updated_at');
    map.remove('released_at');
    map.remove('refunded_at');
    return map;
  }

  Payment copyWith({
    String? id,
    String? bookingId,
    String? clientId,
    int? amountCents,
    int? platformCommissionCents,
    int? ptAmountCents,
    String? paymentMethod,
    PaymentStatus? status,
    String? externalPaymentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? releasedAt,
    DateTime? refundedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      clientId: clientId ?? this.clientId,
      amountCents: amountCents ?? this.amountCents,
      platformCommissionCents: platformCommissionCents ?? this.platformCommissionCents,
      ptAmountCents: ptAmountCents ?? this.ptAmountCents,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      externalPaymentId: externalPaymentId ?? this.externalPaymentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      releasedAt: releasedAt ?? this.releasedAt,
      refundedAt: refundedAt ?? this.refundedAt,
    );
  }

  @override
  String toString() {
    return 'Payment(id: $id, bookingId: $bookingId, amountCents: $amountCents, status: ${status.dbValue})';
  }
}