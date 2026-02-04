import 'dart:developer';

import 'package:collaby_app/repository/auth_repository/sign_up_repository/sign_up_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/custom_snakbar.dart';
import 'package:collaby_app/utils/indicator.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/services/auth_service/auth_service.dart';
import 'package:collaby_app/view_models/services/google_signin_services/google_signin_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  // form
  final formKey = GlobalKey<FormState>();

  // state
  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;

  final obscure1 = true.obs; // password
  final obscure2 = true.obs; // confirm

  final isSubmitting = false.obs;
  final SignUpRepository signUpRepo = SignUpRepository();
  final AuthService _auth = AuthService();

  // validation messages
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  // computed
  bool get isValid =>
      _validateEmail(email.value) == null &&
      _validatePassword(password.value) == null &&
      _validateConfirm(confirmPassword.value) == null &&
      email.value.isNotEmpty &&
      password.value.isNotEmpty &&
      confirmPassword.value.isNotEmpty;

  // --- field handlers ---
  void onEmailChanged(String v) {
    email.value = v.trim();
    emailError = _validateEmail(email.value);
    update(['emailField', 'signUpButton']);
  }

  void onPasswordChanged(String v) {
    password.value = v;
    passwordError = _validatePassword(password.value);
    // re-check confirm when password changes
    confirmPasswordError = _validateConfirm(confirmPassword.value);
    update(['passwordField', 'confirmField', 'signUpButton']);
  }

  void onConfirmChanged(String v) {
    confirmPassword.value = v;
    confirmPasswordError = _validateConfirm(confirmPassword.value);
    update(['confirmField', 'signUpButton']);
  }

  void toggleObscure1() {
    obscure1.value = !obscure1.value;
    update(['passwordField']);
  }

  void toggleObscure2() {
    obscure2.value = !obscure2.value;
    update(['confirmField']);
  }

  // --- actions ---
  Future<void> signUp() async {
    // 1) Validate
    if (!isValid) {
      emailError = _validateEmail(email.value);
      passwordError = _validatePassword(password.value);
      confirmPasswordError = _validateConfirm(confirmPassword.value);
      update(['emailField', 'passwordField', 'confirmField', 'signUpButton']);
      return;
    }

    try {
      // 2) Loading ON
      isSubmitting.value = true;
      update(['signUpButton']);

      // 3) API call
      final raw = await signUpRepo.signUpApi({
        "email": email.value,
        "password": password.value,
      });

      // Normalize to Map<String, dynamic>
      final Map<String, dynamic> resp = raw == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(raw as Map);

      final int? status = resp['statusCode'] is int
          ? resp['statusCode'] as int
          : null;
      final bool hasError =
          resp['error'] != null || (status != null && status >= 400);

      if (hasError) {
        // Example: 409 duplicate email
        final msg = (resp['message'] ?? 'Sign up failed. Please try again.')
            .toString();
        Utils.snackBar('Sign Up Failed', msg);
        return; // 🚫 do not navigate
      }

      // If your backend returns success markers, check them here.
      // e.g., status == 201 || resp['success'] == true || resp['data'] != null
      // Adjust this predicate to your API’s real success shape:
      final bool isSuccess =
          (status == null || (status >= 200 && status < 300)) &&
          resp['error'] == null;

      if (!isSuccess) {
        Utils.snackBar(
          'Sign Up Failed',
          (resp['message'] ?? 'Unexpected server response.').toString(),
        );
        return;
      }

      // 4) Success — go to OTP
      Get.toNamed(
        RouteName.otpView,
        arguments: {'email': email.value, 'isRecovery': false},
      );
    } catch (e) {
      // 5) Exceptions
      Utils.snackBar('Error', e.toString());
    } finally {
      // 6) Loading OFF
      isSubmitting.value = false;
      update(['signUpButton']);
    }
  }

  Future<void> tapGoogle() async {
    LoadingIndicator.onStart(context: Get.context!);

    try {
      await GoogleSignServices.signOutFromGoogle();
      final GoogleSignInResult googleSignInResult =
          await GoogleSignServices.signInWithGoogle();

      if (!googleSignInResult.success) {
        await GoogleSignServices.signOutFromGoogle();
        CustomSnackBar.show(
          context: Get.context!,
          message: googleSignInResult.errorMessage ?? 'Something went wrong',
        );
        return;
      }
      final userData = googleSignInResult.userData ?? {};
      final idToken = (userData['idToken'] ?? '') as String;
      final emailFromGoogle = (userData['email'] ?? '') as String;

      if (idToken.isEmpty) {
        throw 'Google ID token is missing.';
      }

      final decision = await _auth.loginWithGoogleFlow(
        googleIdToken: idToken,
        fallbackEmailForOtp: emailFromGoogle, // used if OTP needed
      );

      if (decision.otpSent) {
        CustomSnackBar.show(
          context: Get.context!,
          message: 'We sent you an OTP. Please verify your email.',
        );
      }

      Get.offAllNamed(decision.route, arguments: decision.arguments);
    } catch (e, st) {
      log('Google Sign-In error: $e', stackTrace: st);
      await GoogleSignServices.signOutFromGoogle();
      CustomSnackBar.show(context: Get.context!, message: e.toString());
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      LoadingIndicator.onStop(context: Get.context!);
    }
  }

  void tapApple() => Utils.snackBar('Apple', 'Continue with Apple (demo).');

  // --- validators ---
  String? _validateEmail(String v) {
    if (v.isEmpty) return 'Enter your email';
    final rgx = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!rgx.hasMatch(v)) return 'Please enter a valid email address.';
    return null;
  }

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'Enter your password';
    if (v.length < 8) return 'Min 8 characters';
    return null;
  }

  String? _validateConfirm(String v) {
    if (v.isEmpty) return 'Confirm your password';
    if (v != password.value) return 'Password do not match';
    return null;
  }
}
