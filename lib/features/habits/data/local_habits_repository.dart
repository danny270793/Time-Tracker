import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/habit.dart';
import '../domain/habits_repository.dart';

class LocalHabitsRepository implements HabitsRepository {
  static const _key = 'habits_v2';

  @override
  Future<List<Habit>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Habit.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> save(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(habits.map((habit) => habit.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
