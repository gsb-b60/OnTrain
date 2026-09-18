# Phase 7 — Integration & Final Validation

## Goal
Run end-to-end widget tests with fully mocked data layer covering the complete user journeys. Verify all prior phases work together, `flutter analyze` is clean, and the full test suite passes.

## Scope
No new features. This phase:
1. Ensures all providers are wired in `main.dart`.
2. Creates integration-style widget tests using the mock harness from Phase 0.
3. Runs the full test suite and coverage.
4. Documents any known gaps for future work (real Stripe, admin payout processing, messages/conversations).

## Code Changes

### 1. Provider Wiring Check (`lib/main.dart`)
Verify all providers exist:
- `Authrepo`, `Ptrepository`, `BookingRepository`, `PaymentRepository`, `EarningsRepository`, `PayoutRepository`, `NotificationRepository`, `ReviewRepository`
- `AuthController`, `Calendarcontroller`, `Bookingcontroller`, `PTController`, `PaymentController`, `PTEarningsController`, `NotificationController`, `ReviewController`

### 2. Integration Widget Tests (`test/integration/`)
Create `test/integration/app_flow_test.dart` using `WidgetTester` with mocked controllers/repos:
```dart
// Journey 1: Client books a session
testWidgets('Client browses PT → views CV → selects slot → books → sees in Sessions', (tester) async {
  // Setup mocks: PT list, slots, booking create success
  await tester.pumpWidget(MyApp());
  // Navigate: Home → PTListpage → PTCVPage → BookingScreen → confirm
  // Assert: YourSessionPage shows booking, Sessions tab shows upcoming
});

// Journey 2: Client cancels with fee preview
testWidgets('Client cancels upcoming booking → fee preview shown → cancel confirmed', (tester) async {
  // Setup: existing booking in confirmed state
  // Navigate to CancelAppoint → verify fee text → submit
  // Assert: booking status = cancelled_by_client, fee recorded
});

// Journey 3: PT views earnings → requests payout
testWidgets('PT opens earnings page → sees available balance → requests payout ≥ min', (tester) async {
  // Login as PT (mock auth)
  // Navigate to earnings page
  // Assert: available balance shown, request payout works
});

// Journey 4: Review flow
testWidgets('Completed booking → ReviewPage → submit rating+comment → PT rating updates', (tester) async {
  // Setup: completed booking
  // Open ReviewPage → select 5 stars → submit
  // Assert: review submitted, PT ratingAvg updated
});
```

### 3. Coverage
- Run `flutter test --coverage` and ensure meaningful coverage on:
  - `cancellation_policy.dart` (100%)
  - All controllers (state transitions)
  - All repos (query building)
  - Models (fromMap/toMap)

### 4. Lint & Format
- `dart format --set-exit-if-changed .`
- `flutter analyze` — 0 errors, 0 new warnings.

## Files to Add / Modify
| File | Action |
|---|---|
| `test/integration/app_flow_test.dart` | Create |
| `test/integration/mock_providers.dart` | Create (shared test widget wrapper) |
| `lib/main.dart` | Verify all providers present |

## Acceptance Tests

| Test | Description |
|---|---|
| `flutter analyze` | 0 errors, 0 warnings (new code) |
| `flutter test` | All tests green (unit + widget + integration) |
| `flutter test --coverage` | Generates `coverage/lcov.info` |
| Integration: Client booking flow | `app_flow_test.dart` Journey 1 passes |
| Integration: Client cancel with fee | Journey 2 passes |
| Integration: PT earnings + payout | Journey 3 passes |
| Integration: Review submit | Journey 4 passes |
| No `print()` in production code | `grep -r "print(" lib/` returns only comments/tests |

## Verification Command
```bash
flutter analyze && flutter test && flutter test --coverage
```

## Known Gaps (Documented for Future)
| Area | Status | Notes |
|---|---|---|
| Real Stripe PaymentIntent | Deferred | Phase 3 is data-only; add `flutter_stripe` + edge function later |
| Admin payout processing UI | Out of scope | Admin panel separate |
| Messages / Conversations | Out of scope | `update_conversation_last_message` trigger exists; UI not built |
| Push notifications (FCM/APNs) | Out of scope | Local notifications only |
| Time slot generation pg_cron | Manual for dev | Add cron job in prod |
| Multi-language (ARB) | Not wired | `flutter_localization` in deps but `app_en.arb` empty |

## Sign-Off Criteria
- [ ] All 7 phase specs implemented
- [ ] `flutter analyze` clean
- [ ] `flutter test` 100% pass
- [ ] Coverage report generated
- [ ] No TODOs/FIXMEs in new code (except documented gaps above)
- [ ] README updated with run instructions for tests