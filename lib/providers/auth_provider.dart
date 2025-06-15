// File: lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  /// Log in an existing user by email & password.
  Future<String?> login(String email, String password) async {
    final u = await DBHelper.getUserByEmail(email);
    if (u == null) return 'User not found';
    if (u.password != password) return 'Incorrect password';
    _user = u;
    notifyListeners();
    return null;
  }

  /// Register a new user with given details.
  Future<String?> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final existing = await DBHelper.getUserByEmail(email);
    if (existing != null) return 'Email already registered';
    await DBHelper.insertUser(
      User(name: name, email: email, password: password, role: role),
    );
    return null;
  }

  /// Log out the current user.
  void logout() {
    _user = null;
    notifyListeners();
  }

  /// Change the password for the currently logged-in user.
  Future<String?> changePassword(String oldPass, String newPass) async {
    if (_user == null) return 'No user logged in';
    if (_user!.password != oldPass) return 'Old password is incorrect';
    _user!.password = newPass;
    await DBHelper.updateUser(_user!);
    notifyListeners();
    return null;
  }

  /// Update profile info (name, email, role) for the current user.
  Future<String?> updateProfile(User updatedUser) async {
    if (_user == null) return 'No user logged in';
    updatedUser.id = _user!.id;
    await DBHelper.updateUser(updatedUser);
    _user = updatedUser;
    notifyListeners();
    return null;
  }
}
