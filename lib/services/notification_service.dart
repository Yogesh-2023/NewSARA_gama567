import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(initSettings);

    // Create notification channel
    const channel = AndroidNotificationChannel(
      'default_channel',
      'Default Channel',
      description: 'Used for general notifications.',
      importance: Importance.high,
    );

    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    if (message.notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        channelDescription: 'Used for general notifications.',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification!.title ?? 'Notification',
        message.notification!.body ?? '',
        platformDetails,
        payload: message.data.toString(),
      );
    }
  }

  void handleForegroundMessage(RemoteMessage message) {
    print("Received foreground message: ${message.messageId}");
    print("Message data: ${message.data}");
    print("Message notification: ${message.notification?.toMap()}");

    // Show local notification when app is in foreground
    showLocalNotification(message);
  }
}