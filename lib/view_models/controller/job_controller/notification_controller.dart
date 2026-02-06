import 'package:collaby_app/models/orders_model/notification_model.dart';
import 'package:collaby_app/repository/order_repository/notification_repository.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view/orders_view/notification_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repo = NotificationRepository();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final hasMore = false.obs;

  int _page = 1;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(initial: true);
  }

  // ---------- Fetch Notifications ----------
  Future<void> fetchNotifications({bool initial = false}) async {
    try {
      if (initial) {
        _page = 1;
        notifications.clear();
      }

      isLoading.value = true;

      final resp = await _repo.fetchNotifications(page: _page, limit: _limit);

      final int statusCode = (resp['statusCode'] ?? 0) is int
          ? resp['statusCode']
          : 0;

      if (statusCode != 200) {
        final msg = (resp['message'] ?? 'Failed to load notifications')
            .toString();
        Utils.snackBar('Error', msg);
        return;
      }

      final List<dynamic> dataList = resp['data'] as List<dynamic>? ?? [];
      final List<NotificationModel> fetched = dataList
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (initial) {
        notifications.assignAll(fetched);
      } else {
        notifications.addAll(fetched);
      }

      // Pagination flags
      final pagination = resp['pagination'] as Map<String, dynamic>? ?? {};
      hasMore.value = pagination['hasNext'] == true;

      if (hasMore.value) {
        _page++;
      }
    } catch (e, st) {
      debugPrint('Notification fetch error: $e');
      debugPrintStack(stackTrace: st);
      Utils.snackBar('Error', 'Unable to load notifications');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------- Actions ----------

  void markAsRead(String notificationId) {
    final idx = notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      notifications[idx] = notifications[idx].copyWith(isRead: true);
    }
  }

  void viewNotification(NotificationModel notification) {
    markAsRead(notification.id);

    // Navigate to a detailed view or order/whatever
    // Example: open generic notification screen:
    // Get.to(() => NotificationView(notification: notification));
  }

  String getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return ImageAssets.orderIcon;
      case NotificationType.jobApplication:
        return ImageAssets.jobIcon;
      case NotificationType.message:
        return ImageAssets.jobIcon;
      case NotificationType.payment:
        return ImageAssets.jobIcon;
      case NotificationType.other:
        return ImageAssets.jobIcon;
    }
  }

  void showNotificationsBottomSheet() {
    Get.bottomSheet(
      NotificationBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }
}



