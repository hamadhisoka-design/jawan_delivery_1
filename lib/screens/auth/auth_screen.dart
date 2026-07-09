import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/session.dart';
import '../../services/user_store.dart';
import '../../utils/constants.dart';
import '../home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "customer";
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أكمل الإيميل وكلمة المرور")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      if (isLogin) {
        if (email == adminEmail && password == adminPassword) {
          await Session.login(
            userEmail: email,
            userRole: "admin",
            userName: "Admin",
            userPhone: "",
          );

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return;
        }

        final user = await UserStore.login(email, password);

        if (!mounted) return;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("بيانات الدخول غير صحيحة")),
          );
          return;
        }

        await Session.login(
          userEmail: user.email,
          userRole: user.role,
          userName: user.name,
          userPhone: user.phone,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        final name = nameController.text.trim();
        final phone = phoneController.text.trim();

        if (name.isEmpty || phone.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("أكمل الاسم والهاتف")),
          );
          return;
        }

        final user = AppUser(
          name: name,
          email: email,
          phone: phone,
          password: password,
          role: role,
        );

        final ok = await UserStore.register(user);

        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("هذا الإيميل مسجل بالفعل")),
          );
          return;
        }

        await Session.login(
          userEmail: user.email,
          userRole: user.role,
          userName: user.name,
          userPhone: user.phone,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "جوان للتوصيل",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("دخول الإدارة: بريد وكلمة مرور فقط"),
              const SizedBox(height: 24),
              ToggleButtons(
                isSelected: [isLogin, !isLogin],
                onPressed: (index) {
                  setState(() {
                    isLogin = index == 0;
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("تسجيل دخول"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("إنشاء حساب"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!isLogin) ...[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "الاسم",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "الإيميل",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (!isLogin) ...[
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "رقم الهاتف",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(
                    labelText: "نوع الحساب",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "customer", child: Text("عميل")),
                    DropdownMenuItem(value: "driver", child: Text("سائق")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => role = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "كلمة المرور",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : handleSubmit,
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isLogin ? "دخول" : "إنشاء الحساب"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
