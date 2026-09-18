# Common Query Patterns

> **OnTrain PT Marketplace** — Frequently used Supabase queries for Dart/Flutter.
> All queries assume RLS is enabled and user is authenticated.

---

## Table of Contents

1. [PT Discovery & Search](#1-pt-discovery--search)
2. [Booking & Scheduling](#2-booking--scheduling)
3. [Client Dashboard](#3-client-dashboard)
4. [PT Dashboard](#4-pt-dashboard)
5. [Payments & Earnings](#5-payments--earnings)
6. [Reviews & Social](#6-reviews--social)
7. [Chat & Notifications](#7-chat--notifications)
8. [Admin/Analytics](#8-adminanalytics)

---

## 1. PT Discovery & Search

### 1.1 Browse Active PTs (with filters)
```dart
// Basic: All active PTs with profiles
final pts = await supabase
  .from('pt_profiles')
  .select('''
    *,
    profiles!inner(full_name, avatar_url),
    pt_specialties(specialty_id, specialties(name, slug, icon_name)),
    service_packages!inner(id, name, price_cents, duration_minutes, service_type, status)
  ''')
  .eq('status', 'active')
  .eq('profiles.role', 'pt')
  .eq('service_packages.status', 'active')
  .order('avg_rating', ascending: false)
  .limit(20);

// With specialty filter
final strengthPts = await supabase
  .from('pt_profiles')
  .select('''
    *,
    profiles!inner(full_name, avatar_url),
    pt_specialties!inner(specialty_id, specialties!inner(name, slug))
  ''')
  .eq('status', 'active')
  .eq('pt_specialties.specialties.slug', 'strength-training')
  .order('avg_rating', ascending: false);

// With city filter
final hcmcPts = await supabase
  .from('pt_profiles')
  .select('*, profiles!inner(full_name, avatar_url)')
  .eq('status', 'active')
  .ilike('city', '%ho chi minh%')
  .order('avg_rating', ascending: false);
```

### 1.2 Search PTs by Name
```dart
// Full-text search on PT name + headline
final results = await supabase
  .from('pt_profiles')
  .select('''
    *,
    profiles!inner(full_name, avatar_url)
  ''')
  .eq('status', 'active')
  .or('headline.ilike.%$query%,profiles.full_name.ilike.%$query%')
  .limit(20);
```

### 1.3 Get Single PT Profile (Detail Page)
```dart
final pt = await supabase
  .from('pt_profiles')
  .select('''
    *,
    profiles!inner(full_name, avatar_url, email, phone),
    pt_certifications(*),
    pt_specialties(
      proficiency_level,
      years_experience,
      is_primary,
      specialties(name, slug, icon_name, category)
    ),
    pt_gallery(*),
    service_packages!inner(
      id, name, description, service_type, price_cents, 
      duration_minutes, max_participants, status
    )
  ''')
  .eq('id', ptId)
  .eq('status', 'active')
  .single();
```

### 1.4 Get PT's Active Service Packages
```dart
final packages = await supabase
  .from('service_packages')
  .select('''
    *,
    pt_availability!inner(start_time, end_time, week_days, frequency)
  ''')
  .eq('pt_id', ptId)
  .eq('status', 'active');
```

---

## 2. Booking & Scheduling

### 2.1 Get Available Slots for PT + Date Range
```dart
// Client view: only available & unbooked slots
final slots = await supabase
  .from('time_slots')
  .select('''
    *,
    service_packages!inner(
      id, name, price_cents, duration_minutes, service_type,
      max_participants, is_online
    )
  ''')
  .eq('pt_id', ptId)
  .eq('is_available', true)
  .eq('is_booked', false)
  .gte('start_at', startDate.toIso8601String())
  .lte('start_at', endDate.toIso8601String())
  .order('start_at');

// Group by date for calendar UI
final grouped = <String, List<TimeSlot>>{};
for (final slot in slots) {
  final dateKey = DateTime.parse(slot['start_at']).toLocal().toIso8601String().split('T').first;
  grouped.putIfAbsent(dateKey, () => []).add(TimeSlot.fromMap(slot));
}
```

### 2.2 Get Slots for Specific Service Package
```dart
final slots = await supabase
  .from('time_slots')
  .select()
  .eq('pt_id', ptId)
  .eq('service_package_id', packageId)
  .eq('is_available', true)
  .eq('is_booked', false)
  .gte('start_at', from.toIso8601String())
  .lte('start_at', to.toIso8601String())
  .order('start_at');
```

### 2.3 Create Booking (Client)
```dart
// 1. Verify slot is still available
final slot = await supabase
  .from('time_slots')
  .select()
  .eq('id', slotId)
  .eq('is_available', true)
  .eq('is_booked', false)
  .single();

// 2. Get commission settings
final commission = await supabase
  .from('platform_settings')
  .select('value')
  .eq('key', 'commission')
  .single();
final commissionPct = (commission['value'] as Map)['percent'] as double;
final commissionFixed = (commission['value'] as Map)['fixed_cents'] as int;

// 3. Calculate amounts
final priceCents = slot['service_packages']['price_cents'] as int;
final platformCommissionCents = (priceCents * commissionPct / 100).round() + commissionFixed;
final ptEarningsCents = priceCents - platformCommissionCents;

// 4. Create booking (atomic via RPC recommended)
final booking = await supabase.rpc('create_booking', params: {
  'p_client_id': userId,
  'p_slot_id': slotId,
  'p_price_cents': priceCents,
  'p_platform_commission_percent': commissionPct,
  'p_platform_commission_fixed_cents': commissionFixed,
  'p_pt_earnings_cents': ptEarningsCents,
});

// 5. Create payment record
await supabase.from('payments').insert({
  'booking_id': booking['id'],
  'client_id': userId,
  'amount_cents': booking['price_cents'],
  'platform_commission_cents': platformCommissionCents,
  'pt_amount_cents': booking['pt_earnings_cents'],
  'payment_method': 'stripe',
  'status': 'held',
  'external_payment_id': stripePaymentIntentId,
});
```

### 2.4 Get Client's Upcoming Bookings
```dart
final bookings = await supabase
  .from('bookings')
  .select('''
    *,
    service_packages(name, duration_minutes, service_type),
    pt_profiles!inner(
      id,
      profiles!inner(full_name, avatar_url),
      headline
    ),
    payments(status)
  ''')
  .eq('client_id', userId)
  .inFilter('status', ['pending', 'confirmed', 'in_progress'])
  .gte('start_at', DateTime.now().toIso8601String())
  .order('start_at');
```

### 2.5 Get PT's Bookings (Dashboard)
```dart
// Upcoming
final upcoming = await supabase
  .from('bookings')
  .select('''
    *,
    service_packages(name, duration_minutes),
    profiles!inner(full_name, avatar_url, phone),
    payments(status)
  ''')
  .eq('pt_id', ptId)
  .inFilter('status', ['pending', 'confirmed'])
  .gte('start_at', DateTime.now().toIso8601String())
  .order('start_at');

// Past completed
final completed = await supabase
  .from('bookings')
  .select('''
    *,
    service_packages(name, price_cents),
    profiles!inner(full_name, avatar_url),
    payments(status, released_at),
    reviews(overall_rating)
  ''')
  .eq('pt_id', ptId)
  .eq('status', 'completed')
  .lte('start_at', DateTime.now().toIso8601String())
  .order('start_at', ascending: false);
```

### 2.6 PT Confirms/Cancels Booking
```dart
// Confirm
await supabase.from('bookings')
  .update({'status': 'confirmed'})
  .eq('id', bookingId)
  .eq('pt_id', ptId)
  .eq('status', 'pending');

// Cancel by PT
await supabase.from('bookings')
  .update({
    'status': 'cancelled_by_pt',
    'cancelled_at': DateTime.now().toIso8601String(),
    'cancellation_reason': reason,
  })
  .eq('id', bookingId)
  .eq('pt_id', ptId)
  .inFilter('status', ['pending', 'confirmed']);
```

### 2.7 Client Cancels Booking
```dart
await supabase.from('bookings')
  .update({
    'status': 'cancelled_by_client',
    'cancelled_at': DateTime.now().toIso8601String(),
    'cancellation_reason': reason,
    'cancellation_fee_cents': feeCents, // Calculate based on policy
  })
  .eq('id', bookingId)
  .eq('client_id', userId)
  .inFilter('status', ['pending', 'confirmed']);
```

---

## 3. Client Dashboard

### 3.1 Get Client Profile
```dart
final profile = await supabase
  .from('profiles')
  .select()
  .eq('id', userId)
  .single();
```

### 3.2 Get Favorites
```dart
final favorites = await supabase
  .from('favorites')
  .select('''
    *,
    pt_profiles!inner(
      id,
      profiles!inner(full_name, avatar_url),
      headline,
      city,
      avg_rating,
      total_reviews
    )
  ''')
  .eq('client_id', userId)
  .order('created_at', ascending: false);
```

### 3.3 Toggle Favorite
```dart
// Add
await supabase.from('favorites').insert({
  'client_id': userId,
  'pt_id': ptId,
});

// Remove
await supabase.from('favorites')
  .delete()
  .eq('client_id', userId)
  .eq('pt_id', ptId);
```

### 3.4 Check if Favorited
```dart
final result = await supabase
  .from('favorites')
  .select('id')
  .eq('client_id', userId)
  .eq('pt_id', ptId)
  .maybeSingle();

final isFavorited = result != null;
```

---

## 4. PT Dashboard

### 4.1 Get PT Profile (Own)
```dart
final profile = await supabase
  .from('pt_profiles')
  .select('''
    *,
    profiles!inner(full_name, email, phone, avatar_url)
  ''')
  .eq('id', ptId)
  .single();
```

### 4.2 Update PT Profile
```dart
await supabase.from('pt_profiles').update({
  'headline': headline,
  'bio': bio,
  'city': city,
  'address': address,
  'service_radius_km': radius,
  'auto_accept_bookings': autoAccept,
  'booking_lead_time_hours': leadTime,
  'cancellation_policy_hours': cancelPolicy,
  'bank_account_name': bankName,
  'bank_account_number': bankAccount,
  'bank_name': bankBank,
}).eq('id', ptId);
```

### 4.3 Manage Service Packages
```dart
// Create
final pkg = await supabase.from('service_packages').insert({
  'pt_id': ptId,
  'name': '1-on-1 Strength',
  'description': 'Personalized strength training',
  'service_type': 'one_on_one',
  'price_cents': 500000,
  'duration_minutes': 60,
  'max_participants': 1,
  'status': 'active',
}).select().single();

// Update
await supabase.from('service_packages')
  .update({'price_cents': 550000, 'status': 'active'})
  .eq('id', pkgId)
  .eq('pt_id', ptId);

// Archive
await supabase.from('service_packages')
  .update({'status': 'archived'})
  .eq('id', pkgId)
  .eq('pt_id', ptId);
```

### 4.4 Manage Availability (Recurring)
```dart
// Create weekly schedule
await supabase.from('pt_availability').insert({
  'pt_id': ptId,
  'service_package_id': pkgId, // null for all packages
  'frequency': 'weekly',
  'week_days': ['monday', 'wednesday', 'friday'],
  'start_time': '09:00:00',
  'end_time': '17:00:00',
  'valid_from': DateTime.now().toIso8601String().split('T').first,
  'timezone': 'Asia/Ho_Chi_Minh',
  'buffer_minutes': 15,
});

// Update
await supabase.from('pt_availability')
  .update({'end_time': '18:00:00', 'is_active': true})
  .eq('id', availId)
  .eq('pt_id', ptId);
```

### 4.5 Add Blocked Dates (Time Off)
```dart
await supabase.from('pt_blocked_dates').insert({
  'pt_id': ptId,
  'start_datetime': '2025-12-25 00:00:00+07',
  'end_datetime': '2025-12-26 00:00:00+07',
  'reason': 'Christmas Holiday',
});
```

### 4.6 Get Earnings Summary
```dart
// Unreleased earnings (held)
final unreleased = await supabase
  .from('pt_earnings')
  .select('sum(net_amount_cents)')
  .eq('pt_id', ptId)
  .eq('is_released', false)
  .single();

// Released but not paid out
final pendingPayout = await supabase
  .from('pt_earnings')
  .select('sum(net_amount_cents)')
  .eq('pt_id', ptId)
  .eq('is_released', true)
  .isFilter('payout_id', null)
  .single();

// This month's earnings
final thisMonth = await supabase
  .from('pt_earnings')
  .select('sum(net_amount_cents)')
  .eq('pt_id', ptId)
  .gte('created_at', DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String())
  .single();
```

### 4.7 Request Payout
```dart
// Get available earnings
final available = await supabase
  .from('pt_earnings')
  .select('id, net_amount_cents')
  .eq('pt_id', ptId)
  .eq('is_released', true)
  .isFilter('payout_id', null);

final totalCents = available.fold(0, (sum, e) => sum + e['net_amount_cents'] as int);

if (totalCents >= minPayoutAmount) { // Check platform_settings
  final payout = await supabase.from('payouts').insert({
    'pt_id': ptId,
    'amount_cents': totalCents,
    'period_start': periodStart.toIso8601String().split('T').first,
    'period_end': periodEnd.toIso8601String().split('T').first,
    'bank_account_name': bankName,
    'bank_account_number': bankAccount,
    'bank_name': bankBank,
    'status': 'pending',
  }).select().single();
  
  // Link earnings to payout (batch update)
  final earningIds = available.map((e) => e['id']).toList();
  await supabase.from('pt_earnings')
    .update({'payout_id': payout['id']})
    .inFilter('id', earningIds);
}
```

---

## 5. Payments & Earnings

### 5.1 Get Payment for Booking
```dart
final payment = await supabase
  .from('payments')
  .select()
  .eq('booking_id', bookingId)
  .single();
```

### 5.2 Update Payment Status (Webhook/Edge Function)
```dart
// After Stripe capture
await supabase.from('payments')
  .update({
    'status': 'held',
    'authorized_at': DateTime.now().toIso8601String(),
    'external_payment_id': stripePaymentIntentId,
    'external_payment_data': stripeResponseJson,
  })
  .eq('id', paymentId);

// After session completion (trigger does this automatically)
await supabase.from('payments')
  .update({
    'status': 'released',
    'released_at': DateTime.now().toIso8601String(),
  })
  .eq('booking_id', bookingId);
```

### 5.3 Refund Payment
```dart
await supabase.from('payments')
  .update({
    'status': 'refunded',
    'refunded_at': DateTime.now().toIso8601String(),
    'refund_amount_cents': refundAmount,
    'refund_reason': reason,
  })
  .eq('id', paymentId);

// Also update booking
await supabase.from('bookings')
  .update({'status': 'refunded', 'payment_status': 'refunded'})
  .eq('id', bookingId);
```

---

## 6. Reviews & Social

### 6.1 Create Review (After Completed Booking)
```dart
// Verify eligibility first
final booking = await supabase
  .from('bookings')
  .select('status, client_id, pt_id, service_package_id')
  .eq('id', bookingId)
  .single();

if (booking['status'] == 'completed' && booking['client_id'] == userId) {
  await supabase.from('reviews').insert({
    'booking_id': bookingId,
    'client_id': userId,
    'pt_id': booking['pt_id'],
    'service_package_id': booking['service_package_id'],
    'overall_rating': 5,
    'expertise_rating': 5,
    'communication_rating': 4,
    'punctuality_rating': 5,
    'value_rating': 4,
    'title': 'Excellent trainer',
    'comment': 'Very professional and knowledgeable.',
  });
}
```

### 6.2 Get PT's Public Reviews
```dart
final reviews = await supabase
  .from('reviews')
  .select('''
    *,
    profiles!inner(full_name, avatar_url),
    service_packages(name)
  ''')
  .eq('pt_id', ptId)
  .eq('visibility', 'public')
  .eq('moderation_status', 'approved')
  .order('created_at', ascending: false)
  .limit(20);
```

### 6.3 PT Responds to Review
```dart
await supabase.from('reviews')
  .update({
    'pt_response': 'Thank you for your feedback!',
    'pt_responded_at': DateTime.now().toIso8601String(),
  })
  .eq('id', reviewId)
  .eq('pt_id', ptId);
```

---

## 7. Chat & Notifications

### 7.1 Get/Create Conversation
```dart
// Get existing or create
final existing = await supabase
  .from('conversations')
  .select()
  .eq('client_id', userId)
  .eq('pt_id', ptId)
  .eq('booking_id', bookingId) // nullable
  .maybeSingle();

final conversation = existing ?? await supabase
  .from('conversations')
  .insert({
    'client_id': userId,
    'pt_id': ptId,
    'booking_id': bookingId,
    'subject': 'Booking #$bookingId',
  })
  .select()
  .single();
```

### 7.2 Get Messages
```dart
final messages = await supabase
  .from('messages')
  .select('''
    *,
    profiles!inner(full_name, avatar_url)
  ''')
  .eq('conversation_id', conversationId)
  .order('created_at')
  .limit(50);

// Real-time subscription
supabase.channel('messages:$conversationId')
  .onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'messages',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'conversation_id',
      value: conversationId,
    ),
    callback: (payload) {
      // Add new message to UI
    },
  )
  .subscribe();
```

### 7.3 Send Message
```dart
await supabase.from('messages').insert({
  'conversation_id': conversationId,
  'sender_id': userId,
  'content': messageText,
  'message_type': 'text',
});

// Update conversation preview
await supabase.from('conversations')
  .update({
    'last_message_at': DateTime.now().toIso8601String(),
    'last_message_preview': messageText.length > 50 
      ? '${messageText.substring(0, 50)}...' 
      : messageText,
    'unread_count_client': userId == clientId ? 0 : unreadCount + 1,
    'unread_count_pt': userId == ptId ? 0 : unreadCount + 1,
  })
  .eq('id', conversationId);
```

### 7.4 Get Unread Notifications
```dart
final notifications = await supabase
  .from('notifications')
  .select()
  .eq('user_id', userId)
  .eq('is_read', false)
  .order('created_at', ascending: false)
  .limit(20);
```

### 7.5 Mark Notifications Read
```dart
await supabase.from('notifications')
  .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
  .eq('user_id', userId)
  .inFilter('id', notificationIds);
```

---

## 8. Admin/Analytics

### 8.1 Platform Daily Analytics (Materialized View)
```dart
final analytics = await supabase
  .from('platform_daily_analytics')
  .select()
  .gte('date', startDate.toIso8601String().split('T').first)
  .lte('date', endDate.toIso8601String().split('T').first)
  .order('date', ascending: false);
```

### 8.2 PT Monthly Earnings (Materialized View)
```dart
final earnings = await supabase
  .from('pt_monthly_earnings')
  .select()
  .eq('pt_id', ptId)
  .gte('month', DateTime(DateTime.now().year, DateTime.now().month - 12, 1).toIso8601String().split('T').first)
  .order('month', ascending: false);
```

### 8.3 Get Pending Disputes
```dart
final disputes = await supabase
  .from('disputes')
  .select('''
    *,
    bookings!inner(
      start_at,
      service_packages(name),
      profiles!inner(full_name)
    ),
    profiles!disputes_initiated_by_fkey(full_name),
    profiles!disputes_against_user_id_fkey(full_name)
  ''')
  .eq('status', 'open')
  .order('priority', ascending: false)
  .order('created_at');
```

### 8.4 Get Moderation Queue
```dart
final queue = await supabase
  .from('moderation_queue')
  .select('''
    *,
    profiles!inner(full_name, email)
  ''')
  .eq('status', 'pending')
  .order('priority', ascending: false)
  .order('created_at');
```

---

## Performance Tips

| Pattern | Optimization |
|---------|--------------|
| Frequent PT search | Add `pg_trgm` index on `pt_profiles.headline`, `profiles.full_name` |
| Slot availability | Use `idx_time_slots_available` partial index |
| Booking lists | Composite indexes on `(pt_id, status, start_at)` |
| Review aggregates | Materialized view `pt_monthly_earnings` refreshed daily |
| Chat messages | Paginate with `limit(50)` + cursor-based `created_at` |

---

## Query Result Type Helpers (Dart)

```dart
// Generated types matching DB schema
class PTProfile {
  final String id;
  final String headline;
  final String bio;
  final int yearsExperience;
  final String city;
  final PtStatus status;
  final double avgRating;
  final int totalReviews;
  final List<Specialty> specialties;
  final List<Certification> certifications;
  final List<GalleryItem> gallery;
  final List<ServicePackage> packages;
  
  factory PTProfile.fromMap(Map<String, dynamic> map) => PTProfile(...);
}

class Booking {
  final String id;
  final String clientId;
  final String ptId;
  final String servicePackageId;
  final DateTime startAt;
  final DateTime endAt;
  final BookingStatus status;
  final int priceCents;
  final int ptEarningsCents;
  final PaymentStatus paymentStatus;
  final ServicePackage servicePackage;
  final PTProfile ptProfile;
  final Payment? payment;
  final Review? review;
  
  factory Booking.fromMap(Map<String, dynamic> map) => Booking(...);
}

class TimeSlot {
  final String id;
  final String ptId;
  final String servicePackageId;
  final DateTime startAt;
  final DateTime endAt;
  final bool isAvailable;
  final bool isBooked;
  final ServicePackage servicePackage;
  
  factory TimeSlot.fromMap(Map<String, dynamic> map) => TimeSlot(...);
}
```

---

*Keep queries in sync with RLS policies. Test with `supabase.from().select().explain()` for query plans.*