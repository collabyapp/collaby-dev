import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

class CustomSnackBar {
  static bool _isSnackbarActive = false;

  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_isSnackbarActive) return;

    _isSnackbarActive = true;

    final snackBar = SnackBar(
      content: Text(
        message,
        style: AppTextStyles.smallTextBold.copyWith(color: textColor),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,

      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 140, // Adjust this value
        right: 20,
        left: 20,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(snackBar).closed.then((_) => _isSnackbarActive = false);
  }
}
