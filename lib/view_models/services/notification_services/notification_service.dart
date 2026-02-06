import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:collaby_app/view_models/services/notification_services/awesome_notification_services.dart';
import 'package:flutter/material.dart';
class NotificationServices {
  Future<void> handleForegroundNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint(":calling: Foreground notification received");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");
      // Show local notification manually only in foreground
      if (Platform.isIOS != true &&
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

  /// ðŸš€ Get FCM Token function
  static Future<String?> getDeviceToken() async {
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log('ðŸ“± FCM Device Token: $token');
      } else {
        log('âš ï¸ Failed to retrieve FCM Token');
      }
    } catch (e) {
      log('âŒ Error retrieving FCM token: $e');
    }
    return token;
  }

  // Future<String?> getFcmToken() async {
  //   var token = await _messaging.getToken();
  //   debugPrint(":envelope_with_arrow: FCM Token: $token");
  //   return token;
  // }
}
/// :back: Background or terminated state handler
@pragma('vm:entry-point')
Future<void> handleBackgroundNotification(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(":inbox_tray: Background notification received");
  debugPrint("Message Data: ${message.data}");
  // :x: Do NOT show local notification here to avoid duplicate
  // Firebase shows it automatically in background/terminated
}


