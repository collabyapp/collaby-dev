import 'dart:async';
import 'package:collaby_app/repository/auth_repository/forgot_repository/forgot_repository.dart';
import 'package:collaby_app/repository/auth_repository/otp_verification_repository/otp_verification_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class VerificationCodeController extends GetxController {
  VerificationCodeController({
    required this.email,
    this.username,
    required this.isFromRecovery,
  });

  final String email; // plain String
  final String? username; // optional, for AccountCreated screen
  final bool isFromRecovery; // decides where to go after OTP

  final RxInt secondsLeft = 60.obs;
  final RxBool isResendEnabled = false.obs;
  final RxString code = ''.obs;

  Timer? _timer;
  final OtpVerificationRepository otpVerificationRepo =
      OtpVerificationRepository();
  final ForgotRepository _forgotRepo = ForgotRepository();
  final UserPreference userPreference = UserPreference();

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    secondsLeft.value = 60;
    isResendEnabled.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        t.cancel();
        secondsLeft.value = 0;
        isResendEnabled.value = true;
      } else {
        secondsLeft.value--;
      }
    });
  }

  Future<void> onCompleted(String value) async {
    code.value = value.trim();

    try {
      // 1) Call the right API
      final raw = isFromRecovery
          ? await _forgotRepo.verifyForgotOTPApi({
              "email": email,
              "otp": code.value,
            })
          : await otpVerificationRepo.verifyOTPApi({
              "email": email,
              "otp": code.value,
            });

      // 2) Null/shape guard
      if (raw == null || raw is! Map) {
        Utils.snackBar('Error', 'No response from server. Please try again.');
        return;
      }
      final Map<String, dynamic> resp = Map<String, dynamic>.from(raw);

      // 3) Unified error handling: repo returns {error: true, statusCode, message}
      final int? status = resp['statusCode'] is int
          ? resp['statusCode'] as int
          : null;
      final bool isError =
          resp['error'] == true || (status != null && status >= 400);
      final String serverMsg = (resp['message'] ?? '').toString();

      if (isError) {
        Utils.snackBar(
          'Invalid OTP',
          serverMsg.isNotEmpty
              ? serverMsg
              : 'Please check the code and try again.',
        );
        return;
      }

      // 4) Success path: read data safely (may be absent on some backends)
      final Map<String, dynamic> data = resp['data'] is Map
          ? Map<String, dynamic>.from(resp['data'])
          : <String, dynamic>{};
      final String token = (data['token'] ?? '').toString(); // optional

      // 5) Navigate based on flow
      if (isFromRecovery) {
        Get.offAllNamed(
          RouteName.passwordRecoveryView,
          arguments: {'email': email, 'otp': code.value},
        );
      } else {
        final displayName = (username != null && username!.isNotEmpty)
            ? username!
            : _emailToName(email);
        await userPreference.saveUser(
          token: token,
          email: email,
          isLogin: false,
        );

        Get.offAllNamed(
          RouteName.accountCreatedView,
          arguments: {'username': displayName},
        );
      }
    } catch (e, st) {
      debugPrint("OTP verification error: $e");
      debugPrintStack(stackTrace: st);
      Utils.snackBar('Error', e.toString());
    }
  }

  String _emailToName(String e) {
    final at = e.indexOf('@');
    return at > 0 ? e.substring(0, at) : e;
  }

  // Optional (top of controller)
  final RxBool isResending =
      false.obs; // for a small loader on the resend button (if you want)

  Future<void> resendCode() async {
    // Guard: cooldown active or already sending
    if (!isResendEnabled.value || isResending.value) return;

    if (email.isEmpty) {
      Utils.snackBar('Missing email', 'Please provide an email address first.');
      return;
    }

    try {
      isResending.value = true;
      isResendEnabled.value = false; // lock immediately to avoid double taps

      if (isFromRecovery) {
        await _forgotRepo.forgotApi({'email': email});
      } else {
        await otpVerificationRepo.sendOTPApi({'email': email});
      }

      Utils.snackBar('OTP sent', 'Weâ€™ve sent a new code to $email.');
      _startTimer(); // should handle enabling after countdown completes
    } catch (e) {
      // On failure, allow user to try again
      isResendEnabled.value = true;
      Utils.snackBar('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}



