import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/date_labels.dart';
import '../features/habits/domain/entities/habit.dart';
import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../l10n/app_localizations.dart';
import '../widgets/habit_visuals.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.watch<HabitsCubit>();
    final data = cubit.dashboard();
    final progress = data.totalActive == 0
        ? 0.0
        : data.doneToday / data.totalActive;
    final maxWeek = data.weekCounts.fold<int>(1, math.max);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboard)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 9,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        Text(
                          '${data.doneToday}/${data.totalActive}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.today,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.openToday.isEmpty
                              ? l10n.allCaughtUp
                              : l10n.remainingTodayCount(data.openToday.length),
                        ),
                        if (data.atRisk.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.atRiskList(
                              data.atRisk.map((h) => h.name).join(', '),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_outlined,
                  label: l10n.streaks,
                  value: data.bestStreak == 0 ? '0' : '${data.bestStreak}',
                  caption: data.bestStreakHabit ?? l10n.startToday,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.insights_outlined,
                  label: l10n.thisWeek,
                  value: '${(data.weeklyRate * 100).round()}%',
                  caption: l10n.activeCompletedSummary(
                    data.totalActive,
                    data.archivedCount,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.thisWeek,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 92,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < data.weekDates.length; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: FractionallySizedBox(
                                      heightFactor:
                                          data.weekCounts[i] / maxWeek,
                                      widthFactor: 1,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color:
                                              dayKey(data.weekDates[i]) ==
                                                  dayKey(DateTime.now())
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: .35),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    shortWeekdayLabel(l10n, data.weekDates[i]),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (data.topStreaks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.streaks,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    for (final streak in data.topStreaks)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: HabitIconSmall(habit: streak.habit),
                        title: Text(streak.habit.name),
                        trailing: Text(
                          l10n.streakDays(streak.days),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.remainingToday,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  if (data.openToday.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(l10n.allCaughtUp),
                    )
                  else
                    for (final habit in data.openToday)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: HabitIconSmall(habit: habit),
                        title: Text(habit.name),
                        subtitle: Text(l10n.tapToComplete),
                        trailing: const Icon(Icons.circle_outlined),
                        onTap: () => cubit.toggleDay(habit.id, DateTime.now()),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(l10n.library),
              subtitle: Text(
                l10n.activeCompletedSummary(
                  data.totalActive,
                  data.archivedCount,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/completed-habits'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}
