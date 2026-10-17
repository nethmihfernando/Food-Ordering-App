import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/user.dart';
import '../utils/password_hasher.dart';

/// Handles registration, login, logout, and session persistence.
class AuthProvider extends ChangeNotifier {
  static const _kSessionUserIdKey = 'auth_session_user_id';

  final DatabaseHelper _db = DatabaseHelper.instance;

  User? _currentUser;
  bool _isLoading = false;
  bool _sessionChecked = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get sessionChecked => _sessionChecked;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_kSessionUserIdKey);
    if (userId != null) {
      _currentUser = await _db.getUserById(userId);
    }

    _isLoading = false;
    _sessionChecked = true;
    notifyListeners();
  }

  /// Registers a new account. Returns null on success, or an error
  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
    String address = '',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await _db.getUserByEmail(normalizedEmail);
    if (existing != null) {
      return 'An account with this email already exists.';
    }

    final user = User(
      fullName: fullName.trim(),
      email: normalizedEmail,
      passwordHash: PasswordHasher.hash(password),
      phone: phone.trim(),
      address: address.trim(),
    );

    final userId = await _db.insertUser(user);
    _currentUser = user.copyWith(userId: userId);
    await _persistSession(userId);
    notifyListeners();
    return null;
  }

  /// Logs in with email + password. Returns null on success, or an
  Future<String?> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await _db.getUserByEmail(normalizedEmail);

    if (user == null || !PasswordHasher.verify(password, user.passwordHash)) {
      return 'Incorrect email or password.';
    }

    _currentUser = user;
    await _persistSession(user.userId!);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionUserIdKey);
    notifyListeners();
  }

  /// Updates the current user's profile.
  Future<void> updateProfile(User updatedUser) async {
    await _db.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> _persistSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSessionUserIdKey, userId);
  }
}
