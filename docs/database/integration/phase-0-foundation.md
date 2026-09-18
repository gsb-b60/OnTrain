# Phase 0 — Foundation & Test Infrastructure

## Goal
Establish the complete DB schema (authored as SQL migrations), make all Supabase access injectable for offline testing, and set up a mockito-based test harness so every subsequent phase can run `flutter test` without a live database.

## DB Objects (authored in `supabase/migrations/`)
Create the following migrations in order. Use snake_case table/column names matching `docs/database/05-transaction-flows.md`.

| Migration | Tables / Objects | Key Details |
|---|---|---|
| `0001_profiles.sql` | `profiles` (exists) | Keep; add `phone`, `avatar_url` optional. |
| `0002_pt_profiles.sql` | `pt_profiles` | PT bank details for payouts: `id` (FK profiles), `bank_account_name`, `bank_account_number`, `bank_name`, `bank_branch`, `tax_id`. Link from existing `PT` table or migrate `PT` → `pt_profiles` (see below). |
| `0003_service_packages.sql` | `service_packages` | `id`, `pt_id` (FK pt_profiles), `name`, `description`, `price_cents`, `duration_minutes`, `is_active`. |
| `0004_time_slots.sql` | `time_slots` | `id`, `pt_id`, `service_package_id`, `start_at`, `end_at`, `timezone`, `is_available`, `is_booked`, `booking_id` (FK bookings). |
| `0005_bookings.sql` | `bookings` | `id`, `client_id`, `pt_id`, `service_package_id`, `start_at`, `end_at`, `timezone`, `price_cents`, `currency`, `platform_commission_percent`, `platform_commission_fixed_cents`, `pt_earnings_cents`, `status`, `payment_status`, `cancelled_by`, `cancelled_at`, `cancellation_reason`, `cancellation_fee_cents`, `no_show_by`, `created_at`, `updated_at`. Status enum per §1.2. |
| `0006_payments.sql` | `payments` | `id`, `booking_id`, `client_id`, `amount_cents`, `platform_commission_cents`, `pt_amount_cents`, `payment_method`, `status` (pending/held/released/refunded/failed/disputed), `external_payment_id`, `created_at`, `updated_at`. |
| `0007_pt_earnings.sql` | `pt_earnings` | `id`, `pt_id`, `booking_id`, `amount_cents`, `status` (pending/released/paid_out), `created_at`, `released_at`, `paid_out_at`. |
| `0008_payouts.sql` | `payouts` | `id`, `pt_id`, `amount_cents`, `status` (requested/processing/completed/failed), `requested_at`, `processed_at`, `bank_account_name`, `bank_account_number`, `bank_name`, `bank_branch`. |
| `0009_disputes.sql` | `disputes` | `id`, `booking_id`, `raised_by` (client/pt), `reason`, `status` (open/resolved_client/resolved_pt/resolved_split/refunded), `resolution`, `created_at`, `resolved_at`. |
| `0010_notifications.sql` | `notifications` | `id`, `user_id`, `type`, `title`, `body`, `data` (jsonb), `is_read`, `created_at`. |
| `0011_platform_settings.sql` | `platform_settings` | `key`, `value` (jsonb). Seed: `commission` {percent: 10, fixed_cents: 5000}, `cancellation_policy` {free_until_hours_before: 24, late_fee_percent: 50, no_show_fee_percent: 100}. |
| `0012_rpcs_and_triggers.sql` | RPCs & Triggers | `create_booking(p_client_id, p_slot_id, ...)`, `release_payment_on_completion()`, `create_earnings_on_completion()`, `update_pt_rating_aggregate()`, `notify_on_booking_events()`, `detect_no_shows()`, `generate_time_slots()` (pg_cron). |

**Reconcile `PT`**: Keep existing `PT` table for UI (favorites, list). Add nullable `pt_profile_id` FK to `pt_profiles`; on PT registration, insert into both. Or migrate fully — choose in migration. Document decision in the migration.

## Code Changes

### 1. Make `SupabaseClient` injectable
- All repos accept `SupabaseClient` in constructor (default to `Supabase.instance.client` for prod).
- Update `main.dart` providers accordingly.

```dart
// Example pattern
class BookingRepository {
  final SupabaseClient _client;
  BookingRepository({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  ...
}
```

### 2. Add test dependencies
```yaml
dev_dependencies:
  flutter_test: {sdk: flutter}
  flutter_lints: ^5.0.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

### 3. Create test harness (`test/test_utils/mock_supabase.dart`)
- Use mockito to mock `SupabaseClient`, `PostgrestQueryBuilder`, `PostgrestFilterBuilder`, `PostgrestTransformBuilder`.
- Provide helper `MockSupabaseBuilder` to chain `.from().select().eq()...` with canned responses.

### 4. Replace `test/widget_test.dart`
- Delete boilerplate counter test.
- Add a simple baseline test that boots `MyApp` with mocked repos and verifies no crash.

## Files to Add / Modify
| File | Action |
|---|---|
| `supabase/migrations/0001_profiles.sql` … `0012_rpcs_and_triggers.sql` | Create |
| `lib/repo/auth/authRepo.dart` | Inject client |
| `lib/repo/ptRepository.dart` | Inject client |
| `lib/repo/bookingRepository.dart` | Inject client |
| `lib/main.dart` | Update provider wiring |
| `pubspec.yaml` | Add mockito, build_runner |
| `test/test_utils/mock_supabase.dart` | Create |
| `test/widget_test.dart` | Replace with baseline test |
| `test/repo/booking_repository_test.dart` | Create (placeholder) |
| `test/controller/booking_controller_test.dart` | Create (placeholder) |

## Acceptance Tests (must all pass)

| Test | Description |
|---|---|
| `flutter analyze` | 0 errors, 0 warnings (new files only; legacy infos allowed) |
| `flutter test` | All tests green (mock-only, no live DB) |
| `test/widget_test.dart::App boots with mocked repos` | `pumpWidget(MyApp())` completes without throwing |
| `test/repo/booking_repository_test.dart::fetchBookingByPTID returns parsed list` | Mock `.from('bookings').select().eq('pt_id', id)` returns canned JSON; repo returns `Result.success(List<Booking>)` |
| `test/repo/booking_repository_test.dart::insertBooking calls insert with correct map` | Verify insert payload includes all required columns |

## Verification Command
```bash
flutter analyze && flutter test
```

## Notes
- Run `dart run build_runner build --delete-conflicting-outputs` after adding mockito annotations.
- The migration SQL should be idempotent (use `IF NOT EXISTS`, `CREATE OR REPLACE`).
- Keep `Booking` model fields aligned with the new `bookings` table columns exactly (snake_case → camelCase mapping in `fromMap`/`toMap`).