import 'package:flutter/foundation.dart';

import '../models/order.dart';

abstract class PersistenceService {
  Future<void> init();

  Future<List<Order>> loadOrders();

  Future<void> saveOrders(List<Order> orders);

  Future<void> clearAll();
}
