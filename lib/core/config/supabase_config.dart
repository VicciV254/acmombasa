/// Supabase connection settings, supplied at build/run time so no secret ever
/// lives in source control:
///
///   flutter run -d windows --dart-define-from-file=env.json
///
/// Only the project URL and the public *anon* key belong here. The
/// service-role key must never be placed in this app.
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Set to true by the app initialiser once `Supabase.initialize` succeeded.
  static bool initialized = false;

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
  static bool get isAvailable => isConfigured && initialized;
}
