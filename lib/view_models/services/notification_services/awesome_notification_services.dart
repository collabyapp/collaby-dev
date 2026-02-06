import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:collaby_app/view_models/services/notification_services/permission_services.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

String notificationAlertsKey = "alerts";
class AwsomeNotificationService {
  final AwesomeNotifications _notifications = AwesomeNotifications();
  Future initializeNotification() async {
    await PermissionService().checkPermission(Permission.notification);
    await _notifications.initialize(
      null,
      // 'resource://drawable/pic',
      [
        NotificationChannel(
          channelKey: notificationAlertsKey,
          channelName: 'Alerts',
          channelDescription: 'Notification tests as alerts',
          playSound: true,
          // soundSource: 'resource://raw/notificationsound',
          defaultRingtoneType: DefaultRingtoneType.Notification,
          onlyAlertOnce: false,
          groupAlertBehavior: GroupAlertBehavior.Children,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Public,
          defaultColor: Colors.deepPurple,
          ledColor: Colors.deepPurple,
        )
      ],
      // debug: false
    );
  }
  Future<void> setNotificationListners() async {
    await _notifications.setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod);
  }
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("init noification created");
  }
  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("init notification displayed aaction");
  }
  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint("init dismiss aaction received");
  }
  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint("init aaction recieved");
    debugPrint("Payload : ${receivedAction.payload}");
  }
  Future showNotification(
      {required int notificationId,
      required String title,
      required String body,
      String? imagePath,
      Map<String, String?>? payload = const {}}) async {
    bool notificationPermissionGranted =
        await _notifications.isNotificationAllowed();
    if (notificationPermissionGranted) {
      await _notifications.createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: notificationAlertsKey,
          title: title,
          body: body,
          bigPicture: imagePath,
          // largeIcon: 'asset://assets/pic.png',
          notificationLayout: NotificationLayout.BigPicture,
          actionType: ActionType.Default,
          color: Colors.black,
          backgroundColor: Colors.black,
          // customSound: 'resource://raw/notificationsound.wav',
          payload: payload,
        ),
      );
    } else {
      await PermissionService().checkPermission(Permission.notification);
    }
  }
  Future scheduleNotification(
      {required int notificationId,
      required String title,
      required String body,
      String? imagePath,
      Map<String, String?>? payload = const {},
      required DateTime scheduleDateTime,
      bool repeat = true}) async {
    bool notificationPermissionGranted =
        await _notifications.isNotificationAllowed();
    if (notificationPermissionGranted) {
      String localTimezone = await FlutterTimezone.getLocalTimezone();
      final content = NotificationContent(
          id: -1,
          channelKey: notificationAlertsKey,
          title: title,
          body: body,
          bigPicture: imagePath,
          notificationLayout: NotificationLayout.BigPicture,
          actionType: ActionType.Default,
          color: Colors.black,
          backgroundColor: Colors.black,
          customSound: 'resource://raw/notificationsound.wav',
          payload: payload);
      final schedule = NotificationCalendar(
          weekday: scheduleDateTime.weekday,
          hour: null,
          //scheduleDateTime.hour,
          minute: null,
          //scheduleDateTime.minute,
          second: 2,
          //scheduleDateTime.second,
          repeats: true,
          allowWhileIdle: true,
          timeZone: localTimezone);
      await _notifications.createNotification(
        content: content,
        schedule: schedule,
      );
    } else {
      await PermissionService().checkPermission(Permission.notification);
    }
  }
  Future cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  Future cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}



