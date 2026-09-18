import 'package:ontrain/data/enum/ptStatus.dart';

class PT {
  final String id;
  final String headline;
  final String bio;
  final int yearsExperience;
  final String? address;
  final String? city;
  final String? stateProvince;
  final String? country;
  final String? postalCode;
  final String? location;
  final int serviceRadiusKm;
  final String? businessName;
  final String? businessRegistrationNumber;
  final String? taxId;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankName;
  final String? bankBranch;
  final String? bankSwiftCode;
  final PTStatus status;
  final DateTime? submittedForReviewAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;
  final double avgRating;
  final int totalReviews;
  final int totalSessionsCompleted;
  final bool autoAcceptBookings;
  final int bookingLeadTimeHours;
  final int cancellationPolicyHours;
  final String slug;
  final String? metaTitle;
  final String? metaDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  // From profiles join
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? phone;
  final bool isVerified;

  bool isFavorite;

  PT({
    required this.id,
    required this.headline,
    required this.bio,
    required this.yearsExperience,
    this.address,
    this.city,
    this.stateProvince,
    this.country,
    this.postalCode,
    this.location,
    required this.serviceRadiusKm,
    this.businessName,
    this.businessRegistrationNumber,
    this.taxId,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankName,
    this.bankBranch,
    this.bankSwiftCode,
    required this.status,
    this.submittedForReviewAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
    required this.avgRating,
    required this.totalReviews,
    required this.totalSessionsCompleted,
    required this.autoAcceptBookings,
    required this.bookingLeadTimeHours,
    required this.cancellationPolicyHours,
    required this.slug,
    this.metaTitle,
    this.metaDescription,
    required this.createdAt,
    required this.updatedAt,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phone,
    required this.isVerified,
    this.isFavorite = false,
  });

  factory PT.fromMap(Map<String, dynamic> map) {
    return PT(
      id: map['id'] as String,
      headline: map['headline'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      yearsExperience: map['years_experience'] as int? ?? 0,
      address: map['address'] as String?,
      city: map['city'] as String?,
      stateProvince: map['state_province'] as String?,
      country: map['country'] as String?,
      postalCode: map['postal_code'] as String?,
      location: map['location'] as String?,
      serviceRadiusKm: map['service_radius_km'] as int? ?? 20,
      businessName: map['business_name'] as String?,
      businessRegistrationNumber: map['business_registration_number'] as String?,
      taxId: map['tax_id'] as String?,
      bankAccountName: map['bank_account_name'] as String?,
      bankAccountNumber: map['bank_account_number'] as String?,
      bankName: map['bank_name'] as String?,
      bankBranch: map['bank_branch'] as String?,
      bankSwiftCode: map['bank_swift_code'] as String?,
      status: PTStatus.fromString(map['status'] as String? ?? 'draft'),
      submittedForReviewAt: map['submitted_for_review_at'] != null
          ? DateTime.parse(map['submitted_for_review_at'] as String)
          : null,
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'] as String)
          : null,
      reviewedBy: map['reviewed_by'] as String?,
      rejectionReason: map['rejection_reason'] as String?,
      avgRating: (map['avg_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: map['total_reviews'] as int? ?? 0,
      totalSessionsCompleted: map['total_sessions_completed'] as int? ?? 0,
      autoAcceptBookings: map['auto_accept_bookings'] as bool? ?? false,
      bookingLeadTimeHours: map['booking_lead_time_hours'] as int? ?? 2,
      cancellationPolicyHours: map['cancellation_policy_hours'] as int? ?? 24,
      slug: map['slug'] as String? ?? '',
      metaTitle: map['meta_title'] as String?,
      metaDescription: map['meta_description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
      isVerified: map['is_verified'] as bool? ?? false,
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'headline': headline,
      'bio': bio,
      'years_experience': yearsExperience,
      'address': address,
      'city': city,
      'state_province': stateProvince,
      'country': country,
      'postal_code': postalCode,
      'location': location,
      'service_radius_km': serviceRadiusKm,
      'business_name': businessName,
      'business_registration_number': businessRegistrationNumber,
      'tax_id': taxId,
      'bank_account_name': bankAccountName,
      'bank_account_number': bankAccountNumber,
      'bank_name': bankName,
      'bank_branch': bankBranch,
      'bank_swift_code': bankSwiftCode,
      'status': status.dbValue,
      'submitted_for_review_at': submittedForReviewAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
      'rejection_reason': rejectionReason,
      'avg_rating': avgRating,
      'total_reviews': totalReviews,
      'total_sessions_completed': totalSessionsCompleted,
      'auto_accept_bookings': autoAcceptBookings,
      'booking_lead_time_hours': bookingLeadTimeHours,
      'cancellation_policy_hours': cancellationPolicyHours,
      'slug': slug,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'is_verified': isVerified,
      'isFavorite': isFavorite,
    };
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map.remove('updated_at');
    map.remove('email');
    map.remove('full_name');
    map.remove('avatar_url');
    map.remove('phone');
    map.remove('is_verified');
    map.remove('isFavorite');
    return map;
  }

  PT copyWith({
    String? id,
    String? headline,
    String? bio,
    int? yearsExperience,
    String? address,
    String? city,
    String? stateProvince,
    String? country,
    String? postalCode,
    String? location,
    int? serviceRadiusKm,
    String? businessName,
    String? businessRegistrationNumber,
    String? taxId,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankName,
    String? bankBranch,
    String? bankSwiftCode,
    PTStatus? status,
    DateTime? submittedForReviewAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
    double? avgRating,
    int? totalReviews,
    int? totalSessionsCompleted,
    bool? autoAcceptBookings,
    int? bookingLeadTimeHours,
    int? cancellationPolicyHours,
    String? slug,
    String? metaTitle,
    String? metaDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phone,
    bool? isVerified,
    bool? isFavorite,
  }) {
    return PT(
      id: id ?? this.id,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      address: address ?? this.address,
      city: city ?? this.city,
      stateProvince: stateProvince ?? this.stateProvince,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      location: location ?? this.location,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      businessName: businessName ?? this.businessName,
      businessRegistrationNumber: businessRegistrationNumber ?? this.businessRegistrationNumber,
      taxId: taxId ?? this.taxId,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      bankBranch: bankBranch ?? this.bankBranch,
      bankSwiftCode: bankSwiftCode ?? this.bankSwiftCode,
      status: status ?? this.status,
      submittedForReviewAt: submittedForReviewAt ?? this.submittedForReviewAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      avgRating: avgRating ?? this.avgRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalSessionsCompleted: totalSessionsCompleted ?? this.totalSessionsCompleted,
      autoAcceptBookings: autoAcceptBookings ?? this.autoAcceptBookings,
      bookingLeadTimeHours: bookingLeadTimeHours ?? this.bookingLeadTimeHours,
      cancellationPolicyHours: cancellationPolicyHours ?? this.cancellationPolicyHours,
      slug: slug ?? this.slug,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    return 'PT('
        'id: $id, '
        'fullName: $fullName, '
        'headline: $headline, '
        'city: $city, '
        'status: ${status.dbValue}, '
        'avgRating: $avgRating, '
        'totalReviews: $totalReviews, '
        'isFavorite: $isFavorite'
        ')';
  }

  // Backward compatibility getters for existing UI code
  String get name => fullName;
  String? get phoneNumber => phone;
  String? get notes => bio;
}