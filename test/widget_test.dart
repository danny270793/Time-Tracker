import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracker/core/app_preferences.dart';
import 'package:time_tracker/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('starts empty and creates a habit', (tester) async {
    final preferences = AppPreferences();
    await tester.pumpWidget(HabitFlowApp(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.text('Sleep 8h'), findsNothing);
    expect(find.text('Create your first habit'), findsWidgets);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('habit-name')), 'Read');
    await tester.tap(find.byKey(const ValueKey('save-habit')));
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsOneWidget);
  });

  testWidgets('opens dashboard and settings', (tester) async {
    final preferences = AppPreferences();
    await tester.pumpWidget(HabitFlowApp(preferences: preferences));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.textContaining('This week'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Export JSON'), findsOneWidget);
    expect(find.text('Import JSON'), findsOneWidget);
  });
}
