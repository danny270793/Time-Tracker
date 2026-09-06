import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracker/core/app_preferences.dart';
import 'package:time_tracker/features/auth/auth_service.dart';
import 'package:time_tracker/features/auth/session_controller.dart';
import 'package:time_tracker/features/habits/data/habits_migrator.dart';
import 'package:time_tracker/features/habits/data/local_habits_repository.dart';
import 'package:time_tracker/features/habits/domain/habit.dart';
import 'package:time_tracker/features/habits/domain/habits_repository.dart';
import 'package:time_tracker/main.dart';

class FakeAuthService implements AuthService {
  final changes = StreamController<AppUser?>.broadcast();
  AppUser? user;

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> get userChanges => changes.stream;

  @override
  Future<AppUser> signIn(String email, String password) async {
    user = AppUser(id: 'user-1', email: email);
    changes.add(user);
    return user!;
  }

  @override
  Future<void> signOut() async {
    user = null;
    changes.add(null);
  }

  @override
  Future<void> updateEmail(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}
}

class MemoryRepository implements HabitsRepository {
  List<Habit> items = [];

  @override
  Future<List<Habit>> load() async => items;

  @override
  Future<void> save(List<Habit> habits) async => items = habits;
}

SessionController _session(FakeAuthService auth) {
  final local = LocalHabitsRepository();
  final cloud = MemoryRepository();
  return SessionController(
    auth: auth,
    migrator: HabitsMigrator(local: local, cloudForUser: (_) => cloud),
    localRepository: local,
    cloudRepository: (_) => cloud,
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows login then persists Continue without account', (
    tester,
  ) async {
    final auth = FakeAuthService();
    final first = _session(auth);
    await tester.pumpWidget(
      HabitFlowApp(preferences: AppPreferences(), sessionController: first),
    );
    await first.initialize();
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    await tester.tap(find.text('Continue without account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your first habit'), findsOneWidget);

    final second = _session(auth);
    await second.initialize();
    expect(second.status, SessionStatus.guest);

    first.dispose();
    second.dispose();
    await auth.changes.close();
  });
}
