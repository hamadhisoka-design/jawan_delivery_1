  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

  import '../../services/local_notification_service.dart';
  import '../../services/session.dart';

  class NotificationsScreen extends StatelessWidget {
    const NotificationsScreen({super.key});

    @override
    Widget build(BuildContext context) {
      final service = context.watch<LocalNotificationService>();
      final role = Session.role ?? 'customer';
      final email = Session.email;

      final items = service.items.where((item) {
        if (item.targetRole != role) return false;
        if (item.targetEmail == null) return true;
        return item.targetEmail == email;
      }).toList();

      if (items.isEmpty) {
        return const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('لا توجد إشعارات بعد'),
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    item.isRead ? Icons.notifications_none : Icons.notifications_active,
                  ),
                ),
                title: Text(item.title),
                subtitle: Text(
                  '${item.body}\n${item.createdAt}',
                ),
                isThreeLine: true,
                trailing: item.isRead
                    ? const Icon(Icons.done_all, color: Colors.green)
                    : TextButton(
                        onPressed: () => context.read<LocalNotificationService>().markRead(item.id),
                        child: const Text('تمت القراءة'),
                      ),
              ),
            );
          },
        ),
      );
    }
  }
