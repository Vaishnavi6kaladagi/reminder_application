<<<<<<< HEAD
# Reminder App (Flutter)

Cross-platform reminder application for **Android** and **iOS** with real system notifications that fire even when the app is fully closed.

## Features

- **Page 1 – Create Reminder**: Enter a message and tap **Set Reminder**
- **Immediate notification**: System notification titled **"Reminder Set"**
- **30-second notification**: System notification **"You have a reminder. Click to view it."** (works with app killed)
- **Page 2 – Reminder Details**: Opens when the user taps the 30-second notification, showing the original message

## Tech Stack

- [Flutter](https://flutter.dev)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) — local/scheduled device notifications
- [timezone](https://pub.dev/packages/timezone) — exact 30-second scheduling
- [shared_preferences](https://pub.dev/packages/shared_preferences) — persist reminder text for cold-start navigation

## Prerequisites

- Flutter SDK 3.7+
- Android Studio / Xcode (for device builds)
- Physical device or emulator with Google Play services (Android)

## Run

```bash
cd reminder_app
flutter pub get
flutter run
```

For release testing on Android:

```bash
flutter run --release
```

## Testing the assessment flow

1. Install and open the app on a **physical device** (recommended for notifications).
2. Grant **notification** permission when prompted (Android 13+ may also ask for **exact alarms**).
3. Enter a reminder message and tap **Set Reminder**.
4. Confirm the **"Reminder Set"** notification appears in the status bar / notification shade.
5. **Force-close** the app (swipe away from recents).
6. Wait **30 seconds** — the second notification should appear even with the app killed.
7. Tap the notification — the app should reopen on **Reminder Details** with your message.

## Platform notes

### Android

- Requires `POST_NOTIFICATIONS` (API 33+) and exact alarm permissions for reliable 30-second delivery when the app is not running.
- If the 30s notification is delayed on some OEMs, disable battery optimization for the app.

### iOS

- Notification permission is requested on first **Set Reminder**.
- Scheduled local notifications are delivered by iOS when the app is not running (subject to system policies).

## Project structure

```
lib/
  main.dart                          # App entry, navigation from notifications
  services/notification_service.dart # Permissions, show & schedule notifications
  screens/create_reminder_screen.dart
  screens/reminder_details_screen.dart
```
=======
# reminder_application
>>>>>>> 47f367af08b567af77b90864166427d366d91caf
