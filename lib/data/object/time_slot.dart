import 'package:ontrain/data/object/service_package.dart';
import 'package:ontrain/data/object/pt.dart';

class TimeSlot {
  final String id;
  final String ptId;
  final String servicePackageId;
  final DateTime startAt;
  final DateTime endAt;
  final String timezone;
  final bool isAvailable;
  final bool isBooked;
  final String? bookingId;
  final ServicePackage? servicePackage;
  final PT? pt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TimeSlot({
    required this.id,
    required this.ptId,
    required this.servicePackageId,
    required this.startAt,
    required this.endAt,
    required this.timezone,
    required this.isAvailable,
    required this.isBooked,
    this.bookingId,
    this.servicePackage,
    this.pt,
    this.createdAt,
    this.updatedAt,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'] as String,
      ptId: map['pt_id'] as String,
      servicePackageId: map['service_package_id'] as String,
      startAt: DateTime.parse(map['start_at'] as String),
      endAt: DateTime.parse(map['end_at'] as String),
      timezone: map['timezone'] as String? ?? 'UTC',
      isAvailable: map['is_available'] as bool? ?? true,
      isBooked: map['is_booked'] as bool? ?? false,
      bookingId: map['booking_id'] as String?,
      servicePackage: map['service_packages'] != null
          ? ServicePackage.fromMap(map['service_packages'])
          : null,
      pt: map['pt_profiles'] != null
          ? PT.fromMap(map['pt_profiles'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pt_id': ptId,
      'service_package_id': servicePackageId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'timezone': timezone,
      'is_available': isAvailable,
      'is_booked': isBooked,
      'booking_id': bookingId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map.remove('updated_at');
    return map;
  }

  TimeSlot copyWith({
    String? id,
    String? ptId,
    String? servicePackageId,
    DateTime? startAt,
    DateTime? endAt,
    String? timezone,
    bool? isAvailable,
    bool? isBooked,
    String? bookingId,
    ServicePackage? servicePackage,
    PT? pt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      ptId: ptId ?? this.ptId,
      servicePackageId: servicePackageId ?? this.servicePackageId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      timezone: timezone ?? this.timezone,
      isAvailable: isAvailable ?? this.isAvailable,
      isBooked: isBooked ?? this.isBooked,
      bookingId: bookingId ?? this.bookingId,
      servicePackage: servicePackage ?? this.servicePackage,
      pt: pt ?? this.pt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get durationMinutes => endAt.difference(startAt).inMinutes;

  @override
  String toString() {
    return 'TimeSlot(id: $id, startAt: $startAt, endAt: $endAt, isAvailable: $isAvailable, isBooked: $isBooked)';
  }
}