import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/object/user.dart';
import 'package:ontrain/data/enum/bookingStatus.dart';

class Booking {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime startAt;
  final DateTime endAt;
  final String timezone;
  final String clientId;
  final String ptId;
  final String? servicePackageId;
  final BookingStatus status;
  final String? paymentId;
  final String? paymentStatus;
  final int priceCents;
  final String currency;
  final double platformCommissionPercent;
  final int platformCommissionFixedCents;
  final int ptEarningsCents;
  final String? clientNotes;
  final String? ptNotes;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;
  final int? cancellationFeeCents;
  final String? meetingLink;
  final String? locationDetails;
  final DateTime? completedAt;
  final DateTime? actualStartAt;
  final DateTime? actualEndAt;
  final String? disputeId;
  final PT? pt;
  final UserData? client;

  Booking({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.startAt,
    required this.endAt,
    this.timezone = 'UTC',
    required this.clientId,
    required this.ptId,
    this.servicePackageId,
    this.status = BookingStatus.pending,
    this.paymentId,
    this.paymentStatus,
    required this.priceCents,
    this.currency = 'VND',
    required this.platformCommissionPercent,
    required this.platformCommissionFixedCents,
    required this.ptEarningsCents,
    this.clientNotes,
    this.ptNotes,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.cancellationFeeCents,
    this.meetingLink,
    this.locationDetails,
    this.completedAt,
    this.actualStartAt,
    this.actualEndAt,
    this.disputeId,
    this.pt,
    this.client,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      startAt: DateTime.parse(map['start_at'] as String),
      endAt: DateTime.parse(map['end_at'] as String),
      timezone: map['timezone'] as String? ?? 'UTC',
      clientId: map['client_id'] as String,
      ptId: map['pt_id'] as String,
      servicePackageId: map['service_package_id'] as String?,
      status: BookingStatus.fromString(map['status'] as String? ?? 'pending'),
      paymentId: map['payment_id'] as String?,
      paymentStatus: map['payment_status'] as String?,
      priceCents: map['price_cents'] as int? ?? 0,
      currency: map['currency'] as String? ?? 'VND',
      platformCommissionPercent:
          (map['platform_commission_percent'] as num?)?.toDouble() ?? 0.0,
      platformCommissionFixedCents:
          map['platform_commission_fixed_cents'] as int? ?? 0,
      ptEarningsCents: map['pt_earnings_cents'] as int? ?? 0,
      clientNotes: map['client_notes'] as String?,
      ptNotes: map['pt_notes'] as String?,
      cancelledAt: map['cancelled_at'] != null
          ? DateTime.parse(map['cancelled_at'] as String)
          : null,
      cancelledBy: map['cancelled_by'] as String?,
      cancellationReason: map['cancellation_reason'] as String?,
      cancellationFeeCents: map['cancellation_fee_cents'] as int?,
      meetingLink: map['meeting_link'] as String?,
      locationDetails: map['location_details'] as String?,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      actualStartAt: map['actual_start_at'] != null
          ? DateTime.parse(map['actual_start_at'] as String)
          : null,
      actualEndAt: map['actual_end_at'] != null
          ? DateTime.parse(map['actual_end_at'] as String)
          : null,
      disputeId: map['dispute_id'] as String?,
      pt: map['PT'] != null
          ? PT.fromMap(map['PT'])
          : (map['pt_profiles'] != null
              ? PT.fromMap(map['pt_profiles'])
              : null),
      client: map['client'] != null
          ? UserData.fromMap(map['client'])
          : (map['profiles'] != null
              ? UserData.fromMap(map['profiles'])
              : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'timezone': timezone,
      'client_id': clientId,
      'pt_id': ptId,
      'service_package_id': servicePackageId,
      'status': status.dbValue,
      'payment_id': paymentId,
      'payment_status': paymentStatus,
      'price_cents': priceCents,
      'currency': currency,
      'platform_commission_percent': platformCommissionPercent,
      'platform_commission_fixed_cents': platformCommissionFixedCents,
      'pt_earnings_cents': ptEarningsCents,
      'client_notes': clientNotes,
      'pt_notes': ptNotes,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancelled_by': cancelledBy,
      'cancellation_reason': cancellationReason,
      'cancellation_fee_cents': cancellationFeeCents,
      'meeting_link': meetingLink,
      'location_details': locationDetails,
      'completed_at': completedAt?.toIso8601String(),
      'actual_start_at': actualStartAt?.toIso8601String(),
      'actual_end_at': actualEndAt?.toIso8601String(),
      'dispute_id': disputeId,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map.remove('updated_at');
    map.remove('payment_id');
    map.remove('payment_status');
    map.remove('cancelled_at');
    map.remove('cancelled_by');
    map.remove('cancellation_reason');
    map.remove('cancellation_fee_cents');
    map.remove('completed_at');
    map.remove('actual_start_at');
    map.remove('actual_end_at');
    map.remove('dispute_id');
    return map;
  }

  Booking copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startAt,
    DateTime? endAt,
    String? timezone,
    String? clientId,
    String? ptId,
    String? servicePackageId,
    BookingStatus? status,
    String? paymentId,
    String? paymentStatus,
    int? priceCents,
    String? currency,
    double? platformCommissionPercent,
    int? platformCommissionFixedCents,
    int? ptEarningsCents,
    String? clientNotes,
    String? ptNotes,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancellationReason,
    int? cancellationFeeCents,
    String? meetingLink,
    String? locationDetails,
    DateTime? completedAt,
    DateTime? actualStartAt,
    DateTime? actualEndAt,
    String? disputeId,
    PT? pt,
    UserData? client,
  }) {
    return Booking(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      timezone: timezone ?? this.timezone,
      clientId: clientId ?? this.clientId,
      ptId: ptId ?? this.ptId,
      servicePackageId: servicePackageId ?? this.servicePackageId,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      priceCents: priceCents ?? this.priceCents,
      currency: currency ?? this.currency,
      platformCommissionPercent: platformCommissionPercent ?? this.platformCommissionPercent,
      platformCommissionFixedCents: platformCommissionFixedCents ?? this.platformCommissionFixedCents,
      ptEarningsCents: ptEarningsCents ?? this.ptEarningsCents,
      clientNotes: clientNotes ?? this.clientNotes,
      ptNotes: ptNotes ?? this.ptNotes,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationFeeCents: cancellationFeeCents ?? this.cancellationFeeCents,
      meetingLink: meetingLink ?? this.meetingLink,
      locationDetails: locationDetails ?? this.locationDetails,
      completedAt: completedAt ?? this.completedAt,
      actualStartAt: actualStartAt ?? this.actualStartAt,
      actualEndAt: actualEndAt ?? this.actualEndAt,
      disputeId: disputeId ?? this.disputeId,
      pt: pt ?? this.pt,
      client: client ?? this.client,
    );
  }

  @override
  String toString() {
    return 'Booking('
        'id: $id, '
        'startAt: $startAt, '
        'endAt: $endAt, '
        'clientId: $clientId, '
        'ptId: $ptId, '
        'status: ${status.dbValue}, '
        'priceCents: $priceCents'
        ')';
  }

  // Backward compatibility getters for existing UI code
  DateTime? get startTime => startAt;
  DateTime? get endTime => endAt;
  String? get notes => clientNotes;
}