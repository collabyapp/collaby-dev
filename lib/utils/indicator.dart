import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingIndicator {
  static bool state = false;

  ///common method for showing progress dialog
  static void onStart({required BuildContext context}) {
    if (state) {
      onStop(context: context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        state = true;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, data) async => false,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      },
    );
  }

  ///common method for hiding progress dialog
  static void onStop({required BuildContext context}) {
    if (state) {
      state = false;
      Get.back();
    }
  }
}
