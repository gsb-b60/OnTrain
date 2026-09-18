# Phase 6 — Notifications & Reviews

## Goal
Implement the `notifications` data layer + UI badge/list, and persist reviews with PT rating aggregate trigger.

## DB Objects (from Phase 0)
- `notifications`: `id`, `user_id`, `type`, `title`, `body`, `data` (jsonb), `is_read`, `created_at`.
- Trigger `notify_on_booking_events` inserts rows on: booking created, confirmed, cancelled, completed, no-show, dispute opened.
- `reviews` (new table): `id`, `booking_id`, `client_id`, `pt_id`, `rating` (1-5), `comment`, `created_at`.
- Trigger `update_pt_rating_aggregate` on `reviews` insert/update → updates `pt_profiles.rating_avg`, `pt_profiles.rating_count`.

## Code Changes

### 1. Models
`lib/data/object/notification.dart`
```dart
class Notification {
  final String id;
  final String userId;
  final String type; // 'booking_created', 'booking_confirmed', ...
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  ...
}
```

`lib/data/object/review.dart`
```dart
class Review {
  final String? id;
  final String bookingId;
  final String clientId;
  final String ptId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;
  ...
}
```

### 2. Repositories
`lib/repo/notificationRepository.dart`
- `fetchNotifications(String userId, {int limit=20, int offset=0})` → `Result<List<Notification>>`
- `fetchUnreadCount(String userId)` → `Result<int>`
- `markAsRead(String notificationId)` → `Result<void>`
- `markAllAsRead(String userId)` → `Result<void>`

`lib/repo/reviewRepository.dart`
- `submitReview(Review review)` → `Result<void>`
- `fetchReviewsForPT(String ptId)` → `Result<List<Review>>`
- `fetchReviewForBooking(String bookingId)` → `Result<Review?>`

### 3. Controllers
`lib/controller/notificationController.dart`
- `fetchNotifications()`, `unreadCount`, `markRead()`, `markAllRead()`.

`lib/controller/reviewController.dart`
- `submitReview(Review)`, `fetchPTReviews(String ptId)`.

### 4. UI
- **Notification badge** on HomePage bottom nav (Sessions tab) → shows unread count.
- **Notifications page** `lib/feature/book/notifications_page.dart` (new): list with tap → mark read, navigate per `data`.
- **ReviewPage** `lib/feature/book/review.dart` (rewire): on submit → `ReviewController.submitReview` → on success show thank-you dialog.
- **PT rating display** on `PTCVPage` / `PTListpage`: show `rating_avg` / `rating_count` from PT model.

### 5. PT Model Extension
Add to `PT`: `double? ratingAvg`, `int? ratingCount`. Update `fromMap` to read from `pt_profiles` (or join).

## Files to Add / Modify
| File | Action |
|---|---|
| `lib/data/object/notification.dart` | Create |
| `lib/data/object/review.dart` | Create |
| `lib/repo/notificationRepository.dart` | Create |
| `lib/repo/reviewRepository.dart` | Create |
| `lib/controller/notificationController.dart` | Create |
| `lib/controller/reviewController.dart` | Create |
| `lib/feature/book/notifications_page.dart` | Create |
| `lib/feature/book/review.dart` | Rewire to controller |
| `lib/feature/book/home/homepage.dart` | Add notification badge on Sessions tab |
| `lib/data/object/pt.dart` | Add `ratingAvg`, `ratingCount` |
| `lib/main.dart` | Add providers |

## Acceptance Tests

| Test | Description |
|---|---|
| `Notification.fromMap` parses all fields | Round-trip |
| `Review.fromMap` parses rating/comment | Round-trip |
| `NotificationRepository.fetchUnreadCount` returns count | Mock `.eq('is_read', false).count` |
| `NotificationController.fetchNotifications` populates list + unread count | Controller test |
| `NotificationController.markAsRead` updates local list | Controller test |
| `ReviewController.submitReview` calls repo + refreshes | Controller test |
| `ReviewPage` submit button disabled until rating selected | Widget test |
| `ReviewPage` on success shows dialog + pops | Widget test |
| `PTCVPage` displays `ratingAvg` / `ratingCount` | Widget test with canned PT |
| HomePage Sessions tab badge shows unread count | Widget test with mocked notification controller |

## Verification Command
```bash
flutter analyze && flutter test
```

## Notes
- `notify_on_booking_events` trigger (Phase 0) handles notification creation automatically. The app only reads.
- Review is only allowed for `completed` bookings (enforce in controller).
- Rating aggregate is maintained by DB trigger; app reads denormalized columns.
- `data` jsonb in notifications can carry `booking_id`, `type` for deep linking.