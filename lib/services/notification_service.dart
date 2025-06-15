// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final _inst = NotificationService._();
  factory NotificationService() => _inst;
  NotificationService._();

  final _fln = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios    = DarwinInitializationSettings();
    await _fln.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) { /* handle tap if needed */ },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseBgHandler);
  }

  Future<void> showNotificationFromFCM(RemoteMessage msg) async {
    final n = msg.notification;
    if (n == null) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications',
      importance: Importance.max,
    );
    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final androidDetails = AndroidNotificationDetails(
      channel.id, channel.name,
      channelDescription: channel.description,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();

    await _fln.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}

Future<void> _firebaseBgHandler(RemoteMessage msg) async {
  await NotificationService().showNotificationFromFCM(msg);
}
