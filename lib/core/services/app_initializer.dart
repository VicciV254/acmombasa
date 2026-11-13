import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../providers.dart';

/// Where the app should go once start-up has finished.
enum StartupDestination {
  /// A valid staff session exists.
  dashboard,

  /// Staff accounts exist but nobody is signed in.
  signIn,

  /// First run: no staff account exists yet, so create the administrator.
  setup,
}

/// Runs start-up work: local database, seed data, optional cloud client and
/// session restore.
class AppInitializer {
  const AppInitializer(this._ref);

  final WidgetRef _ref;

  Future<StartupDestination> initialize() async {
    // Opens the SQLite database and runs migrations.
    await _ref.read(databaseProvider).customSelect('SELECT 1').get();

    await _ref.read(programRepositoryProvider).seedIfEmpty();
    await _ref.read(visitRepositoryProvider).closeStaleVisits();
    await _initSupabase();

    if (!await _ref.read(authRepositoryProvider).hasStaff()) {
      return StartupDestination.setup;
    }
    final user = await _ref.read(sessionProvider.notifier).restore();
    return user == null ? StartupDestination.signIn : StartupDestination.dashboard;
  }

  /// The cloud is optional: a missing config or no network must never stop
  /// the desktop app from starting.
  Future<void> _initSupabase() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      SupabaseConfig.initialized = true;
    } catch (error) {
      debugPrint('Supabase initialisation skipped: $error');
    }
  }
}
