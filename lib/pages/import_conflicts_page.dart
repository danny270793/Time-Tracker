import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/habits/domain/entities/habit_import.dart';
import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.importConflicts)),
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
                          title: Text(l10n.importMerge),
                        ),
                        RadioListTile<ImportChoice>(
                          value: ImportChoice.rename,
                          title: Text(l10n.importRename),
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
          child: Text(l10n.importApply),
        ),
      ),
    );
  }
}
