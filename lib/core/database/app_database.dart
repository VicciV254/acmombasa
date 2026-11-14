import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

/// Local SQLite database (Drift). The `.g.dart` part is generated; run
/// `dart run build_runner build` after adding the packages (see SETUP.md).
@DriftDatabase(tables: [StaffUsers, Visitors, Programs, ProgramRegistrations, Visits, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'american_corner'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(visitors, visitors.gender);
            await m.addColumn(visitors, visitors.ageBracket);
            await m.addColumn(visitors, visitors.residence);
            await m.addColumn(visitors, visitors.occupation);
            await m.addColumn(programs, programs.sessionDate);
            await m.addColumn(programs, programs.recurrence);
            await m.addColumn(programs, programs.pillar);
            await m.addColumn(programs, programs.format);
            await m.addColumn(programs, programs.capacity);
            await m.addColumn(programs, programs.facilitator);
            await m.addColumn(programs, programs.walkInsAllowed);
            await m.addColumn(programs, programs.audience);
            await m.addColumn(programs, programs.status);
            await m.createTable(programRegistrations);

            // Give the starter programs sensible pillars and mark them for sync.
            const pillars = {
              'English Conversation': 'English Language & Teaching',
              'English Lessons & TOEFL Prep': 'English Language & Teaching',
              'Research & Study': 'EducationUSA & Library',
              'American Culture Activities': 'Cultural Programs & Arts',
              'Games Corner & Makerspace': 'STEM & Makerspace Innovation',
            };
            for (final e in pillars.entries) {
              await (update(programs)..where((p) => p.name.equals(e.key))).write(
                ProgramsCompanion(
                  pillar: Value(e.value),
                  updatedAt: Value(DateTime.now()),
                  dirty: const Value(true),
                ),
              );
            }
            // Existing visitors gained new columns: push them again.
            await customStatement('UPDATE visitors SET dirty = 1');
          }
        },
      );
}
