import 'dart:async';

import 'package:time_tracker/core/di/injection.dart';
import 'package:time_tracker/features/auth/domain/entities/app_user.dart';
import 'package:time_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:time_tracker/features/auth/presentation/cubit/session_cubit.dart';
import 'package:time_tracker/features/habits/data/repositories/habits_migrator.dart';
import 'package:time_tracker/features/habits/data/repositories/local_habits_repository.dart';
import 'package:time_tracker/features/habits/domain/entities/habit.dart';
import 'package:time_tracker/features/habits/domain/repositories/habits_repository.dart';

class FakeAuthRepository implements AuthRepository {
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

SessionCubit buildSession(AuthRepository auth) {
  final local = LocalHabitsRepository();
  final cloud = MemoryRepository();
  return SessionCubit(
    auth: auth,
    migrator: HabitsMigrator(local: local, cloudForUser: (_) => cloud),
    localRepository: local,
    cloudRepository: (_) => cloud,
  );
}

/// Registers app dependencies with a fake auth backend (no Supabase).
Future<SessionCubit> setupTestDi(AuthRepository auth) async {
  await getIt.reset();
  setupCoreDi();
  final session = buildSession(auth);
  getIt.registerSingleton<SessionCubit>(session);
  return session;
}
