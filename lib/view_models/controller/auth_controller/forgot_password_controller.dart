import 'package:collaby_app/repository/auth_repository/forgot_repository/forgot_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  // form
  final formKey = GlobalKey<FormState>();

  final ForgotRepository _forgotRepo = ForgotRepository();

  // state
  final email = ''.obs;
  final isSubmitting = false.obs;

  // validation messages
  String? emailError;
  String? passwordError;

  // computed
  bool get isValid =>
      _validateEmail(email.value) == null && email.value.isNotEmpty;

  void onEmailChanged(String v) {
    email.value = v.trim();
    emailError = _validateEmail(email.value);
    update(['emailField', 'resetButton']);
  }

  Future<void> sendOTP() async {
    try {
      isSubmitting.value = true; // Start loading
      final result = await _forgotRepo.forgotApi({'email': email.value});

      // Normalize to Map<String, dynamic>
      final Map<String, dynamic> resp = result == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(result as Map);

      final int? status = resp['statusCode'] is int
          ? resp['statusCode'] as int
          : null;
      final bool hasError =
          resp['error'] != null || (status != null && status >= 400);
      if (hasError) {
        // Example: 409 duplicate email
        final msg = (resp['message'] ?? 'Sign up failed. Please try again.')
            .toString();
        Utils.snackBar('Error', msg);
        return; // 🚫 do not navigate
      }
      final bool isSuccess =
          (status == null || (status >= 200 && status < 300)) &&
          resp['error'] == null;

      if (!isSuccess) {
        Utils.snackBar(
          'Error',
          (resp['message'] ?? 'Unexpected server response.').toString(),
        );
        return;
      }

      Get.toNamed(
        RouteName.otpView,
        arguments: {"email": email.value, 'isRecovery': true},
      );
    } catch (e) {
      // Optional: Handle any exceptions
      Utils.snackBar('Error', e.toString());
    } finally {
      isSubmitting.value = false; // Stop loading
    }
  }

  Future<void> resetPassword() async {
    if (!isValid) {
      // trigger errors
      emailError = _validateEmail(email.value);
      update(['emailField', 'resetButton']);
      return;
    }
    isSubmitting.value = true;
    update(['resetButton']);

    await Future.delayed(const Duration(seconds: 1)); // TODO: API call

    isSubmitting.value = false;
    update(['resetButton']);
  }

  // --- validators ---
  String? _validateEmail(String v) {
    if (v.isEmpty) return 'Enter your email';
    final rgx = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!rgx.hasMatch(v))
      return 'Please enter a valid email address.'; // as in mock
    return null;
  }
}
