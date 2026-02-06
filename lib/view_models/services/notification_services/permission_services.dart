import 'dart:io';
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
    PermissionStatus permissionStatus = await permission.status;
    debugPrint("before............");
    debugPrint(permissionStatus.toString());
    if (Platform.isIOS) {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    } else {
      switch (permissionStatus) {
        case PermissionStatus.granted:
          return true;
        case PermissionStatus.denied:
          // Request permission
          PermissionStatus requestedStatus = await permission.request();
          return requestedStatus == PermissionStatus.granted;
        case PermissionStatus.permanentlyDenied:
          // Open app settings
          debugPrint("init open app setting");
          bool openedSettings = await openAppSettings();
          debugPrint('Opened app settings: $openedSettings');
          break;
        default:
          break;
      }
    }
    debugPrint("after............");
    debugPrint(permissionStatus.toString());
    return false;
  }
}




