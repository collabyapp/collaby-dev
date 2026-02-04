import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/components/TextInputField.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/auth_controller/forgot_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordView extends StatelessWidget {
  
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, size: 25),
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
                Text('Forgot Password', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Text(
                    'Enter your register email address to reset your password',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.smallText.copyWith(
                      color: Color(0xff4F4F4F),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Email
                GetBuilder<ForgotPasswordController>(
                  id: 'emailField',
                  builder: (_) {
                    final iconClr = c.email.isEmpty
                        ? const Color(0xff9CA3AF) // grey when empty
                        : AppColor.blackColor; // primary when not empty

                    return CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: SizedBox(
                        width: 13,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.asset(
                            ImageAssets.emailIcon,
                            color: iconClr,
                          ),
                        ),
                      ),
                      errorText: c.emailError,
                      onChanged: c.onEmailChanged,
                    );
                  },
                ),
                const Spacer(),

                Obx(
                  () => CustomButton(
                    title: 'Reset Password',
                    isDisabled: !c.isValid,
                    isLoading: c.isSubmitting.value,
                    onPressed: () async {
                      await c.sendOTP();
                    },
                  ),
                ),
                SizedBox(height: 50),

                /// COUNTDOWN + RESEND
              ],
            ),
          ),
        ),
      ),
    );
  }
}
