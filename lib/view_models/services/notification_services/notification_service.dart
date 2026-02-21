import 'dart:developer';

import 'package:collaby_app/view_models/services/notification_services/awesome_notification_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationServices {
  Future<void> handleForegroundNotification() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint(':calling: Foreground notification received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');

      // Show local notification manually only in foreground on mobile non-iOS.
      if (!kIsWeb &&
          defaultTargetPlatform != TargetPlatform.iOS &&
          message.notification?.title != null &&
          message.notification?.body != null) {
        await AwsomeNotificationService().showNotification(
          notificationId: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: message.notification!.title!,
          body: message.notification!.body!,
        );
      }
    });
  }

  static Future<String?> getDeviceToken() async {
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log('FCM Device Token: $token');
      } else {
        log('Failed to retrieve FCM Token');
      }
    } catch (e) {
      log('Error retrieving FCM token: $e');
    }
    return token;
  }
}

@pragma('vm:entry-point')
Future<void> handleBackgroundNotification(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(':inbox_tray: Background notification received');
  debugPrint('Message Data: ${message.data}');
}
