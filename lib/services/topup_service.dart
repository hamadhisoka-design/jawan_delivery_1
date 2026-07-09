import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/topup_request.dart';
import 'notification_service.dart';
import 'wallet_service.dart';

class TopupService extends ChangeNotifier {
  static const _key = 'jawan_topup_requests_v2';

  final WalletService walletService;
  final NotificationService? notifier;
  final List<TopupRequest> _requests = [];
  SharedPreferences? _prefs;
  bool _loaded = false;

  TopupService({
    required this.walletService,
    this.notifier,
  });

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (_loaded) return;
    final raw = _prefs!.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as List<dynamic>;
        _requests
          ..clear()
          ..addAll(decoded.map((e) => TopupRequest.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        _requests.clear();
      }
    }
    _loaded = true;
  }

  Future<void> _save() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_key, json.encode(_requests.map((r) => r.toJson()).toList()));
  }

  List<TopupRequest> get pending => _requests.where((r) => r.status == "pending").toList();

  List<TopupRequest> byDriver(String email) => _requests.where((r) => r.driverEmail == email).toList();

  Future<void> createRequest(TopupRequest request) async {
    await init();
    _requests.insert(0, request);
    await _save();
    await notifier?.sendToAdmin(
      title: 'طلب شحن جديد',
      body: 'السائق ${request.driverEmail} طلب شحن ${request.amount} عبر ${request.method}',
    );
    notifyListeners();
  }

  Future<void> approve(String id) async {
    await init();
    final req = _requests.firstWhere((r) => r.id == id);
    if (req.status != "pending") return;

    req.status = "approved";
    await walletService.topUp(
      driverEmail: req.driverEmail,
      amount: req.amount,
      source: req.method,
    );
    await notifier?.sendToDriver(
      driverId: req.driverEmail,
      title: 'تمت الموافقة على الشحن',
      body: 'تمت الموافقة على طلب شحن ${req.amount} عبر ${req.method}',
    );
    await _save();
    notifyListeners();
  }

  Future<void> reject(String id) async {
    await init();
    final req = _requests.firstWhere((r) => r.id == id);
    if (req.status != "pending") return;

    req.status = "rejected";
    await notifier?.sendToDriver(
      driverId: req.driverEmail,
      title: 'تم رفض طلب الشحن',
      body: 'تم رفض طلب شحن ${req.amount} عبر ${req.method}',
    );
    await _save();
    notifyListeners();
  }
}
