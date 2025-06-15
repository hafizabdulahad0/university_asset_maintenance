// File: lib/helpers/notification_helper.dart

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level entry for background FCM messages.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure plugin binding, if you ever perform more async work here:
  final helper = NotificationHelper.instance;
  await helper._ensureInitialized();
  await helper.showNotification(message);
}

class NotificationHelper {
  NotificationHelper._();
  static final NotificationHelper instance = NotificationHelper._();

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  // A single channel for all high-priority notifications
  final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications',
    importance: Importance.high,
  );

  bool _initialized = false;

  /// Call exactly once at app startup.
  /// Hooks into FCM and local notifications.
  Future<void> initialize() async => _ensureInitialized();

  /// Internal initializer.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    // 1) iOS / macOS permission
    if (Platform.isIOS || Platform.isMacOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // 2) Initialize flutter_local_notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _fln.initialize(
      InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        macOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        // optional: handle when user taps the notification
      },
    );

    // 3) Create (or update) the Android notification channel
    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 4) Register FCM handlers
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(showNotification);
  }

  /// Display a native banner for the given FCM message.
  Future<void> showNotification(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      icon: n.android?.smallIcon ?? '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
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
