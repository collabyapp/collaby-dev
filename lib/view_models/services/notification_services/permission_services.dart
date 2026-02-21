import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final _permission = PermissionService._instance();

  factory PermissionService() {
    return _permission;
  }

  PermissionService._instance();

  Future<bool> checkPermission(Permission permission) async {
    if (kIsWeb) {
      // Browser notification permission is handled differently.
      return true;
    }

    final permissionStatus = await permission.status;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      return true;
    }

    switch (permissionStatus) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.denied:
        final requestedStatus = await permission.request();
        return requestedStatus == PermissionStatus.granted;
      case PermissionStatus.permanentlyDenied:
        await openAppSettings();
        return false;
      default:
        return false;
    }
  }
}
