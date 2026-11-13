import 'package:drift/drift.dart';

/// Staff accounts. Local to each terminal; never synced to the cloud.
class StaffUsers extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get displayName => text()();

  /// 'admin' or 'receptionist'.
  TextColumn get role => text().withDefault(const Constant('receptionist'))();
  TextColumn get passwordHash => text()();
  TextColumn get passwordSalt => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Registered visitors / members. Synced.
class Visitors extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text()();
  TextColumn get fullName => text()();

  /// Compact international form, e.g. +254722849102.
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get category =>
      text().withDefault(const Constant('General Visitor'))();
  BoolColumn get isVerified => boolean().withDefault(const Constant(true))();
  BoolColumn get cardIssued => boolean().withDefault(const Constant(false))();
  DateTimeColumn get registeredAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// True while the row has local changes not yet pushed to the cloud.
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Programs and activities shown under "Today's Activities". Synced.
class Programs extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get location => text()();

  /// Minutes since midnight. Both null means "all day".
  IntColumn get startMinute => integer().nullable()();
  IntColumn get endMinute => integer().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per visit (check-in, optionally check-out). Synced.
class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get visitorId => text()();
  TextColumn get programId => text().nullable()();

  /// Snapshot of the purpose label at check-in time.
  TextColumn get purpose => text()();
  TextColumn get workstation => text().nullable()();
  DateTimeColumn get checkInAt => dateTime()();
  DateTimeColumn get checkOutAt => dateTime().nullable()();
  TextColumn get staffId => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small key/value store: capacity, session, sync cursors.
class AppSettings extends Table {
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();

  @override
  Set<Column> get primaryKey => {settingKey};
}
