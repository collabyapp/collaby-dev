import 'package:collaby_app/models/orders_model/orders_models.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/orders_view/earning_view/earning_view.dart';
import 'package:collaby_app/view/orders_view/notification_view.dart';
import 'package:collaby_app/view/orders_view/order_details_view/order_details_view.dart';
import 'package:collaby_app/view/orders_view/order_request_view/order_request_view.dart';
import 'package:collaby_app/view_models/controller/order_controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersView extends StatelessWidget {
  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(RouteName.bottomNavigationView);
        return true; // prevent default behavior (app close)
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('orders_title'.tr),
          centerTitle: false,
          actions: [
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.all(7),
                child: Icon(Icons.notifications_outlined, color: Colors.black),
              ),
              onTap: () {
                Get.bottomSheet(
                  NotificationBottomSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black.withOpacity(0.5),
                );
              },
            ),
            SizedBox(width: 15),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: controller.refreshOrders,
          child: Column(
            children: [
              // Earnings Available Section
              GestureDetector(
                onTap: () {
                  Get.to(() => EarningsView());
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'orders_earning_available'.tr,
                          style: AppTextStyles.extraSmallText,
                        ),
                        Row(
                          children: [
                            Obx(
                              () => Text(
                                '\$${controller.earningAvailable.value.toStringAsFixed(2)}',
                                style: AppTextStyles.normalTextMedium,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Color(0xff3F4146),
                              size: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tab Section
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffF4F7FF),
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Obx(() => _buildTab('orders_tab_active'.tr, 0))),
                    Expanded(child: Obx(() => _buildTab('orders_tab_new'.tr, 1))),
                    Expanded(child: Obx(() => _buildTab('orders_tab_completed'.tr, 2))),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.orders.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return _buildTabContent();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    String count;
    if (index == 0) {
      count = '(${controller.activeCount.value})';
    } else if (index == 1) {
      count = '(${controller.newCount.value})';
    } else {
      count = '(${controller.completedCount.value})';
    }

    return GestureDetector(
      onTap: () {
        controller.changeTab(index);
      },
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
            '$title $count',
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.OpenSansRegular,
              fontWeight: controller.selectedTab.value == index
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: controller.selectedTab.value == index
                  ? Colors.black
                  : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (controller.selectedTab.value) {
      case 0: // Active
        return _buildOrdersList(controller.activeOrders);
      case 1: // New
        return _buildOrdersList(controller.newOrders);
      case 2: // Completed
        return controller.completedOrders.isEmpty
            ? _buildEmptyCompletedState()
            : _buildOrdersList(controller.completedOrders);
      default:
        return Container();
    }
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImageAssets.noOrderImage, width: 58),
            SizedBox(height: 16),
            Text(
              'orders_empty_active'.tr,
              style: AppTextStyles.extraSmallText,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // _buildBoostBanner(),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // Load more when reaching bottom
              if (!controller.isLoading.value &&
                  controller.hasMoreData.value &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                controller.loadMoreOrders();
              }
              return false;
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: orders.length + (controller.hasMoreData.value ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at bottom if loading more
                if (index == orders.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildOrderCard(orders[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildBoostBanner() {
  //   return Container(
  //     margin: EdgeInsets.all(16),
  //     padding: EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Color(0xFF816CED), Color(0xFF33196A), Color(0xFF432C73)],
  //         begin: Alignment.centerLeft,
  //         end: Alignment.centerRight,
  //       ),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Expanded(
  //           child: Text(
  //             'Boost Your Profile and get\nmore UGC Deals',
  //             style: AppTextStyles.extraSmallText.copyWith(color: Colors.white),
  //           ),
  //         ),
  //         ElevatedButton.icon(
  //           onPressed: controller.boostProfile,
  //           icon: Image.asset(ImageAssets.boostIcon, width: 20, height: 20),
  //           label: Text('Boost Now', style: AppTextStyles.extraSmallMediumText),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.white,
  //             foregroundColor: Colors.black,
  //             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(25),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () {
        if (order.status == OrderStatus.newOrder) {
          Get.to(
            () => OrderRequestView(),
            arguments: {'id': order.id, 'status': order.status},
          );
        } else if (order.status == OrderStatus.inProgress ||
            order.status == OrderStatus.active ||
            order.status == OrderStatus.inRevision ||
            order.status == OrderStatus.delivered ||
            order.status == OrderStatus.completed) {
          Get.to(
            () => OrderDetailView(),
            arguments: {'id': order.id, 'status': 'inProgress', 'order': order},
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.title,
                    style: AppTextStyles.smallMediumText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller
                        .getStatusColor(order.status)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.OpenSansBold,
                      color: controller.getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  order.status == OrderStatus.completed ||
                          order.status == OrderStatus.declined
                      ? 'orders_order_by'.tr
                      : order.status == OrderStatus.inProgress ||
                            order.status == OrderStatus.active ||
                            order.status == OrderStatus.inRevision ||
                            order.status == OrderStatus.delivered
                      ? 'orders_hired_by'.tr
                      : 'orders_order_by'.tr,
                  style: AppTextStyles.extraSmallText.copyWith(fontSize: 11),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Use network image if available, fallback to placeholder
                    order.brandLogo.isNotEmpty
                        ? CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(order.brandLogo),
                            backgroundColor: const Color(0xFFEFF0FF),
                            onBackgroundImageError: (_, __) {},
                          )
                        : Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(0xFF0066CC),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                order.brandName.isNotEmpty
                                    ? order.brandName[0].toUpperCase()
                                    : 'B',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(width: 8),
                    Text(
                      order.brandName,
                      style: AppTextStyles.extraSmallMediumText,
                    ),
                  ],
                ),
                Text(
                  order.status == OrderStatus.completed ||
                          order.status == OrderStatus.declined
                      ? 'orders_ended_on'.trParams(
                        {'date': _formatDate(order.endDate)},
                      )
                      : order.daysRemaining != null
                      ? 'orders_days_left'.trParams(
                        {'days': order.daysRemaining!.ceil().toString()},
                      )
                      : 'orders_deliver_on'.trParams(
                        {'date': _formatDate(order.endDate)},
                      ),
                  style: AppTextStyles.extraSmallText.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCompletedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ImageAssets.noOrderImage, width: 58),
          SizedBox(height: 24),
          Text(
            'orders_empty_completed'.tr,
            style: AppTextStyles.extraSmallText,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
