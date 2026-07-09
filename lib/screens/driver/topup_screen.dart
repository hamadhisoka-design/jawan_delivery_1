import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/topup_request.dart';
import '../../services/session.dart';
import '../../services/topup_service.dart';

class TopupScreen extends StatefulWidget {
  const TopupScreen({super.key});

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  final amountController = TextEditingController();
  String method = "بنكك";

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) return;

    await context.read<TopupService>().createRequest(
      TopupRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        driverEmail: Session.email ?? "",
        amount: amount,
        method: method,
        time: DateTime.now(),
      ),
    );

    amountController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إرسال طلب الشحن")),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final myRequests = context.watch<TopupService>().byDriver(Session.email ?? "");

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "شحن المحفظة",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "المبلغ",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: method,
          items: const [
            DropdownMenuItem(value: "بنكك", child: Text("بنكك")),
            DropdownMenuItem(value: "فوري", child: Text("فوري")),
            DropdownMenuItem(value: "أوكاش", child: Text("أوكاش")),
            DropdownMenuItem(value: "ماي كاشي", child: Text("ماي كاشي")),
          ],
          onChanged: (v) => setState(() => method = v ?? "بنكك"),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: submit,
          child: const Text("إرسال طلب الشحن"),
        ),
        const SizedBox(height: 20),
        const Text(
          "طلباتي",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...myRequests.map((r) {
          return Card(
            child: ListTile(
              title: Text("${r.amount} - ${r.method}"),
              subtitle: Text("الحالة: ${r.status}"),
            ),
          );
        }),
      ],
    );
  }
}
