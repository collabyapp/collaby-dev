import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/gig_creation_views/steps/gallery_step.dart';
import 'package:collaby_app/view_models/controller/gig_creation_controller/create_gig_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'steps/overview_step.dart';
import 'steps/pricing_step.dart';
import 'steps/description_step.dart';

class CreateGigView extends GetView<CreateGigController> {
  const CreateGigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(147),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4C1CAE), Color(0xFF816CED)],
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Text(
                        controller.isEditMode.value ? 'Edit Service' : 'Create Service',
                        style: AppTextStyles.normalTextBold.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.tabs.length,
                    itemBuilder: (context, index) {
                      final tab = controller.tabs[index];

                      return Obx(() {
                        final isSelected = controller.currentIndex.value == index;
                        final isCompleted = index < controller.highestCompletedStep.value;
                        final isLocked = index > controller.highestCompletedStep.value;

                        return GestureDetector(
                          onTap: () => controller.onTabTapped(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      tab,
                                      style: AppTextStyles.extraSmallMediumText.copyWith(
                                        color: isLocked ? Colors.white.withOpacity(0.5) : Colors.white,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 3,
                                  width: tab.length * 8.0,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : isCompleted
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: TabBarView(
          controller: controller.tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            OverviewStep(),
            PricingStep(),
            DescriptionStep(),
            GalleryStep(),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 5,
              offset: const Offset(0, -2),
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
              child: Obx(() {
                final isLast = controller.currentIndex.value == controller.tabs.length - 1;

                return CustomButton(
                  isDisabled: !controller.isCurrentStepReady,
                  title: isLast
                      ? (controller.isEditMode.value ? 'Update Service' : 'Publish Service')
                      : 'Next',
                  onPressed: controller.onNext,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
