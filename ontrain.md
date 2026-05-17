# OnTrain Project Documentation

## Project Overview
**OnTrain** is a Flutter-based mobile application designed as a platform for booking Personal Trainers (PTs). It allows users to browse available trainers, view their profiles, book training sessions, and manage their training schedules.

## Tech Stack
- **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.9.2)
- **Language:** Dart
- **Backend:** [Supabase](https://supabase.com/) (Auth and Database)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **UI Components:**
  - `table_calendar`: For scheduling and session display.
  - `flutter_localization`: For multilingual support.
  - `intl`: For date and number formatting.

## Architecture
The project follows a layered architecture to separate concerns:

1.  **Data Layer (`lib/data`):**
    - **Models (`object/`):** Defines domain entities like `User`, `PT`, `PTSession`, `PTContrast` (Contract), etc.
    - **Enums (`enum/`):** Defines application-specific enumerations like `UserRole`, `PTState`, `SessionState`.
    - **Mock Data (`datacreator.dart`):** Provides sample data for development and testing.

2.  **Repository Layer (`lib/repo`):**
    - Handles data fetching and persistence, primarily interacting with Supabase.
    - **`authRepo.dart`:** Manages user authentication (Sign In, Sign Up, Sign Out) and profile retrieval.

3.  **Controller Layer (`lib/controller`):**
    - Acts as the bridge between the UI and the Repository.
    - **`authController.dart`:** Manages the authentication state and provides user data to the UI using the Provider pattern.

4.  **Feature Layer (`lib/feature`):**
    - Contains the UI implementation organized by feature:
        - **`auth/`:** Login, registration, splash, and welcome screens.
        - **`book/`:** Core booking logic, home page with calendar, PT CV/profile, and session management.
        - **`profile/`:** User profile viewing and updating.
        - **`PTDisplay/`:** Lists and detailed views of Personal Trainers.

5.  **Core Layer (`lib/core`):**
    - Contains app-wide constants like colors (`app_colors.dart`) and sizes (`app_size.dart`).

## Key Features
- **Authentication:** Secure sign-in and sign-up with role-based access (User vs. PT).
- **PT Directory:** Browse a list of Personal Trainers with their details and specialties.
- **Session Scheduling:** A calendar-based view to see upcoming and past training sessions.
- **Booking Management:** Interface for booking new sessions and canceling existing ones.
- **Profile Management:** Users can view and update their personal information.
- **Reviews:** Ability to review and rate PT sessions (WIP).

## Project Structure
```text
lib/
├── controller/        # State management (Provider)
├── core/              # Constants and shared utilities
├── data/              # Domain models, enums, and mock data
├── feature/           # UI screens and feature-specific logic
│   ├── auth/          # Authentication flows
│   ├── book/          # Booking and scheduling
│   ├── profile/       # User profile management
│   └── PTDisplay/     # PT listings and details
├── L10n/              # Localization files (ARB)
├── model/             # Generic result and error models
├── repo/              # Data access layer (Supabase)
├── routes/            # Navigation routing (WIP)
├── UI/                # Shared UI widgets
└── main.dart          # Entry point and initialization
```

## Current State & Notes
- The project is currently in development ("unfinished").
- Supabase is used for backend services, with credentials initialized in `main.dart`.
- Mock data is extensively used in `DataCreator` for UI prototyping.
- Some features like "Specialties", "Records", and detailed "Review" logic appear to be in the early stages of implementation.
- There are some minor typos in the codebase (e.g., `ptContrast` vs `PTContranst`, `constrants` vs `constants`) which should be addressed during refactoring.

## Getting Started
To run the project:
1. Ensure you have Flutter installed.
2. Run `flutter pub get` to install dependencies.
3. Configure your Supabase project or use the existing one (if keys are still valid).
4. Run `flutter run` on your preferred device.
