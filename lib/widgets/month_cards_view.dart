import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/utils/date_labels.dart';
import '../features/habits/domain/entities/habit.dart';
import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../l10n/app_localizations.dart';
import 'empty_habits.dart';
import 'habit_heatmap.dart';
import 'habit_visuals.dart';
import 'today_toggle.dart';

class MonthCardsView extends StatelessWidget {
  const MonthCardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsCubit>().state.active;
    if (habits.isEmpty) return const EmptyHabits();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10, 62, 10, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: .92,
      ),
      itemCount: habits.length,
      itemBuilder: (context, index) => _MonthCard(
        key: ValueKey(habits[index].id),
        habit: habits[index],
        index: index,
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({super.key, required this.habit, required this.index});
  final Habit habit;
  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final card = _card(context);
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) => details.data != index,
          onAcceptWithDetails: (details) => context.read<HabitsCubit>().reorder(
            details.data,
            details.data < index ? index + 1 : index,
          ),
          builder: (context, candidate, _) => LongPressDraggable<int>(
            data: index,
            feedback: Material(
              type: MaterialType.transparency,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: card,
              ),
            ),
            childWhenDragging: Opacity(opacity: .3, child: card),
            child: AnimatedScale(
              scale: candidate.isEmpty ? 1 : 1.05,
              duration: const Duration(milliseconds: 150),
              child: card,
            ),
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context) {
    final now = DateTime.now();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openHabitScreen(context, habit.id),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: .5),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  TodayToggle(habit: habit, size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${shortMonthLabel(AppLocalizations.of(context)!, now)} ${now.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: IgnorePointer(
                  child: HabitHeatmap(
                    habit: habit,
                    days: DateTime(now.year, now.month + 1, 0).day,
                    spacing: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
