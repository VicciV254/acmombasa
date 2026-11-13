/// An expected, user-presentable failure (bad input, duplicate record, etc.).
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Turns any thrown object into text that is safe to show to staff.
String friendlyError(Object error) {
  if (error is AppException) return error.message;
  return 'Something went wrong. Please try again.';
}
