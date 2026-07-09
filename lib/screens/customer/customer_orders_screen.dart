import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/order_service.dart';
import '../../services/session.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderService>().customerOrders(Session.email ?? "");

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: orders.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 180),
                Center(child: Text("لا توجد طلبات بعد")),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${order.from} → ${order.to}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("النوع: ${order.type}"),
                        Text("الوصف: ${order.description.isEmpty ? 'لا يوجد' : order.description}"),
                        Text("السعر: ${order.price}"),
                        Text("السائق: ${order.driverEmail ?? 'لم يتم التعيين بعد'}"),
                        const SizedBox(height: 8),
                        Text(
                          "الحالة: ${order.status.label}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
