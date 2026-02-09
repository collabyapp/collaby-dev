import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/onboarding_controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glass/glass.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());

    // transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              // PageView for onboarding images only
              Expanded(
                child: Obx(() {
                  return GestureDetector(
                    onHorizontalDragEnd: (details) {
                      // Swipe left (next image)
                      if (details.primaryVelocity! < 0) {
                        if (controller.currentIndex <
                            controller.onboardingData.length - 1) {
                          controller.nextPage();
                        }
                      }
                      // Swipe right (previous image)
                      else if (details.primaryVelocity! > 0) {
                        controller.previousPage();
                      }
                    },
                    child: Container(
                      height: 450.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                            controller
                                .onboardingData[controller.currentIndex]
                                .image,
                          ),
                          // fit: BoxFit.cover,
                        ),
                      ),
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          // Swipe left (next image)
                          if (details.primaryVelocity! < 0) {
                            if (controller.currentIndex <
                                controller.onboardingData.length - 1) {
                              controller.nextPage();
                            }
                          }
                          // Swipe right (previous image)
                          else if (details.primaryVelocity! > 0) {
                            controller.previousPage();
                          }
                        },
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child:
                              Container(
                                height: 187.h,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'onboarding_title'.tr,
                                      style: AppTextStyles.h2.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'onboarding_subtitle'.tr,
                                      style: AppTextStyles.smallMediumText
                                          .copyWith(color: Colors.white),
                                    ),
                                    const SizedBox(height: 14),

                                    // Dots indicator
                                    Obx(() {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          controller.onboardingData.length,
                                          (index) => Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color:
                                                  controller.currentIndex ==
                                                      index
                                                  ? Colors.white
                                                  : Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ).asGlass(
                                tintColor: Color(0xff000000).withOpacity(0.37),
                                clipBorderRadius: BorderRadius.circular(15.0),
                              ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Single "Get Started" Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CustomButton(
                  title: 'onboarding_get_started'.tr,
                  onPressed: () {
                    controller.onGetStarted();
                  },
                ),
              ),

              // Bottom text
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'onboarding_have_account'.tr,
                      style: AppTextStyles.extraSmallMediumText.copyWith(
                        color: AppColor.secondaryTextColor,
                        fontFamily: AppFonts.OpenSansSemiBold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.onLogin,
                      child: Text(
                        'onboarding_login'.tr,
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColor.primaryColor,
                          fontFamily: AppFonts.OpenSansSemiBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
