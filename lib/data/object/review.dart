class Review {
  final String? id;
  final String bookingId;
  final String clientId;
  final String ptId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  Review({
    this.id,
    required this.bookingId,
    required this.clientId,
    required this.ptId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String?,
      bookingId: map['booking_id'] as String,
      clientId: map['client_id'] as String,
      ptId: map['pt_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'client_id': clientId,
      'pt_id': ptId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    return map;
  }

  Review copyWith({
    String? id,
    String? bookingId,
    String? clientId,
    String? ptId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      clientId: clientId ?? this.clientId,
      ptId: ptId ?? this.ptId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, bookingId: $bookingId, rating: $rating)';
  }
}