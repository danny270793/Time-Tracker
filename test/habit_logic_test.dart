import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/features/habits/domain/habit.dart';
import 'package:time_tracker/features/habits/domain/habits_repository.dart';
import 'package:time_tracker/features/habits/presentation/habits_cubit.dart';

class MemoryRepository implements HabitsRepository {
  MemoryRepository(this.items);
  List<Habit> items;

  @override
  Future<List<Habit>> load() async => items;

  @override
  Future<void> save(List<Habit> habits) async => items = habits;
}

Habit habit(
  String id,
  String name, {
  Set<String> days = const {},
  DateTime? archivedAt,
}) => Habit(
  id: id,
  name: name,
  color: 0xFF3366FF,
  icon: 0xe318,
  completedDays: days,
  archivedAt: archivedAt,
);

void main() {
  test('dashboard calculates today, week, and streak', () {
    final today = DateTime(2026, 9, 4);
    final data = BuildHabitDashboard()([
      habit(
        'a',
        'Read',
        days: {dayKey(today), dayKey(today.subtract(const Duration(days: 1)))},
      ),
      habit('b', 'Walk'),
    ], today);

    expect(data.doneToday, 1);
    expect(data.totalActive, 2);
    expect(data.bestStreak, 2);
    expect(data.bestStreakHabit, 'Read');
    expect(data.weeklyRate, closeTo(2 / 14, 0.001));
  });

  test('import conflict can merge days and rename incoming habit', () async {
    final local = habit('a', 'Read', days: {'2026-09-01'});
    final repository = MemoryRepository([local]);
    final cubit = HabitsCubit(repository);
    await cubit.load();

    final exported = jsonEncode({
      'version': 1,
      'habits': [
        habit('a', 'Read', days: {'2026-09-02'}).toJson(),
      ],
    });
    final mergePlan = cubit.prepareImport(exported);
    expect(mergePlan.conflicts, hasLength(1));
    await cubit.applyImport(mergePlan, [
      ImportResolution(
        conflict: mergePlan.conflicts.single,
        choice: ImportChoice.merge,
      ),
    ]);
    expect(cubit.state.habits.single.completedDays, {
      '2026-09-01',
      '2026-09-02',
    });

    final renamePlan = cubit.prepareImport(exported);
    await cubit.applyImport(renamePlan, [
      ImportResolution(
        conflict: renamePlan.conflicts.single,
        choice: ImportChoice.rename,
        newName: 'Read books',
      ),
    ]);
    expect(cubit.state.habits, hasLength(2));
    expect(cubit.state.habits.last.name, 'Read books');
    expect(cubit.state.habits.last.id, isNot('a'));
  });

  test('archive and restore keep completion history', () async {
    final repository = MemoryRepository([
      habit('a', 'Read', days: {'2026-09-01'}),
    ]);
    final cubit = HabitsCubit(repository);
    await cubit.load();

    await cubit.archive('a');
    expect(cubit.state.active, isEmpty);
    expect(cubit.state.archived.single.isArchived, isTrue);

    await cubit.restore('a');
    expect(cubit.state.active.single.completedDays, {'2026-09-01'});
    expect(cubit.state.active.single.isArchived, isFalse);
  });
}
