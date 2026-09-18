import 'package:ontrain/data/enum/payoutStatus.dart';

class Payout {
  final String? id;
  final String ptId;
  final int amountCents;
  final PayoutStatus status;
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String bankAccountName;
  final String bankAccountNumber;
  final String bankName;
  final String? bankBranch;
  final String? failureReason;

  Payout({
    this.id,
    required this.ptId,
    required this.amountCents,
    this.status = PayoutStatus.requested,
    this.requestedAt,
    this.processedAt,
    required this.bankAccountName,
    required this.bankAccountNumber,
    required this.bankName,
    this.bankBranch,
    this.failureReason,
  });

  factory Payout.fromMap(Map<String, dynamic> map) {
    return Payout(
      id: map['id'] as String?,
      ptId: map['pt_id'] as String,
      amountCents: map['amount_cents'] as int,
      status: PayoutStatus.fromString(map['status'] as String? ?? 'requested'),
      requestedAt: map['requested_at'] != null
          ? DateTime.parse(map['requested_at'] as String)
          : null,
      processedAt: map['processed_at'] != null
          ? DateTime.parse(map['processed_at'] as String)
          : null,
      bankAccountName: map['bank_account_name'] as String,
      bankAccountNumber: map['bank_account_number'] as String,
      bankName: map['bank_name'] as String,
      bankBranch: map['bank_branch'] as String?,
      failureReason: map['failure_reason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pt_id': ptId,
      'amount_cents': amountCents,
      'status': status.dbValue,
      'requested_at': requestedAt?.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'bank_account_name': bankAccountName,
      'bank_account_number': bankAccountNumber,
      'bank_name': bankName,
      'bank_branch': bankBranch,
      'failure_reason': failureReason,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('requested_at');
    map.remove('processed_at');
    return map;
  }

  Payout copyWith({
    String? id,
    String? ptId,
    int? amountCents,
    PayoutStatus? status,
    DateTime? requestedAt,
    DateTime? processedAt,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankName,
    String? bankBranch,
    String? failureReason,
  }) {
    return Payout(
      id: id ?? this.id,
      ptId: ptId ?? this.ptId,
      amountCents: amountCents ?? this.amountCents,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      bankBranch: bankBranch ?? this.bankBranch,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  @override
  String toString() {
    return 'Payout(id: $id, ptId: $ptId, amountCents: $amountCents, status: ${status.dbValue})';
  }
}