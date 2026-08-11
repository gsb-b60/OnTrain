# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project: OnTrain

Flutter mobile app for booking Personal Trainers (PTs). Users browse PT profiles, book training sessions, and manage schedules via a calendar view. Backend is Supabase (Auth + Postgres). State is managed with `provider` (`ChangeNotifier`).

- SDK: Dart `^3.9.2`
- Active platforms in tree: `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`
- Default locale: `en`; UI strings are Vietnamese in places (errors, comments)
- App ID/bundle: `com.example.ontrain` (see `android/app/build.gradle`)

## Common Commands

```bash
flutter pub get            # Install dependencies
flutter run                # Run on connected device/emulator
flutter analyze            # Static analysis (uses flutter_lints via analysis_options.yaml)
flutter test               # Run all tests in test/
flutter test test/widget_test.dart   # Run a single test file
flutter test --name "test name"      # Run a single test by name
flutter build apk          # Build Android
flutter build ios          # Build iOS
dart run flutter_launcher_icons      # Regenerate app icons (configured in pubspec.yaml)
```

There is no separate lint task — `flutter analyze` is the lint entry point.

## Architecture

Layered structure under `lib/`. Controllers depend on repositories; repositories depend on Supabase; features consume controllers via `provider`. Dependencies are wired up in `main.dart` using `MultiProvider`.

```
lib/
  main.dart                  # Supabase init + Provider tree composition
  core/constrants/           # AppColors, AppGradients, AppSizes (note: typo "constrants")
  data/
    enum/                    # UserRole, PTState, SessionState, ViewState
    object/                  # Domain models (PT, Booking, UserData, etc.)
    datacreator.dart         # Mock/sample data for prototyping
  model/                     # Generic Result<T> + RepoError wrappers
  repo/                      # Supabase data access (auth/, ptRepository, bookingRepository)
    errorHandle/             # AuthException → RepoError translation (Vietnamese messages)
  controller/                # ChangeNotifier-based state holders
  feature/                   # UI screens grouped by domain
    auth/                    # splash, welcome, signIn, signUp, authGate
    book/                    # booking screen, calendar home, sessions, PT CV
      home/                  # home page with TableCalendar
      searchPT/              # PT list + filter
      sessiondisplay/        # session list / detail
    PTDisplay/               # PT list/grid pages (note: separate from book/searchPT)
    profile/                 # user profile view/edit
    specialties/             # PT specialties screen
  UI/                        # Cross-feature shared widgets (HeaderBar, FavoriteIconBtn)
  L10n/                      # Localization ARB files (currently empty app_en.arb)
  routes/                    # Navigation routing (WIP)
```

### Provider tree (`main.dart`)

Repositories (plain `Provider`):
- `Authrepo`
- `Ptrepository`
- `BookingRepository`

Controllers (`ChangeNotifierProvider`), constructed in dependency order:
1. `AuthController(repo)` — manages `signIn`/`signUp`/`signOut`, fetches `UserData` from the `profile` table, exposes `ViewState` (`idle`/`loading`/`success`/`error`)
2. `Calendarcontroller` — calendar focus + bookings-for-selected-date filter (uses `table_calendar`'s `isSameDay`)
3. `Bookingcontroller(repo, authController, calendarController)` — fetches/inserts bookings, tracks `_ptID` for the currently viewed PT
4. `PTController(repo, authController, bookingController)` — list, search (`filterByName`/`clearFilter`), favorite toggle, selected PT; calls `initController()` on creation which preloads PTs

`AuthGateWay` (root widget) listens to `Supabase.instance.client.auth.onAuthStateChange` and switches between `SignInScreen` and `HomePage`.

### Key conventions

- All UI must use `AppColors` and `AppGradients` from `lib/core/constrants/app_colors.dart`. Primary brand: `aquaTeal` (#50C9C3). Primary buttons use `AppGradients.focus`. Headers use `AppGradients.brand` or solid `aquaTeal`. See `designPrinciple.md` for the full design system.
- Sizes from `lib/core/constrants/app_size.dart` — `AppSizes.padding` (16), `radius` (12), `semiLarge` (24), `large` (32).
- Repository return type: `Future<Result<T>>` (see `lib/model/result.dart`). `Result<T>` has `data`/`error`, with `isSuccess`/`isError` getters. Repositories map Supabase errors to `RepoError` (see `repo/errorHandle/authErrorHandle.dart` for auth-specific mapping).
- Domain models use `fromMap` / `toMap` factories for Supabase JSON interop (e.g., `Booking.fromMap`, `PT.fromMap`).
- Shared widgets live in `lib/UI/` (e.g., `HeaderBar`, `FavoriteIconBtn`).
- Calendar uses `table_calendar`; styled with `AppColors.aquaTeal` (markers) and `AppColors.mintLight` (today highlight).

## Supabase

- Initialized at app start in `main.dart` — URL and `anonKey` are **hardcoded there** (commit-worthy, low-privilege anon key, but be aware they ship in the binary).
- Tables touched: `profile` (auth user profile rows, keyed by `auth.users.id`), `PT`, `Booking`.
- `BookingRepository.fetchBookingByPTID` joins `*, PT(*), client(*)`. `Authrepo.getCurrentUser` does `.from("profile").select().eq('id', user.id).single()`.
- `Authrepo.signUp` inserts into `profile` with `role: role.dbValue` (i.e., `"Client"` or `"PT"`).

## Known issues / things to know

- `lib/core/constrants/` is a misspelling of "constants" — kept for compatibility; do not create a parallel `constants/` folder.
- `authControlller.dart` has a double-l typo in the filename (matches the import in `main.dart`).
- `data/object/ptContrast.dart`, `data/object/ptReview.dart`, `data/object/ptSepecialties.dart`, `data/object/ptSession.dart` are early/WIP domain models.
- `controller/specialtiesController.dart` is a near-empty stub.
- `lib/routes/` is a WIP placeholder.
- `test/widget_test.dart` is the default Flutter counter test (boilerplate) — it imports `MyApp` but the app uses `AuthGateWay` and Supabase; it will fail without additional setup. Tests likely need a mocked Supabase client.
- Several UI strings and most error messages are in Vietnamese; mixed with English throughout the codebase.
- `flutter_localization` is in `pubspec.yaml` but `L10n/app_en.arb` is empty — localization is not yet wired.
- Feature `book/` and feature `PTDisplay/` overlap: `book/searchPT/` has `ptlistpage.dart` and `filterpage.dart`; `feature/PTDisplay/` has its own `ptlistpage.dart` and `ptlistpagenoti.dart`. When editing PT list UIs, check both locations.

## Reading order for new contributors

1. `lib/main.dart` — Provider wiring and Supabase init
2. `lib/model/result.dart` and `lib/model/error.dart` — error envelope
3. `lib/feature/auth/authGate.dart` — auth-driven routing
4. One repository (e.g., `repo/auth/authRepo.dart`) + its controller (`controller/authControlller.dart`)
5. `lib/core/constrants/app_colors.dart` + `designPrinciple.md` — visual language
6. A representative feature screen (e.g., `lib/feature/book/home/homepage.dart`)
