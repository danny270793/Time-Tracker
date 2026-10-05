import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/habits/domain/entities/habit.dart';
import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../l10n/app_localizations.dart';
import 'habit_visuals.dart';

class TodayToggle extends StatelessWidget {
  const TodayToggle({super.key, required this.habit, this.size = 56});
  final Habit habit;
  final double size;

  Future<void> _toggle(BuildContext context, bool done) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<HabitsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    await cubit.toggleDay(habit.id, DateTime.now());
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(done ? l10n.todayUnmarked : l10n.todayMarked),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => cubit.toggleDay(habit.id, DateTime.now()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = habitColor(habit);
    final done = habit.completedDays.contains(dayKey(DateTime.now()));
    final radius = BorderRadius.circular(size / 3);
    return Tooltip(
      message: done ? l10n.undoToday : l10n.markToday,
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
