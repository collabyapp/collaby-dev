import 'package:collaby_app/models/orders_model/orders_models.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/orders_view/order_details_view/order_details_tab/chat_tab.dart';
import 'package:collaby_app/view/orders_view/order_details_view/order_details_tab/deliver_order_view.dart';
import 'package:collaby_app/view/orders_view/order_details_view/order_details_tab/delivery_tab.dart';
import 'package:collaby_app/view/orders_view/order_details_view/order_details_tab/timeline_tab.dart';
import 'package:collaby_app/view_models/controller/order_controller/order_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailView extends StatelessWidget {
  final OrderDetailController controller = Get.put(OrderDetailController());

  @override
  Widget build(BuildContext context) {
    // final order = controller.currentOrder.value;

    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Get.back(),
        // ),
        title: Text('Order Detail'),
        // actions: [
        //   Container(
        //     margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //     decoration: BoxDecoration(
        //       color: _getStatusColor(order!.orderInfo!.status).withOpacity(0.1),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: Text(
        //       _getStatusText(order!.status),
        //       style: TextStyle(
        //         fontSize: 12,
        //         color: _getStatusColor(order!.orderInfo!.status),
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // Tab Section
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.5, color: Color(0xff666666)),
              ),
            ),
            child: Obx(
              () => Row(
                children: [
                  Expanded(child: _buildTab('Timeline', 0)),
                  Expanded(child: _buildTab('Chat', 1)),
                  Expanded(child: _buildTab('Delivery', 2)),
                ],
              ),
            ),
          ),

          // Content
          Expanded(child: Obx(() => _buildTabContent(context))),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          // Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 5, // softness
              spreadRadius: 0,
              offset: const Offset(0, -2), // <â€” cast shadow upward
            ),
          ],
        ),
        child: Obx(() => _buildBottomBar()),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: controller.selectedTab.value == index
                  ? Colors.black
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.OpenSansRegular,
              fontWeight: controller.selectedTab.value == index
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: controller.selectedTab.value == index
                  ? Colors.black
                  : Color(0xff666666),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (controller.selectedTab.value) {
      case 0:
        return buildTimelineTab(context, controller);
      case 1:
        return buildChatTab(
          controller.orderChatId.toString(),
          controller.orderId.toString(),
        );
      case 2:
        return buildDeliveryTab(controller);
      default:
        return Container();
    }
  }

  Widget _buildBottomBar() {
    if (controller.selectedTab.value == 0) {
      final order = controller.currentOrder.value;
      if (order?.status == OrderStatus.completed) {
        return Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your order has been delivered. Wait for\n approval from client',
                style: AppTextStyles.extraSmallText.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              CustomButton(title: 'Delivered', isDisabled: true),
            ],
          ),
        );
      } else {
        return Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text(
              //   'Time left to deliver (2 Days)',
              //   style: TextStyle(fontSize: 12, color: Colors.grey),
              // ),
              SizedBox(height: 12),
              Obx(
                () => CustomButton(
                  isDisabled: !controller.canDeliverNow.value,
                  title: 'Deliver Now',
                  onPressed: () {
                    // log(controller.canDeliverNow.value);
                    DeliverWorkBottomSheet.show(controller.orderId.toString());
                  },
                ),
              ),
            ],
          ),
        );
      }
    }
    return SizedBox.shrink();
  }
}




