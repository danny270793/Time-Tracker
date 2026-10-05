import 'habit.dart';

class ImportConflict {
  const ImportConflict({required this.incoming, required this.existing});
  final Habit incoming;
  final Habit existing;
}

class ImportPlan {
  const ImportPlan({required this.newHabits, required this.conflicts});
  final List<Habit> newHabits;
  final List<ImportConflict> conflicts;
}

enum ImportChoice { merge, rename }

class ImportResolution {
  const ImportResolution({
    required this.conflict,
    required this.choice,
    this.newName,
  });
  final ImportConflict conflict;
  final ImportChoice choice;
  final String? newName;
}
