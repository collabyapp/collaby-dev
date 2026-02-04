import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

/// Social button with icon and label
class SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FD),
            borderRadius: BorderRadius.circular(30),
            // border: Border.all(color: const Color(0xFFE8E8EF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.smallText),
            ],
          ),
        ),
      ),
    );
  }
}
