import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracker/features/habits/data/habits_migrator.dart';
import 'package:time_tracker/features/habits/data/local_habits_repository.dart';
import 'package:time_tracker/features/habits/domain/habit.dart';
import 'package:time_tracker/features/habits/domain/habits_repository.dart';

class CloudRepository implements HabitsRepository {
  CloudRepository(this.items, {this.failSave = false});

  List<Habit> items;
  final bool failSave;
  int saves = 0;

  @override
  Future<List<Habit>> load() async => items;

  @override
  Future<void> save(List<Habit> habits) async {
    if (failSave) throw StateError('upload failed');
    saves++;
    items = habits;
  }
}

Habit _habit(String id, String name, Set<String> days) =>
    Habit(id: id, name: name, color: 1, icon: 2, completedDays: days);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('merges guest habits once and keeps cloud order', () async {
    final local = LocalHabitsRepository();
    await local.save([
      _habit('other-id', '  Morning   Walk ', {'2026-09-02'}),
      _habit('guest-only', 'Read', {'2026-09-03'}),
    ]);
    final cloud = CloudRepository([
      _habit('cloud-id', 'morning walk', {'2026-09-01'}),
      _habit('cloud-only', 'Stretch', {}),
    ]);
    final migrator = HabitsMigrator(local: local, cloudForUser: (_) => cloud);

    await migrator.migrateOnce('user-1');
    await migrator.migrateOnce('user-1');

    expect(cloud.saves, 1);
    expect(cloud.items.map((habit) => habit.id), [
      'cloud-id',
      'cloud-only',
      'guest-only',
    ]);
    expect(cloud.items.first.completedDays, {'2026-09-01', '2026-09-02'});
    expect(await local.load(), isEmpty);
  });

  test('does not clear guest data when upload fails', () async {
    final local = LocalHabitsRepository();
    await local.save([_habit('guest', 'Read', {})]);
    final cloud = CloudRepository([], failSave: true);
    final migrator = HabitsMigrator(local: local, cloudForUser: (_) => cloud);

    await expectLater(migrator.migrateOnce('user-1'), throwsStateError);

    expect(await local.load(), hasLength(1));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('habits_migrated_user-1'), isNot(true));
  });
}
