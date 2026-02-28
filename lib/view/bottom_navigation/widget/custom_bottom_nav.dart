import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/bottom_navigation/bottom_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomNav extends StatelessWidget {
  final NavController controller = Get.put(NavController());

  CustomBottomNav({super.key});

  final List<String> labels = [
    'nav_jobs',
    'nav_orders',
    'nav_chats',
    'nav_profile',
  ];

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

      return Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: bottomInset,
        ),
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
          height: 66,
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
              (index) => _buildNavItem(index, icons[index], labels[index]),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(int index, String assetName, String label) {
    bool isSelected = controller.selectedIndex.value == index;

    return InkWell(
      onTap: () => controller.changeTabIndex(index),
      child: Transform.translate(
        offset: const Offset(0, -4),
        child: Container(
          width: 90,
          height: 47,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isSelected ? Color(0xff4C1CAE) : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetName,
                width: 22,
                height: 22,
                color: (isSelected
                    ? AppColor.whiteColor
                    : const Color(0xff0A0A0A)),
              ),
              const SizedBox(width: 4),
              Text(
                label.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.extraSmallText.copyWith(
                  fontSize: 10,
                  fontFamily: isSelected
                      ? AppFonts.OpenSansBold
                      : AppFonts.OpenSansMedium,
                  color: isSelected
                      ? AppColor.whiteColor
                      : const Color(0xff979797),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
