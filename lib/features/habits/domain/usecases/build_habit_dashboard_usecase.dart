import '../entities/habit.dart';

class HabitStreak {
  const HabitStreak({required this.habit, required this.days});
  final Habit habit;
  final int days;
}

class HabitDashboard {
  const HabitDashboard({
    required this.doneToday,
    required this.totalActive,
    required this.weeklyRate,
    required this.bestStreak,
    required this.bestStreakHabit,
    required this.openToday,
    required this.archivedCount,
    required this.weekCounts,
    required this.weekDates,
    required this.atRisk,
    required this.topStreaks,
  });

  final int doneToday;
  final int totalActive;
  final double weeklyRate;
  final int bestStreak;
  final String? bestStreakHabit;
  final List<Habit> openToday;
  final int archivedCount;
  final List<int> weekCounts;
  final List<DateTime> weekDates;
  final List<Habit> atRisk;
  final List<HabitStreak> topStreaks;
}

class BuildHabitDashboard {
  int _streak(Habit habit, DateTime today) {
    var streak = 0;
    var cursor = today;
    while (habit.completedDays.contains(dayKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  HabitDashboard call(List<Habit> habits, DateTime today) {
    final active = habits.where((habit) => !habit.isArchived).toList();
    final todayKey = dayKey(today);
    final yesterdayKey = dayKey(today.subtract(const Duration(days: 1)));
    final open = active
        .where((habit) => !habit.completedDays.contains(todayKey))
        .toList();
    final weekDates = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
    final weekCounts = [
      for (final date in weekDates)
        active.where((h) => h.completedDays.contains(dayKey(date))).length,
    ];
    final checked = weekCounts.fold<int>(0, (sum, value) => sum + value);
    final streaks = [
      for (final habit in active)
        HabitStreak(habit: habit, days: _streak(habit, today)),
    ]..sort((a, b) => b.days.compareTo(a.days));
    final opportunities = active.length * 7;
    return HabitDashboard(
      doneToday: active.length - open.length,
      totalActive: active.length,
      weeklyRate: opportunities == 0 ? 0 : checked / opportunities,
      bestStreak: streaks.isEmpty ? 0 : streaks.first.days,
      bestStreakHabit: streaks.isEmpty || streaks.first.days == 0
          ? null
          : streaks.first.habit.name,
      openToday: open,
      archivedCount: habits.where((habit) => habit.isArchived).length,
      weekCounts: weekCounts,
      weekDates: weekDates,
      atRisk: active
          .where(
            (habit) =>
                habit.completedDays.contains(yesterdayKey) &&
                !habit.completedDays.contains(todayKey),
          )
          .toList(),
      topStreaks: streaks.where((item) => item.days > 0).take(3).toList(),
    );
  }
}
