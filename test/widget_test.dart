import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracker/features/auth/presentation/cubit/session_cubit.dart';
import 'package:time_tracker/main.dart';

import 'helpers/test_app.dart';

Future<void> _pumpGuestApp(WidgetTester tester) async {
  final session = await setupTestDi(FakeAuthRepository());
  await tester.pumpWidget(const App());
  await session.initialize();
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({SessionCubit.guestKey: true});
  });

  testWidgets('starts empty and creates a habit', (tester) async {
    await _pumpGuestApp(tester);

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
    await _pumpGuestApp(tester);

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

    await tester.scrollUntilVisible(find.text('Rate on Google Play'), 200);
    expect(find.text('Rate on Google Play'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
  });
}
