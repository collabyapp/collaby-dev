import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/components/MilestoneProgreaaBar.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/profile_setup_controller/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NicheSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final ProfileSetUpController controller = Get.put(ProfileSetUpController());

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('profile_setup_title'.tr),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MilestonedProgressBar(
              progress: 0.67, // filled portion
              milestones: [0.35, 0.65], // two points
              showProgressHeadDot:
                  false, // set true if you also want the moving white dot
            ),
            SizedBox(height: 16),

            Text(
              'profile_setup_niches_title'.tr,
              style: AppTextStyles.smallTextBold,
            ),
            SizedBox(height: 16),
            // Search Bar
            TextField(
              onChanged: (query) {
                controller.searchQuery.value = query; // Update the search query
              },
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                hintText: 'search'.tr,
                hintStyle: AppTextStyles.extraSmallText.copyWith(
                  color: Color(0xff000000).withOpacity(0.41),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xffE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColor.primaryColor),
                ),
                contentPadding: EdgeInsets.all(16),

                suffixIcon: Padding(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    width: 13,
                    child: Image.asset(ImageAssets.searchIcon, width: 10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Niche Chips
            Obx(() {
              var filteredNiches = controller.filteredNiches;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filteredNiches.map((niche) {
                  return _buildNicheChip(niche, controller);
                }).toList(),
              );
            }),
            // Spacer(),

            // SizedBox(height: 30),
          ],
        ),
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
              offset: const Offset(0, -2), // <— cast shadow upward
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(
                () => CustomButton(
                  isLoading: controller.isSubmittingProfile.value,
                  isDisabled: controller.selectedNiches.isEmpty,
                  title: 'next'.tr,
                  onPressed: () {
                    controller.submitToApi();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNicheChip(String niche, ProfileSetUpController controller) {
    return GestureDetector(
      onTap: () {
        controller.toggleNiche(niche); // Toggle selection
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 11),
        decoration: BoxDecoration(
          color: controller.selectedNiches.contains(niche)
              ? Color(0xff917DE5)
              : Color(0xff898A8D).withOpacity(0.10),
          borderRadius: BorderRadius.circular(60),
        ),
        child: Text(
          niche.tr,
          style: AppTextStyles.extraSmallText.copyWith(
            color: controller.selectedNiches.contains(niche)
                ? Colors.white
                : Color(0xff5E5E5E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
