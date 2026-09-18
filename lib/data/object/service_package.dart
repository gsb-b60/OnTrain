import 'package:ontrain/data/object/pt.dart';

class ServicePackage {
  final String id;
  final String ptId;
  final String name;
  final String? description;
  final int priceCents;
  final int durationMinutes;
  final bool isActive;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PT? pt;

  ServicePackage({
    required this.id,
    required this.ptId,
    required this.name,
    this.description,
    required this.priceCents,
    required this.durationMinutes,
    required this.isActive,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.pt,
  });

  factory ServicePackage.fromMap(Map<String, dynamic> map) {
    return ServicePackage(
      id: map['id'] as String,
      ptId: map['pt_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      priceCents: map['price_cents'] as int,
      durationMinutes: map['duration_minutes'] as int,
      isActive: map['is_active'] as bool? ?? true,
      status: map['status'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      pt: map['pt_profiles'] != null
          ? PT.fromMap(map['pt_profiles'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pt_id': ptId,
      'name': name,
      'description': description,
      'price_cents': priceCents,
      'duration_minutes': durationMinutes,
      'is_active': isActive,
      'status': status,
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

  ServicePackage copyWith({
    String? id,
    String? ptId,
    String? name,
    String? description,
    int? priceCents,
    int? durationMinutes,
    bool? isActive,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    PT? pt,
  }) {
    return ServicePackage(
      id: id ?? this.id,
      ptId: ptId ?? this.ptId,
      name: name ?? this.name,
      description: description ?? this.description,
      priceCents: priceCents ?? this.priceCents,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pt: pt ?? this.pt,
    );
  }

  @override
  String toString() {
    return 'ServicePackage(id: $id, name: $name, priceCents: $priceCents, durationMinutes: $durationMinutes)';
  }
}