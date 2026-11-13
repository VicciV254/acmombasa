import '../database/app_database.dart';

/// A visit joined with the visitor who made it.
class VisitLogEntry {
  const VisitLogEntry({required this.visit, required this.visitor});

  final Visit visit;
  final Visitor visitor;

  bool get isInside => visit.checkOutAt == null;
}

/// Everything the check-in panel needs to know about one visitor.
class VisitorSummary {
  const VisitorSummary({
    required this.visitor,
    required this.totalVisits,
    this.lastVisit,
    this.openVisit,
    this.latestTodayVisit,
  });

  final Visitor visitor;
  final int totalVisits;

  /// Most recent visit before today.
  final Visit? lastVisit;

  /// Today's visit that has not been checked out, if any.
  final Visit? openVisit;

  /// Most recent visit today (open or closed), if any.
  final Visit? latestTodayVisit;

  bool get isInside => openVisit != null;
}

class DashboardStats {
  const DashboardStats({
    required this.todayVisits,
    required this.yesterdayVisits,
    required this.directoryCount,
    required this.newThisWeek,
    required this.inside,
    required this.capacity,
    required this.workstationsInUse,
    required this.registeredToday,
    required this.cardsIssuedToday,
    required this.checkedOutToday,
  });

  final int todayVisits;
  final int yesterdayVisits;
  final int directoryCount;
  final int newThisWeek;
  final int inside;
  final int capacity;
  final int workstationsInUse;
  final int registeredToday;
  final int cardsIssuedToday;
  final int checkedOutToday;
}

class ActivityView {
  const ActivityView({
    required this.program,
    required this.attendees,
    required this.isLive,
  });

  final Program program;
  final int attendees;

  /// A timed session that is running right now.
  final bool isLive;
}

/// One entry in the "Purpose of Visit" dropdown.
class PurposeOption {
  const PurposeOption({required this.label, this.programId});

  final String label;
  final String? programId;

  static const PurposeOption general = PurposeOption(label: 'General Visit');
}

class CheckInResult {
  const CheckInResult({required this.visit, required this.workstationFull});

  final Visit visit;

  /// A workstation was requested but none was free.
  final bool workstationFull;
}
