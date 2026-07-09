import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService extends ChangeNotifier {
  static const _balancesKey = 'jawan_wallet_balances_v2';
  static const _transactionsKey = 'jawan_wallet_transactions_v2';

  SharedPreferences? _prefs;
  final Map<String, double> _balances = {};
  final List<Map<String, dynamic>> _transactions = [];
  double companyCommissionTotal = 0.0;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _load();
  }

  Future<void> _load() async {
    final balancesRaw = _prefs!.getString(_balancesKey);
    final txRaw = _prefs!.getString(_transactionsKey);

    _balances.clear();
    _transactions.clear();
    companyCommissionTotal = 0.0;

    if (balancesRaw != null && balancesRaw.isNotEmpty) {
      try {
        final decoded = json.decode(balancesRaw) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          _balances[key] = (value as num).toDouble();
        });
      } catch (_) {}
    }

    if (txRaw != null && txRaw.isNotEmpty) {
      try {
        final decoded = json.decode(txRaw) as List<dynamic>;
        for (final item in decoded) {
          final map = Map<String, dynamic>.from(item as Map);
          final type = map['type'] as String? ?? '';
          final amount = (map['amount'] as num?)?.toDouble() ?? 0.0;
          if (map['time'] is String) {
            map['time'] = DateTime.tryParse(map['time'] as String) ?? DateTime.now();
          }
          _transactions.add(map);
          if (type == 'commission') {
            companyCommissionTotal += amount;
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_balancesKey, json.encode(_balances));
    await _prefs!.setString(
      _transactionsKey,
      json.encode(
        _transactions.map((t) {
          final copy = Map<String, dynamic>.from(t);
          final time = copy['time'];
          if (time is DateTime) {
            copy['time'] = time.toIso8601String();
          }
          return copy;
        }).toList(),
      ),
    );
  }

  double balanceOf(String driverEmail) => _balances[driverEmail] ?? 0.0;

  List<Map<String, dynamic>> transactionsOf(String driverEmail) {
    return _transactions
        .where((t) => t['driverEmail'] == driverEmail)
        .toList()
        .reversed
        .toList();
  }

  Future<void> topUp({
    required String driverEmail,
    required double amount,
    required String source,
  }) async {
    await init();
    _balances[driverEmail] = balanceOf(driverEmail) + amount;
    _transactions.add({
      'driverEmail': driverEmail,
      'type': 'topup',
      'amount': amount,
      'source': source,
      'time': DateTime.now(),
    });
    await _save();
    notifyListeners();
  }

  Future<void> addEarning({
    required String driverEmail,
    required double amount,
    required String orderId,
  }) async {
    await init();
    _balances[driverEmail] = balanceOf(driverEmail) + amount;
    _transactions.add({
      'driverEmail': driverEmail,
      'type': 'earning',
      'amount': amount,
      'orderId': orderId,
      'time': DateTime.now(),
    });
    await _save();
    notifyListeners();
  }

  Future<void> addCommission({
    required String driverEmail,
    required double amount,
    required String orderId,
  }) async {
    await init();
    companyCommissionTotal += amount;
    _transactions.add({
      'driverEmail': driverEmail,
      'type': 'commission',
      'amount': amount,
      'orderId': orderId,
      'time': DateTime.now(),
    });
    await _save();
    notifyListeners();
  }

  Future<void> withdraw({
    required String driverEmail,
    required double amount,
    required String reason,
  }) async {
    await init();
    _balances[driverEmail] = balanceOf(driverEmail) - amount;
    _transactions.add({
      'driverEmail': driverEmail,
      'type': 'withdraw',
      'amount': amount,
      'reason': reason,
      'time': DateTime.now(),
    });
    await _save();
    notifyListeners();
  }
}
