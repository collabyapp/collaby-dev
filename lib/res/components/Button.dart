import 'package:flutter/material.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final TextStyle? textStyle;
  final Color textColor;
  final Color borderColor;
  final Color buttonColor; // For the custom button color
  final double? height, width;
  final Widget? icon;

  const CustomButton({
    Key? key,
    required this.title,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.textColor = AppColor.whiteColor,
    this.borderColor = Colors.transparent,
    this.buttonColor = AppColor.primaryButtonColor,
    this.textStyle,
    this.width,
    this.height,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the decoration based on buttonColor
    BoxDecoration decoration;

    decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(25.5),
      border: Border.all(color: borderColor),
      color: isDisabled
          ? Color(0xff000000).withOpacity(0.20)
          : buttonColor, // Solid color if buttonColor is provided
    );

    return GestureDetector(
      onTap: isDisabled || isLoading
          ? null
          : onPressed, // Handle tap if button is enabled
      child: Container(
        height: height != null ? height! : 54,
        width: width != null ? width! : double.infinity,
        decoration: decoration,
        child: Row(
          mainAxisAlignment: icon == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.center, // Adjust alignment if no icon
          children: [
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(left: 0.0), // Add padding to the icon
                child: icon,
              ),
            if (icon != null)
              SizedBox(width: 10), // Space between icon and text
            Center(
              child: isLoading
                  ? SizedBox(
                      height: 25,
                      width: 25,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      title,
                      style:
                          textStyle ??
                          TextStyle(
                            color: isDisabled ? Colors.white : textColor,
                            fontSize: 16,
                            // fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.OpenSansMedium, // Custom font
                          ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
