import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/habit.dart';
import '../domain/habits_repository.dart';

class SupabaseHabitsRepository implements HabitsRepository {
  SupabaseHabitsRepository(this._client, this.userId);

  final SupabaseClient _client;
  final String userId;

  static const table = 'habit_tracker_data';

  @override
  Future<List<Habit>> load() async {
    final row = await _client
        .from(table)
        .select('habits')
        .eq('userId', userId)
        .maybeSingle();
    if (row == null) return [];
    final raw = row['habits'];
    if (raw is! List) return [];
    return raw
        .map((item) => Habit.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<void> save(List<Habit> habits) async {
    await _client.from(table).upsert({
      'userId': userId,
      'habits': habits.map((habit) => habit.toJson()).toList(),
      'version': 1,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'userId');
  }
}
