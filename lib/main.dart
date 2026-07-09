import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/local_notification_service.dart';
import 'services/local_persistence_service.dart';
import 'services/notification_service.dart';
import 'services/order_service.dart';
import 'services/session.dart';
import 'services/topup_service.dart';
import 'services/user_store.dart';
import 'services/wallet_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Session.init();
  await UserStore.ensureSeedData();

  final persistence = LocalPersistenceService();
  await persistence.init();

  final notifier = LocalNotificationService();
  await notifier.init();

  final walletService = WalletService();
  await walletService.init();

  final topupService = TopupService(
    walletService: walletService,
    notifier: notifier,
  );
  await topupService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalPersistenceService>.value(value: persistence),
        Provider<NotificationService>.value(value: notifier),
        ChangeNotifierProvider<LocalNotificationService>.value(value: notifier),
        ChangeNotifierProvider<WalletService>.value(value: walletService),
        ChangeNotifierProvider<TopupService>.value(value: topupService),
        ChangeNotifierProvider(
          create: (context) => OrderService(
            walletService: context.read<WalletService>(),
            persistence: context.read<LocalPersistenceService>(),
            notifier: context.read<NotificationService>(),
          ),
        ),
      ],
      child: const JawanDeliveryApp(),
    ),
  );
}
