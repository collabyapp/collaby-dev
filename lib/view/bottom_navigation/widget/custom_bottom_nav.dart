import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/view_models/controller/bottom_navigation/bottom_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomNav extends StatelessWidget {
  final NavController controller = Get.put(NavController());

  CustomBottomNav({super.key});

  final List<String> icons = [
    ImageAssets.jobIcon,
    ImageAssets.orderIcon,
    ImageAssets.chatIcon,
    ImageAssets.profileIcon,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bottomInset = MediaQuery.of(context).padding.bottom;
      final bottomPadding = bottomInset > 0 ? (bottomInset - 6) : 6.0;

      return Container(
        padding: EdgeInsets.only(left: 12, right: 12, bottom: bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          height: 58,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              icons.length,
              (index) => _buildNavItem(index, icons[index]),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(int index, String assetName) {
    bool isSelected = controller.selectedIndex.value == index;

    return InkWell(
      onTap: () => controller.changeTabIndex(index),
      child: Container(
        width: 64,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: isSelected ? const Color(0xff4C1CAE) : Colors.transparent,
        ),
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, 1.5),
            child: Image.asset(
              assetName,
              width: 24,
              height: 24,
              color: isSelected ? AppColor.whiteColor : const Color(0xff0A0A0A),
            ),
          ),
        ),
      ),
    );
  }
}
