import 'package:shared_preferences/shared_preferences.dart';

import '../domain/habit.dart';
import '../domain/habits_repository.dart';
import 'local_habits_repository.dart';

class HabitsMigrator {
  HabitsMigrator({
    required this.local,
    required this.cloudForUser,
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  final LocalHabitsRepository local;
  final HabitsRepository Function(String userId) cloudForUser;
  final Future<SharedPreferences> Function() _preferences;

  Future<void> migrateOnce(String userId) async {
    final prefs = await _preferences();
    final marker = 'habits_migrated_$userId';
    if (prefs.getBool(marker) == true) return;

    final guest = await local.load();
    if (guest.isNotEmpty) {
      final cloud = cloudForUser(userId);
      final merged = mergeHabits(await cloud.load(), guest);
      await cloud.save(merged);
      await local.clear();
    }

    await prefs.setBool(marker, true);
  }
}

List<Habit> mergeHabits(List<Habit> cloud, List<Habit> guest) {
  final result = [...cloud];

  for (final incoming in guest) {
    final normalized = _normalize(incoming.name);
    final index = result.indexWhere(
      (existing) =>
          existing.id == incoming.id || _normalize(existing.name) == normalized,
    );
    if (index == -1) {
      result.add(incoming);
      continue;
    }

    final existing = result[index];
    result[index] = existing.copyWith(
      completedDays: {...existing.completedDays, ...incoming.completedDays},
    );
  }

  return result;
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
