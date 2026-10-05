import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/utils/date_labels.dart';
import '../features/habits/domain/entities/habit.dart';
import '../l10n/app_localizations.dart';
import 'habit_visuals.dart';

class HabitHeatmap extends StatelessWidget {
  const HabitHeatmap({
    super.key,
    required this.habit,
    required this.days,
    this.spacing = 4,
    this.showColumnDates = false,
    this.showWeekdays = false,
    this.onDayTap,
  });
  final Habit habit;
  final int days;
  final double spacing;
  final bool showColumnDates;
  final bool showWeekdays;
  final ValueChanged<DateTime>? onDayTap;

  static const _labelWidth = 26.0;

  @override
  Widget build(BuildContext context) {
    final color = habitColor(habit);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final columns = (days / 7).ceil();
    // With weekday labels each column is a Monday–Sunday week, so the grid is
    // anchored to the Monday of the current week.
    final start = showWeekdays
        ? today
              .subtract(Duration(days: today.weekday - 1))
              .subtract(Duration(days: (columns - 1) * 7))
        : today.subtract(Duration(days: days - 1));

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = showWeekdays
            ? constraints.maxWidth - _labelWidth
            : constraints.maxWidth;
        final byWidth = (gridWidth - spacing * (columns - 1)) / columns;
        final byHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight - spacing * 6) / 7
            : double.infinity;
        final cell = math.max(2.0, math.min(byWidth, byHeight));

        final grid = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: cell * 7 + spacing * 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var column = 0; column < columns; column++)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var row = 0; row < 7; row++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: row == 6 ? 0 : spacing,
                            ),
                            child: _cell(
                              column * 7 + row,
                              start,
                              today,
                              cell,
                              color,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            if (showColumnDates) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final date in [
                    for (var column = 0; column < columns; column++)
                      start.add(Duration(days: column * 7)),
                  ])
                    SizedBox(
                      width: cell,
                      child: _label(context, '${date.day}/${date.month}'),
                    ),
                ],
              ),
            ],
          ],
        );

        if (!showWeekdays) return grid;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var row = 0; row < 7; row++)
                  Container(
                    width: _labelWidth,
                    height: cell,
                    margin: EdgeInsets.only(bottom: row == 6 ? 0 : spacing),
                    alignment: Alignment.centerLeft,
                    child: _label(context, shortWeekdayLabels(l10n)[row]),
                  ),
              ],
            ),
            Expanded(child: grid),
          ],
        );
      },
    );
  }

  Widget _label(BuildContext context, String text) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );

  Widget _cell(
    int index,
    DateTime start,
    DateTime today,
    double cell,
    Color color,
  ) {
    final date = start.add(Duration(days: index));
    if ((!showWeekdays && index >= days) || date.isAfter(today)) {
      return SizedBox(width: cell, height: cell);
    }
    final done = habit.completedDays.contains(dayKey(date));
    return GestureDetector(
      onTap: onDayTap == null ? null : () => onDayTap!(date),
      child: Container(
        width: cell,
        height: cell,
        decoration: BoxDecoration(
          color: done ? color : color.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(cell < 10 ? 2 : 4),
        ),
      ),
    );
  }
}
