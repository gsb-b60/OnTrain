# Phase 5 — Cancellation, Refund, Dispute, No-Show

## Goal
Implement the full cancellation policy engine (fee calculation), refund processing, dispute lifecycle, and no-show handling. Wire the existing `CancelAppoint` screen end-to-end.

## DB Objects (from Phase 0)
- `bookings` columns: `cancelled_by`, `cancelled_at`, `cancellation_reason`, `cancellation_fee_cents`, `no_show_by`.
- `disputes` table with status: `open`, `resolved_client`, `resolved_pt`, `resolved_split`, `refunded`.
- `platform_settings.cancellation_policy`: `free_until_hours_before`, `late_fee_percent`, `no_show_fee_percent`.
- Trigger `notify_on_booking_events` emits notifications on cancel/no-show/dispute.

## Code Changes

### 1. Pure Policy Function (fully testable, no deps)
`lib/core/cancellation_policy.dart`
```dart
class CancellationPolicy {
  final int freeUntilHoursBefore;
  final int lateFeePercent;      // e.g., 50
  final int noShowFeePercent;    // e.g., 100

  const CancellationPolicy({
    required this.freeUntilHoursBefore,
    required this.lateFeePercent,
    required this.noShowFeePercent,
  });

  /// Returns (feeCents, reasonCode)
  (int, String) calculateFee({
    required int priceCents,
    required DateTime sessionStart,
    required DateTime cancelledAt,
    required String cancelledBy, // 'client' | 'pt' | 'admin'
    bool isNoShow = false,
  }) {
    if (cancelledBy == 'admin') return (0, 'admin_cancel');
    if (isNoShow) {
      return ((priceCents * noShowFeePercent / 100).round(), 'no_show');
    }
    final hoursBefore = sessionStart.difference(cancelledAt).inHours;
    if (hoursBefore >= freeUntilHoursBefore) {
      return (0, 'free_cancel');
    }
    return ((priceCents * lateFeePercent / 100).round(), 'late_cancel');
  }
}
```

### 2. Repository: `lib/repo/bookingRepository.dart` (extend)
- `cancelBooking({required String bookingId, required String cancelledBy, String? reason})`
  - Fetches booking + policy → calculates fee → updates booking with `status=cancelled_by_*`, `cancellation_fee_cents`, `payment_status=refunded` (if fee < price).
  - Creates `Payment` refund record if applicable.
- `markNoShow(String bookingId, String noShowBy)` → sets `status=no_show_*`, fee = 100%.
- `createDispute({required String bookingId, required String raisedBy, required String reason})` → inserts `disputes` row.
- `resolveDispute(String disputeId, DisputeResolution resolution)` → updates dispute + booking status.

### 3. Controller: `lib/controller/bookingController.dart` (extend)
- `cancelBooking({required String bookingId, required String reason, required CancelReason uiReason})` → calls repo, refreshes lists.
- `markNoShow(String bookingId, String noShowBy)`.
- `createDispute(...)` / `resolveDispute(...)`.

### 4. UI: `lib/feature/book/cancelsess.dart` (rewire)
- Pass `bookingId` to screen.
- On submit: read selected `CancelReason` + text field → call `Bookingcontroller.cancelBooking`.
- Show fee preview before confirm (fetch policy + calculate).
- On success: pop with result, show snackbar with fee info.

### 5. UI: `lib/feature/book/dispute_page.dart` (new, minimal)
- List disputes for current user (client/PT).
- Detail: reason, status, resolution.

### 6. Enum: `lib/data/enum/cancelReason.dart` (align with UI)
```dart
enum CancelReason { rescheduling, unexpectedWork, weather, others }
```

## Files to Add / Modify
| File | Action |
|---|---|
| `lib/core/cancellation_policy.dart` | Create (pure function) |
| `lib/repo/bookingRepository.dart` | Add cancel/no-show/dispute methods |
| `lib/controller/bookingController.dart` | Add cancel/no-show/dispute methods |
| `lib/feature/book/cancelsess.dart` | Rewire to controller + fee preview |
| `lib/feature/book/dispute_page.dart` | Create |
| `lib/data/enum/cancelReason.dart` | Create |
| `lib/data/enum/disputeStatus.dart` | Create |
| `lib/data/object/dispute.dart` | Create |

## Acceptance Tests

| Test | Description |
|---|---|
| `CancellationPolicy.calculateFee` free cancel (>24h) | 0 fee, reason='free_cancel' |
| `CancellationPolicy.calculateFee` late cancel (2h before) | 50% fee, reason='late_cancel' |
| `CancellationPolicy.calculateFee` no-show client | 100% fee, reason='no_show' |
| `CancellationPolicy.calculateFee` no-show PT | 100% fee + PT penalized |
| `CancellationPolicy.calculateFee` admin cancel | 0 fee |
| `BookingRepository.cancelBooking` applies fee + updates status | Mock repo: fetch booking → calc fee → update with correct columns |
| `BookingRepository.cancelBooking` creates refund payment when fee < price | Mock verify payment insert |
| `Bookingcontroller.cancelBooking` refreshes lists after success | Controller test |
| `CancelAppoint` shows fee preview before submit | Widget test with canned booking + policy |
| `CancelAppoint` submit calls controller with correct params | Widget test |
| Dispute create/resolve repo methods | Repo tests with mocks |

## Verification Command
```bash
flutter analyze && flutter test
```

## Notes
- Fee calculation is **pure** — no DB, no time dependencies (pass `cancelledAt` explicitly for testability).
- Policy values come from `platform_settings` (cached or fetched once).
- Refund: if `cancellation_fee_cents < price_cents`, create `Payment` with `status=refunded`, `pt_amount_cents = 0`, `platform_commission_cents = fee`.
- No-show: fee = 100% → no refund payment.
- Dispute resolution updates `disputes.status` and may trigger refund via `refunded` status.