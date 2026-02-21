import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/components/SocialButton.dart';
import 'package:collaby_app/res/components/TextInputField.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view_models/controller/auth_controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Widget _safeAsset(
  String path, {
  double? width,
  double? height,
  Color? color,
  IconData fallbackIcon = Icons.image_not_supported_outlined,
}) {
  return Image.asset(
    path,
    width: width,
    height: height,
    color: color,
    errorBuilder: (context, error, stackTrace) {
      final size = (width ?? height ?? 18).clamp(12, 64).toDouble();
      return Icon(
        fallbackIcon,
        size: size,
        color: color ?? const Color(0xFF9CA3AF),
      );
    },
  );
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LogInController());
    return Scaffold(
      body: Stack(
        children: [
          const _GradientHeader(),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: AuthSheet(
                onClose: () => Get.offAllNamed(RouteName.onboardingView),
                child: _LoginForm(controller: controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------- Header Section ----------------------------

class _GradientHeader extends StatelessWidget {
  const _GradientHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8281E6), Color(0xFF4C1CAE)],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 300.h),
          child: _safeAsset(
            ImageAssets.logoImage,
            width: 138,
            fallbackIcon: Icons.flutter_dash,
          ),
        ),
      ),
    );
  }
}

// ---------------------------- Login Form ----------------------------

class _LoginForm extends StatelessWidget {
  final LogInController controller;

  const _LoginForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildHeader(),
        const SizedBox(height: 22),
        _EmailField(controller: controller),
        const SizedBox(height: 16),
        _PasswordField(controller: controller),
        const SizedBox(height: 15),
        _buildForgotPassword(),
        const SizedBox(height: 4),
        _LoginButton(controller: controller),
        const SizedBox(height: 18),
        const _Divider(),
        const SizedBox(height: 14),
        _SocialButtons(controller: controller),
        const SizedBox(height: 16),
        _buildSignUpLink(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(child: Text('login_welcome'.tr, style: AppTextStyles.h3)),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'login_subtitle'.tr,
            style: AppTextStyles.smallText.copyWith(
              color: const Color(0xFF4F4F4F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: controller.forgotPassword,
        child: Text(
          'forgot_password'.tr,
          style: AppTextStyles.smallMediumText.copyWith(
            color: AppColor.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "no_account".tr + "  ",
            style: AppTextStyles.extraSmallMediumText.copyWith(
              color: const Color(0xFF727172),
            ),
          ),
          GestureDetector(
            onTap: () => Get.offAllNamed(RouteName.signUpView),
            child: Text(
              'signup'.tr,
              style: AppTextStyles.smallMediumText.copyWith(
                color: AppColor.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------- Email Field ----------------------------

class _EmailField extends StatelessWidget {
  final LogInController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LogInController>(
      id: 'emailField',
      builder: (_) {
        final iconColor = controller.email.isEmpty
            ? const Color(0xFF9CA3AF)
            : AppColor.blackColor;

        return CustomTextField(
          label: 'Email',
          hint: 'login_email_hint'.tr,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: _buildPrefixIcon(ImageAssets.emailIcon, iconColor),
          errorText: controller.emailError,
          onChanged: controller.onEmailChanged,
        );
      },
    );
  }

  Widget _buildPrefixIcon(String asset, Color color) {
        return SizedBox(
      width: 13,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: _safeAsset(asset, color: color),
      ),
    );
  }
}

// ---------------------------- Password Field ----------------------------

class _PasswordField extends StatelessWidget {
  final LogInController controller;

  const _PasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LogInController>(
      id: 'passwordField',
      builder: (_) {
        final iconColor = controller.password.isEmpty
            ? const Color(0xFF9CA3AF)
            : AppColor.blackColor;

        return CustomTextField(
          label: 'login_password_label'.tr,
          hint: 'login_password_hint'.tr,
          obscureText: controller.obscure,
          prefixIcon: _buildPrefixIcon(ImageAssets.lockIcon, iconColor),
          suffixIcon: _buildVisibilityToggle(),
          errorText: controller.passwordError,
          onChanged: controller.onPasswordChanged,
        );
      },
    );
  }

  Widget _buildPrefixIcon(String asset, Color color) {
    return SizedBox(
      width: 13,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: _safeAsset(asset, color: color),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return IconButton(
      icon: _safeAsset(
        controller.obscure
            ? ImageAssets.visibility_off_outlined
            : ImageAssets.visibility_outlined,
        width: 20,
        color: const Color(0xFF585C65),
        fallbackIcon: controller.obscure ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: controller.toggleObscure,
    );
  }
}

// ---------------------------- Login Button ----------------------------

class _LoginButton extends StatelessWidget {
  final LogInController controller;

  const _LoginButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomButton(
        title: 'Login',
        isDisabled: !controller.isValid,
        isLoading: controller.isSubmitting,
        onPressed: controller.isValid && !controller.isSubmitting
            ? controller.login
            : null,
      ),
    );
  }
}

// ---------------------------- Divider ----------------------------

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(thickness: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('or'.tr, style: AppTextStyles.extraSmallText),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(thickness: 0.5),
          ),
        ),
      ],
    );
  }
}

// ---------------------------- Social Buttons ----------------------------

class _SocialButtons extends StatelessWidget {
  final LogInController controller;

  const _SocialButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SocialButton(
          icon: _safeAsset(
            ImageAssets.googleIcon,
            width: 20,
            height: 20,
            fallbackIcon: Icons.g_mobiledata,
          ),
          label: 'Google',
          onTap: controller.tapGoogle,
        ),
        const SizedBox(width: 12),
        SocialButton(
          icon: _safeAsset(
            ImageAssets.appleIcon,
            width: 20,
            height: 20,
            fallbackIcon: Icons.apple,
          ),
          label: 'Apple',
          onTap: controller.tapApple,
        ),
      ],
    );
  }
}

// ---------------------------- Auth Sheet Container ----------------------------

class AuthSheet extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClose;

  const AuthSheet({super.key, required this.child, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [_buildBackLayer(), _buildFrontLayer()],
    );
  }

  Widget _buildBackLayer() {
    return Positioned(
      top: -12,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 345.w,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withOpacity(0.26),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(41)),
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
    );
  }

  Widget _buildFrontLayer() {
    return Container(
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
                icon: const Icon(Icons.close, size: 22, color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }
}
