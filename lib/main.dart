import 'package:flutter/material.dart';

import 'screens/create_reminder_screen.dart';
import 'screens/reminder_details_screen.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const ReminderApp());
}

class ReminderApp extends StatefulWidget {
  const ReminderApp({super.key});

  @override
  State<ReminderApp> createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.onOpenReminderDetails = _openReminderDetails;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.consumePendingLaunchNavigation();
    });
  }

  void _openReminderDetails(String message) {
    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => ReminderDetailsScreen(message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Reminder App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CreateReminderScreen(),
    );
  }
}
