import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view_models/controller/auth_controller/account_created_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountCreatedView extends StatefulWidget {
  const AccountCreatedView({super.key});

  @override
  State<AccountCreatedView> createState() => _AccountCreatedViewState();
}

class _AccountCreatedViewState extends State<AccountCreatedView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;

  // Rail
  late Animation<Offset> _railSlide;
  late Animation<double> _railFade;

  // Steps (top â†’ bottom)
  late Animation<Offset> _step1Slide;
  late Animation<double> _step1Fade;

  late Animation<Offset> _step2Slide;
  late Animation<double> _step2Fade;

  late Animation<Offset> _step3Slide;
  late Animation<double> _step3Fade;

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      duration: const Duration(milliseconds: 2200), // slower
      vsync: this,
    );
    // Helper function to build slide tweens
    Tween<Offset> o(double dy) => Tween<Offset>(
      begin: Offset(0, -dy), // slide in from slightly above
      end: Offset.zero,
    );

    // Rail (starts first)
    _railSlide = o(0.08).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.00, 0.30, curve: Curves.easeOutCubic),
      ),
    );

    // Helper

    // Rail (starts first)
    _railSlide = o(0.08).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.00, 0.30, curve: Curves.easeOutCubic),
      ),
    );
    _railFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.00, 0.30, curve: Curves.easeOutExpo),
    );

    // Step 1
    _step1Slide = o(0.06).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _step1Fade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOutExpo),
    );

    // Step 2
    _step2Slide = o(0.06).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _step2Fade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutExpo),
    );

    // Step 3
    _step3Slide = o(0.06).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.55, 0.95, curve: Curves.easeOutCubic),
      ),
    );
    _step3Fade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOutExpo),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ac.forward();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

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
              Text(
                ctrl.username.isEmpty ? 'â€”' : ctrl.username,
                textAlign: TextAlign.center,
                style: (AppTextStyles.normalTextMedium),
              ),
              const SizedBox(height: 6),

              // Sub-heading
              Text(
                'account_created_title'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 16),

              // Minor caption
              Text(
                'account_created_next'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.smallMediumText,
              ),
              const SizedBox(height: 16),

              // Animated Steps (staggered top â†’ bottom)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rail first
                  FadeTransition(
                    opacity: _railFade,
                    child: SlideTransition(
                      position: _railSlide,
                      child: const _StepsRail(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Step texts staggered
                  Expanded(
                    child: Obx(() {
                      final step = ctrl.currentStep.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),

                          FadeTransition(
                            opacity: _step1Fade,
                            child: SlideTransition(
                              position: _step1Slide,
                              child: _StepText(
                                'account_created_step_profile'.tr,
                                isActive: step == 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 62),

                          FadeTransition(
                            opacity: _step2Fade,
                            child: SlideTransition(
                              position: _step2Slide,
                              child: _StepText(
                                'account_created_step_service'.tr,
                                isActive: step == 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 55),

                          FadeTransition(
                            opacity: _step3Fade,
                            child: SlideTransition(
                              position: _step3Slide,
                              child: _StepText(
                                'account_created_step_publish'.tr,
                                isActive: step == 2,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),

              const Spacer(),

              // Bottom CTA (big rounded)
              CustomButton(
                title: 'account_created_cta'.tr,
                onPressed: () {
                  Get.toNamed(RouteName.profileSetUpView);
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

            child: Image.asset(ImageAssets.createProfileIcon, width: 25),

            iconColor: Colors.white,
          ),
          const SizedBox(height: 28),
          _RailDot(
            bg: Colors.transparent,
            borderColor: mutedIcon,
            iconColor: mutedIcon,

            child: Image.asset(
              ImageAssets.createGigIcon,
              color: mutedIcon,
              width: 25,
            ),
          ),

          const SizedBox(height: 28),
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

class _RailDot extends StatelessWidget {
  const _RailDot({
    required this.bg,
    this.icon,
    this.child,
    required this.iconColor,
    this.borderColor,
  });

  final Color bg;
  final IconData? icon;
  final Widget? child;
  final Color iconColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        // border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      alignment: Alignment.center,
      child: child ?? Icon(icon, size: 25, color: iconColor),
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

