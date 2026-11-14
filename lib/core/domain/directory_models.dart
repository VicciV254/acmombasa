import '../database/app_database.dart';

enum DirectoryStatus { all, insideNow, active, inactive }

enum DirectorySort { recentVisit, nameAsc, mostVisits, newestMember }

class DirectoryQuery {
  const DirectoryQuery({
    this.search = '',
    this.category,
    this.status = DirectoryStatus.all,
    this.sort = DirectorySort.recentVisit,
  });

  final String search;
  final String? category;
  final DirectoryStatus status;
  final DirectorySort sort;

  DirectoryQuery copyWith({
    String? search,
    String? category,
    bool clearCategory = false,
    DirectoryStatus? status,
    DirectorySort? sort,
  }) {
    return DirectoryQuery(
      search: search ?? this.search,
      category: clearCategory ? null : (category ?? this.category),
      status: status ?? this.status,
      sort: sort ?? this.sort,
    );
  }
}

enum RowStatus { insideNow, checkedOut, active, inactive }

class DirectoryRow {
  const DirectoryRow({
    required this.visitor,
    required this.totalVisits,
    required this.lastVisitAt,
    required this.insideNow,
    required this.visitedToday,
    required this.isInactive,
  });

  final Visitor visitor;
  final int totalVisits;
  final DateTime? lastVisitAt;
  final bool insideNow;
  final bool visitedToday;

  /// No visit in the last 90 days (or never).
  final bool isInactive;

  RowStatus get status {
    if (insideNow) return RowStatus.insideNow;
    if (visitedToday) return RowStatus.checkedOut;
    return isInactive ? RowStatus.inactive : RowStatus.active;
  }
}

class DirectorySummary {
  const DirectorySummary({required this.totalVisitors, required this.insideNow});

  final int totalVisitors;
  final int insideNow;
}

class ProfileVisit {
  const ProfileVisit({required this.visit, this.location});

  final Visit visit;

  /// Room of the program the visit was for, if any.
  final String? location;
}

class VisitorProfileData {
  const VisitorProfileData({
    required this.visitor,
    required this.totalVisits,
    required this.monthlyAverage,
    required this.avgStayMinutes,
    required this.favoriteWeekday,
    required this.topPurposes,
    required this.recent,
    required this.openVisit,
  });

  final Visitor visitor;
  final int totalVisits;
  final double monthlyAverage;
  final int? avgStayMinutes;

  /// DateTime.weekday (1 = Monday), or null with no visits.
  final int? favoriteWeekday;
  final List<String> topPurposes;
  final List<ProfileVisit> recent;

  /// Today's visit that has not been checked out, if any.
  final Visit? openVisit;

  bool get isInside => openVisit != null;
}
