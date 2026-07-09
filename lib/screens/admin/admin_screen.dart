import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../models/order_status.dart';
import '../../services/order_service.dart';
import '../../services/topup_service.dart';
import '../../services/user_store.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Future<void> block(String email) async {
    await UserStore.blockUser(email);
    if (mounted) setState(() {});
  }

  Future<void> unblock(String email) async {
    await UserStore.unblockUser(email);
    if (mounted) setState(() {});
  }

  Future<void> acceptOrder(String id) async {
    final driverCtrl = TextEditingController();

    final driverEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعيين سائق'),
        content: TextField(
          controller: driverCtrl,
          decoration: const InputDecoration(labelText: 'إيميل السائق'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(driverCtrl.text.trim()),
            child: const Text('قبول'),
          ),
        ],
      ),
    );

    if (driverEmail == null || driverEmail.isEmpty) return;
    final ok = await context.read<OrderService>().adminAccept(id, driverEmail);
    if (ok && mounted) setState(() {});
  }

  Future<void> rejectOrder(String id) async {
    await context.read<OrderService>().adminReject(id);
    if (mounted) setState(() {});
  }

  Future<void> _deleteOrder(BuildContext context, String id) async {
    final ok = await context.read<OrderService>().deleteOrder(id);
    if (ok && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الطلب')),
      );
    }
  }

  Future<void> _editOrder(BuildContext context, Order order) async {
    final fromCtrl = TextEditingController(text: order.from);
    final toCtrl = TextEditingController(text: order.to);
    final typeCtrl = TextEditingController(text: order.type);
    final descCtrl = TextEditingController(text: order.description);
    final priceCtrl = TextEditingController(text: order.price.toString());
    final driverCtrl = TextEditingController(text: order.driverEmail ?? '');
    var status = order.status;

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل الطلب'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: fromCtrl, decoration: const InputDecoration(labelText: 'من')),
              TextField(controller: toCtrl, decoration: const InputDecoration(labelText: 'إلى')),
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'النوع')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'الوصف')),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'السعر')),
              TextField(controller: driverCtrl, decoration: const InputDecoration(labelText: 'إيميل السائق')),
              const SizedBox(height: 12),
              DropdownButtonFormField<OrderStatus>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'الحالة'),
                items: OrderStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) status = v;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newOrder = Order(
                id: order.id,
                customerEmail: order.customerEmail,
                driverEmail: driverCtrl.text.trim().isEmpty ? null : driverCtrl.text.trim(),
                from: fromCtrl.text.trim(),
                to: toCtrl.text.trim(),
                type: typeCtrl.text.trim(),
                description: descCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text.trim()) ?? order.price,
                status: status,
              );

              await context.read<OrderService>().updateOrder(newOrder);
              if (ctx.mounted) Navigator.of(ctx).pop(true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (res == true && mounted) setState(() {});
  }

  Future<void> _approveTopup(String id) async {
    await context.read<TopupService>().approve(id);
    if (mounted) setState(() {});
  }

  Future<void> _rejectTopup(String id) async {
    await context.read<TopupService>().reject(id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final orderService = context.watch<OrderService>();
    final topupService = context.watch<TopupService>();
    final pending = orderService.pendingOrders();
    final allOrders = orderService.orders;
    final usersFuture = UserStore.loadUsers();

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "لوحة التحكم",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('إجمالي الطلبات'),
              subtitle: Text('${allOrders.length}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('الطلبات المعلقة'),
              subtitle: Text('${pending.length}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('طلبات الشحن المعلقة'),
              subtitle: Text('${topupService.pending.length}'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "طلبات الشحن",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (topupService.pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('لا توجد طلبات شحن معلقة'),
            )
          else
            ...topupService.pending.map((r) {
              return Card(
                child: ListTile(
                  title: Text('${r.amount} - ${r.method}'),
                  subtitle: Text('السائق: ${r.driverEmail}\nالحالة: ${r.status}'),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => _approveTopup(r.id),
                        child: const Text('قبول'),
                      ),
                      TextButton(
                        onPressed: () => _rejectTopup(r.id),
                        child: const Text('رفض'),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
          const Text(
            "الطلبات المعلقة",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('لا توجد طلبات معلقة'),
            )
          else
            ...pending.map((o) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${o.from} → ${o.to}"),
                      Text("السعر: ${o.price}"),
                      Text("الحالة: ${o.status.label}"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => acceptOrder(o.id),
                              child: const Text("قبول"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => rejectOrder(o.id),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text("رفض"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 30),
          const Text(
            "جميع الطلبات",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (allOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('لا توجد طلبات بعد'),
            )
          else
            ...allOrders.map((o) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${o.from} → ${o.to}"),
                      Text("السعر: ${o.price}"),
                      Text("الحالة: ${o.status.label}"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _editOrder(context, o),
                            child: const Text("تعديل"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _deleteOrder(context, o.id),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("حذف"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
          const Text(
            "المستخدمون",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FutureBuilder(
            future: usersFuture,
            builder: (context, snapshot) {
              final users = snapshot.data ?? [];
              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('لا يوجد مستخدمون بعد'),
                );
              }

              return Column(
                children: users.map((u) {
                  return Card(
                    child: ListTile(
                      title: Text(u.email),
                      subtitle: Text('${u.role} - ${u.isBlocked ? 'موقوف' : 'نشط'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!u.isBlocked)
                            IconButton(
                              icon: const Icon(Icons.block),
                              onPressed: () => block(u.email),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () => unblock(u.email),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
