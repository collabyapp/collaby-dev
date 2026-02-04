import 'package:collaby_app/models/orders_model/notification_model.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/job_controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationBottomSheet extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          SizedBox(height: 10),
          Expanded(child: _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildHandle() => Container(
    margin: EdgeInsets.only(top: 12, bottom: 8),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _buildHeader() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Text('Notifications', style: AppTextStyles.h6Bold),
  );

  Widget _buildNotificationsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.notifications.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.notifications.isEmpty) {
        return Center(
          child: Text('No notifications yet', style: AppTextStyles.smallText),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.notifications.length,
        separatorBuilder: (_, __) => SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = controller.notifications[index];
          return _buildNotificationItem(notification);
        },
      );
    });
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xffE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Image.asset(
              controller.getNotificationIcon(notification.type),
              color: Colors.black,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: AppTextStyles.smallMediumText),
                if (notification.description.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: AppTextStyles.extraSmallText,
                  ),
                ],
              ],
            ),
          ),
          // SizedBox(width: 12),
          // GestureDetector(
          //   onTap: () => controller.viewNotification(notification),
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //     decoration: BoxDecoration(
          //       color: Color(0xffDFDFDF),
          //       borderRadius: BorderRadius.circular(16),
          //     ),
          //     child: Text(
          //       'View',
          //       style: AppTextStyles.extraSmallText.copyWith(fontSize: 10),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
