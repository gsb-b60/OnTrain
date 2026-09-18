# Phase 2 — Time Slots & Availability

## Goal
Replace the hardcoded hour grid in `BookingScreen` with real `time_slots` fetched from Supabase. Enforce availability at booking time via the `create_booking` RPC (atomic slot lock).

## DB Objects (from Phase 0)
- `service_packages`: per-PT packages (name, price_cents, duration_minutes).
- `time_slots`: `id`, `pt_id`, `service_package_id`, `start_at`, `end_at`, `timezone`, `is_available`, `is_booked`, `booking_id`.
- `generate_time_slots()` pg_cron job (optional, can be invoked manually for dev).

## Code Changes

### 1. Models
`lib/data/object/service_package.dart`
```dart
class ServicePackage {
  final String id;
  final String ptId;
  final String name;
  final String? description;
  final int priceCents;
  final int durationMinutes;
  final bool isActive;
  ...
}
```

`lib/data/object/time_slot.dart`
```dart
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
  ...
}
```

### 2. Repository: `lib/repo/ptRepository.dart` (or new `SlotRepository`)
- `fetchServicePackages(String ptId)` → `Result<List<ServicePackage>>`
- `fetchAvailableSlots({required String ptId, DateTime? from, DateTime? to})` → `Result<List<TimeSlot>>`
  - Query: `.eq('pt_id', ptId).eq('is_available', true).eq('is_booked', false).gte('start_at', from).lte('start_at', to).order('start_at')`
- `fetchSlotsForDate(String ptId, DateTime date)` → `Result<List<TimeSlot>>`

### 3. Controller: `lib/controller/bookingController.dart` (or new `SlotController`)
- `fetchAvailableSlotsForPT(String ptId, DateTime date)` → populates `_slotsForDate`.
- `getSlotsForDate(DateTime date)` → returns grouped by `servicePackage` for UI.

### 4. UI: `lib/feature/book/bookingScreen.dart`
- `TableCanlendarBooking` state loads slots for `_selectedDay` from controller.
- Hour blocks rendered from `TimeSlot` list (not hardcoded `hours` list).
- Each slot shows `servicePackage.name`, `price_cents`, duration.
- Tapping a free slot → confirm dialog → calls `Bookingcontroller.createBookingFromSlot(slotId)`.

### 5. `Bookingcontroller.createBookingFromSlot(String slotId)`
- Calls `BookingRepository.createBooking(clientId: ..., slotId: ...)`.
- On success, refreshes slots + bookings.

## Files to Add / Modify
| File | Action |
|---|---|
| `lib/data/object/service_package.dart` | Create |
| `lib/data/object/time_slot.dart` | Create |
| `lib/repo/ptRepository.dart` | Add slot/service package methods (or new `SlotRepository`) |
| `lib/controller/bookingController.dart` | Add slot fetching + `createBookingFromSlot` |
| `lib/feature/book/bookingScreen.dart` | Replace hardcoded hours with real slots |
| `lib/feature/book/bookingScreen.dart` | Slot-aware confirm dialog |

## Acceptance Tests

| Test | Description |
|---|---|
| `TimeSlot.fromMap` parses all fields | Round-trip test |
| `ServicePackage.fromMap` parses price_cents/duration | Unit test |
| `SlotRepository.fetchAvailableSlots` builds correct query | Mock `.eq('is_available', true).eq('is_booked', false)...` |
| `SlotRepository.fetchSlotsForDate` filters by date | Mock date range |
| `Bookingcontroller.fetchAvailableSlotsForPT` groups slots by servicePackage | Controller test with canned slots |
| `BookingScreen` renders slot cards for each available slot | Widget test with mocked controller |
| Tapping a free slot opens confirm dialog with package name + price | Widget test |
| `createBookingFromSlot` calls RPC with correct `p_slot_id` | Controller test with mock repo |
| Double-book attempt: slot with `is_booked=true` is disabled in UI | Widget test with pre-booked slot |

## Verification Command
```bash
flutter analyze && flutter test
```

## Notes
- The `create_booking` RPC (§1.3 in doc) atomically locks the slot (`FOR UPDATE`), creates booking, marks `is_booked=true`. If slot already booked, it raises exception → controller surfaces error.
- Timezone: store all times in UTC (`timezone='UTC'`). Display in user local time.
- If `generate_time_slots` pg_cron not ready, provide a manual script to seed slots for a PT.