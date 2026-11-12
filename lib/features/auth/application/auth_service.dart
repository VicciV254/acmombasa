class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthService {
  Future<void> signIn({required String email, required String password});
}

/// TEMPORARY stand-in so the UI flow can be developed.
///
/// This is NOT authentication: it accepts any non-empty email and password and
/// stores no session. Replace it with a Supabase-backed implementation (using
/// the anon key only, never the service-role key) before real use.
class TemporaryAuthService implements AuthService {
  const TemporaryAuthService();

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthException('Enter your email and password.');
    }
  }
}
