import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _emailKey = 'session_email';
  static const _roleKey = 'session_role';
  static const _nameKey = 'session_name';
  static const _phoneKey = 'session_phone';

  static SharedPreferences? _prefs;

  static String? email;
  static String? role;
  static String? name;
  static String? phone;

  static bool get isLoggedIn => email != null;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    email = _prefs!.getString(_emailKey);
    role = _prefs!.getString(_roleKey);
    name = _prefs!.getString(_nameKey);
    phone = _prefs!.getString(_phoneKey);
  }

  static Future<void> login({
    required String userEmail,
    required String userRole,
    required String userName,
    required String userPhone,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();
    email = userEmail;
    role = userRole;
    name = userName;
    phone = userPhone;

    await _prefs!.setString(_emailKey, userEmail);
    await _prefs!.setString(_roleKey, userRole);
    await _prefs!.setString(_nameKey, userName);
    await _prefs!.setString(_phoneKey, userPhone);
  }

  static Future<void> logout() async {
    _prefs ??= await SharedPreferences.getInstance();
    email = null;
    role = null;
    name = null;
    phone = null;

    await _prefs!.remove(_emailKey);
    await _prefs!.remove(_roleKey);
    await _prefs!.remove(_nameKey);
    await _prefs!.remove(_phoneKey);
  }
}
