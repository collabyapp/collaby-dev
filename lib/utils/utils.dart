import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:collaby_app/res/colors/app_color.dart';

class Utils {
  static void fieldFocusChange(
    BuildContext context,
    FocusNode current,
    FocusNode nextFocus,
  ) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static void toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColor.blackColor,
      textColor: AppColor.whiteColor,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  static void toastMessageCenter(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColor.blackColor,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_LONG,
      textColor: AppColor.whiteColor,
    );
  }

  static void snackBar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5), // The color of the shadow
          spreadRadius: 0.5, // How much the shadow should spread
          blurRadius: 20, // How soft the shadow should be
          offset: const Offset(0, 0), // Shifts the shadow (x, y)
        ),
      ],
      borderRadius: 20,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(15),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  static void success(String text) {
    _showToast(text, const Color.fromARGB(255, 2, 212, 62), Icons.check);
  }

  static void warn(String text) {
    _showToast(
      text,
      const Color.fromARGB(255, 245, 192, 101),
      Icons.info_outline_rounded,
    );
  }

  static void error(String text) {
    _showToast(text, const Color.fromARGB(255, 255, 21, 0), Icons.cancel);
  }

  static void _showToast(String text, Color color, IconData icon) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
