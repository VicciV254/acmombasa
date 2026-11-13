import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

/// Local SQLite database (Drift). The `.g.dart` part is generated; run
/// `dart run build_runner build` after adding the packages (see SETUP.md).
@DriftDatabase(tables: [StaffUsers, Visitors, Programs, Visits, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'american_corner'));

  @override
  int get schemaVersion => 1;
}
