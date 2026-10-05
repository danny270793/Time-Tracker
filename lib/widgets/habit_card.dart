import 'package:flutter/material.dart';

import '../features/habits/domain/entities/habit.dart';
import '../l10n/app_localizations.dart';
import 'habit_heatmap.dart';
import 'habit_visuals.dart';
import 'today_toggle.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final color = habitColor(habit);
    final l10n = AppLocalizations.of(context)!;
    final complete = habit.completedDays.contains(dayKey(DateTime.now()));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openHabitScreen(context, habit.id),
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                color.withValues(alpha: .07),
                Theme.of(context).colorScheme.surface,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant
                    .withValues(alpha: .5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    HabitIcon(habit: habit),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            complete ? l10n.doneToday : l10n.pendingToday,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: complete
                                      ? color
                                      : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    TodayToggle(
                      key: ValueKey('today-${habit.id}'),
                      habit: habit,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                IgnorePointer(child: HabitHeatmap(habit: habit, days: 126)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
