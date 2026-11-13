import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../domain/app_exception.dart';
import '../domain/models.dart';
import '../utils/id_generator.dart';
import 'settings_repository.dart';

class VisitRepository {
  VisitRepository(this._db, this._settings);

  final AppDatabase _db;
  final SettingsRepository _settings;

  static const int workstationCount = 16;

  static String workstationLabel(int number) =>
      'PC-${number.toString().padLeft(2, '0')}';

  Future<Visit?> getById(String id) {
    return (_db.select(_db.visits)..where((v) => v.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Visit?> openVisitFor(String visitorId) {
    final start = startOfDay(DateTime.now());
    return (_db.select(_db.visits)
          ..where((v) =>
              v.visitorId.equals(visitorId) &
              v.checkOutAt.isNull() &
              v.checkInAt.isBiggerOrEqualValue(start))
          ..orderBy([(v) => OrderingTerm.desc(v.checkInAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<CheckInResult> checkIn({
    required Visitor visitor,
    required String staffId,
    required String purpose,
    String? programId,
    bool assignWorkstation = false,
  }) {
    return _db.transaction(() async {
      if (await openVisitFor(visitor.id) != null) {
        throw AppException('${visitor.fullName} is already checked in.');
      }

      String? workstation;
      var workstationFull = false;
      if (assignWorkstation) {
        workstation = await _nextFreeWorkstation();
        workstationFull = workstation == null;
      }

      final now = DateTime.now();
      final id = newId();
      await _db.into(_db.visits).insert(
            VisitsCompanion.insert(
              id: id,
              visitorId: visitor.id,
              purpose: purpose,
              checkInAt: now,
              staffId: staffId,
              updatedAt: now,
              programId: Value(programId),
              workstation: Value(workstation),
            ),
          );

      final visit = await (_db.select(_db.visits)..where((v) => v.id.equals(id)))
          .getSingle();
      return CheckInResult(visit: visit, workstationFull: workstationFull);
    });
  }

  Future<void> checkOut(String visitId) async {
    final visit = await getById(visitId);
    if (visit == null) throw const AppException('Visit not found.');
    if (visit.checkOutAt != null) return;

    final now = DateTime.now();
    await (_db.update(_db.visits)..where((v) => v.id.equals(visitId))).write(
      VisitsCompanion(
        checkOutAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  /// Checks a returning visitor back in with the same purpose as [previous].
  Future<CheckInResult> readmit({
    required Visit previous,
    required String staffId,
  }) async {
    final visitor = await (_db.select(_db.visitors)
          ..where((v) => v.id.equals(previous.visitorId)))
        .getSingleOrNull();
    if (visitor == null) throw const AppException('Visitor not found.');
    return checkIn(
      visitor: visitor,
      staffId: staffId,
      purpose: previous.purpose,
      programId: previous.programId,
      assignWorkstation: previous.workstation != null,
    );
  }

  /// Visits from earlier days that were never checked out are closed at the
  /// end of their own day so they don't count as "inside" forever.
  Future<void> closeStaleVisits() async {
    final start = startOfDay(DateTime.now());
    final stale = await (_db.select(_db.visits)
          ..where((v) =>
              v.checkOutAt.isNull() & v.checkInAt.isSmallerThanValue(start)))
        .get();
    if (stale.isEmpty) return;

    final now = DateTime.now();
    await _db.batch((batch) {
      for (final v in stale) {
        batch.update(
          _db.visits,
          VisitsCompanion(
            checkOutAt: Value(
              DateTime(v.checkInAt.year, v.checkInAt.month, v.checkInAt.day, 23, 59),
            ),
            updatedAt: Value(now),
            dirty: const Value(true),
          ),
          where: (t) => t.id.equals(v.id),
        );
      }
    });
  }

  Future<List<VisitLogEntry>> visitsOn(DateTime day) async {
    final start = startOfDay(day);
    final end = DateTime(day.year, day.month, day.day + 1);

    final query = _db.select(_db.visits).join([
      innerJoin(_db.visitors, _db.visitors.id.equalsExp(_db.visits.visitorId)),
    ])
      ..where(_db.visits.checkInAt.isBiggerOrEqualValue(start) &
          _db.visits.checkInAt.isSmallerThanValue(end))
      ..orderBy([OrderingTerm.desc(_db.visits.checkInAt)]);

    final rows = await query.get();
    return [
      for (final row in rows)
        VisitLogEntry(
          visit: row.readTable(_db.visits),
          visitor: row.readTable(_db.visitors),
        ),
    ];
  }

  Future<List<VisitLogEntry>> todayLog() => visitsOn(DateTime.now());

  Future<DashboardStats> loadStats() async {
    final now = DateTime.now();
    final today = startOfDay(now);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final weekAgo = DateTime(now.year, now.month, now.day - 7);

    final recent = await (_db.select(_db.visits)
          ..where((v) => v.checkInAt.isBiggerOrEqualValue(yesterday)))
        .get();
    final todays = recent.where((v) => !v.checkInAt.isBefore(today)).toList();
    final yesterdays = recent.length - todays.length;

    final open = todays.where((v) => v.checkOutAt == null).toList();
    final wsInUse = open.where((v) => v.workstation != null).length;

    final todaysNewVisitors = await (_db.select(_db.visitors)
          ..where((v) => v.registeredAt.isBiggerOrEqualValue(today)))
        .get();

    return DashboardStats(
      todayVisits: todays.length,
      yesterdayVisits: yesterdays,
      directoryCount: await _countVisitors(),
      newThisWeek: await _countVisitors(since: weekAgo),
      inside: open.length,
      capacity: await _settings.capacity(),
      workstationsInUse: wsInUse,
      registeredToday: todaysNewVisitors.length,
      cardsIssuedToday: todaysNewVisitors.where((v) => v.cardIssued).length,
      checkedOutToday: todays.length - open.length,
    );
  }

  Future<int> _countVisitors({DateTime? since}) async {
    final count = _db.visitors.id.count();
    final query = _db.selectOnly(_db.visitors)..addColumns([count]);
    if (since != null) {
      query.where(_db.visitors.registeredAt.isBiggerOrEqualValue(since));
    }
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<String?> _nextFreeWorkstation() async {
    final start = startOfDay(DateTime.now());
    final open = await (_db.select(_db.visits)
          ..where((v) =>
              v.checkOutAt.isNull() & v.checkInAt.isBiggerOrEqualValue(start)))
        .get();
    final used = open.map((v) => v.workstation).whereType<String>().toSet();
    for (var n = 1; n <= workstationCount; n++) {
      final label = workstationLabel(n);
      if (!used.contains(label)) return label;
    }
    return null;
  }
}
