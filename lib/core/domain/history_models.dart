import '../database/app_database.dart';

enum HistoryPeriod { today, thisWeek, thisMonth, custom }

/// Special values for [HistoryFilters.roomKey].
abstract final class RoomKeys {
  static const workstation = '__workstation';
  static const noWorkstation = '__none';
}

class HistoryFilters {
  const HistoryFilters({
    required this.period,
    required this.start,
    required this.end,
    this.search = '',
    this.purposeKey,
    this.roomKey,
    this.newestFirst = true,
  });

  final HistoryPeriod period;

  /// Inclusive.
  final DateTime start;

  /// Exclusive (midnight after the last day).
  final DateTime end;

  final String search;

  /// A program id, or "general"; null means every purpose.
  final String? purposeKey;

  /// A program location, a [RoomKeys] value, or null for everything.
  final String? roomKey;

  final bool newestFirst;

  int get daysFiltered => (end.difference(start).inHours / 24).round();

  bool get includesToday => end.isAfter(DateTime.now());

  bool get hasExtraFilters =>
      search.trim().isNotEmpty || purposeKey != null || roomKey != null;

  HistoryFilters copyWith({
    HistoryPeriod? period,
    DateTime? start,
    DateTime? end,
    String? search,
    String? purposeKey,
    bool clearPurpose = false,
    String? roomKey,
    bool clearRoom = false,
    bool? newestFirst,
  }) {
    return HistoryFilters(
      period: period ?? this.period,
      start: start ?? this.start,
      end: end ?? this.end,
      search: search ?? this.search,
      purposeKey: clearPurpose ? null : (purposeKey ?? this.purposeKey),
      roomKey: clearRoom ? null : (roomKey ?? this.roomKey),
      newestFirst: newestFirst ?? this.newestFirst,
    );
  }
}

class HistoryEntry {
  const HistoryEntry({
    required this.visit,
    required this.visitor,
    required this.program,
    required this.staffName,
  });

  final Visit visit;
  final Visitor visitor;
  final Program? program;
  final String staffName;

  bool get isOpen => visit.checkOutAt == null;

  Duration? get duration => visit.checkOutAt?.difference(visit.checkInAt);

  /// Where the visit happened: a workstation, the program's room, or the desk.
  String get space => visit.workstation ?? program?.location ?? 'Front Desk';
}

class HistoryKpis {
  const HistoryKpis({
    required this.total,
    required this.previousTotal,
    required this.avgMinutes,
    required this.medianMinutes,
    required this.checkedOutRate,
    required this.uniquePatrons,
    required this.returnRate,
    required this.firstTimeRegistrations,
    required this.peakStartHour,
    required this.peakConcurrent,
  });

  final int total;
  final int previousTotal;
  final int? avgMinutes;
  final int? medianMinutes;

  /// Share of visits that have been checked out (0..1).
  final double checkedOutRate;
  final int uniquePatrons;

  /// Share of patrons with more than one visit in the period (0..1).
  final double returnRate;
  final int firstTimeRegistrations;

  /// Start hour (0..22) of the busiest 2-hour window, or null with no visits.
  final int? peakStartHour;

  /// Most people inside at the same time.
  final int peakConcurrent;
}

class PillarShare {
  const PillarShare({
    required this.label,
    required this.count,
    required this.fraction,
  });

  final String label;
  final int count;
  final double fraction;
}

class HistoryReport {
  const HistoryReport({
    required this.entries,
    required this.kpis,
    required this.distribution,
  });

  /// Entries matching every filter, already sorted.
  final List<HistoryEntry> entries;
  final HistoryKpis kpis;
  final List<PillarShare> distribution;
}
