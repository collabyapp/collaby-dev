import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/gig_creation_controller/create_gig_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GigSuccessView extends StatelessWidget {
  const GigSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateGigController());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background image (PNG)
                    Image.asset(
                      ImageAssets.gigCreationImage, // your PNG background
                      fit: BoxFit.cover,
                    ),

                    // Foreground GIF
                    Image.asset(
                      ImageAssets.gigCreationGIF, // your GIF
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Congratulations text
              Text("gig_congrats".tr, style: AppTextStyles.h5),
              const SizedBox(height: 8),
              Text("gig_open_for_business".tr, style: AppTextStyles.h5),
              const SizedBox(height: 8),
              Text(
                "gig_share_with_client".tr,
                style: AppTextStyles.smallMediumText,
              ),

              const SizedBox(height: 24),

              // Link box with copy
              // Obx(
              //   () => Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 12,
              //       vertical: 8,
              //     ),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.grey.shade300),
              //       borderRadius: BorderRadius.circular(40),
              //     ),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: Text(
              //             controller.gigLink.value,
              //             style: AppTextStyles.smallText,
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //         ),
              //         const SizedBox(width: 12),
              //         ElevatedButton(
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: AppColor.primaryColor,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(30),
              //             ),
              //             padding: const EdgeInsets.symmetric(
              //               horizontal: 16,
              //               vertical: 10,
              //             ),
              //           ),
              //           onPressed: controller.copyLink,
              //           child: const Text(
              //             "Copy Link",
              //             style: TextStyle(color: Colors.white),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 24),

              // Explore Jobs button
              CustomButton(
                title: "gig_explore_jobs".tr,
                onPressed: () {
                  controller.exploreJobs();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
