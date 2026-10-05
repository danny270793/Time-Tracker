import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracker/features/auth/presentation/cubit/session_state.dart';
import 'package:time_tracker/main.dart';

import 'helpers/test_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows login then persists Continue without account', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final first = await setupTestDi(auth);
    await tester.pumpWidget(const App());
    await first.initialize();
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    await tester.tap(find.text('Continue without account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your first habit'), findsOneWidget);

    final second = buildSession(auth);
    await second.initialize();
    expect(second.state.status, SessionStatus.guest);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await first.close();
      await second.close();
      await auth.changes.close();
    });
  });
}
