import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/utils/date_labels.dart';
import '../features/habits/domain/entities/habit.dart';
import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../l10n/app_localizations.dart';
import 'empty_habits.dart';
import 'habit_visuals.dart';
import 'sheet_header.dart';

class FiveDayView extends StatefulWidget {
  const FiveDayView({super.key});

  @override
  State<FiveDayView> createState() => _FiveDayViewState();
}

class _FiveDayViewState extends State<FiveDayView> {
  int _days = 7;

  String _rangeLabel(AppLocalizations l10n) => switch (_days) {
    7 => l10n.last7Days,
    30 => l10n.last30Days,
    _ => l10n.last3Months,
  };

  Future<void> _pickRange() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(l10n.rangeTitle),
            for (final option in const [7, 30, 90])
              ListTile(
                title: Text(switch (option) {
                  7 => l10n.last7Days,
                  30 => l10n.last30Days,
                  _ => l10n.last3Months,
                }),
                trailing: _days == option ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _days = option);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habits = context.watch<HabitsCubit>().state.active;
    final today = DateTime.now();
    final dates = List.generate(
      _days,
      (index) => today.subtract(Duration(days: _days - 1 - index)),
    );
    const labelWidth = 168.0;
    const cellWidth = 36.0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 62, 10, 110),
      children: [
        Row(
          children: [
            ActionChip(
              avatar: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text(_rangeLabel(l10n)),
              onPressed: _pickRange,
            ),
            const Spacer(),
            Text(
              '${shortMonthLabel(l10n, dates.first)} ${dates.first.day} — '
              '${shortMonthLabel(l10n, dates.last)} ${dates.last.day}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (habits.isEmpty)
          const EmptyHabits()
        else
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 16 + labelWidth + dates.length * cellWidth + 8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: labelWidth,
                            child: Text(
                              l10n.habitsCount(habits.length),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                          for (final date in dates)
                            SizedBox(
                              width: cellWidth,
                              child: Column(
                                children: [
                                  Text(shortWeekdayLabel(l10n, date)),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontWeight: dayKey(date) == dayKey(today)
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      height: math.max(1, habits.length) * 64,
                      child: ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: habits.length,
                        onReorderItem: (oldIndex, newIndex) =>
                            context.read<HabitsCubit>().reorder(
                              oldIndex,
                              oldIndex < newIndex ? newIndex + 1 : newIndex,
                            ),
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(habit.id),
                            index: index,
                            child: SizedBox(
                              height: 64,
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  InkWell(
                                    onTap: () =>
                                        openHabitScreen(context, habit.id),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Row(
                                      children: [
                                        HabitIconSmall(habit: habit),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: labelWidth - 52,
                                          child: Text(
                                            habit.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  for (final date in dates)
                                    SizedBox(
                                      width: cellWidth,
                                      child: GestureDetector(
                                        onTap: () => context
                                            .read<HabitsCubit>()
                                            .toggleDay(habit.id, date),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color:
                                                    habit.completedDays
                                                        .contains(dayKey(date))
                                                    ? habitColor(habit)
                                                    : habitColor(
                                                        habit,
                                                      ).withValues(alpha: .09),
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
