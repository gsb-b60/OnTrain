# Phase 4 — Earnings & Payouts (PT Side)

## Goal
Implement the PT earnings ledger (`pt_earnings`) and payout request flow (`payouts`). Build the PT-facing UI: earnings summary + request payout screen with min-amount guard.

## DB Objects (live schema)
Source of truth: `docs/live-schema.md` + `docs/database/05-transaction-flows.md`.

- `pt_earnings`: one row per completed booking (trigger `release_payment_on_completion`). There is **no status column**:
  - `is_released = false` → pending (payment still held)
  - `is_released = true AND payout_id IS NULL` → available for payout
  - `payout_id IS NOT NULL` → included in a payout batch
- `payouts`: PT requests payout; status `pending` → `processing` → `completed`/`failed`, or `cancelled`. `period_start` / `period_end` are required.
- `pt_profiles`: bank account details for the payout destination.
- `platform_settings`: `payout_min_amount_cents` = `{"min_amount": 50000}`.

## Code Changes

### 1. Models
`lib/data/object/pt_earnings.dart`
```dart
class PTEarnings {
  final String? id;
  final String ptId;
  final String bookingId;
  final String? paymentId;
  final int amountCents;
  final int platformCommissionPercent;
  final int platformCommissionFixedCents;
  final int platformCommissionCents;
  final int netAmountCents;
  final bool isReleased;
  final String? payoutId;
  final DateTime? createdAt;
  final DateTime? releasedAt;

  // UI-only derived status.
  EarningsStatus get status => !isReleased
      ? EarningsStatus.pending
      : (payoutId == null
          ? EarningsStatus.released
          : EarningsStatus.paidOut);
}
```

`lib/data/object/payout.dart`
```dart
enum PayoutStatus { pending, processing, completed, failed, cancelled }

class Payout {
  final String? id;
  final String ptId;
  final int amountCents;
  final PayoutStatus status;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String bankAccountName;
  final String bankAccountNumber;
  final String bankName;
  final String? bankBranch;
  ...
}
```

`lib/data/enum/earningsStatus.dart` remains `pending, released, paidOut`; it is **not persisted**.

### 2. Repositories
`lib/repo/earningsRepository.dart`
- `fetchEarningsByPT(String ptId)` → `Result<List<PTEarnings>>`
- `fetchAvailableEarnings(String ptId)` → `Result<int>`:
  `.eq('is_released', true).isFilter('payout_id', null)`
- `fetchPendingEarnings(String ptId)` → `Result<int>`:
  `.eq('is_released', false)`
- `fetchPaidOutEarnings(String ptId)` → `Result<int>`:
  `.eq('is_released', true).not('payout_id', 'is', null)`
- `fetchEarningsHistory(String ptId)` → `Result<List<PTEarnings>>` (all)

`lib/repo/payoutRepository.dart`
- `requestPayout()` → `Result<String>` (returns payout_id). Calls the atomic `request_payout` RPC; it does not insert directly.
- `fetchPayoutsByPT(String ptId)` → `Result<List<Payout>>`
- `fetchMinPayoutAmount()` → `Result<int>` (reads `platform_settings` key `payout_min_amount_cents`)

### 3. DB RPC (`docs/database/db-config.sql`)
`request_payout()` is `SECURITY DEFINER` and performs one transaction:
1. Reads the PT's bank details from `pt_profiles`.
2. Locks the PT's payout requests (`pg_advisory_xact_lock`).
3. Sums released, unlinked earnings.
4. Enforces the minimum payout.
5. Inserts `payouts` with `status='pending'`, `period_start`/`period_end`.
6. Sets `pt_earnings.payout_id` for those earnings.
7. Returns the new payout id.

### 4. Controller: `lib/controller/ptEarningsController.dart`
- `fetchEarningsSummary()` → loads available + pending + paid-out + history.
- `requestPayout()` → validates authentication and minimum, calls the RPC, then re-fetches the summary. The full available balance is requested; no local balance mutation.

### 5. UI: `lib/feature/PTDisplay/pt_earnings_page.dart`
- Top card: Available balance, Pending balance, Paid Out.
- Button: "Request Payout" → confirmation dialog showing the full available balance and bank destination → calls controller.
- List: Earnings history (booking date, package, amount, derived status).
- List: Past payouts (`requested_at`, amount, status).
- Disable the request action while `availableBalance < minPayoutAmount`.

### 6. PT Profile Bank Details
- `PT` model / `pt_profiles` already has `bankAccountName`, `bankAccountNumber`, `bankName`, `bankBranch`; the RPC snapshots them into the payout row.

## Files to Add / Modify
| File | Action |
|---|---|
| `lib/data/object/pt_earnings.dart` | Update to live schema |
| `lib/data/object/payout.dart` | Update to live schema |
| `lib/data/enum/payoutStatus.dart` | Align statuses |
| `lib/data/enum/earningsStatus.dart` | Keep (derived UI enum) |
| `lib/repo/earningsRepository.dart` | Update filters |
| `lib/repo/payoutRepository.dart` | Call RPC |
| `lib/controller/ptEarningsController.dart` | Full-balance request |
| `lib/feature/PTDisplay/pt_earnings_page.dart` | Confirmation dialog + status chips |
| `docs/database/db-config.sql` | Add `request_payout()` RPC |

## Acceptance Tests

| Test | Description |
|---|---|
| `PTEarnings.fromMap` | `is_released` false → pending; true + null `payout_id` → released; true + `payout_id` → paidOut |
| `PTEarnings.toInsertMap` | Contains `is_released` / `payout_id`, not `status` / `paid_out_at` |
| `Payout.fromMap` | Round-trip for all five live statuses |
| `EarningsRepository.fetchAvailableEarnings` | Query filters `is_released = true` and `payout_id IS NULL` |
| `PayoutRepository.requestPayout` | Calls `rpc('request_payout')` and returns the id |
| `PayoutRepository.fetchMinPayoutAmount` | Reads `platform_settings` key `payout_min_amount_cents` |
| `PTEarningsController.requestPayout` | Rejects balance < min; refreshes summary on success |
| `PTEarningsPage` | Displays available/pending/paid-out and the derived status chips |

## Verification Command
```bash
flutter analyze && flutter test
```

## Notes
- `release_payment_on_completion` inserts `pt_earnings` with `is_released = TRUE`, `released_at = NOW()`.
- Payout bank details are snapshotted from `pt_profiles` at request time by the RPC.
- Min payout amount defaults to 50000 VND if not in settings.
- Partial withdrawals are out of scope: the schema links whole earning rows to one payout.
- Admin-side payout processing UI is **out of scope** for this phase.
