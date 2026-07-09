import '../models/app_notification.dart';
import 'notification_service.dart';

class FcmNotificationService implements NotificationService {
  FcmNotificationService();

  @override
  Future<void> init() async {}

  @override
  Future<void> sendToDriver({
    required String driverId,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> sendToCustomer({
    required String customerEmail,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> sendToAdmin({required String title, required String body}) async {}

  @override
  Future<List<AppNotification>> loadInbox({
    required String role,
    String? email,
  }) async {
    return const [];
  }

  @override
  Future<void> markRead(String notificationId) async {}
}
