import '../models/app_notification.dart';

abstract class NotificationService {
  Future<void> init();

  Future<void> sendToDriver({
    required String driverId,
    required String title,
    required String body,
  });

  Future<void> sendToCustomer({
    required String customerEmail,
    required String title,
    required String body,
  });

  Future<void> sendToAdmin({
    required String title,
    required String body,
  });

  Future<List<AppNotification>> loadInbox({
    required String role,
    String? email,
  });

  Future<void> markRead(String notificationId);
}
