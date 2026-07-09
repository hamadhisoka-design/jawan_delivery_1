import 'dart:convert';

import 'order_status.dart';

class Order {
  final String id;
  final String customerEmail;
  String? driverEmail;

  final String from;
  final String to;
  final String type;
  final String description;
  final double price;

  OrderStatus status;

  Order({
    required this.id,
    required this.customerEmail,
    this.driverEmail,
    required this.from,
    required this.to,
    required this.type,
    required this.description,
    required this.price,
    this.status = OrderStatus.pending,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerEmail': customerEmail,
        'driverEmail': driverEmail,
        'from': from,
        'to': to,
        'type': type,
        'description': description,
        'price': price,
        'status': status.name,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        customerEmail: json['customerEmail'] as String,
        driverEmail: json['driverEmail'] as String?,
        from: json['from'] as String,
        to: json['to'] as String,
        type: json['type'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        status: OrderStatusExtension.fromName(json['status'] as String? ?? 'pending'),
      );

  String encode() => json.encode(toJson());

  static Order decode(String source) => Order.fromJson(json.decode(source) as Map<String, dynamic>);
}
