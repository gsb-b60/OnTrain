# Phase 1 — Booking Lifecycle

## Goal
Implement the full booking state machine (11 statuses per §1.2) in the data layer, wire controllers to surface grouped lists, and render the real status-driven tabs in the session UI.

## DB Objects (from Phase 0 migrations)
- `bookings` table with `status`, `payment_status`, `cancelled_by`, `cancelled_at`, `cancellation_reason`, `cancellation_fee_cents`, `no_show_by`.
- RPC: `create_booking` (atomic slot lock + insert).
- Triggers: `release_payment_on_completion`, `create_earnings_on_completion`, `notify_on_booking_events`.

## Code Changes

### 1. Model: `lib/data/object/booking.dart`
```dart
enum BookingStatus {
  pending, confirmed, inProgress, completed,
  cancelledByClient, cancelledByPT, cancelledByAdmin,
  noShowClient, noShowPT, disputed, refunded;
}

enum PaymentStatus { pending, held, released, refunded, failed, disputed }

class Booking {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? timezone;
  final String? clientId;
  final String? ptId;
  final String? servicePackageId;
  final int? priceCents;
  final String? currency;
  final double? platformCommissionPercent;
  final int? platformCommissionFixedCents;
  final int? ptEarningsCents;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? cancelledBy; // 'client' | 'pt' | 'admin'
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final int? cancellationFeeCents;
  final String? noShowBy; // 'client' | 'pt'
  final String? notes;
  final PT? pt;
  final UserData? client;
  ...
}
```

### 2. Repository: `lib/repo/bookingRepository.dart`
Add methods:
- `fetchBookingsByClient(String clientId)` → `Result<List<Booking>>`
- `fetchBookingsByPT(String ptId)` → `Result<List<Booking>>`
- `createBooking({required String clientId, required String slotId, ...})` → `Result<String>` (calls RPC `create_booking`)
- `updateBookingStatus(String bookingId, BookingStatus newStatus)` → `Result<void>`
- `cancelBooking({required String bookingId, required String cancelledBy, String? reason})` → `Result<void>` (applies fee logic from Phase 5)
- `markNoShow(String bookingId, String noShowBy)` → `Result<void>`

### 3. Controller: `lib/controller/bookingController.dart`
- State: `_bookings`, `_clientBookings`, `_ptBookings`.
- Methods: `fetchClientBookings()`, `fetchPTBookings(String ptId)`, `createBookingFromSlot(String slotId)`, `cancelBooking(...)`, `markNoShow(...)`.
- Getters: `upcoming`, `completed`, `cancelled`, `disputed`, `noShow` (filtered by `status` + `startTime`).

### 4. UI: `lib/feature/book/sessiondisplay/sessionpage.dart`
- Replace mock `PTSession` lists with real bookings from `Bookingcontroller`.
- Three tabs (Completed / Upcoming / Cancelled) + disputed/no-show badges.
- Each row uses `_StatusChip` with color per `BookingStatus`.

### 5. UI: `lib/feature/book/yoursessionpage.dart`
- Show live `Booking.status` badge.
- Cancel button enabled only when `status` ∈ {pending, confirmed}.

## Files to Add / Modify
| File | Action |
|---|---|
| `lib/data/object/booking.dart` | Extend with status/payment_status enums & all fields |
| `lib/repo/bookingRepository.dart` | Add fetch/create/update/cancel methods |
| `lib/controller/bookingController.dart` | Add grouped getters + mutation methods |
| `lib/feature/book/sessiondisplay/sessionpage.dart` | Wire to real bookings, remove mock data |
| `lib/feature/book/yoursessionpage.dart` | Show status badge, conditional cancel |
| `lib/data/enum/bookingStatus.dart` | Create (new file) |
| `lib/data/enum/paymentStatus.dart` | Create (new file) |

## Acceptance Tests

| Test | Description |
|---|---|
| `BookingStatus.values.length == 11` | All doc statuses present |
| `Booking.fromMap` parses all status strings correctly | Round-trip JSON for each status |
| `Bookingcontroller.fetchPTBookings` populates `_ptBookings` | Mock repo returns list; controller state = success |
| `Bookingcontroller.upcoming` filters `status ∈ {confirmed, inProgress} ∧ startTime > now` | Pure function test on controller getters |
| `Bookingcontroller.completed` filters `status == completed` | Unit test |
| `Bookingcontroller.cancelled` filters `status.startsWith('cancelled')` | Unit test |
| `Bookingcontroller.disputed` filters `status == disputed` | Unit test |
| `Bookingcontroller.noShow` filters `status ∈ {noShowClient, noShowPT}` | Unit test |
| `YourSessionPage` renders correct status chip for each status | Widget test with canned `Booking` per status |
| `createBookingFromSlot` calls repo RPC with correct params | Controller test with mock repo |

## Verification Command
```bash
flutter analyze && flutter test
```

## Notes
- The `create_booking` RPC returns `booking_id`; controller should then call `fetchPTBookings` to refresh.
- Status transitions must respect doc §1.2 valid next states (enforce in controller or repo).
- `payment_status` transitions are driven by triggers (Phase 3 data layer).