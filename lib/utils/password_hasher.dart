import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Hashes and verifies passwords using SHA-256 with a static app-level
/// salt. This is sufficient for a student project's local SQLite auth —
/// it means plain-text passwords are never stored — but it is not the
/// same as a production-grade algorithm like bcrypt/argon2.
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
