import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/habit.dart';
import '../domain/habits_repository.dart';

class HabitsState {
  const HabitsState({this.habits = const [], this.loading = true, this.error});

  final List<Habit> habits;
  final bool loading;
  final String? error;

  List<Habit> get active => habits.where((habit) => !habit.isArchived).toList();
  List<Habit> get archived =>
      habits.where((habit) => habit.isArchived).toList();
}

class ImportConflict {
  const ImportConflict({required this.incoming, required this.existing});
  final Habit incoming;
  final Habit existing;
}

class ImportPlan {
  const ImportPlan({required this.newHabits, required this.conflicts});
  final List<Habit> newHabits;
  final List<ImportConflict> conflicts;
}

enum ImportChoice { merge, rename }

class ImportResolution {
  const ImportResolution({
    required this.conflict,
    required this.choice,
    this.newName,
  });
  final ImportConflict conflict;
  final ImportChoice choice;
  final String? newName;
}

class HabitsCubit extends Cubit<HabitsState> {
  HabitsCubit(this._repository) : super(const HabitsState());

  final HabitsRepository _repository;

  Future<void> load() async {
    try {
      emit(HabitsState(habits: await _repository.load(), loading: false));
    } catch (error) {
      emit(HabitsState(loading: false, error: error.toString()));
    }
  }

  Future<void> _commit(List<Habit> habits) async {
    emit(HabitsState(habits: habits, loading: false));
    await _repository.save(habits);
  }

  Future<void> add({
    required String name,
    required int color,
    required int icon,
  }) async {
    final habit = Habit(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      color: color,
      icon: icon,
      completedDays: {},
    );
    await _commit([...state.habits, habit]);
  }

  Future<void> toggleDay(String id, DateTime date) async {
    final key = dayKey(date);
    final updated = state.habits.map((habit) {
      if (habit.id != id) return habit;
      final days = {...habit.completedDays};
      days.contains(key) ? days.remove(key) : days.add(key);
      return habit.copyWith(completedDays: days);
    }).toList();
    await _commit(updated);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final active = state.active;
    if (oldIndex < newIndex) newIndex--;
    final moved = active.removeAt(oldIndex);
    active.insert(newIndex, moved);
    await _commit([...active, ...state.archived]);
  }

  Future<void> archive(String id) async {
    await _commit(
      state.habits
          .map(
            (habit) => habit.id == id
                ? habit.copyWith(archivedAt: DateTime.now())
                : habit,
          )
          .toList(),
    );
  }

  Future<void> restore(String id) async {
    final restored = state.habits
        .firstWhere((habit) => habit.id == id)
        .copyWith(clearArchive: true);
    await _commit([
      ...state.active,
      restored,
      ...state.archived.where((habit) => habit.id != id),
    ]);
  }

  HabitDashboard dashboard([DateTime? now]) =>
      BuildHabitDashboard()(state.habits, now ?? DateTime.now());

  String exportJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'habits': [
        for (var i = 0; i < state.habits.length; i++)
          {...state.habits[i].toJson(), 'sortIndex': i},
      ],
    });
  }

  ImportPlan prepareImport(String raw) {
    final root = jsonDecode(raw) as Map<String, dynamic>;
    if (root['version'] != 1 || root['habits'] is! List) {
      throw const FormatException('Unsupported habit export');
    }
    final incoming = (root['habits'] as List<dynamic>)
        .map((item) => Habit.fromJson(item as Map<String, dynamic>))
        .toList();
    final additions = <Habit>[];
    final conflicts = <ImportConflict>[];
    for (final candidate in incoming) {
      Habit? existing;
      for (final local in state.habits) {
        if (local.id == candidate.id ||
            local.name.trim().toLowerCase() ==
                candidate.name.trim().toLowerCase()) {
          existing = local;
          break;
        }
      }
      if (existing == null) {
        additions.add(candidate);
      } else {
        conflicts.add(ImportConflict(incoming: candidate, existing: existing));
      }
    }
    return ImportPlan(newHabits: additions, conflicts: conflicts);
  }

  Future<void> applyImport(
    ImportPlan plan,
    List<ImportResolution> resolutions,
  ) async {
    final result = [...state.habits, ...plan.newHabits];
    for (final resolution in resolutions) {
      if (resolution.choice == ImportChoice.merge) {
        final index = result.indexWhere(
          (habit) => habit.id == resolution.conflict.existing.id,
        );
        final existing = result[index];
        result[index] = existing.copyWith(
          completedDays: {
            ...existing.completedDays,
            ...resolution.conflict.incoming.completedDays,
          },
        );
      } else {
        result.add(
          resolution.conflict.incoming.copyWith(
            id: '${DateTime.now().microsecondsSinceEpoch}-${result.length}',
            name: resolution.newName?.trim().isNotEmpty == true
                ? resolution.newName!.trim()
                : '${resolution.conflict.incoming.name} imported',
          ),
        );
      }
    }
    await _commit(result);
  }
}
