import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../l10n/app_localizations.dart';
import '../widgets/habit_delete_dialog.dart';
import '../widgets/habit_visuals.dart';

const _tilePadding = EdgeInsets.symmetric(horizontal: 24);

class CompletedHabitsPage extends StatelessWidget {
  const CompletedHabitsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habits = context.watch<HabitsCubit>().state.archived;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.completedHabits)),
      body: habits.isEmpty
          ? Center(child: Text(l10n.noCompletedHabits))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return ListTile(
                  contentPadding: _tilePadding,
                  leading: HabitIconSmall(habit: habit),
                  title: Text(habit.name),
                  subtitle: Text(
                    l10n.completedOn(
                      '${habit.archivedAt?.toLocal().toString().split(' ').first}',
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () =>
                            context.read<HabitsCubit>().restore(habit.id),
                        child: Text(l10n.reactivate),
                      ),
                      IconButton(
                        tooltip: l10n.deleteHabit,
                        onPressed: () => confirmDeleteHabit(context, habit),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
