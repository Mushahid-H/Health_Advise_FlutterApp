// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_advisor/main.dart';

// import 'package:flutter_application_1/main.dart'; // Update the path accordingly.

void main() {
  testWidgets('App UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Enter symptoms and tap the button.
    await tester.enterText(find.byType(TextField), 'headache');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify the suggested disease and medication are displayed.
    expect(find.text('Suggested Disease: Hypertension (High Blood Pressure)'),
        findsOneWidget);
    expect(
        find.text(
            'Suggested Medication: ACE inhibitors (e.g., lisinopril), ARBs, beta-blockers, diuretics.'),
        findsOneWidget);
  });
}
