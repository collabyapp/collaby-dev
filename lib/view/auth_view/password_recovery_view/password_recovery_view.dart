import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/components/TextInputField.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view_models/controller/auth_controller/password_recovery_controller.dart';
import 'package:flutter/material.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:get/get.dart';

class PasswordRecoveryView extends StatelessWidget {
  const PasswordRecoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PasswordRecoveryController());

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.offAllNamed(RouteName.forgotPasswordView),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          splashRadius: 24,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),

                // Title
                Text('Password recovery', style: AppTextStyles.h3),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  'Please enter your new password',
                  style: AppTextStyles.smallText.copyWith(
                    color: const Color(0xff4F4F4F),
                  ),
                ),
                const SizedBox(height: 20),

                // New Password
                GetBuilder<PasswordRecoveryController>(
                  id: 'newPasswordField',
                  builder: (_) {
                    final iconClr = c.newPassword.isEmpty
                        ? const Color(0xff9CA3AF) // grey when empty
                        : AppColor.blackColor; // primary when not empty

                    return CustomTextField(
                      label: 'New Password',
                      hint: 'Enter your password',
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: SizedBox(
                        width: 13,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.asset(
                            ImageAssets.lockIcon,
                            color: iconClr,
                          ),
                        ),
                      ),
                      errorText: c.newPassError,
                      onChanged: c.onNewPasswordChanged,
                      // If your CustomTextField supports these:
                      obscureText: c.hideNew,
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          c.hideNew
                              ? ImageAssets.visibility_off_outlined
                              : ImageAssets.visibility_outlined,
                          width: 20,
                          color: Color(0xff585C65),
                        ),
                        onPressed: c.toggleNewVisibility,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                GetBuilder<PasswordRecoveryController>(
                  id: 'confirmPasswordField',
                  builder: (_) {
                    final iconClr = c.confirmPassword.isEmpty
                        ? const Color(0xff9CA3AF) // grey when empty
                        : AppColor.blackColor; // primary when not empty

                    return CustomTextField(
                      label: 'Confirm New Password',
                      hint: 'Enter your password',
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: SizedBox(
                        width: 13,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.asset(
                            ImageAssets.lockIcon,
                            color: iconClr,
                          ),
                        ),
                      ),
                      errorText: c.confirmPassError,
                      onChanged: c.onConfirmPasswordChanged,
                      // If supported:
                      obscureText: c.hideConfirm,
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          c.hideConfirm
                              ? ImageAssets.visibility_off_outlined
                              : ImageAssets.visibility_outlined,
                          width: 20,
                          color: Color(0xff585C65),
                        ),
                        onPressed: c.toggleConfirmVisibility,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Spacer to push button to bottom
                const Spacer(),
                GetBuilder<PasswordRecoveryController>(
                  id: 'submitButton',
                  builder: (_) => SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      isDisabled: !c.isValid,
                      isLoading: c.isSubmitting,
                      title: 'Update Password',
                      onPressed: () {
                        c.submit();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
