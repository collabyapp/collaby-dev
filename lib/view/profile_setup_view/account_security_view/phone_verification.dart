import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collaby_app/view_models/controller/profile_setup_controller/account_security_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneVerificationView extends StatelessWidget {
  const PhoneVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountSecurityController c = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, size: 25),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text('verification_code'.tr, style: AppTextStyles.h3),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.smallText,
                  children: [
                    TextSpan(
                      text: 'verification_code_prompt'.tr,
                    ),
                    TextSpan(
                      text: '${c.phoneNumber}',
                      style: AppTextStyles.smallTextBold,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: PinCodeTextField(
                  appContext: context,
                  length: 4,
                  keyboardType: TextInputType.number,
                  autoDismissKeyboard: true,
                  animationType: AnimationType.fade,
                  cursorColor: Colors.black,
                  textStyle: AppTextStyles.normalText,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 58,
                    fieldWidth: 63,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: Color(0xffE2E8F0),
                    inactiveColor: const Color(0xFFE6E8EC),
                    selectedColor: Color(0xff816CED),
                  ),
                  enableActiveFill: true,
                  onChanged: (v) => c.code.value = v,
                  onCompleted: (value) async {
                    await c.onCompleted(value);
                    // c.verifyPhone();
                  },
                ),
              ),
              Spacer(),
              Center(
                child: Obx(
                  () => Text(
                    _formatTimer(c.secondsLeft.value),
                    // '00:${c.secondsLeft.value}',
                    style: AppTextStyles.smallText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Obx(
                () => GestureDetector(
                  onTap: c.isResendEnabled.value ? c.resendCode : null,
                  child: Text(
                    'resend_code'.tr,
                    style: AppTextStyles.smallMediumText.copyWith(
                      color:
                          // c.isResendEnabled.value
                          //     ? Colors.black
                          //     :
                          const Color(0xFF828282),

                      // decoration: c.isResendEnabled.value
                      //     ? TextDecoration.underline
                      //     : TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimer(int seconds) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
