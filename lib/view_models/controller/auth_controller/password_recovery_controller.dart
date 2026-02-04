import 'package:collaby_app/repository/auth_repository/forgot_repository/forgot_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class PasswordRecoveryController extends GetxController {
  // State
  String newPassword = '';
  String confirmPassword = '';

  String? newPassError;
  String? confirmPassError;

  bool hideNew = true;
  bool hideConfirm = true;
  bool isSubmitting = false;

  // Passed arguments
  late String email;
  late String code;

  @override
  void onInit() {
    super.onInit();

    // ✅ Get arguments passed via Get.toNamed / Get.offAllNamed
    final args = Get.arguments as Map<String, dynamic>;
    email = args['email'];
    code = args['otp'];

    // You can add print statements for debugging
    if (kDebugMode) {
      print("Received email: $email, code: $code");
    }
  }

  // Validation
  bool get isValid =>
      newPassError == null &&
      confirmPassError == null &&
      newPassword.isNotEmpty &&
      confirmPassword.isNotEmpty;
  final ForgotRepository _forgotRepo = ForgotRepository();
  void onNewPasswordChanged(String v) {
    newPassword = v.trim();
    _validateNew();
    _validateConfirm(); // re-check match when first changes
    update(['newPasswordField', 'submitButton', 'confirmPasswordField']);
  }

  void onConfirmPasswordChanged(String v) {
    confirmPassword = v.trim();
    _validateConfirm();
    update(['confirmPasswordField', 'submitButton']);
  }

  void toggleNewVisibility() {
    hideNew = !hideNew;
    update(['newPasswordField']);
  }

  void toggleConfirmVisibility() {
    hideConfirm = !hideConfirm;
    update(['confirmPasswordField']);
  }

  void _validateNew() {
    if (newPassword.isEmpty) {
      newPassError = 'Password is required';
    } else if (newPassword.length < 8) {
      newPassError = 'Minimum 8 characters';
    } else {
      newPassError = null;
    }
  }

  void _validateConfirm() {
    if (confirmPassword.isEmpty) {
      confirmPassError = 'Please confirm your password';
    } else if (confirmPassword != newPassword) {
      confirmPassError = 'Password do not match';
    } else {
      confirmPassError = null;
    }
  }

  Future<void> submit() async {
    // Run validations
    _validateNew();
    _validateConfirm();
    update(['newPasswordField', 'confirmPasswordField', 'submitButton']);

    if (!isValid) return;

    try {
      isSubmitting = true;

      final response = await _forgotRepo.changePasswordApi({
        "email": email,
        "otp": code,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      });

      // Normalize to Map<String, dynamic>
      final Map<String, dynamic> resp = response == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(response as Map);

      final int? status = resp['statusCode'] is int
          ? resp['statusCode'] as int
          : null;
      final bool hasError =
          resp['error'] != null || (status != null && status >= 400);

      if (hasError) {
        // Example: 409 duplicate email
        final msg =
            (resp['message'] ?? 'Password Reset Failed. Please try again.')
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

      Get.offAllNamed(RouteName.logInView);
    } catch (e) {
      isSubmitting = false;

      // print("Error during password reset: $e");
      Utils.snackBar('Error', 'Something went wrong. Please try again.');
    } finally {
      isSubmitting = false;
      update(['submitButton']);
    }
  }
}
