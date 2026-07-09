import 'package:flutter/material.dart';

import '../services/session.dart';
import '../services/user_store.dart';
import 'admin/admin_screen.dart';
import 'auth/auth_screen.dart';
import 'customer/create_order_screen.dart';
import 'customer/customer_orders_screen.dart';
import 'driver/driver_orders_screen.dart';
import 'driver/driver_wallet_screen.dart';
import 'driver/topup_screen.dart';
import 'notifications/notifications_screen.dart';
import 'tab_placeholder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  List<Widget> get _pages {
    if (Session.role == "admin") {
      return const [
        AdminScreen(),
        TabPlaceholder(
          title: 'الطلبات',
          icon: Icons.list,
          description: 'هنا ستظهر الطلبات بالتفصيل لاحقًا.',
        ),
        TabPlaceholder(
          title: 'الحساب',
          icon: Icons.person,
          description: 'بيانات الإدارة هنا.',
        ),
      ];
    }

    if (Session.role == "driver") {
      return const [
        DriverOrdersScreen(),
        DriverWalletScreen(),
        TopupScreen(),
      ];
    }

    return const [
      CreateOrderScreen(),
      CustomerOrdersScreen(),
      TabPlaceholder(
        title: 'حسابي',
        icon: Icons.person,
        description: 'بيانات العميل هنا.',
      ),
    ];
  }

  Future<void> _logout() async {
    await Session.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  Future<void> _deleteAccount() async {
    final email = Session.email;
    if (email == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text('سيتم حذف الحساب المحلي وتسجيل الخروج. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (Session.role != 'admin') {
      await UserStore.deleteUser(email);
    }

    await Session.logout();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Session.isLoggedIn) {
      return const AuthScreen();
    }

    final role = Session.role ?? 'customer';

    return Scaffold(
      appBar: AppBar(
        title: Text("جوان للتوصيل - ${Session.name ?? ''}"),
        actions: [
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await _logout();
              } else if (value == 'delete') {
                await _deleteAccount();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('تسجيل الخروج'),
              ),
              if (role != 'admin')
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('حذف الحساب'),
                ),
            ],
          ),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "الطلبات",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "الحساب",
          ),
        ],
      ),
    );
  }
}
