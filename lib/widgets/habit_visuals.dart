import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/habits/domain/entities/habit.dart';

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

IconData habitIcon(Habit habit) {
  return habitIconChoices.firstWhere(
    (icon) => icon.codePoint == habit.icon,
    orElse: () => Icons.check_circle_outline,
  );
}

Future<void> openHabitScreen(BuildContext context, String habitId) =>
    context.push('/habits/$habitId');

class HabitIcon extends StatelessWidget {
  const HabitIcon({super.key, required this.habit});
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

class HabitIconSmall extends StatelessWidget {
  const HabitIconSmall({super.key, required this.habit});
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
