import 'dart:developer';
import 'dart:io';

import 'package:collaby_app/view_models/services/auth_service/apple_signin_service/apple_signin_service.dart';
import 'package:collaby_app/view_models/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/custom_snakbar.dart';
import 'package:collaby_app/utils/indicator.dart';
import 'package:collaby_app/utils/utils.dart';

import 'package:collaby_app/view_models/services/google_signin_services/google_signin_service.dart';

class LogInController extends GetxController {
  // Services
  final AuthService _auth = AuthService();

  // Form
  final formKey = GlobalKey<FormState>();

  // State
  final _email = ''.obs;
  final _password = ''.obs;
  final _obscure = true.obs;
  final _isSubmitting = false.obs;

  // Getters
  String get email => _email.value;
  String get password => _password.value;
  bool get obscure => _obscure.value;
  bool get isSubmitting => _isSubmitting.value;

  // Validation errors
  String? emailError;
  String? passwordError;

  bool get isValid =>
      _validateEmail(_email.value) == null &&
      _validatePassword(_password.value) == null &&
      _email.value.isNotEmpty &&
      _password.value.isNotEmpty;

  // ---------------------------- UI Callbacks ----------------------------

  void onEmailChanged(String value) {
    _email.value = value.trim();
    emailError = _validateEmail(_email.value);
    update(['emailField', 'loginButton']);
  }

  void onPasswordChanged(String value) {
    _password.value = value;
    passwordError = _validatePassword(_password.value);
    update(['passwordField', 'loginButton']);
  }

  void toggleObscure() {
    _obscure.value = !_obscure.value;
    update(['passwordField']);
  }

  void forgotPassword() => Get.toNamed(RouteName.forgotPasswordView);

  // ---------------------------- Login (Email/Password) ----------------------------

  Future<void> login() async {
    if (!_validateForm()) return;

    _setSubmitting(true);

    try {
      final decision = await _auth.loginWithEmailFlow(
        email: _email.value,
        password: _password.value,
      );

      if (decision.otpSent) {
        Utils.snackBar(
          'Success',
          'We sent you an OTP. Please verify your email.',
        );
      }

      Get.offAllNamed(decision.route, arguments: decision.arguments);
    } catch (e) {
      Utils.snackBar('Error', '${e.toString()}');
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _setSubmitting(false);
    }
  }

  // ---------------------------- Login with Google ----------------------------

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
        throw Exception('Google ID token is missing.');
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

  // ---------------------------- Login with Apple ----------------------------
  Future<void> tapApple() async {
    LoadingIndicator.onStart(context: Get.context!);

    try {
      // 1️⃣ Call Apple Sign-In once
      final AppleSignInResult appleResult =
          await AppleSignInServices.signInWithApple();

      // 2️⃣ Handle cancellation / failure from Apple
      if (!appleResult.success) {
        CustomSnackBar.show(
          context: Get.context!,
          message: appleResult.errorMessage ?? 'Something went wrong',
        );
        return;
      }

      // 3️⃣ Extract token + email
      final userData = appleResult.userData ?? {};
      final String idToken = (userData['idToken'] ?? '') as String;
      final String emailFromApple = (userData['email'] ?? '') as String? ?? '';

      if (idToken.isEmpty) {
        throw Exception('Apple ID token is missing.');
      }

      // 4️⃣ Call your backend/AuthService for Apple login
      final decision = await _auth.loginWithAppleFlow(
        appleIdToken: idToken,
        fallbackEmailForOtp: emailFromApple, // used if OTP needed
      );

      // 5️⃣ Handle OTP flow (same style as Google)
      if (decision.otpSent) {
        CustomSnackBar.show(
          context: Get.context!,
          message: 'We sent you an OTP. Please verify your email.',
        );
      }

      // 6️⃣ Navigate as per backend decision
      Get.offAllNamed(decision.route, arguments: decision.arguments);
    } catch (e, st) {
      log('Apple Sign-In error: $e', stackTrace: st);
      CustomSnackBar.show(context: Get.context!, message: e.toString());
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      LoadingIndicator.onStop(context: Get.context!);
    }
  }

  // Future<void> tapAaapple() async {
  //   LoadingIndicator.onStart(context: Get.context!);

  //   try {
  //     await AppleSignInServices.signInWithApple();
  //     final AppleSignInResult googleSignInResult =
  //         await AppleSignInServices.signInWithApple();

  //     if (!googleSignInResult.success) {
  //       await GoogleSignServices.signOutFromGoogle();
  //       CustomSnackBar.show(
  //         context: Get.context!,
  //         message: googleSignInResult.errorMessage ?? 'Something went wrong',
  //       );
  //       return;
  //     }
  //     final userData = googleSignInResult.userData ?? {};
  //     final idToken = (userData['idToken'] ?? '') as String;
  //     final emailFromGoogle = (userData['email'] ?? '') as String;

  //     if (idToken.isEmpty) {
  //       throw Exception('Google ID token is missing.');
  //     }

  //     final decision = await _auth.loginWithAppleFlow(
  //       googleIdToken: idToken,
  //       fallbackEmailForOtp: emailFromGoogle, // used if OTP needed
  //     );

  //     if (decision.otpSent) {
  //       CustomSnackBar.show(
  //         context: Get.context!,
  //         message: 'We sent you an OTP. Please verify your email.',
  //       );
  //     }

  //     Get.offAllNamed(decision.route, arguments: decision.arguments);
  //   } catch (e, st) {
  //     log('Google Sign-In error: $e', stackTrace: st);
  //     await GoogleSignServices.signOutFromGoogle();
  //     CustomSnackBar.show(context: Get.context!, message: e.toString());
  //   } finally {
  //     await Future.delayed(const Duration(milliseconds: 300));
  //     LoadingIndicator.onStop(context: Get.context!);
  //   }
  // }

  // ---------------------------- Helpers ----------------------------

  bool _validateForm() {
    if (isValid) return true;
    emailError = _validateEmail(_email.value);
    passwordError = _validatePassword(_password.value);
    update(['emailField', 'passwordField', 'loginButton']);
    return false;
  }

  void _setSubmitting(bool value) {
    _isSubmitting.value = value;
    update(['loginButton']);
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Enter your email';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value))
      return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  @override
  void onClose() {
    _email.close();
    _password.close();
    _obscure.close();
    _isSubmitting.close();
    super.onClose();
  }
}
