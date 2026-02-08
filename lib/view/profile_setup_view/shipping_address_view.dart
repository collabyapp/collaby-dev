import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/components/MilestoneProgreaaBar.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/profile_setup_view/common/TextInputField.dart';
import 'package:collaby_app/view_models/controller/profile_setup_controller/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShippingAddressView extends StatelessWidget {
  final ProfileSetUpController controller = Get.put(ProfileSetUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          controller.isEdit.value ? "Edit Shipping Address" : "Profile Setup",
        ),
      ),
      body: Obx(() {
        // Show loading when fetching profile data in edit mode
        if (controller.isEdit.value && controller.isLoadingProfile.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !controller.isEdit.value
                    ? MilestonedProgressBar(
                        progress: 0.67,
                        milestones: [0.35, 0.65],
                        showProgressHeadDot: false,
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 16),
                Text('Shipping Address', style: AppTextStyles.smallTextBold),
                SizedBox(height: 24),
                buildTextField(
                  label: 'Street',
                  controller: controller.streetController.value,
                  placeholder: 'Street',
                ),
                SizedBox(height: 20),
                buildTextField(
                  label: 'City',
                  controller: controller.cityController.value,
                  placeholder: 'City',
                ),
                SizedBox(height: 20),
                buildTextField(
                  label: 'ZIP Code',
                  controller: controller.zipCodeController.value,
                  placeholder: 'ZIP Code',
                ),
                SizedBox(height: 20),
                buildTextField(
                  label: 'Country',
                  controller: controller.countryController.value,
                  placeholder: 'Country',
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 5,
              spreadRadius: 0,
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
                // In edit mode, check if there are changes
                final isDisabled =
                    !controller.isShippingValid.value ||
                    controller.isSubmittingProfile.value ||
                    (controller.isEdit.value && !controller.hasChanges.value);

                return CustomButton(
                  title: controller.isEdit.value ? 'Update' : 'Next',
                  isDisabled: isDisabled,
                  onPressed: () {
                    if (controller.isSubmittingProfile.value) return;

                    if (controller.isEdit.value) {
                      // Update profile in edit mode
                      controller.updateProfile();
                    } else {
                      // Continue to next step in creation mode
                      controller.submitToApi();
                    }
                  },
                  isLoading: controller.isSubmittingProfile.value,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
