# Phase A · Align & Config

**Objective:** Align the Flutter codebase to the live Supabase schema, make repos testable with an injectable Supabase client, and establish a mockito-based test harness. All subsequent phases build on this foundation.

---

## Scope

### Must deliver
1. **`docs/database/db-config.sql`** — Complete, run-ordered SQL script (grants → policies → RPC → triggers → seeds).
2. **Model rewrites** — `UserData` (profiles), `PT` (pt_profiles × profiles join), `Booking` (bookings table + enums).
3. **Repo fixes** — `authRepo.signUp` columns/roles; `ptRepository` → `pt_profiles`; `bookingRepository` → `bookings` with correct columns.
4. **Injectable SupabaseClient** — All repos/controllers accept `SupabaseClient` ctor arg (default `Supabase.instance.client`).
5. **Test harness** — `mockito` + `build_runner`; `test/test_utils/mock_supabase.dart`; replace `test/widget_test.dart`.
6. **Green gate** — `flutter analyze` (0 errors) + `flutter test` (all pass).

### Out of scope
- Any UI changes.
- Booking lifecycle, payments, slots, earnings, notifications — those are Phases B–G.

---

## Schema Mapping (from `docs/live-schema.md`)

| App Model | Supabase Table(s) | Key Changes |
|---|---|---|
| `UserData` | `profiles` | `name` → `full_name`; `role` enum values lowercase (`client`/`pt`/`admin`); new fields: `phone`, `avatar_url`, `is_verified`, `deleted_at` |
| `PT` | `pt_profiles` + `profiles` (join on `id`) | `notes` removed; use `headline`, `bio`, `years_experience`, `city`, `avg_rating`, `total_reviews`, `total_sessions_completed`, bank fields, `slug`, `status` (`pt_status` enum) |
| `Booking` | `bookings` | `start_time`/`end_time` → `start_at`/`end_at`; `notes` → `client_notes`/`pt_notes`; `cancelled_by` = UUID; `status` = `booking_status` enum (11 states); `price_cents`, `platform_commission_*`, `pt_earnings_cents` |

### Enums (must match DB exactly)
- `user_role`: `client`, `pt`, `admin`
- `pt_status`: `draft`, `pending_review`, `active`, `suspended`, `rejected`
- `booking_status`: `pending`, `confirmed`, `in_progress`, `completed`, `cancelled_by_client`, `cancelled_by_pt`, `no_show_client`, `no_show_pt`, `refunded`, `disputed`, `expired`
- `payment_status`: `pending`, `authorized`, `captured`, `held`, `released`, `refunded`, `failed`
- `payout_status`: `pending`, `processing`, `completed`, `failed`, `cancelled`

---

## File Changes

### Models
| File | Action |
|---|---|
| `lib/data/object/user.dart` | Rewrite as `UserData` with `fromMap`/`toMap` for `profiles` columns; `role` as `UserRole` enum (lowercase) |
| `lib/data/object/pt.dart` | Rewrite as `PT` joining `pt_profiles` + `profiles`; `fromMap` accepts combined map; expose `fullName` from profiles |
| `lib/data/object/booking.dart` | Rewrite columns to match `bookings`; `status` as `BookingStatus` enum; `start_at`/`end_at` as `DateTime` |
| `lib/data/enum/userRole.dart` | Keep enum; ensure `dbValue` returns lowercase (`client`/`pt`/`admin`) |

### Repositories
| File | Action |
|---|---|
| `lib/repo/auth/authRepo.dart` | `signUp` → `profiles` table, insert `full_name`, `role: role.dbValue`; `getCurrentUser` → `profiles` select |
| `lib/repo/ptRepository.dart` | `.from('PT')` → `.from('pt_profiles')`; join `profiles` for `full_name`, `phone`, `avatar_url`; map `status` to `PTStatus` |
| `lib/repo/bookingRepository.dart` | `.from('Booking')` → `.from('bookings')`; column rename map; `insertBooking` calls `create_booking` RPC |

### Controllers (ctor signature only; logic unchanged)
| File | Action |
|---|---|
| `lib/controller/authControlller.dart` | Accept `SupabaseClient?` and pass to `Authrepo` |
| `lib/controller/bookingController.dart` | Accept `SupabaseClient?` and pass to `BookingRepository` |
| `lib/controller/ptController.dart` | Accept `SupabaseClient?` and pass to `Ptrepository` |

### Main / DI
| File | Action |
|---|---|
| `lib/main.dart` | Repos/controllers instantiated with explicit `Supabase.instance.client` (keeps runtime behavior); ctor signature allows injection |

### Test Infra
| File | Action |
|---|---|
| `pubspec.yaml` | Add `mockito: ^5.4.0`, `build_runner: ^2.4.0` under `dev_dependencies` |
| `test/test_utils/mock_supabase.dart` | New file: `MockSupabaseClient`, `MockPostgrestQueryBuilder`, `MockPostgrestFilterBuilder`, `MockPostgrestTransformBuilder` with sensible stubs |
| `test/widget_test.dart` | Replace boilerplate with a smoke test that wires `AuthGateWay` with mocked repos; verify `AuthController` loads |

---

## Acceptance Criteria

1. `docs/database/db-config.sql` exists and matches this spec.
2. `docs/database/integration/phase-a-align-config.md` (this file) exists.
3. All models compile with `flutter analyze` (0 errors).
4. Repos use correct table/column names; `authRepo.signUp` inserts to `profiles` with lowercase role.
5. Every repo/controller ctor has optional `SupabaseClient` param defaulting to `Supabase.instance.client`.
6. `pubspec.yaml` contains `mockito` + `build_runner`.
7. `test/test_utils/mock_supabase.dart` compiles and provides mocks for `SupabaseClient`, query builders.
8. `flutter test` runs at least one test and passes (smoke test in `widget_test.dart`).
9. `flutter analyze` → 0 errors, 0 warnings.

---

## Dependencies

- None (foundation phase).
- Blocks Phases B–G.

---

## Rollback Plan

If any model change breaks existing features:
- Revert the specific model file.
- Keep DI/injectable changes (they're backward-compatible).
- Re-run `flutter analyze` + `flutter test`.

---

## Notes for Implementer

- Use `withValues(alpha:)` not `withOpacity`; `WidgetStateProperty` not `MaterialStateProperty`.
- No `print()` in production code (`avoid_print`).
- Async code must guard `BuildContext` with `mounted`/`context.mounted` after `await`.
- The `location` column in `pt_profiles` is PostGIS EWKB hex — ignore for now; add `ST_AsGeoJSON` RPC later if needed.
- `specialties` table is empty; old specialty-by-notes filter must be redesigned in Phase B/F.