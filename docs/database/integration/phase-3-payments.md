# Phase 3 — Payments Data Layer (No UI)

## Goal
Implement the `payments` table data layer: model, repo methods, and controller state for escrow flow (held/released/refunded/failed/disputed). **No UI screen** — this phase is data-only per decision.

## DB Objects (from Phase 0)
- `payments` table with status: `pending`, `held`, `released`, `refunded`, `failed`, `disputed`.
- Trigger `release_payment_on_completion` fires when `bookings.status = completed` → sets payment `status = released` and creates `pt_earnings` row.

## Code Changes

### 1. Model: `lib/data/object/payment.dart`
```dart
enum PaymentStatus { pending, held, released, refunded, failed, disputed }

class Payment {
  final String? id;
  final String bookingId;
  final String clientId;
  final int amountCents;
  final int platformCommissionCents;
  final int ptAmountCents;
  final String paymentMethod; // 'stripe'
  final PaymentStatus status;
  final String? externalPaymentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  ...
}
```

### 2. Repository: `lib/repo/paymentRepository.dart` (new file)
- `createPayment(Payment payment)` → `Result<void>`
- `fetchPaymentByBooking(String bookingId)` → `Result<Payment?>`
- `fetchPaymentsByClient(String clientId)` → `Result<List<Payment>>`
- `updatePaymentStatus(String paymentId, PaymentStatus newStatus)` → `Result<void>`
- `refundPayment(String paymentId)` → `Result<void>` (sets status=refunded, triggers refund)

### 3. Controller: `lib/controller/paymentController.dart` (new file)
- Holds `_payments` list, `_state`, `_error`.
- Methods: `fetchPaymentsForBooking(String bookingId)`, `fetchClientPayments()`.
- Called by `Bookingcontroller` after booking creation to create payment record (held).

### 4. Integration with Booking flow
- In `Bookingcontroller.createBookingFromSlot`, after successful booking insert:
  - Create `Payment` with `status=held`, `externalPaymentId=stripe_payment_intent_id` (simulated for now).
  - Call `PaymentRepository.createPayment`.

## Files to Add / Modify
| File | Action |
|---|---|
| `lib/data/object/payment.dart` | Create |
| `lib/data/enum/paymentStatus.dart` | Create (if not in Phase 1) |
| `lib/repo/paymentRepository.dart` | Create |
| `lib/controller/paymentController.dart` | Create |
| `lib/controller/bookingController.dart` | Call payment repo after booking |
| `lib/main.dart` | Add PaymentRepository + PaymentController providers |

## Acceptance Tests

| Test | Description |
|---|---|
| `Payment.fromMap` parses all statuses | Round-trip for each `PaymentStatus` |
| `PaymentRepository.createPayment` inserts correct columns | Mock verify insert payload |
| `PaymentRepository.fetchPaymentByBooking` filters by booking_id | Mock query chain |
| `PaymentRepository.updatePaymentStatus` transitions held→released | Mock update + status enum |
| `PaymentController.fetchPaymentsForBooking` populates list | Controller test with mock repo |
| `Bookingcontroller.createBookingFromSlot` creates payment with status=held | Integration test with mocks |
| Trigger simulation: `release_payment_on_completion` logic tested via repo | Unit test: update booking status → payment status becomes released |

## Verification Command
```bash
flutter analyze && flutter test
```

## Notes
- Real Stripe integration is **deferred**. For now, `externalPaymentId` is a simulated UUID.
- The `release_payment_on_completion` trigger is a Postgres function; we test the *effect* by updating a booking to `completed` and asserting the payment row transitions to `released` (mocked at DB level in integration test, or verified via SQL in Phase 0).
- `pt_amount_cents` mirrors `bookings.pt_earnings_cents` at creation.