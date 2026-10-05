import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/habits/domain/entities/habit.dart';
import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../l10n/app_localizations.dart';
import '../widgets/habit_delete_dialog.dart';
import '../widgets/habit_editor_sheet.dart';
import '../widgets/habit_heatmap.dart';
import '../widgets/habit_visuals.dart';

class HabitDetailPage extends StatelessWidget {
  const HabitDetailPage({super.key, required this.habitId});
  final String habitId;

  int _streak(Habit habit) {
    var streak = 0;
    var cursor = DateTime.now();
    while (habit.completedDays.contains(dayKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<void> _markOtherDay(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<HabitsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today.subtract(const Duration(days: 730)),
      lastDate: today,
      helpText: l10n.pickDay,
    );
    if (date == null) return;
    final wasDone = cubit.state.habits
        .firstWhere((habit) => habit.id == id)
        .completedDays
        .contains(dayKey(date));
    await cubit.toggleDay(id, date);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          wasDone
              ? l10n.dayUnmarked('${date.day}/${date.month}')
              : l10n.dayMarked('${date.day}/${date.month}'),
        ),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => cubit.toggleDay(id, date),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.watch<HabitsCubit>();
    Habit? habit;
    for (final item in cubit.state.habits) {
      if (item.id == habitId) habit = item;
    }
    if (habit == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('')),
      );
    }
    final complete = habit.completedDays.contains(dayKey(DateTime.now()));
    final color = habitColor(habit);
    final editable = habit;
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editHabit,
            onPressed: () => openHabitEditor(context, habit: editable),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.deleteHabit,
            onPressed: () async {
              final deleted = await confirmDeleteHabit(context, editable);
              if (deleted && context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              HabitIcon(habit: habit),
              const SizedBox(width: 14),
              Text(
                complete ? l10n.doneToday : l10n.pendingToday,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: complete
                      ? color
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          HabitHeatmap(
            habit: habit,
            days: 70,
            spacing: 5,
            showColumnDates: true,
            showWeekdays: true,
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.local_fire_department_outlined),
            title: Text(l10n.currentStreak),
            trailing: Text(l10n.streakDays(_streak(habit))),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(l10n.totalCheckIns),
            trailing: Text('${habit.completedDays.length}'),
          ),
          const SizedBox(height: 16),
          if (!habit.isArchived)
            TextButton(
              onPressed: () async {
                await cubit.archive(habit!.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(l10n.markComplete),
            )
          else
            FilledButton(
              onPressed: () async {
                await cubit.restore(habit!.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(l10n.reactivate),
            ),
        ],
      ),
      bottomNavigationBar: habit.isArchived
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: complete
                        ? OutlinedButton.icon(
                            onPressed: () =>
                                cubit.toggleDay(habitId, DateTime.now()),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              foregroundColor: color,
                              side: BorderSide(
                                color: color.withValues(alpha: .5),
                              ),
                            ),
                            icon: const Icon(Icons.undo_rounded),
                            label: Text(l10n.undoToday),
                          )
                        : FilledButton.icon(
                            onPressed: () =>
                                cubit.toggleDay(habitId, DateTime.now()),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.check_rounded),
                            label: Text(l10n.markToday),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _markOtherDay(context, habitId),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.event_outlined),
                      label: Text(l10n.markOtherDay),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
