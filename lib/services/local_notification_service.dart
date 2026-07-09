import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';
import 'notification_service.dart';

class LocalNotificationService extends ChangeNotifier implements NotificationService {
  static const _key = 'jawan_notifications_v2';

  SharedPreferences? _prefs;
  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);

  Future<void> _ensureLoaded() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (_items.isNotEmpty) return;

    final raw = _prefs!.getString(_key);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = json.decode(raw) as List<dynamic>;
      _items
        ..clear()
        ..addAll(decoded.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)));
    } catch (_) {
      _items.clear();
    }
  }

  Future<void> _save() async {
    _prefs ??= await SharedPreferences.getInstance();
    final payload = _items.map((e) => e.toJson()).toList();
    await _prefs!.setString(_key, json.encode(payload));
  }

  AppNotification _build({
    required String title,
    required String body,
    required String targetRole,
    String? targetEmail,
  }) {
    return AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      targetRole: targetRole,
      targetEmail: targetEmail,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _push(AppNotification notification) async {
    await _ensureLoaded();
    _items.insert(0, notification);
    await _save();
    notifyListeners();
  }

  @override
  Future<void> init() async {
    await _ensureLoaded();
  }

  @override
  Future<void> sendToAdmin({required String title, required String body}) async {
    await _push(_build(title: title, body: body, targetRole: 'admin'));
  }

  @override
  Future<void> sendToDriver({
    required String driverId,
    required String title,
    required String body,
  }) async {
    await _push(
      _build(
        title: title,
        body: body,
        targetRole: 'driver',
        targetEmail: driverId,
      ),
    );
  }

  @override
  Future<void> sendToCustomer({
    required String customerEmail,
    required String title,
    required String body,
  }) async {
    await _push(
      _build(
        title: title,
        body: body,
        targetRole: 'customer',
        targetEmail: customerEmail,
      ),
    );
  }

  @override
  Future<List<AppNotification>> loadInbox({
    required String role,
    String? email,
  }) async {
    await _ensureLoaded();
    return _items.where((item) {
      if (item.targetRole != role) return false;
      if (item.targetEmail == null) return true;
      return item.targetEmail == email;
    }).toList();
  }

  @override
  Future<void> markRead(String notificationId) async {
    await _ensureLoaded();
    final idx = _items.indexWhere((n) => n.id == notificationId);
    if (idx == -1) return;
    _items[idx].isRead = true;
    await _save();
    notifyListeners();
  }
}
