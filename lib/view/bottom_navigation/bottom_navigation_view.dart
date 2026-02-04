import 'package:collaby_app/view/bottom_navigation/widget/custom_bottom_nav.dart';
import 'package:collaby_app/view/chats_view/chats_list_view.dart';
import 'package:collaby_app/view/jobs_view/jobs_view.dart';
import 'package:collaby_app/view/orders_view/orders_view.dart';
import 'package:collaby_app/view/profile_view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collaby_app/view_models/controller/bottom_navigation/bottom_navigation_controller.dart';

class BottomNavigationView extends StatelessWidget {
  final NavController controller = Get.put(NavController());

  final List<Widget> pages = [
    JobsView(),
    OrdersView(),
    ChatsListView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
