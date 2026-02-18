import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

class SettingsMenuItem extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final VoidCallback onTap;
  final bool isIcon;

  const SettingsMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.onTap,
    this.isIcon = true, // Default is true
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(icon, width: 23),
            ),
            SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.normalTextMedium)),
            // Conditionally render the arrow icon
            if (isIcon)
              Icon(Icons.arrow_forward_ios, color: Color(0xFF6366F1), size: 16),
          ],
        ),
      ),
    );
  }
}
