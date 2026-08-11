import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/object/user.dart';

class Booking {
  final String? id;
  final DateTime? createdAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? clientId;
  final String? ptId;
  final String? notes;
  final PT? pt; 
  final UserData? client;
  Booking({
    this.id,
    this.createdAt,
    this.startTime,
    this.endTime,
    this.clientId,
    this.ptId,
    this.notes,
    this.pt,
    this.client,
  });

  /// FROM MAP (Supabase / JSON → Dart)
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      startTime: map['start_time'] != null
          ? DateTime.parse(map['start_time'])
          : null,
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'])
          : null,
      clientId: map['client_id'] as String?,
      ptId: map['pt_id'] as String?,
      notes: map['notes'] as String?,
      pt: map['PT'] != null
          ? PT.fromMap(map['PT'])
          : null,

      client: map['client'] != null
          ? UserData.fromMap(map['client'])
          : null,
    );
  }

  /// TO MAP (Dart → Supabase insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'client_id': clientId,
      'pt_id': ptId,
      'notes': notes,
    };
  }

  Map<String, dynamic> toInsertMap() {
  return {
    'start_time': startTime?.toIso8601String(),
    'end_time': endTime?.toIso8601String(),
    'client_id': clientId,
    'pt_id': ptId,
    'notes': notes,
  };
}

  /// TO STRING (debug / logging)
  @override
  String toString() {
    return 'Booking('
        'id: $id, '
        'createdAt: $createdAt, '
        'startTime: $startTime, '
        'endTime: $endTime, '
        'clientId: $clientId, '
        'ptId: $ptId, '
        'notes: $notes, '
        'pt: $pt, '
        'client: $client'
        ')';
  }
}