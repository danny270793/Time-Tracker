import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/habits/domain/entities/habit.dart';
import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../l10n/app_localizations.dart';
import 'habit_visuals.dart';
import 'sheet_header.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
              widget.habit == null ? l10n.newHabit : l10n.editHabit,
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
                  labelText: l10n.habitName,
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
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
