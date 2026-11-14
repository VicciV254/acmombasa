import 'history_models.dart' show PillarShare;

export 'history_models.dart' show PillarShare;

class MonthBar {
  const MonthBar({
    required this.label,
    required this.walkIns,
    required this.programVisits,
    required this.isSelected,
  });

  final String label;

  /// Visits not tied to a program.
  final int walkIns;
  final int programVisits;
  final bool isSelected;

  int get total => walkIns + programVisits;
}

class ShareRow {
  const ShareRow({required this.label, required this.count, required this.fraction});

  final String label;
  final int count;
  final double fraction;
}

class PillarLedgerRow {
  const PillarLedgerRow({
    required this.pillar,
    required this.visits,
    required this.sessions,
    required this.uniqueAttendees,
  });

  final String pillar;
  final int visits;
  final int sessions;
  final int uniqueAttendees;
}

class MonthlyReport {
  const MonthlyReport({
    required this.month,
    required this.footfall,
    required this.previousFootfall,
    required this.target,
    required this.dailyAverage,
    required this.uniqueVisitors,
    required this.newMembers,
    required this.female,
    required this.male,
    required this.genderRecorded,
    required this.youth,
    required this.ageRecorded,
    required this.educationUsaVisits,
    required this.educationUsaAttendees,
    required this.trend,
    required this.pillars,
    required this.ledger,
    required this.residence,
    required this.residenceRecorded,
    required this.cohorts,
  });

  /// First day of the month being reported.
  final DateTime month;
  final int footfall;
  final int previousFootfall;
  final int target;
  final double dailyAverage;
  final int uniqueVisitors;
  final int newMembers;

  final int female;
  final int male;

  /// Unique visitors whose gender is recorded as Female or Male.
  final int genderRecorded;

  /// Visitors aged 18-35 and visitors with any age recorded.
  final int youth;
  final int ageRecorded;

  final int educationUsaVisits;
  final int educationUsaAttendees;

  final List<MonthBar> trend;
  final List<PillarShare> pillars;
  final List<PillarLedgerRow> ledger;
  final List<ShareRow> residence;
  final int residenceRecorded;
  final List<ShareRow> cohorts;

  double get femaleShare => genderRecorded == 0 ? 0 : female / genderRecorded;
  double get maleShare => genderRecorded == 0 ? 0 : male / genderRecorded;
  double get youthShare => ageRecorded == 0 ? 0 : youth / ageRecorded;
  double get targetProgress => target == 0 ? 0 : footfall / target;
}
