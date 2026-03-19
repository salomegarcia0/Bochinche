# Bochinche App

Bochinche is a comprehensive Flutter application designed to help users discover, create, and manage local events. It features an interactive map for locating events, seamless user authentication, event registration, and push notifications to keep users engaged.

## 🚀 Features

- **Interactive Event Map:** Discover events around you using a dynamic map interface (powered by `flutter_map`).
- **User Authentication:** Secure login and registration using Firebase Auth.
- **Event Management:** Create, view details, and manage local events.
- **Push Notifications:** Real-time alerts for new events and updates using Firebase Cloud Messaging and Local Notifications.
- **User Profiles:** Customize and manage your personal profile.
- **Event Registration:** Keep track of the events you are registered for.
- **Payments:** Integrated payment processing features (in development).

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend as a Service:** Firebase (Authentication, Firestore, Cloud Messaging)
- **Additional Backend:** Supabase
- **Maps:** `flutter_map`, `latlong2`, `flutter_map_location_marker`
- **Other Tools:** `flutter_local_notifications`, `fl_chart`, `shared_preferences`

## 📁 Project Structure

The project follows a feature-first architecture block logically separated into:

```text
lib/
 ├── core/          # Core application configurations and constants
 ├── data/          # Models, Firebase services, and repositories
 ├── features/      # Main application features
 │    ├── auth/             # Authentication logic and UI
 │    ├── map/              # Map view and markers logic
 │    ├── payment/          # Payment integrations
 │    ├── profile/          # User profile management
 │    └── Registered Events/# Events the user has signed up for
 ├── styles/        # Global styles, themes, and assets
 ├── widgets/       # Reusable global UI components
 └── main.dart      # Application entry point & Notification routing
```

## 💻 Getting Started

### Prerequisites

Ensure you have the following installed to run this project:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version ^3.10.7 or higher)
- Android Studio or Xcode (for emulation)
- A connected Firebase project (with `firebase_options.dart` configured)

### Installation & Execution

1. **Clone the repository and install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

### Helpful Commands for Development
- `flutter doctor` : Verify Flutter installation status
- `flutter clean` : Clear all build caches and dependencies
- `flutter pub get` : Install or reinstall dependencies

## 📝 Notes for Developers

- **Map Dependencies:** This branch focuses on map development. Always run `flutter pub get` after pulling to ensure all map dependencies are properly linked.
- **Notifications:** Android notification channels are pre-configured. To test them, ensure the app is run on a physical device or a fully featured emulator with Google Play Services.
