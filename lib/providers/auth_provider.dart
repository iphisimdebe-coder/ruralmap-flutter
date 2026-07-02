import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  static const _userKey = 'auth_user';
  static const _passwordKey = 'auth_password_hash';
  static const _loggedInKey = 'auth_logged_in';

  AppUser? _user;
  bool _loaded = false;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoaded => _loaded;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    if (isLoggedIn && prefs.containsKey(_userKey)) {
      final raw = prefs.getString(_userKey);
      if (raw != null) {
        _user = AppUser.fromMap(jsonDecode(raw) as Map<String, dynamic>);
      }
    }
    _loaded = true;
    notifyListeners();
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_userKey)) {
      return 'An account already exists. Please log in.';
    }

    final user = AppUser(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      role: 'Enumerator',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    await prefs.setString(_userKey, jsonEncode(user.toMap()));
    await prefs.setString(_passwordKey, _hashPassword(password));
    await prefs.setBool(_loggedInKey, true);

    _user = user;
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userKey) || !prefs.containsKey(_passwordKey)) {
      return 'No account found. Please register first.';
    }

    final raw = prefs.getString(_userKey);
    final storedHash = prefs.getString(_passwordKey);
    if (raw == null || storedHash == null) {
      return 'Unable to sign in. Please try again.';
    }

    final storedUser = AppUser.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    if (storedUser.email != email.trim().toLowerCase()) {
      return 'Email or password is incorrect.';
    }

    if (_hashPassword(password) != storedHash) {
      return 'Email or password is incorrect.';
    }

    final user = storedUser.copyWith(lastLogin: DateTime.now());
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
    await prefs.setBool(_loggedInKey, true);

    _user = user;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    _user = null;
    notifyListeners();
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_user == null) {
      return 'No active user session.';
    }

    final updated = _user!.copyWith(
      name: name.trim(),
      phone: phone.trim(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(updated.toMap()));
    _user = updated;
    notifyListeners();
    return null;
  }
}
