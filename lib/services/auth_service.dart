import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class AuthService extends ChangeNotifier {
  AppUser? _currentUser;
  String? _userRole; // 'admin', 'customer', 'driver'

  AppUser? get currentUser => _currentUser;
  String? get userRole => _userRole;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    try {
      // Simulate login
      final role = _determineRole(email);
      final user = AppUser(
        email: email,
        name: email.split('@')[0],
        phone: '',
        password: password,
        role: role,
      );
      
      _currentUser = user;
      _userRole = user.role;
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_role', user.role);
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String email, String name, String password, String role) async {
    try {
      final user = AppUser(
        email: email,
        name: name,
        phone: '',
        password: password,
        role: role,
      );
      
      _currentUser = user;
      _userRole = role;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_role', role);
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _userRole = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final role = prefs.getString('user_role');
      
      if (email != null && role != null) {
        _currentUser = AppUser(
          email: email,
          name: email.split('@')[0],
          phone: '',
          password: '',
          role: role,
        );
        _userRole = role;
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  String _determineRole(String email) {
    if (email.contains('admin')) return 'admin';
    if (email.contains('driver')) return 'driver';
    return 'customer';
  }
}
