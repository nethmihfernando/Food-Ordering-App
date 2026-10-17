import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Hashes and verifies passwords using SHA-256 with a static app-level salt.
class PasswordHasher {
  static const _salt = 'fastbite_app_salt_v1';

  static String hash(String password) {
    final bytes = utf8.encode('$_salt:$password');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String password, String storedHash) {
    return hash(password) == storedHash;
  }
}
