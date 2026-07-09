import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/session.dart';
import '../../services/wallet_service.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  @override
  Widget build(BuildContext context) {
    final email = Session.email ?? "";
    final walletService = context.watch<WalletService>();
    final balance = walletService.balanceOf(email);
    final transactions = walletService.transactionsOf(email);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "محفظة السائق",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "الرصيد: ${balance.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "إجمالي عمولة الشركة: ${walletService.companyCommissionTotal.toStringAsFixed(2)}",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "آخر العمليات",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text("لا توجد عمليات بعد")),
            )
          else
            ...transactions.map((t) {
              final type = t['type'] ?? '';
              final amount = (t['amount'] ?? 0).toDouble();
              final time = t['time'] as DateTime;

              String title = 'عملية';
              if (type == 'earning') title = 'دخل من طلب';
              if (type == 'commission') title = 'عمولة 5%';
              if (type == 'withdraw') title = 'سحب';
              if (type == 'topup') title = 'شحن محفظة';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(
                    "المبلغ: ${amount.toStringAsFixed(2)}\nالوقت: ${time.toString()}",
                  ),
                  isThreeLine: true,
                ),
              );
            }),
        ],
      ),
    );
  }
}
