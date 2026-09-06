import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_preferences.dart';
import '../../auth/session_controller.dart';
import '../domain/habit.dart';
import 'habits_cubit.dart';

const habitPalette = [
  Color(0xFFF0B90B),
  Color(0xFFF59E42),
  Color(0xFFFF7A45),
  Color(0xFFEF4A4A),
  Color(0xFFE0245E),
  Color(0xFFEC6EA5),
  Color(0xFFD946EF),
  Color(0xFFA855F7),
  Color(0xFF8B5CF6),
  Color(0xFF6366F1),
  Color(0xFF3E8EF7),
  Color(0xFF0EA5E9),
  Color(0xFF06B6D4),
  Color(0xFF13A8A8),
  Color(0xFF10B981),
  Color(0xFF32B67A),
  Color(0xFF65A30D),
  Color(0xFF84CC16),
  Color(0xFF8D6E63),
  Color(0xFF64748B),
];

const habitIconChoices = [
  Icons.bed_outlined,
  Icons.fitness_center,
  Icons.local_drink_outlined,
  Icons.menu_book_outlined,
  Icons.directions_run,
  Icons.self_improvement,
  Icons.water_drop_outlined,
  Icons.restaurant_outlined,
  Icons.music_note_outlined,
  Icons.work_outline,
  Icons.pets_outlined,
  Icons.school_outlined,
];

Color habitColor(Habit habit) => Color(habit.color);

Future<void> openHabitScreen(BuildContext context, String habitId) {
  return Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: context.read<HabitsCubit>(),
        child: HabitDetailPage(habitId: habitId),
      ),
    ),
  );
}

IconData habitIcon(Habit habit) {
  return habitIconChoices.firstWhere(
    (icon) => icon.codePoint == habit.icon,
    orElse: () => Icons.check_circle_outline,
  );
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.preferences,
    this.sessionController,
  });
  final AppPreferences preferences;
  final SessionController? sessionController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _view = 0;

  Future<void> _showCreate() => openHabitEditor(context);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<HabitsCubit, HabitsState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return IndexedStack(
                  index: _view,
                  children: const [
                    YearHeatmapView(),
                    FiveDayView(),
                    MonthCardsView(),
                  ],
                );
              },
            ),
            Positioned(
              top: 8,
              right: 12,
              child: Material(
                elevation: 16,
                shadowColor: Colors.black.withValues(alpha: 0.35),
                color: Theme.of(context).colorScheme.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: PopupMenuButton<_HomeMenuAction>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                    onSelected: (action) {
                      switch (action) {
                        case _HomeMenuAction.dashboard:
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<HabitsCubit>(),
                                child: const DashboardPage(),
                              ),
                            ),
                          );
                        case _HomeMenuAction.settings:
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<HabitsCubit>(),
                                child: SettingsPage(
                                  preferences: widget.preferences,
                                  sessionController: widget.sessionController,
                                ),
                              ),
                            ),
                          );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _HomeMenuAction.dashboard,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.query_stats_outlined),
                          title: Text(strings.dashboard),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: _HomeMenuAction.settings,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.settings_outlined),
                          title: Text(strings.settings),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ViewSwitcher(
                      selected: _view,
                      onSelected: (value) => setState(() => _view = value),
                    ),
                    const SizedBox(width: 10),
                    _RoundButton(
                      icon: Icons.add_rounded,
                      foreground: Colors.white,
                      background: const Color(0xFF5B52ED),
                      tooltip: strings.newHabit,
                      onTap: _showCreate,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _HomeMenuAction { dashboard, settings }

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.foreground,
    this.background,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      color: background ?? Theme.of(context).colorScheme.surfaceContainer,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(icon, color: foreground),
        ),
      ),
    ),
  );
}

class ViewSwitcher extends StatelessWidget {
  const ViewSwitcher({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 16,
    shadowColor: Colors.black.withValues(alpha: 0.35),
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(32),
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(context, 0, Icons.grid_view_rounded),
          _item(context, 1, Icons.checklist_rounded),
          _item(context, 2, Icons.view_week_outlined),
        ],
      ),
    ),
  );

  Widget _item(BuildContext context, int index, IconData icon) => InkWell(
    borderRadius: BorderRadius.circular(28),
    onTap: () => onSelected(index),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 54,
      height: 50,
      decoration: BoxDecoration(
        color: selected == index
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon),
    ),
  );
}

class YearHeatmapView extends StatelessWidget {
  const YearHeatmapView({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsCubit>().state.active;
    if (habits.isEmpty) return const _EmptyHabits();
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 62, 10, 110),
      buildDefaultDragHandles: false,
      itemCount: habits.length,
      onReorderItem: (oldIndex, newIndex) => context
          .read<HabitsCubit>()
          .reorder(oldIndex, oldIndex < newIndex ? newIndex + 1 : newIndex),
      itemBuilder: (context, index) => ReorderableDelayedDragStartListener(
        key: ValueKey(habits[index].id),
        index: index,
        child: HabitCard(habit: habits[index]),
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final color = habitColor(habit);
    final strings = AppStrings.of(context);
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
                    _HabitIcon(habit: habit),
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
                            complete ? strings.doneToday : strings.pendingToday,
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

class _HabitIcon extends StatelessWidget {
  const _HabitIcon({required this.habit});
  final Habit habit;
  @override
  Widget build(BuildContext context) {
    final color = habitColor(habit);
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(habitIcon(habit), color: color),
    );
  }
}

class TodayToggle extends StatelessWidget {
  const TodayToggle({super.key, required this.habit, this.size = 56});
  final Habit habit;
  final double size;

  Future<void> _toggle(BuildContext context, bool done) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<HabitsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    await cubit.toggleDay(habit.id, DateTime.now());
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(done ? strings.todayUnmarked : strings.todayMarked),
        action: SnackBarAction(
          label: strings.undo,
          onPressed: () => cubit.toggleDay(habit.id, DateTime.now()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final color = habitColor(habit);
    final done = habit.completedDays.contains(dayKey(DateTime.now()));
    final radius = BorderRadius.circular(size / 3);
    return Tooltip(
      message: done ? strings.undoToday : strings.markToday,
      child: Material(
        color: done ? color : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => _toggle(context, done),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: done
                  ? null
                  : Border.all(
                      color: color.withValues(alpha: .45),
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
            ),
            child: Icon(
              done ? Icons.undo_rounded : Icons.check_rounded,
              size: size * .45,
              color: done ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

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
    final strings = AppStrings.of(context);
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
                    child: _label(context, strings.weekdaysShort[row]),
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

class FiveDayView extends StatefulWidget {
  const FiveDayView({super.key});

  @override
  State<FiveDayView> createState() => _FiveDayViewState();
}

class _FiveDayViewState extends State<FiveDayView> {
  int _days = 7;

  String _rangeLabel(AppStrings strings) => switch (_days) {
    7 => strings.last7Days,
    30 => strings.last30Days,
    _ => strings.last3Months,
  };

  Future<void> _pickRange() async {
    final strings = AppStrings.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(strings.rangeTitle),
            for (final option in const [7, 30, 90])
              ListTile(
                title: Text(switch (option) {
                  7 => strings.last7Days,
                  30 => strings.last30Days,
                  _ => strings.last3Months,
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
    final strings = AppStrings.of(context);
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
              label: Text(_rangeLabel(strings)),
              onPressed: _pickRange,
            ),
            const Spacer(),
            Text(
              '${_month(dates.first, strings.es)} ${dates.first.day} — '
              '${_month(dates.last, strings.es)} ${dates.last.day}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (habits.isEmpty)
          const _EmptyHabits()
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
                              '${habits.length} ${strings.habits.toLowerCase()}',
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
                                  Text(_weekday(date, strings.es)),
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
                                        _HabitIconSmall(habit: habit),
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

class _HabitIconSmall extends StatelessWidget {
  const _HabitIconSmall({required this.habit});
  final Habit habit;
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: habitColor(habit).withValues(alpha: .13),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Icon(habitIcon(habit), color: habitColor(habit), size: 21),
  );
}

class MonthCardsView extends StatelessWidget {
  const MonthCardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsCubit>().state.active;
    if (habits.isEmpty) return const _EmptyHabits();
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
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
                          '${_month(now, AppStrings.of(context).es)} ${now.year}',
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

class _EmptyHabits extends StatelessWidget {
  const _EmptyHabits();
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      AppStrings.of(context).es
          ? 'Crea tu primer hábito'
          : 'Create your first habit',
    ),
  );
}

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
    final strings = AppStrings.of(context);
    final cubit = context.read<HabitsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today.subtract(const Duration(days: 730)),
      lastDate: today,
      helpText: strings.pickDay,
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
          '${date.day}/${date.month} '
          '${wasDone ? strings.unmarkedWord : strings.markedWord}',
        ),
        action: SnackBarAction(
          label: strings.undo,
          onPressed: () => cubit.toggleDay(id, date),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
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
            tooltip: strings.editHabit,
            onPressed: () => openHabitEditor(context, habit: editable),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              _HabitIcon(habit: habit),
              const SizedBox(width: 14),
              Text(
                complete ? strings.doneToday : strings.pendingToday,
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
            title: Text(strings.currentStreak),
            trailing: Text('${_streak(habit)} ${strings.daysWord}'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(strings.totalCheckIns),
            trailing: Text('${habit.completedDays.length}'),
          ),
          const SizedBox(height: 16),
          if (!habit.isArchived)
            TextButton(
              onPressed: () async {
                await cubit.archive(habit!.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(strings.markComplete),
            )
          else
            FilledButton(
              onPressed: () async {
                await cubit.restore(habit!.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(strings.reactivate),
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
                            label: Text(strings.undoToday),
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
                            label: Text(strings.markToday),
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
                      label: Text(strings.markOtherDay),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

Future<void> openHabitEditor(BuildContext context, {Habit? habit}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<HabitsCubit>(),
      child: HabitEditorSheet(habit: habit),
    ),
  );
}

class HabitEditorSheet extends StatefulWidget {
  const HabitEditorSheet({super.key, this.habit});

  /// Creates a habit when null, otherwise edits [habit].
  final Habit? habit;

  @override
  State<HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends State<HabitEditorSheet> {
  final _name = TextEditingController();
  final _colors = habitPalette;
  final _icons = habitIconChoices;
  int _color = 0;
  int _icon = 0;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    if (habit == null) return;
    _name.text = habit.name;
    final color = _colors.indexWhere((item) => item.toARGB32() == habit.color);
    if (color != -1) _color = color;
    final icon = _icons.indexWhere((item) => item.codePoint == habit.icon);
    if (icon != -1) _icon = icon;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final cubit = context.read<HabitsCubit>();
    final habit = widget.habit;
    final color = _colors[_color].toARGB32();
    final icon = _icons[_icon].codePoint;
    if (habit == null) {
      cubit.add(name: _name.text, color: color, icon: icon);
    } else {
      cubit.edit(id: habit.id, name: _name.text, color: color, icon: icon);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    const gutter = EdgeInsets.symmetric(horizontal: 22);
    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(
              widget.habit == null ? strings.newHabit : strings.editHabit,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: gutter,
              child: TextField(
                key: const ValueKey('habit-name'),
                controller: _name,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: strings.habitName,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: gutter,
                itemCount: _colors.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) => InkWell(
                  onTap: () => setState(() => _color = i),
                  customBorder: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: _colors[i],
                    child: _color == i
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: gutter,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 9,
                runSpacing: 9,
                children: [
                  for (var i = 0; i < _icons.length; i++)
                    InkWell(
                      onTap: () => setState(() => _icon = i),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _icon == i
                              ? _colors[_color].withValues(alpha: .2)
                              : Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_icons[i], color: _colors[_color]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: gutter,
              child: FilledButton(
                key: const ValueKey('save-habit'),
                onPressed: _name.text.trim().isEmpty ? null : _save,
                child: Text(strings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.watch<HabitsCubit>();
    final data = cubit.dashboard();
    final progress = data.totalActive == 0
        ? 0.0
        : data.doneToday / data.totalActive;
    final maxWeek = data.weekCounts.fold<int>(1, math.max);
    return Scaffold(
      appBar: AppBar(title: Text(strings.dashboard)),
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
                          strings.today,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.openToday.isEmpty
                              ? strings.allCaughtUp
                              : '${data.openToday.length} ${strings.remainingToday.toLowerCase()}',
                        ),
                        if (data.atRisk.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${strings.atRisk}: ${data.atRisk.map((h) => h.name).join(', ')}',
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
                  label: strings.streaks,
                  value: data.bestStreak == 0 ? '0' : '${data.bestStreak}',
                  caption: data.bestStreakHabit ?? strings.startToday,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.insights_outlined,
                  label: strings.thisWeek,
                  value: '${(data.weeklyRate * 100).round()}%',
                  caption:
                      '${data.totalActive} ${strings.activeWord} · ${data.archivedCount} ${strings.completedWord}',
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
                    strings.thisWeek,
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
                                    _weekday(data.weekDates[i], strings.es),
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
                      strings.streaks,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    for (final streak in data.topStreaks)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _HabitIconSmall(habit: streak.habit),
                        title: Text(streak.habit.name),
                        trailing: Text(
                          '${streak.days} ${strings.daysWord}',
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
                    strings.remainingToday,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  if (data.openToday.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(strings.allCaughtUp),
                    )
                  else
                    for (final habit in data.openToday)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _HabitIconSmall(habit: habit),
                        title: Text(habit.name),
                        subtitle: Text(strings.tapToComplete),
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
              title: Text(strings.library),
              subtitle: Text(
                '${data.totalActive} ${strings.activeWord} · ${data.archivedCount} ${strings.completedWord}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const CompletedHabitsPage(),
                  ),
                ),
              ),
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

class SheetHeader extends StatelessWidget {
  const SheetHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const BackButtonIcon(),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        // Balances the leading icon button so the title stays centered.
        const SizedBox(width: 48),
      ],
    ),
  );
}

const _tilePadding = EdgeInsets.symmetric(horizontal: 20);

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.preferences,
    this.sessionController,
  });
  final AppPreferences preferences;
  final SessionController? sessionController;

  Future<void> _export(BuildContext context) async {
    final json = context.read<HabitsCubit>().exportJson();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/habits-export.json');
    await file.writeAsString(json);
    if (context.mounted) {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], title: 'Habit tracker export'),
      );
    }
  }

  Future<void> _import(BuildContext context) async {
    final cubit = context.read<HabitsCubit>();
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (picked == null || !context.mounted) return;
    try {
      final raw = String.fromCharCodes(await picked.readAsBytes());
      final plan = cubit.prepareImport(raw);
      if (plan.conflicts.isEmpty) {
        await cubit.applyImport(plan, const []);
      } else if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: ImportConflictsPage(plan: plan),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.of(context).es
                  ? 'El archivo no es válido'
                  : 'The file is not valid',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final signedIn = sessionController?.status == SessionStatus.authenticated;
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          if (signedIn) ...[
            _SectionTitle(strings.es ? 'Cuenta' : 'Account'),
            ListTile(
              contentPadding: _tilePadding,
              leading: const Icon(Icons.email_outlined),
              title: Text(strings.es ? 'Cambiar correo' : 'Change email'),
              subtitle: Text(sessionController!.user?.email ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _changeCredential(context, email: true),
            ),
            ListTile(
              contentPadding: _tilePadding,
              leading: const Icon(Icons.password_outlined),
              title: Text(
                strings.es ? 'Cambiar contraseña' : 'Change password',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _changeCredential(context, email: false),
            ),
            SwitchListTile(
              contentPadding: _tilePadding,
              secondary: const Icon(Icons.fingerprint),
              title: Text(
                strings.es ? 'Face ID / biometría' : 'Face ID / biometrics',
              ),
              value: preferences.biometricLock,
              onChanged: (value) => _setBiometric(context, value),
            ),
            const Divider(height: 32, indent: 20, endIndent: 20),
          ],
          _SectionTitle(strings.appearance),
          ListTile(
            contentPadding: _tilePadding,
            leading: const Icon(Icons.language_outlined),
            title: Text(strings.language),
            subtitle: Text(_languageLabel(strings, preferences.language)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickLanguage(context),
          ),
          ListTile(
            contentPadding: _tilePadding,
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(strings.theme),
            subtitle: Text(_themeLabel(strings, preferences.theme)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickTheme(context),
          ),
          const Divider(height: 32, indent: 20, endIndent: 20),
          _SectionTitle(strings.habits),
          ListTile(
            contentPadding: _tilePadding,
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(strings.completed),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<HabitsCubit>(),
                  child: const CompletedHabitsPage(),
                ),
              ),
            ),
          ),
          // Signed-in habits live in Supabase, so the JSON backup is only
          // offered while the data is local to this device.
          if (!signedIn) ...[
            ListTile(
              contentPadding: _tilePadding,
              leading: const Icon(Icons.file_upload_outlined),
              title: Text(strings.exportJson),
              onTap: () => _export(context),
            ),
            ListTile(
              contentPadding: _tilePadding,
              leading: const Icon(Icons.file_download_outlined),
              title: Text(strings.importJson),
              onTap: () => _import(context),
            ),
          ],
          const Divider(height: 32, indent: 20, endIndent: 20),
          _SectionTitle(strings.about),
          _legalTile(context, LegalInfoKind.about, Icons.info_outline),
          _legalTile(
            context,
            LegalInfoKind.privacy,
            Icons.privacy_tip_outlined,
          ),
          _legalTile(context, LegalInfoKind.terms, Icons.description_outlined),
          if (sessionController != null) ...[
            const Divider(height: 32, indent: 20, endIndent: 20),
            ListTile(
              key: const ValueKey('session-action'),
              contentPadding: _tilePadding,
              leading: Icon(
                sessionController!.status == SessionStatus.authenticated
                    ? Icons.logout
                    : Icons.login,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                sessionController!.status == SessionStatus.authenticated
                    ? (strings.es ? 'Cerrar sesión' : 'Log out')
                    : (strings.es ? 'Iniciar sesión' : 'Sign in'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () async {
                await sessionController!.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _setBiometric(BuildContext context, bool enabled) async {
    if (!enabled) {
      await preferences.setBiometricLock(false);
      return;
    }
    try {
      final auth = LocalAuthentication();
      final supported =
          await auth.isDeviceSupported() && await auth.canCheckBiometrics;
      if (!supported) throw StateError('Biometrics are not available');
      final verified = await auth.authenticate(
        localizedReason: 'Enable biometric lock',
        biometricOnly: true,
      );
      if (verified) await preferences.setBiometricLock(true);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _changeCredential(
    BuildContext context, {
    required bool email,
  }) async {
    final strings = AppStrings.of(context);
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          email
              ? (strings.es ? 'Cambiar correo' : 'Change email')
              : (strings.es ? 'Cambiar contraseña' : 'Change password'),
        ),
        content: TextField(
          controller: controller,
          obscureText: !email,
          keyboardType: email
              ? TextInputType.emailAddress
              : TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: email
                ? (strings.es ? 'Nuevo correo' : 'New email')
                : (strings.es ? 'Nueva contraseña' : 'New password'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              MaterialLocalizations.of(dialogContext).cancelButtonLabel,
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(strings.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty) return;
    try {
      if (email) {
        await sessionController!.auth.updateEmail(value);
      } else {
        await sessionController!.auth.updatePassword(value);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.es ? 'Actualizado' : 'Updated')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(error.toString()),
          ),
        );
      }
    }
  }

  Widget _legalTile(BuildContext context, LegalInfoKind kind, IconData icon) {
    final strings = AppStrings.of(context);
    final title = switch (kind) {
      LegalInfoKind.about => strings.about,
      LegalInfoKind.privacy => strings.privacy,
      LegalInfoKind.terms => strings.terms,
    };
    return ListTile(
      contentPadding: _tilePadding,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => LegalInfoPage(kind: kind)),
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final strings = AppStrings.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(strings.language),
            for (final option in AppLanguage.values)
              ListTile(
                title: Text(_languageLabel(strings, option)),
                trailing: preferences.language == option
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await preferences.setLanguage(option);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTheme(BuildContext context) async {
    final strings = AppStrings.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(strings.theme),
            for (final option in AppThemePreference.values)
              ListTile(
                title: Text(_themeLabel(strings, option)),
                trailing: preferences.theme == option
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await preferences.setTheme(option);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

String _languageLabel(AppStrings s, AppLanguage value) => switch (value) {
  AppLanguage.system => s.system,
  AppLanguage.es => s.spanish,
  AppLanguage.en => s.english,
};
String _themeLabel(AppStrings s, AppThemePreference value) => switch (value) {
  AppThemePreference.system => s.system,
  AppThemePreference.light => s.light,
  AppThemePreference.dark => s.dark,
};

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class CompletedHabitsPage extends StatelessWidget {
  const CompletedHabitsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final habits = context.watch<HabitsCubit>().state.archived;
    return Scaffold(
      appBar: AppBar(title: Text(strings.completed)),
      body: habits.isEmpty
          ? Center(
              child: Text(
                strings.es ? 'Aún no hay hábitos' : 'No completed habits yet',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return ListTile(
                  contentPadding: _tilePadding,
                  leading: _HabitIconSmall(habit: habit),
                  title: Text(habit.name),
                  subtitle: Text(
                    '${strings.completed}: '
                    '${habit.archivedAt?.toLocal().toString().split(' ').first}',
                  ),
                  trailing: TextButton(
                    onPressed: () =>
                        context.read<HabitsCubit>().restore(habit.id),
                    child: Text(strings.reactivate),
                  ),
                );
              },
            ),
    );
  }
}

class ImportConflictsPage extends StatefulWidget {
  const ImportConflictsPage({super.key, required this.plan});
  final ImportPlan plan;
  @override
  State<ImportConflictsPage> createState() => _ImportConflictsPageState();
}

class _ImportConflictsPageState extends State<ImportConflictsPage> {
  late final List<ImportChoice> choices;
  late final List<TextEditingController> names;

  @override
  void initState() {
    super.initState();
    choices = List.filled(widget.plan.conflicts.length, ImportChoice.merge);
    names = [
      for (final conflict in widget.plan.conflicts)
        TextEditingController(text: '${conflict.incoming.name} imported'),
    ];
  }

  @override
  void dispose() {
    for (final controller in names) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.importConflicts)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.plan.conflicts.length,
        itemBuilder: (context, index) {
          final conflict = widget.plan.conflicts[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${conflict.incoming.name} ↔ ${conflict.existing.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  RadioGroup<ImportChoice>(
                    groupValue: choices[index],
                    onChanged: (value) =>
                        setState(() => choices[index] = value!),
                    child: Column(
                      children: [
                        RadioListTile<ImportChoice>(
                          value: ImportChoice.merge,
                          title: Text(strings.merge),
                        ),
                        RadioListTile<ImportChoice>(
                          value: ImportChoice.rename,
                          title: Text(strings.rename),
                        ),
                      ],
                    ),
                  ),
                  if (choices[index] == ImportChoice.rename)
                    TextField(controller: names[index]),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () async {
            await context.read<HabitsCubit>().applyImport(widget.plan, [
              for (var i = 0; i < widget.plan.conflicts.length; i++)
                ImportResolution(
                  conflict: widget.plan.conflicts[i],
                  choice: choices[i],
                  newName: names[i].text,
                ),
            ]);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(strings.apply),
        ),
      ),
    );
  }
}

enum LegalInfoKind { about, privacy, terms }

class LegalInfoPage extends StatelessWidget {
  const LegalInfoPage({super.key, required this.kind});
  final LegalInfoKind kind;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final title = switch (kind) {
      LegalInfoKind.about => strings.about,
      LegalInfoKind.privacy => strings.privacy,
      LegalInfoKind.terms => strings.terms,
    };
    final icon = switch (kind) {
      LegalInfoKind.about => Icons.auto_graph_rounded,
      LegalInfoKind.privacy => Icons.privacy_tip_outlined,
      LegalInfoKind.terms => Icons.article_outlined,
    };
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          CircleAvatar(radius: 38, child: Icon(icon, size: 38)),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _tagline(strings, kind),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (kind == LegalInfoKind.about) const _VersionLine(),
          const SizedBox(height: 30),
          for (final section in _sections(strings, kind))
            _PolicySection(
              title: section.$1,
              body: section.$2,
              callout: section.$3,
            ),
        ],
      ),
    );
  }

  String _tagline(AppStrings s, LegalInfoKind type) => switch (type) {
    LegalInfoKind.about =>
      s.es
          ? 'Hábitos y rachas en un lugar.'
          : 'Habits and streaks in one place.',
    LegalInfoKind.privacy =>
      s.es
          ? 'Cómo trata esta app tu información.'
          : 'How this app treats your information.',
    LegalInfoKind.terms =>
      s.es ? 'Reglas para usar esta app.' : 'Rules for using this app.',
  };

  List<(String, String, bool)> _sections(AppStrings s, LegalInfoKind type) =>
      switch (type) {
        LegalInfoKind.about => [
          (
            s.es ? 'Qué puedes hacer' : 'What you can do',
            s.es
                ? 'Crea hábitos, registra cada día, cambia de vista y reordena tu lista.'
                : 'Create habits, check in each day, switch views, and reorder your list.',
            false,
          ),
          (
            s.es ? 'Tus datos' : 'Your data',
            s.es
                ? 'Como invitado, tus hábitos se guardan en este dispositivo. Si inicias sesión, se sincronizan con Supabase. La cuenta es opcional.'
                : 'As a guest, your habits stay on this device. If you sign in, they sync with Supabase. An account is optional.',
            false,
          ),
        ],
        LegalInfoKind.privacy => [
          (
            s.es ? 'Cuenta (opcional)' : 'Account (optional)',
            s.es
                ? 'Puedes usar la app sin cuenta. Si inicias sesión, la autenticación la proporciona Supabase. Tu correo y credenciales los procesa Supabase; esta app no guarda tu contraseña.'
                : 'You can use the app without an account. If you sign in, authentication is provided by Supabase. Your email and credentials are processed by Supabase; this app does not store your password.',
            false,
          ),
          (
            s.es
                ? 'Qué guardamos hoy — y más adelante'
                : 'What we store today — and later',
            s.es
                ? 'Como invitado, tus hábitos se quedan en este dispositivo. Si has iniciado sesión, tus hábitos se guardan en Supabase ligados a tu cuenta. En el futuro también podremos guardar otra información generada por la app (por ejemplo favoritos) en Supabase cuando hayas iniciado sesión.'
                : 'As a guest, your habits stay on this device. If you are signed in, your habits are stored in Supabase and tied to your account. In the future we may also store other app-generated information (for example favorites) in Supabase when you are signed in.',
            false,
          ),
          (
            s.es ? 'Compartir y anuncios' : 'Sharing and ads',
            s.es
                ? 'No vendemos datos ni los usamos para anuncios. El inicio de sesión y, si aplica, la sincronización los procesa Supabase.'
                : 'We do not sell your data or use it for advertising. Sign-in and, when used, sync are processed by Supabase.',
            true,
          ),
        ],
        LegalInfoKind.terms => [
          (
            s.es ? 'Aceptación' : 'Acceptance',
            s.es
                ? 'Al usar Habit tracker aceptas estos términos. El inicio de sesión es opcional y lo gestiona Supabase.'
                : 'By using Habit tracker, you accept these terms. Sign-in is optional and is handled by Supabase.',
            false,
          ),
          (
            s.es ? 'Tus datos' : 'Your data',
            s.es
                ? 'Sin cuenta, los hábitos se quedan en el dispositivo. Con sesión iniciada se guardan en Supabase. Más adelante podremos sincronizar datos adicionales generados por la app.'
                : 'Without an account, habits stay on the device. When signed in they are stored in Supabase. Later we may sync additional app-generated data the same way.',
            false,
          ),
          (
            s.es ? 'No es consejo profesional' : 'Not professional advice',
            s.es
                ? 'La app no ofrece consejo médico ni profesional.'
                : 'The app does not provide medical or professional advice.',
            true,
          ),
          (
            s.es ? 'Responsabilidad' : 'Your responsibility',
            s.es
                ? 'Eres responsable de tu dispositivo, tu cuenta y tus copias exportadas.'
                : 'You are responsible for your device, your account, and exported backups.',
            false,
          ),
        ],
      };
}

class _VersionLine extends StatelessWidget {
  const _VersionLine();
  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
    future: PackageInfo.fromPlatform(),
    builder: (_, snapshot) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        snapshot.hasData
            ? 'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : 'Version…',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    required this.body,
    required this.callout,
  });
  final String title;
  final String body;
  final bool callout;
  @override
  Widget build(BuildContext context) {
    final content = SelectableText(
      body,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 9),
          if (callout)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: content),
                ],
              ),
            )
          else
            content,
        ],
      ),
    );
  }
}

String _month(DateTime value, bool es) {
  const en = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  const spanish = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];
  return (es ? spanish : en)[value.month - 1];
}

String _weekday(DateTime value, bool es) {
  const en = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  const spanish = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];
  return (es ? spanish : en)[value.weekday - 1];
}
