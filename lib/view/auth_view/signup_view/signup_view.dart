import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/components/SocialButton.dart';
import 'package:collaby_app/res/components/TextInputField.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view_models/controller/auth_controller/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SignUpController());

    return Scaffold(
      body: Stack(
        children: [
          // Top gradient header with logo text
          Container(
            height: 500.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                colors: [
                  Color(0xFF8281E6),
                  Color(0xFF4C1CAE),
                  // Color(0xFF816CED),
                ],
              ),
            ),
            // child: SafeArea(
            //   child: Center(
            //     child: Image.asset(ImageAssets.logoImage, width: 138),
            //   ),
            // ),
          ),
          // Foreground white sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              // padding: EdgeInsets.only(
              //   bottom: MediaQuery.of(context).padding.bottom + 12,
              // ),
              child: AuthSheet(
                onClose: () => Get.offAllNamed(RouteName.onboardingView),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Text('Create Account', style: AppTextStyles.h3),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Provide some info to get started!',
                        style: AppTextStyles.smallText.copyWith(
                          color: Color(0xff4F4F4F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Email
                    GetBuilder<SignUpController>(
                      id: 'emailField',
                      builder: (_) {
                        final iconClr = c.email.value.isEmpty
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
                    const SizedBox(height: 16),

                    // Password
                    GetBuilder<SignUpController>(
                      id: 'passwordField',
                      builder: (_) {
                        final iconClr = c.password.value.isEmpty
                            ? const Color(0xff9CA3AF) // grey when empty
                            : AppColor.blackColor; // primary when not empty
                        return CustomTextField(
                          label: 'Set Password',
                          hint: 'Enter your password',
                          obscureText: c.obscure1.value,
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
                          suffixIcon: IconButton(
                            icon: Image.asset(
                              c.obscure1.value
                                  ? ImageAssets.visibility_off_outlined
                                  : ImageAssets.visibility_outlined,

                              color: Color(0xff585C65),
                              width: 20,
                            ),
                            onPressed: c.toggleObscure1,
                          ),
                          errorText: c.passwordError,
                          onChanged: c.onPasswordChanged,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password
                    GetBuilder<SignUpController>(
                      id: 'confirmField',
                      builder: (_) {
                        final iconClr = c.confirmPassword.value.isEmpty
                            ? const Color(0xff9CA3AF) // grey when empty
                            : AppColor.blackColor; // primary when not empty
                        return CustomTextField(
                          label: 'Confirm Password',
                          hint: 'Enter confirm password',
                          obscureText: c.obscure2.value,
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
                          suffixIcon: IconButton(
                            icon: Image.asset(
                              c.obscure2.value
                                  ? ImageAssets.visibility_off_outlined
                                  : ImageAssets.visibility_outlined,
                              color: Color(0xff585C65),
                              width: 20,
                            ),
                            onPressed: c.toggleObscure2,
                          ),
                          errorText: c.confirmPasswordError,
                          onChanged: c.onConfirmChanged,
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Login button
                    Obx(
                      () => CustomButton(
                        title: 'SignUp',
                        isDisabled: !c.isValid,
                        isLoading: c.isSubmitting.value,
                        onPressed: c.isValid && !c.isSubmitting.value
                            ? c.signUp
                            : null,
                      ),
                    ),

                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(thickness: 0.5),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OR',
                            style: AppTextStyles.extraSmallText,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(thickness: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Social buttons
                    Row(
                      children: [
                        SocialButton(
                          icon: Image.asset(
                            ImageAssets.googleIcon,
                            width: 20,
                            height: 20,
                            // errorBuilder: (_, __, ___) =>
                            //     const Icon(Icons.g_mobiledata),
                          ),
                          label: 'Google',
                          onTap: c.tapGoogle,
                        ),
                        const SizedBox(width: 12),
                        SocialButton(
                          icon: Image.asset(
                            ImageAssets.appleIcon,
                            width: 20,
                            height: 20,
                            // errorBuilder: (_, __, ___) =>
                            //     const Icon(Icons.g_mobiledata),
                          ),
                          label: 'Apple',
                          onTap: c.tapApple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Already have an account?  ",
                            style: AppTextStyles.extraSmallMediumText.copyWith(
                              color: Color(0xff727172),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => {Get.offAllNamed(RouteName.logInView)},
                            child: Text(
                              'Login',
                              style: AppTextStyles.smallMediumText.copyWith(
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthSheet extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClose;
  const AuthSheet({super.key, required this.child, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // BACK piece (the translucent top lip)
        Positioned(
          top: -12, // show it behind the white sheet’s top edge
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 345.w,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xffFFFFFF).withOpacity(0.26),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(41),
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 16,
                    color: Color(0x14000000),
                    offset: Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),
        ),

        // FRONT piece (the white sheet)
        Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: Color(0x14000000),
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Stack(
            children: [
              child,
              if (onClose != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.close,
                      size: 22,
                      color: Colors.black87,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
