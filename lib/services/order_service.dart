import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/order_status.dart';
import 'notification_service.dart';
import 'persistence_service.dart';
import 'user_store.dart';
import 'wallet_service.dart';

class OrderService extends ChangeNotifier {
  final WalletService walletService;
  final PersistenceService? persistence;
  final NotificationService? notifier;

  final List<Order> _orders = [];
  bool _loaded = false;

  OrderService({
    required this.walletService,
    this.persistence,
    this.notifier,
  }) {
    _loadFromPersistence();
  }

  Future<void> _loadFromPersistence() async {
    if (_loaded) return;
    if (persistence == null) {
      _loaded = true;
      return;
    }

    final loaded = await persistence!.loadOrders();
    _orders
      ..clear()
      ..addAll(loaded);
    _loaded = true;
    notifyListeners();
  }

  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> addOrder(Order order) async {
    await _loadFromPersistence();
    _orders.insert(0, order);
    notifyListeners();
    await persistence?.saveOrders(_orders);

    await notifier?.sendToAdmin(
      title: 'طلب جديد',
      body: 'تم إنشاء طلب جديد من ${order.from} إلى ${order.to}',
    );

    await notifier?.sendToCustomer(
      customerEmail: order.customerEmail,
      title: 'تم استلام طلبك',
      body: 'تم تسجيل طلبك بنجاح من ${order.from} إلى ${order.to}',
    );

    await _notifyDriversOfNewOrder(order);
  }

  Future<void> _notifyDriversOfNewOrder(Order order) async {
    final users = await UserStore.loadUsers();
    final driverEmails = users
        .where((u) => u.role == 'driver' && !u.isBlocked)
        .map((u) => u.email)
        .toList();

    for (final email in driverEmails) {
      await notifier?.sendToDriver(
        driverId: email,
        title: 'طلب جديد',
        body: 'طلب جديد من ${order.from} إلى ${order.to}',
      );
    }
  }

  Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Order> pendingOrders() => _orders.where((o) => o.status == OrderStatus.pending).toList();

  List<Order> driverOrders(String email) => _orders.where((o) => o.driverEmail == email).toList();

  List<Order> customerOrders(String email) => _orders.where((o) => o.customerEmail == email).toList();

  List<Order> ordersForCustomer(String email) => customerOrders(email);

  Future<bool> adminAccept(String id, String driverEmail) async {
    await _loadFromPersistence();
    final order = getById(id);
    if (order == null || order.status != OrderStatus.pending) return false;

    order.driverEmail = driverEmail;
    order.status = OrderStatus.accepted;
    notifyListeners();
    await persistence?.saveOrders(_orders);
    await notifier?.sendToDriver(
      driverId: driverEmail,
      title: 'تم تعيين طلب',
      body: 'تم تعيين طلب ${order.id} لك',
    );
    await notifier?.sendToCustomer(
      customerEmail: order.customerEmail,
      title: 'تم تعيين سائق لطلبك',
      body: 'تم تعيين السائق $driverEmail لطلبك ${order.id}',
    );
    return true;
  }

  Future<void> adminReject(String id) async {
    await _loadFromPersistence();
    final order = getById(id);
    if (order == null) return;

    order.status = OrderStatus.cancelled;
    notifyListeners();
    await persistence?.saveOrders(_orders);
    await notifier?.sendToCustomer(
      customerEmail: order.customerEmail,
      title: 'تم إلغاء الطلب',
      body: 'تم إلغاء طلبك ${order.id}',
    );
  }

  Future<bool> acceptOrder(String id, String driverEmail) async {
    await _loadFromPersistence();
    final order = getById(id);
    if (order == null || order.status != OrderStatus.pending) return false;

    order.driverEmail = driverEmail;
    order.status = OrderStatus.accepted;
    notifyListeners();
    await persistence?.saveOrders(_orders);
    await notifier?.sendToDriver(
      driverId: driverEmail,
      title: 'تم قبول طلب',
      body: 'تم تعيين طلب ${order.id} لك',
    );
    await notifier?.sendToCustomer(
      customerEmail: order.customerEmail,
      title: 'تم قبول طلبك',
      body: 'تم قبول طلبك بواسطة السائق $driverEmail',
    );
    return true;
  }

  Future<bool> updateStatus(
    String id,
    String driverEmail,
    OrderStatus status,
  ) async {
    await _loadFromPersistence();
    final order = getById(id);
    if (order == null) return false;
    if (order.driverEmail != driverEmail) return false;

    if (status == OrderStatus.picked && order.status == OrderStatus.accepted) {
      order.status = OrderStatus.picked;
      notifyListeners();
      await persistence?.saveOrders(_orders);
      await notifier?.sendToCustomer(
        customerEmail: order.customerEmail,
        title: 'تم استلام الطلب',
        body: 'السائق استلم طلبك ${order.id}',
      );
      return true;
    }

    if (status == OrderStatus.delivered && order.status == OrderStatus.picked) {
      order.status = OrderStatus.delivered;

      final driverShare = order.price * 0.95;
      final commission = order.price * 0.05;

      await walletService.addEarning(
        driverEmail: driverEmail,
        amount: driverShare,
        orderId: id,
      );

      await walletService.addCommission(
        driverEmail: driverEmail,
        amount: commission,
        orderId: id,
      );

      notifyListeners();
      await persistence?.saveOrders(_orders);
      await notifier?.sendToCustomer(
        customerEmail: order.customerEmail,
        title: 'تم تسليم الطلب',
        body: 'تم تسليم طلبك ${order.id} بنجاح',
      );
      await notifier?.sendToAdmin(
        title: 'تم التسليم',
        body: 'تم تسليم الطلب ${order.id} بواسطة $driverEmail',
      );
      return true;
    }

    return false;
  }

  Future<bool> updateStatusForDriver(String id, String driverEmail, String status) =>
      updateStatus(id, driverEmail, OrderStatusExtension.fromName(status));

  Future<bool> updateOrder(Order updated) async {
    await _loadFromPersistence();
    final idx = _orders.indexWhere((o) => o.id == updated.id);
    if (idx == -1) return false;

    _orders[idx] = updated;
    notifyListeners();
    await persistence?.saveOrders(_orders);

    if (updated.driverEmail != null && updated.status == OrderStatus.accepted) {
      await notifier?.sendToDriver(
        driverId: updated.driverEmail!,
        title: 'تم تعيين طلب',
        body: 'تم تعيين الطلب ${updated.id} لك',
      );
    }

    return true;
  }

  Future<bool> deleteOrder(String id) async {
    await _loadFromPersistence();
    final existsBefore = _orders.any((o) => o.id == id);
    if (!existsBefore) return false;
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
    await persistence?.saveOrders(_orders);
    return true;
  }
}
