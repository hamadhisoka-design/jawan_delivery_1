import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class UserStore {
  static const _key = 'jawan_users_v2';
  static const _seededKey = 'jawan_users_seeded_v2';

  static Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  static Future<void> ensureSeedData() async {
    final prefs = await _prefs();
    final seeded = prefs.getBool(_seededKey) ?? false;
    if (seeded) return;

    final users = <AppUser>[
      AppUser(
        name: 'Admin',
        email: 'admin@jawan.sd',
        phone: '',
        password: 'Jawan@2026',
        role: 'admin',
      ),
      AppUser(
        name: 'Driver One',
        email: 'driver1@jawan.sd',
        phone: '0900000001',
        password: '123456',
        role: 'driver',
      ),
      AppUser(
        name: 'Driver Two',
        email: 'driver2@jawan.sd',
        phone: '0900000002',
        password: '123456',
        role: 'driver',
      ),
      AppUser(
        name: 'Customer Demo',
        email: 'customer@jawan.sd',
        phone: '0900000003',
        password: '123456',
        role: 'customer',
      ),
    ];

    await prefs.setString(_key, json.encode(users.map((u) => u.toJson()).toList()));
    await prefs.setBool(_seededKey, true);
  }

  static Future<List<AppUser>> loadUsers() async {
    await ensureSeedData();
    final prefs = await _prefs();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> saveUsers(List<AppUser> users) async {
    final prefs = await _prefs();
    final list = users.map((u) => u.toJson()).toList();
    return prefs.setString(_key, json.encode(list));
  }

  static Future<bool> register(AppUser user) async {
    await ensureSeedData();
    final users = await loadUsers();
    final exists = users.any((u) => u.email == user.email);
    if (exists) return false;
    users.add(user);
    return saveUsers(users);
  }

  static Future<AppUser?> login(String email, String password) async {
    await ensureSeedData();
    try {
      final users = await loadUsers();
      final user = users.firstWhere((u) => u.email == email && u.password == password);
      if (user.isBlocked) return null;
      return user;
    } catch (_) {
      return null;
    }
  }

  static Future<void> blockUser(String email) async {
    final users = await loadUsers();
    final idx = users.indexWhere((u) => u.email == email);
    if (idx == -1) return;
    users[idx].isBlocked = true;
    await saveUsers(users);
  }

  static Future<void> unblockUser(String email) async {
    final users = await loadUsers();
    final idx = users.indexWhere((u) => u.email == email);
    if (idx == -1) return;
    users[idx].isBlocked = false;
    await saveUsers(users);
  }

  static Future<void> updateUser(AppUser user) async {
    final users = await loadUsers();
    final idx = users.indexWhere((u) => u.email == user.email);
    if (idx == -1) return;
    users[idx] = user;
    await saveUsers(users);
  }

  static Future<void> deleteUser(String email) async {
    final users = await loadUsers();
    users.removeWhere((u) => u.email == email);
    await saveUsers(users);
  }
}
