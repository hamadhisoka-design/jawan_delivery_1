enum OrderStatus { pending, accepted, picked, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  static OrderStatus fromName(String name) {
    switch (name) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'picked':
        return OrderStatus.picked;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.accepted:
        return 'مقبول';
      case OrderStatus.picked:
        return 'تم الاستلام';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغى';
    }
  }
}
