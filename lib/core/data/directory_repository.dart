import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../domain/app_exception.dart';
import '../domain/directory_models.dart';
import '../utils/id_generator.dart';
import '../utils/phone_utils.dart';

/// Queries behind the Visitors Directory page. Reads the same tables as the
/// dashboard, so "inside now" means exactly the same thing in both places.
class DirectoryRepository {
  DirectoryRepository(this._db);

  final AppDatabase _db;

  /// No visit for this many days counts as "Inactive".
  static const int inactiveAfterDays = 90;

  Future<List<DirectoryRow>> loadRows(DirectoryQuery query) async {
    final now = DateTime.now();
    final today = startOfDay(now);
    final inactiveCutoff =
        DateTime(now.year, now.month, now.day - inactiveAfterDays);

    final search = query.search.trim().replaceAll(RegExp(r'[%_]'), '');
    final fragment = PhoneUtils.searchFragment(search);
    final looksLikePhone =
        fragment.length >= 3 && RegExp(r'^[\d\s+()\-]+$').hasMatch(search);

    final visitors = await (_db.select(_db.visitors)
          ..where((v) {
            Expression<bool> condition = const Constant(true);
            if (search.isNotEmpty) {
              var match = v.fullName.like('%$search%') |
                  v.memberId.like('%$search%') |
                  v.email.like('%$search%');
              if (looksLikePhone) match = match | v.phone.like('%$fragment%');
              condition = condition & match;
            }
            if (query.category != null) {
              condition = condition & v.category.equals(query.category!);
            }
            return condition;
          }))
        .get();

    final visits = await _db.select(_db.visits).get();
    final totals = <String, int>{};
    final lastVisit = <String, DateTime>{};
    final visitedToday = <String>{};
    final inside = <String>{};
    for (final v in visits) {
      totals.update(v.visitorId, (c) => c + 1, ifAbsent: () => 1);
      final previous = lastVisit[v.visitorId];
      if (previous == null || v.checkInAt.isAfter(previous)) {
        lastVisit[v.visitorId] = v.checkInAt;
      }
      if (!v.checkInAt.isBefore(today)) {
        visitedToday.add(v.visitorId);
        if (v.checkOutAt == null) inside.add(v.visitorId);
      }
    }

    var rows = [
      for (final v in visitors)
        DirectoryRow(
          visitor: v,
          totalVisits: totals[v.id] ?? 0,
          lastVisitAt: lastVisit[v.id],
          insideNow: inside.contains(v.id),
          visitedToday: visitedToday.contains(v.id),
          isInactive: lastVisit[v.id] == null ||
              lastVisit[v.id]!.isBefore(inactiveCutoff),
        ),
    ];

    rows = switch (query.status) {
      DirectoryStatus.all => rows,
      DirectoryStatus.insideNow => rows.where((r) => r.insideNow).toList(),
      DirectoryStatus.active => rows.where((r) => !r.isInactive).toList(),
      DirectoryStatus.inactive => rows.where((r) => r.isInactive).toList(),
    };

    int byName(DirectoryRow a, DirectoryRow b) => a.visitor.fullName
        .toLowerCase()
        .compareTo(b.visitor.fullName.toLowerCase());

    switch (query.sort) {
      case DirectorySort.recentVisit:
        rows.sort((a, b) {
          final la = a.lastVisitAt;
          final lb = b.lastVisitAt;
          if (la == null && lb == null) return byName(a, b);
          if (la == null) return 1;
          if (lb == null) return -1;
          final c = lb.compareTo(la);
          return c != 0 ? c : byName(a, b);
        });
      case DirectorySort.nameAsc:
        rows.sort(byName);
      case DirectorySort.mostVisits:
        rows.sort((a, b) {
          final c = b.totalVisits.compareTo(a.totalVisits);
          return c != 0 ? c : byName(a, b);
        });
      case DirectorySort.newestMember:
        rows.sort(
          (a, b) => b.visitor.registeredAt.compareTo(a.visitor.registeredAt),
        );
    }
    return rows;
  }

  Future<List<String>> categories() async {
    final query = _db.selectOnly(_db.visitors, distinct: true)
      ..addColumns([_db.visitors.category]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.visitors.category))
        .whereType<String>()
        .toList()
      ..sort();
  }

  Future<DirectorySummary> summary() async {
    final count = _db.visitors.id.count();
    final totalRow =
        await (_db.selectOnly(_db.visitors)..addColumns([count])).getSingle();

    final open = await (_db.select(_db.visits)
          ..where((v) =>
              v.checkOutAt.isNull() &
              v.checkInAt.isBiggerOrEqualValue(startOfDay(DateTime.now()))))
        .get();

    return DirectorySummary(
      totalVisitors: totalRow.read(count) ?? 0,
      insideNow: open.map((v) => v.visitorId).toSet().length,
    );
  }

  Future<VisitorProfileData?> profile(String visitorId) async {
    final visitor = await (_db.select(_db.visitors)
          ..where((v) => v.id.equals(visitorId)))
        .getSingleOrNull();
    if (visitor == null) return null;

    final now = DateTime.now();
    final today = startOfDay(now);

    final visits = await (_db.select(_db.visits)
          ..where((v) => v.visitorId.equals(visitorId))
          ..orderBy([(v) => OrderingTerm.desc(v.checkInAt)]))
        .get();

    final programs = {
      for (final p in await _db.select(_db.programs).get()) p.id: p,
    };

    // Visits per month since the member joined (at least one month).
    var since = visitor.registeredAt;
    if (visits.isNotEmpty && visits.last.checkInAt.isBefore(since)) {
      since = visits.last.checkInAt;
    }
    final months = (now.difference(since).inDays / 30.4375).clamp(1.0, 100000.0);

    final stays = [
      for (final v in visits)
        if (v.checkOutAt != null) v.checkOutAt!.difference(v.checkInAt).inMinutes,
    ];
    final avgStay =
        stays.isEmpty ? null : (stays.reduce((a, b) => a + b) / stays.length).round();

    final weekdayCounts = <int, int>{};
    final purposeCounts = <String, int>{};
    for (final v in visits) {
      weekdayCounts.update(v.checkInAt.weekday, (c) => c + 1, ifAbsent: () => 1);
      purposeCounts.update(v.purpose, (c) => c + 1, ifAbsent: () => 1);
    }
    int? favoriteDay;
    var best = 0;
    weekdayCounts.forEach((day, count) {
      if (count > best || (count == best && favoriteDay != null && day < favoriteDay!)) {
        best = count;
        favoriteDay = day;
      }
    });

    final topPurposes = (purposeCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => e.key)
        .toList();

    return VisitorProfileData(
      visitor: visitor,
      totalVisits: visits.length,
      monthlyAverage: visits.length / months,
      avgStayMinutes: avgStay,
      favoriteWeekday: favoriteDay,
      topPurposes: topPurposes,
      recent: [
        for (final v in visits.take(5))
          ProfileVisit(
            visit: v,
            location: v.programId == null ? null : programs[v.programId]?.location,
          ),
      ],
      openVisit: visits
          .where((v) => v.checkOutAt == null && !v.checkInAt.isBefore(today))
          .firstOrNull,
    );
  }

  /// Edits a visitor's contact details. Marks the row for cloud sync.
  Future<Visitor> updateVisitor({
    required String id,
    required String fullName,
    required String phone,
    String? email,
    required String category,
  }) async {
    final name = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.length < 2) throw const AppException('Enter the visitor\'s name.');

    final normalizedPhone = PhoneUtils.normalize(phone);
    if (normalizedPhone == null) {
      throw const AppException('Enter a valid phone number.');
    }

    final cleanEmail = email?.trim() ?? '';
    if (cleanEmail.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(cleanEmail)) {
      throw const AppException('Enter a valid email address or leave it blank.');
    }

    return _db.transaction(() async {
      final duplicate = await (_db.select(_db.visitors)
            ..where((v) => v.phone.equals(normalizedPhone) & v.id.equals(id).not())
            ..limit(1))
          .getSingleOrNull();
      if (duplicate != null) {
        throw AppException(
          'This phone number already belongs to ${duplicate.fullName} '
          '(${duplicate.memberId}).',
        );
      }

      await (_db.update(_db.visitors)..where((v) => v.id.equals(id))).write(
        VisitorsCompanion(
          fullName: Value(name),
          phone: Value(normalizedPhone),
          email: Value(cleanEmail.isEmpty ? null : cleanEmail),
          category: Value(category),
          updatedAt: Value(DateTime.now()),
          dirty: const Value(true),
        ),
      );
      return (_db.select(_db.visitors)..where((v) => v.id.equals(id))).getSingle();
    });
  }
}
