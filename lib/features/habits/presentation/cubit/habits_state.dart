import '../../domain/entities/habit.dart';

class HabitsState {
  const HabitsState({this.habits = const [], this.loading = true, this.error});

  final List<Habit> habits;
  final bool loading;
  final String? error;

  List<Habit> get active => habits.where((habit) => !habit.isArchived).toList();
  List<Habit> get archived =>
      habits.where((habit) => habit.isArchived).toList();
}
