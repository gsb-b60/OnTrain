# Phase 4 — Earnings & Payouts (PT Side)

## Goal
Implement the PT earnings ledger (`pt_earnings`) and payout request flow (`payouts`). Build the PT-facing UI: earnings summary + request payout screen with min-amount guard.

## DB Objects (from Phase 0)
- `pt_earnings`: one row per completed booking (trigger `create_earnings_on_completion`). Status: `pending` → `released` (when payment released) → `paid_out` (when included in a payout).
- `payouts`: PT requests payout; status `requested` → `processing` → `completed`/`failed`. Min amount from `platform_settings` (e.g., 50000 VND).
- `pt_profiles`: bank account details for payout destination.

## Code Changes

### 1. Models
`lib/data/object/pt_earnings.dart`
```dart
enum EarningsStatus { pending, released, paidOut }

class PTEarnings {
  final String? id;
  final String ptId;
  final String bookingId;
  final int amountCents;
  final EarningsStatus status;
  final DateTime? createdAt;
  final DateTime? releasedAt;
  final DateTime? paidOutAt;
  ...
}
```

`lib/data/object/payout.dart`
```dart
enum PayoutStatus { requested, processing, completed, failed }

class Payout {
  final String? id;
  final String ptId;
  final int amountCents;
  final PayoutStatus status;
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String bankAccountName;
  final String bankAccountNumber;
  final String bankName;
  final String? bankBranch;
  ...
}
```

### 2. Repositories
`lib/repo/earningsRepository.dart`
- `fetchEarningsByPT(String ptId)` → `Result<List<PTEarnings>>`
- `fetchAvailableEarnings(String ptId)` → `Result<int>` (sum of `released` earnings not yet paid out)
- `fetchEarningsHistory(String ptId)` → `Result<List<PTEarnings>>` (all)

`lib/repo/payoutRepository.dart`
- `requestPayout({required String ptId, required int amountCents})` → `Result<String>` (returns payout_id)
- `fetchPayoutsByPT(String ptId)` → `Result<List<Payout>>`
- `fetchMinPayoutAmount()` → `Result<int>` (reads `platform_settings` key `min_payout_cents`)

### 3. Controller: `lib/controller/ptEarningsController.dart`
- `fetchEarningsSummary()` → loads available + pending + history.
- `requestPayout(int amountCents)` → validates ≥ min, calls repo, refreshes.

### 4. UI: `lib/feature/PTDisplay/pt_earnings_page.dart` (new)
- Top card: Available balance (released - paid_out), Pending balance.
- Button: "Request Payout" → opens amount entry dialog → calls controller.
- List: Earnings history (booking date, package, amount, status).
- List: Past payouts (requested_at, amount, status).

### 5. PT Profile Bank Details
- Ensure `PT` model / `pt_profiles` table has bank fields. Add to `PT` model if missing:
  `bankAccountName`, `bankAccountNumber`, `bankName`, `bankBranch`.

## Files to Add / Modify
| File | Action |
|---|---|
| `lib/data/object/pt_earnings.dart` | Create |
| `lib/data/object/payout.dart` | Create |
| `lib/data/enum/earningsStatus.dart` | Create |
| `lib/data/enum/payoutStatus.dart` | Create |
| `lib/repo/earningsRepository.dart` | Create |
| `lib/repo/payoutRepository.dart` | Create |
| `lib/controller/ptEarningsController.dart` | Create |
| `lib/feature/PTDisplay/pt_earnings_page.dart` | Create |
| `lib/feature/PTDisplay/ptlistpage.dart` | Add earnings page entry (or bottom nav) |
| `lib/data/object/pt.dart` | Add bank fields |
| `lib/main.dart` | Add providers |

## Acceptance Tests

| Test | Description |
|---|---|
| `PTEarnings.fromMap` / `Payout.fromMap` | Round-trip for all statuses |
| `EarningsRepository.fetchAvailableEarnings` sums only `released` & not `paid_out` | Mock data with mixed statuses |
| `PayoutRepository.fetchMinPayoutAmount` reads platform_settings | Mock `.eq('key', 'min_payout_cents')` |
| `PTEarningsController.requestPayout` rejects amount < min | Unit test with min=50000, request=30000 |
| `PTEarningsController.requestPayout` accepts amount ≥ min | Unit test |
| `PTEarningsController.requestPayout` calls repo with correct bank details | Mock verify insert payload |
| `PTEarningsPage` displays available/pending correctly | Widget test with canned controller state |
| Earnings history list shows correct status chips | Widget test |

## Verification Command
```bash
flutter analyze && flutter test
```

## Notes
- The `create_earnings_on_completion` trigger (Phase 0) inserts into `pt_earnings` with `status=pending`. The `release_payment_on_completion` trigger updates it to `released`.
- Payout request inserts into `payouts` with bank details snapshotted from `pt_profiles` at request time.
- Min payout amount defaults to 50000 VND if not in settings.
- Admin-side payout processing UI is **out of scope** for this phase.