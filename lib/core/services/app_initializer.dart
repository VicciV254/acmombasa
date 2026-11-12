import 'package:flutter/foundation.dart';

/// Where the app should go once start-up has finished.
enum StartupDestination {
  /// A valid staff session exists.
  dashboard,

  /// No valid staff session; the staff must sign in.
  signIn,
}

/// Runs start-up work. Every step is a clearly marked stub for now; no real
/// database or authentication is implemented yet.
class AppInitializer {
  const AppInitializer();

  Future<StartupDestination> initialize() async {
    await _initLocalStorage();
    await _initServices();
    final hasSession = await _hasValidStaffSession();
    return hasSession ? StartupDestination.dashboard : StartupDestination.signIn;
  }

  /// TODO(storage): open the local SQLite (Drift) database here.
  Future<void> _initLocalStorage() async {
    debugPrint('AppInitializer: local storage (stub)');
  }

  /// TODO(services): initialise Supabase (anon key only; never the
  /// service-role key) and any other app-wide services here.
  Future<void> _initServices() async {
    debugPrint('AppInitializer: services (stub)');
  }

  /// TODO(auth): check for a persisted Supabase session. Until auth exists
  /// there is never a session, so start-up always resolves to sign-in.
  Future<bool> _hasValidStaffSession() async {
    return false;
  }
}
