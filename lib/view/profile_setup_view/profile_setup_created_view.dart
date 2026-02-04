import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view_models/controller/auth_controller/account_created_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSetupCreatedView extends StatelessWidget {
  const ProfileSetupCreatedView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      AccountCreatedController(usernameArg: Get.arguments?['username']),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Illustration
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Image.asset(
                  ImageAssets.verificationImage,
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ),

              // Username (big & bold)
              const SizedBox(height: 6),

              // Sub-heading
              Text(
                'Great 👍🏻   you’re almost done there ',
                textAlign: TextAlign.center,
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 16),

              // Minor caption
              Text(
                'Here’s what’s next:',
                textAlign: TextAlign.center,
                style: AppTextStyles.smallMediumText,
              ),
              const SizedBox(height: 50),

              // Steps
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vertical Rail with 3 icons
                  _StepsRail(),
                  const SizedBox(width: 12),

                  // Step texts
                  Expanded(
                    child: Obx(() {
                      final step = ctrl.currentStep.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),
                          _StepText(
                            'Complete your profile',
                            isActive: step == 0,
                          ),
                          const SizedBox(height: 62),
                          _StepText(
                            'Create your first Gig',
                            isActive: step == 1,
                          ),
                          const SizedBox(height: 60),
                          _StepText('Publish it', isActive: step == 2),
                        ],
                      );
                    }),
                  ),
                ],
              ),

              const Spacer(),

              // Bottom CTA (big rounded)
              CustomButton(
                title: 'Create your first Gig',
                onPressed: () {
                  Get.toNamed(RouteName.createGigView);
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

/// Left-side vertical progress rail
class _StepsRail extends StatelessWidget {
  const _StepsRail();

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6B39FF);
    const railFill = Color(0xFFEDE8FF);
    const mutedIcon = Color(0xFFCBD0D6);

    return Container(
      width: 38,
      // padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: railFill,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _RailDot(
            bg: purple,
            // icon: Icons.person,
            child: Image.asset(ImageAssets.createProfileIcon, width: 25),

            iconColor: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          _VerticalConnector(isActive: true),
          _RailDot(
            bg: purple,
            borderColor: mutedIcon,
            // icon: Icons.widgets_outlined,
            child: Image.asset(ImageAssets.createGigIcon, width: 25),

            iconColor: mutedIcon,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),

          const SizedBox(height: 32),
          _RailDot(
            bg: Colors.transparent,
            borderColor: mutedIcon,
            icon: Icons.check_circle,
            iconColor: mutedIcon,
          ),
        ],
      ),
    );
  }
}

class _VerticalConnector extends StatelessWidget {
  final bool isActive;

  const _VerticalConnector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
      color: isActive ? Color(0xFF6B39FF) : Color(0xFFCBD0D6),
    );
  }
}

/// Step line text with active/inactive styles
class _StepText extends StatelessWidget {
  const _StepText(this.text, {required this.isActive});

  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.normalText;
    return Text(
      text,
      style: isActive
          ? base.copyWith(fontWeight: FontWeight.w600, color: Colors.black)
          : base.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9AA0A6),
            ),
    );
  }
}

class _RailDot extends StatelessWidget {
  const _RailDot({
    required this.bg,
    this.icon,
    required this.iconColor,
    this.child,
    this.borderColor,
    this.borderRadius, // Custom border radius parameter
  });

  final Color bg;
  final IconData? icon;
  final Color iconColor;
  final Widget? child;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius; // Customizable border radius

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            borderRadius ?? BorderRadius.circular(18), // Use custom or default
      ),
      alignment: Alignment.center,
      child: child ?? Icon(icon, size: 25, color: iconColor),
    );
  }
}
