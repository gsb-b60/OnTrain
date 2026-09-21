import 'package:ontrain/data/enum/disputeStatus.dart';

class Dispute {
  final String? id;
  final String bookingId;
  final String raisedBy; // client_id or pt_id
  final String againstUserId; // the other party
  final String reason;
  final DisputeStatus status;
  final String? resolutionNotes;
  final String? resolvedBy; // admin_id
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  Dispute({
    this.id,
    required this.bookingId,
    required this.raisedBy,
    required this.againstUserId,
    required this.reason,
    this.status = DisputeStatus.open,
    this.resolutionNotes,
    this.resolvedBy,
    this.createdAt,
    this.resolvedAt,
  });

  factory Dispute.fromMap(Map<String, dynamic> map) {
    return Dispute(
      id: map['id'] as String?,
      bookingId: map['booking_id'] as String,
      raisedBy: map['raised_by'] as String,
      againstUserId: map['against_user_id'] as String,
      reason: map['reason'] as String,
      status: DisputeStatus.fromString(map['status'] as String? ?? 'open'),
      resolutionNotes: map['resolution_notes'] as String?,
      resolvedBy: map['resolved_by'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      resolvedAt: map['resolved_at'] != null
          ? DateTime.parse(map['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'raised_by': raisedBy,
      'against_user_id': againstUserId,
      'reason': reason,
      'status': status.dbValue,
      'resolution_notes': resolutionNotes,
      'resolved_by': resolvedBy,
      'created_at': createdAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map.remove('resolved_at');
    return map;
  }

  Dispute copyWith({
    String? id,
    String? bookingId,
    String? raisedBy,
    String? againstUserId,
    String? reason,
    DisputeStatus? status,
    String? resolutionNotes,
    String? resolvedBy,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return Dispute(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      raisedBy: raisedBy ?? this.raisedBy,
      againstUserId: againstUserId ?? this.againstUserId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  String toString() {
    return 'Dispute(id: $id, bookingId: $bookingId, status: ${status.dbValue})';
  }
}