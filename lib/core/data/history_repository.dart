import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../domain/history_models.dart';
import '../utils/phone_utils.dart';

/// Queries behind the Visit History & Terminal Logs page.
class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  static const String generalKey = 'general';

  /// Distinct program rooms, for the "Rooms & Workstations" filter.
  Future<List<String>> rooms() async {
    final programs = await _db.select(_db.programs).get();
    return programs.map((p) => p.location).toSet().toList()..sort();
  }

  Future<HistoryReport> load(HistoryFilters f) async {
    final now = DateTime.now();

    final joined = await (_db.select(_db.visits).join([
      innerJoin(_db.visitors, _db.visitors.id.equalsExp(_db.visits.visitorId)),
    ])
          ..where(_db.visits.checkInAt.isBiggerOrEqualValue(f.start) &
              _db.visits.checkInAt.isSmallerThanValue(f.end))
          ..orderBy([OrderingTerm.desc(_db.visits.checkInAt)]))
        .get();

    final programs = {
      for (final p in await _db.select(_db.programs).get()) p.id: p,
    };
    final staff = {
      for (final s in await _db.select(_db.staffUsers).get()) s.id: s.displayName,
    };

    final all = [
      for (final row in joined)
        () {
          final visit = row.readTable(_db.visits);
          return HistoryEntry(
            visit: visit,
            visitor: row.readTable(_db.visitors),
            program: visit.programId == null ? null : programs[visit.programId],
            staffName: staff[visit.staffId] ?? 'Unknown staff',
          );
        }(),
    ];

    final span = f.end.difference(f.start);
    final previous = await (_db.select(_db.visits)
          ..where((v) =>
              v.checkInAt.isBiggerOrEqualValue(f.start.subtract(span)) &
              v.checkInAt.isSmallerThanValue(f.start)))
        .get();

    final newVisitors = await (_db.select(_db.visitors)
          ..where((v) =>
              v.registeredAt.isBiggerOrEqualValue(f.start) &
              v.registeredAt.isSmallerThanValue(f.end)))
        .get();

    final entries = all.where((e) => _matches(e, f)).toList();
    if (!f.newestFirst) {
      entries.sort((a, b) => a.visit.checkInAt.compareTo(b.visit.checkInAt));
    }

    return HistoryReport(
      entries: entries,
      kpis: _kpis(
        all,
        previousTotal: previous.length,
        firstTime: newVisitors.length,
        now: now,
        rangeEnd: f.end,
      ),
      distribution: _distribution(all),
    );
  }

  bool _matches(HistoryEntry e, HistoryFilters f) {
    final q = f.search.trim().toLowerCase();
    if (q.isNotEmpty) {
      final fragment = PhoneUtils.searchFragment(q);
      final byPhone = fragment.length >= 3 &&
          RegExp(r'^[\d\s+()\-]+$').hasMatch(q) &&
          e.visitor.phone.contains(fragment);
      final hit = e.visitor.fullName.toLowerCase().contains(q) ||
          e.visitor.memberId.toLowerCase().contains(q) ||
          e.visit.purpose.toLowerCase().contains(q) ||
          byPhone;
      if (!hit) return false;
    }

    if (f.purposeKey != null && (e.visit.programId ?? generalKey) != f.purposeKey) {
      return false;
    }

    final room = f.roomKey;
    if (room != null) {
      switch (room) {
        case RoomKeys.workstation:
          if (e.visit.workstation == null) return false;
        case RoomKeys.noWorkstation:
          if (e.visit.workstation != null) return false;
        default:
          if (e.program?.location != room) return false;
      }
    }
    return true;
  }

  HistoryKpis _kpis(
    List<HistoryEntry> all, {
    required int previousTotal,
    required int firstTime,
    required DateTime now,
    required DateTime rangeEnd,
  }) {
    final durations = [
      for (final e in all)
        if (e.duration != null) e.duration!.inMinutes,
    ]..sort();

    final avg = durations.isEmpty
        ? null
        : (durations.reduce((a, b) => a + b) / durations.length).round();
    final median = durations.isEmpty ? null : durations[durations.length ~/ 2];

    final perVisitor = <String, int>{};
    for (final e in all) {
      perVisitor.update(e.visitor.id, (c) => c + 1, ifAbsent: () => 1);
    }
    final returning = perVisitor.values.where((c) => c > 1).length;

    // Busiest 2-hour window of check-ins.
    final hourly = List<int>.filled(24, 0);
    for (final e in all) {
      hourly[e.visit.checkInAt.hour]++;
    }
    int? peakStart;
    var bestSum = -1;
    if (all.isNotEmpty) {
      for (var h = 0; h < 23; h++) {
        final sum = hourly[h] + hourly[h + 1];
        if (sum > bestSum) {
          bestSum = sum;
          peakStart = h;
        }
      }
    }

    // Most people inside at once. Still-open visits end "now".
    final events = <(DateTime, int)>[];
    for (final e in all) {
      final start = e.visit.checkInAt;
      var end = e.visit.checkOutAt ?? (now.isBefore(rangeEnd) ? now : rangeEnd);
      if (end.isBefore(start)) end = start;
      events
        ..add((start, 1))
        ..add((end, -1));
    }
    events.sort((a, b) {
      final c = a.$1.compareTo(b.$1);
      return c != 0 ? c : a.$2.compareTo(b.$2);
    });
    var current = 0;
    var peak = 0;
    for (final event in events) {
      current += event.$2;
      if (current > peak) peak = current;
    }

    return HistoryKpis(
      total: all.length,
      previousTotal: previousTotal,
      avgMinutes: avg,
      medianMinutes: median,
      checkedOutRate: all.isEmpty ? 0 : durations.length / all.length,
      uniquePatrons: perVisitor.length,
      returnRate: perVisitor.isEmpty ? 0 : returning / perVisitor.length,
      firstTimeRegistrations: firstTime,
      peakStartHour: peakStart,
      peakConcurrent: peak,
    );
  }

  List<PillarShare> _distribution(List<HistoryEntry> all) {
    if (all.isEmpty) return const [];
    final counts = <String, int>{};
    for (final e in all) {
      counts.update(e.visit.purpose, (c) => c + 1, ifAbsent: () => 1);
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final entry in sorted.take(4))
        PillarShare(
          label: entry.key,
          count: entry.value,
          fraction: entry.value / all.length,
        ),
    ];
  }
}
