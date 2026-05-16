import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reminder_app/screens/create_reminder_screen.dart';

void main() {
  testWidgets('Create reminder screen shows input and button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateReminderScreen()),
    );

    expect(find.text('Create Reminder'), findsOneWidget);
    expect(find.text('Set Reminder'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
