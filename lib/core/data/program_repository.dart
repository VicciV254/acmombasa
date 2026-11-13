import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../domain/models.dart';
import '../utils/id_generator.dart';

class ProgramRepository {
  ProgramRepository(this._db);

  final AppDatabase _db;

  /// Starter schedule so a fresh install isn't empty. Editing programs will
  /// come with the Programs & Activities module.
  Future<void> seedIfEmpty() async {
    final existing = await (_db.select(_db.programs)..limit(1)).get();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    const seeds = <(String, String, int?, int?, String?)>[
      ('English Conversation', 'Room A', 600, 720, null),
      ('Research & Study', 'Quiet Zone & e-Library', null, null, null),
      ('American Culture Activities', 'Main Hall', 840, 930, null),
      ('English Lessons & TOEFL Prep', 'Lab 2', 930, 1020, 'Audio workstations ready'),
      ('Games Corner & Makerspace', 'Creative Lounge', 1080, 1200, '3D Printing & Board Games'),
    ];

    await _db.batch((batch) {
      for (var i = 0; i < seeds.length; i++) {
        final s = seeds[i];
        batch.insert(
          _db.programs,
          ProgramsCompanion.insert(
            id: newId(),
            name: s.$1,
            location: s.$2,
            updatedAt: now,
            startMinute: Value(s.$3),
            endMinute: Value(s.$4),
            note: Value(s.$5),
            sortOrder: Value(i),
          ),
        );
      }
    });
  }

  Future<List<Program>> activePrograms() {
    return (_db.select(_db.programs)
          ..where((p) => p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .get();
  }

  Future<List<PurposeOption>> purposeOptions() async {
    final programs = await activePrograms();
    return [
      for (final p in programs) PurposeOption(label: p.name, programId: p.id),
      PurposeOption.general,
    ];
  }

  Future<List<ActivityView>> todaysActivities() async {
    final now = DateTime.now();
    final minute = now.hour * 60 + now.minute;
    final programs = await activePrograms();

    final visits = await (_db.select(_db.visits)
          ..where((v) =>
              v.checkInAt.isBiggerOrEqualValue(startOfDay(now)) &
              v.programId.isNotNull()))
        .get();
    final counts = <String, int>{};
    for (final v in visits) {
      counts.update(v.programId!, (c) => c + 1, ifAbsent: () => 1);
    }

    final views = [
      for (final p in programs)
        ActivityView(
          program: p,
          attendees: counts[p.id] ?? 0,
          isLive: p.startMinute != null &&
              p.endMinute != null &&
              minute >= p.startMinute! &&
              minute < p.endMinute!,
        ),
    ];

    // All-day programs first, then by start time.
    views.sort((a, b) {
      final sa = a.program.startMinute ?? -1;
      final sb = b.program.startMinute ?? -1;
      final byTime = sa.compareTo(sb);
      return byTime != 0
          ? byTime
          : a.program.sortOrder.compareTo(b.program.sortOrder);
    });
    return views;
  }
}
