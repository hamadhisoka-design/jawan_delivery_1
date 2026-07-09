import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'persistence_service.dart';
import '../models/order.dart';

class LocalPersistenceService implements PersistenceService {
  static const _ordersKey = 'jawan_orders_v1';
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<void> clearAll() async {
    await init();
    await _prefs!.remove(_ordersKey);
  }

  @override
  Future<List<Order>> loadOrders() async {
    await init();
    final raw = _prefs!.getString(_ordersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveOrders(List<Order> orders) async {
    await init();
    final list = orders.map((e) => e.toJson()).toList();
    await _prefs!.setString(_ordersKey, json.encode(list));
  }
}
