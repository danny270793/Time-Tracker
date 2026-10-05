import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/habits/presentation/cubit/habits_cubit.dart';
import 'empty_habits.dart';
import 'habit_card.dart';

class YearHeatmapView extends StatelessWidget {
  const YearHeatmapView({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsCubit>().state.active;
    if (habits.isEmpty) return const EmptyHabits();
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
