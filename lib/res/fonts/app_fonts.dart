// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';
import 'package:collaby_app/res/colors/app_color.dart';

class AppFonts {
  static const String OpenSansBold = 'OpenSans-Bold';
  static const String OpenSansMedium = 'OpenSans-Medium';
  static const String OpenSansRegular = 'OpenSans-Regular';
  static const String OpenSansSemiBold = 'OpenSans-SemiBold';
}

class AppTextStyles {
  // Headings
  static TextStyle get h1 => TextStyle(
    fontSize: 30,
    fontFamily: AppFonts.OpenSansBold,
    color: AppColor.primaryTextColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get h2 => TextStyle(
    fontSize: 28,
    fontFamily: AppFonts.OpenSansBold,
    color: AppColor.primaryTextColor,
  );

  static TextStyle get h3 => TextStyle(
    fontSize: 24,
    fontFamily: AppFonts.OpenSansBold,
    color: AppColor.primaryTextColor,
  );

  static TextStyle get h4 => TextStyle(
    fontSize: 22,
    fontFamily: AppFonts.OpenSansBold,
    color: AppColor.primaryTextColor,
  );

  static TextStyle get h5 => TextStyle(
    fontSize: 20,
    fontFamily: AppFonts.OpenSansSemiBold,
    color: AppColor.primaryTextColor,
  );

  static TextStyle get h6 => TextStyle(
    fontSize: 18,
    fontFamily: AppFonts.OpenSansSemiBold,
    color: AppColor.primaryTextColor,
  );  
  static TextStyle get h6Bold => TextStyle(
    fontSize: 18,
    fontFamily: AppFonts.OpenSansBold,
    color: AppColor.primaryTextColor,
  );

  // Body Text
  static TextStyle get largeText => TextStyle(
    fontSize: 18,
    fontFamily: AppFonts.OpenSansSemiBold,
    color: AppColor.primaryTextColor,
  );

  static TextStyle get normalText => TextStyle(
    fontSize: 16,
    fontFamily: AppFonts.OpenSansRegular,
    color: AppColor.primaryTextColor,
  );
    static TextStyle get normalTextMedium => TextStyle(
    fontSize: 16,
    fontFamily: AppFonts.OpenSansSemiBold,
    color: AppColor.primaryTextColor,
  );

  static TextStyle get normalTextBold => TextStyle(
    fontSize: 16,
    fontFamily: AppFonts.OpenSansBold,
    color: AppColor.primaryTextColor,
  );

  static TextStyle get smallText => TextStyle(
    fontSize: 14,
    fontFamily: AppFonts.OpenSansRegular,
    color: AppColor.primaryTextColor,
  );
    static TextStyle get smallMediumText => TextStyle(
    fontSize: 14,
    fontFamily: AppFonts.OpenSansSemiBold,
    color: AppColor.primaryTextColor,
  );
  static TextStyle get smallTextBold => TextStyle(
    fontSize: 14,
    fontFamily: AppFonts.OpenSansBold,
    color: AppColor.primaryTextColor,
  );

  static TextStyle get extraSmallText => TextStyle(
    fontSize: 12,
    fontFamily: AppFonts.OpenSansRegular,
    color: AppColor.primaryTextColor,
  );
    static TextStyle get extraSmallMediumText => TextStyle(
    fontSize: 12,
    fontFamily: AppFonts.OpenSansSemiBold,
    color: AppColor.primaryTextColor,
  );

  // Special Text Styles
  static TextStyle get subtitleStyle => TextStyle(
    fontSize: 16,
    fontFamily: AppFonts.OpenSansSemiBold,
    color: AppColor.primaryTextColor.withOpacity(0.8),
  );

  static TextStyle get linkStyle => TextStyle(
    fontSize: 12,
    fontFamily: AppFonts.OpenSansSemiBold,
    color: AppColor.primaryTextColor,
    decoration: TextDecoration.underline,
    decorationColor: AppColor.primaryTextColor,
    decorationThickness: 1,
  );

  static TextStyle get buttonTextStyle => TextStyle(
    fontSize: 16,
    fontFamily: AppFonts.OpenSansSemiBold,
    color: AppColor.primaryTextColor,
  );

 static TextStyle get hashtagTextStyle => TextStyle(
    fontFamily: AppFonts.OpenSansRegular,
                  color: Color(0xff0677C8),
                  fontSize: 14,
  );
  static TextStyle get caption => TextStyle(
    fontSize: 12,
    fontFamily: AppFonts.OpenSansRegular,
    color: AppColor.primaryTextColor.withOpacity(0.6),
  );

  static TextStyle get errorText => TextStyle(
    fontSize: 12,
    fontFamily: AppFonts.OpenSansRegular,
    color: AppColor.redColor,
  );
}
