import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/components/MilestoneProgreaaBar.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collaby_app/view_models/controller/profile_setup_controller/account_security_controller.dart';

class AccountSecurityView extends StatelessWidget {
  final AccountSecurityController authController = Get.put(
    AccountSecurityController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('Profile Setup'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            (authController.isEdit == true)
                ? Get.back()
                : Get.offAllNamed(RouteName.logInView);
          },
        ),
      ),
      body: Obx(() {
        // Show loading indicator while fetching user data
        if (authController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !(authController.isEdit == true)
                  ? MilestonedProgressBar(
                      progress: 0100,
                      milestones: [0.35, 0.65],
                      showProgressHeadDot: false,
                    )
                  : SizedBox.shrink(),
              (authController.isEdit == true)
                  ? SizedBox.shrink()
                  : SizedBox(height: 20),
              Text('Account Security', style: AppTextStyles.smallTextBold),
              SizedBox(height: 20),
              _buildEmailSection(),
              SizedBox(height: 20),
              _buildPhoneSection(),
            ],
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
              child: CustomButton(
                title: (authController.isEdit == true)
                    ? 'Save Changes'
                    : 'Finish',
                onPressed: () {
                  (authController.isEdit == true)
                      ? Get.toNamed(
                          RouteName.bottomNavigationView,
                          arguments: {'index': 3},
                        )
                      : Get.toNamed(RouteName.profileSetupCreatedView);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailSection() {
    return Obx(() {
      final emailText = authController.email.value ?? 'Loading...';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email', style: AppTextStyles.smallText),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    emailText,
                    style: AppTextStyles.normalText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xff27AE60),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: Color(0xff27AE60)),
                  ),
                  child: Text(
                    'Approved',
                    style: AppTextStyles.extraSmallText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPhoneSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phone Number', style: AppTextStyles.smallText),
              SizedBox(width: 10),
              if (authController.isPhoneVerified.value)
                GestureDetector(
                  onTap: () {
                    authController.resetVerification();
                    Get.toNamed(RouteName.phoneNumberView);
                  },
                  child: Text(
                    'Change Phone',
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          if (!authController.isPhoneVerified.value)
            GestureDetector(
              onTap: () => Get.toNamed(RouteName.phoneNumberView),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: SizedBox(
                          width: 20,
                          child: Image.asset(ImageAssets.phoneIcon, width: 20),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Add Phone Number', style: AppTextStyles.normalText),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black26),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      authController.phoneNumber.value.isNotEmpty
                          ? authController.fullPhone
                          : 'No phone number',
                      style: AppTextStyles.normalText,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xff27AE60),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: Color(0xff27AE60)),
                    ),
                    child: Text(
                      'Approved',
                      style: AppTextStyles.extraSmallText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
