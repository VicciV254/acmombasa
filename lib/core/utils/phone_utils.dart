abstract final class PhoneUtils {
  /// Returns the compact international form (e.g. +254722849102), or null when
  /// the input can't be a phone number. Local numbers starting with 0 are
  /// treated as Kenyan.
  static String? normalize(String raw) {
    final trimmed = raw.trim();
    var digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    if (!trimmed.startsWith('+')) {
      if (digits.startsWith('00')) {
        digits = digits.substring(2);
      } else if (digits.startsWith('0')) {
        digits = '254${digits.substring(1)}';
      } else if (digits.length == 9) {
        digits = '254$digits';
      }
    }
    if (digits.length < 9 || digits.length > 15) return null;
    return '+$digits';
  }

  /// Display form, e.g. "+254 722 849 102" for Kenyan numbers.
  static String format(String stored) {
    if (stored.startsWith('+254') && stored.length == 13) {
      return '+254 ${stored.substring(4, 7)} ${stored.substring(7, 10)} '
          '${stored.substring(10)}';
    }
    return stored;
  }

  /// Digits to match inside stored numbers when the user types a phone number.
  static String searchFragment(String query) {
    var digits = query.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('254')) {
      digits = digits.substring(3);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }
}
