import 'dart:async';
import 'package:collaby_app/repository/account_&_security_repository/account_&_security_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view/profile_setup_view/account_security_view/phone_verification.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class AccountSecurityController extends GetxController {
  final RxnString email = RxnString();
  var isEmailVerified = true.obs;
  final isSendingOtp = false.obs;

  // national number (without country code)
  var phoneNumber = ''.obs;
  final AccountSecurityRepository phoneVerificationRepo =
      AccountSecurityRepository();
  // selected country dial code & ISO (defaults set for Pakistan)
  var countryDialCode = ''.obs;
  var countryIso = ''.obs;

  // computed full number (E.164-like)
  String get fullPhone =>
      '$countryDialCode${phoneNumber.value.replaceAll(RegExp(r'[^0-9]'), '')}';

  var isPhoneVerified = false.obs;
  var verificationCode = ''.obs;
  var countdown = 60.obs;
  final RxBool isEdit = false.obs;
  final _userPref = UserPreference();

  // Add loading state
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    isEdit.value = Get.arguments?['isEdit'] ?? false;
    _loadUser();
  }

  final RxInt secondsLeft = 60.obs;
  final RxBool isResendEnabled = false.obs;
  final RxString code = ''.obs;

  Future<void> _loadUser() async {
    try {
      isLoading.value = true;
      final user = await _userPref.getUser();

      // Handle both null and missing email cases
      if (user['email'] != null) {
        email.value = user['email'].toString();
        if (user['phoneNumber'] != null) {
          isPhoneVerified.value = true;

          phoneNumber.value = user['phoneNumber'].toString();
        }
      } else {
        email.value = 'No email found'; // Fallback
      }

      // Load phone if exists
      if (user['phone'] != null) {
        phoneNumber.value = user['phone'].toString();
        isPhoneVerified.value = true;
      }
    } catch (e) {
      print('Error loading user: $e');
      email.value = 'Error loading email';
    } finally {
      isLoading.value = false;
    }
  }

  void setPhoneNumber(String number) {
    phoneNumber.value = number;
  }

  // call when user picks a country
  void setCountry(Country c) {
    countryIso.value = c.countryCode; // e.g. 'AE'
    countryDialCode.value = '+${c.phoneCode}'; // e.g. '+971'
  }

  // ---------- NEW: request OTP then navigate on success ----------
  Future<void> requestOtp() async {
    try {
      isSendingOtp.value = true;

      // shape of payload – adjust keys to match your backend
      final payload = {"phoneNumber": phoneNumber.value};

      final raw = await phoneVerificationRepo.sendOTPApi(payload);

      if (raw == null || raw is! Map) {
        Utils.snackBar('Error', 'No response from server. Please try again.');
        return;
      }
      final Map<String, dynamic> resp = Map<String, dynamic>.from(raw);

      // Common patterns: {error: bool, statusCode: int, message: string}
      final int? status = resp['statusCode'] is int
          ? resp['statusCode'] as int
          : null;
      final bool isError =
          resp['error'] == true || (status != null && status >= 400);
      final String serverMsg = (resp['message'] ?? '').toString();

      if (isError) {
        Utils.snackBar(
          'Failed to send code',
          serverMsg.isNotEmpty ? serverMsg : 'Please try again.',
        );
        return;
      }

      // success -> go to OTP screen
      // pass the number if you want to show it masked on next screen
      Get.to(
        PhoneVerificationView(),
      ); // or Get.toNamed(RouteName.phoneVerificationView)
      _startTimer();
    } catch (e, st) {
      debugPrint('Send OTP error: $e');
      debugPrintStack(stackTrace: st);
      Utils.snackBar('Error', e.toString());
    } finally {
      isSendingOtp.value = false;
    }
  }

  void verifyPhone() async {
    // use fullPhone for API / OTP send
    // print(fullPhone);
    isPhoneVerified.value = true;
    await _userPref.saveUser(phoneNumber: phoneNumber.value);
    Get.toNamed(RouteName.accountSecurityView);
  }

  Timer? _timer;
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
      final raw = await phoneVerificationRepo.verifyOTPApi({"otp": code.value});

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

      verifyPhone();

      // await userPreference.saveUser(
      //   token: token,
      //   email: email,
      //   isLogin: false,
      // );
    } catch (e, st) {
      debugPrint("OTP verification error: $e");
      debugPrintStack(stackTrace: st);
      Utils.snackBar('Error', e.toString());
    }
  }

  Future<void> resendCode() async {
    if (!isResendEnabled.value) return;
    await requestOtp();
    _startTimer();
  }

  void resetVerification() {
    isPhoneVerified.value = false;
    phoneNumber.value = '';
    verificationCode.value = '';
  }
}
