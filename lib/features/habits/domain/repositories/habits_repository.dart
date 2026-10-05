import '../entities/habit.dart';

abstract class HabitsRepository {
  Future<List<Habit>> load();
  Future<void> save(List<Habit> habits);
}
