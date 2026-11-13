import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 password hashing, run off the UI isolate.
abstract final class PasswordHasher {
  static const int _iterations = 60000;

  static String generateSalt() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  static Future<String> hash(String password, String salt) {
    return Isolate.run(() => _pbkdf2(password, salt));
  }

  static Future<bool> verify(String password, String salt, String expected) async {
    final actual = await hash(password, salt);
    return _constantTimeEquals(actual, expected);
  }

  static String _pbkdf2(String password, String salt) {
    final hmac = Hmac(sha256, utf8.encode(password));
    var u = hmac.convert([...utf8.encode(salt), 0, 0, 0, 1]).bytes;
    final result = List<int>.from(u);
    for (var i = 1; i < _iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    return base64Url.encode(result);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
