enum PTState { unactive, active, accepted }

class PT {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? address;
  final DateTime? createdAt;
  final PTState status;
  final String? notes;

  PT({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.address,
    this.createdAt,
    this.notes,
    required this.status,
  });

  factory PT.fromMap(Map<String, dynamic> map) {
    return PT(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      email: map['email'] as String?,
      address: map['address'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      status: _parseStatus(map['status'] as String?),
      notes: map['notes'] as String?,
    );
  }

  static PTState _parseStatus(String? value) {
    switch (value) {
      case 'active':
        return PTState.active;
      case 'accepted':
        return PTState.accepted;
      case 'unactive':
      default:
        return PTState.unactive;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'PT('
        'id: $id, '
        'name: $name, '
        'phoneNumber: $phoneNumber, '
        'email: $email, '
        'address: $address, '
        'createdAt: ${createdAt?.toIso8601String()}, '
        'status: ${status.name}'
          'notes: $notes'
        ')';
  }
}

enum SessionState { booked, completed, canceled }






// class PTReview{
//   final int id;
//   final int 
// }
