import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/auth_controller/verification_code_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationCodeView extends StatelessWidget {
  const VerificationCodeView({super.key});

  String _toPlainString(dynamic v) {
    if (v is String) return v;
    if (v is RxString) return v.value;
    return v?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String emailArg = _toPlainString(args['email']);
    final String? username = args['username'] == null
        ? null
        : _toPlainString(args['username']);
    final bool isRecovery =
        args['isRecovery'] == true || args['flow'] == 'recovery';

    final VerificationCodeController c = Get.put(
      VerificationCodeController(
        email: emailArg,
        username: username,
        isFromRecovery: isRecovery,
      ),
    );

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
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text('Verification Code', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.smallText,
                    children: [
                      const TextSpan(
                        text:
                            'Enter the verification code that we have sent to your email address ',
                      ),
                      TextSpan(
                        text: '“$emailArg”',
                        style: AppTextStyles.smallTextBold,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

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
                    onCompleted: c.onCompleted,
                  ),
                ),

                const Spacer(),

                Center(
                  child: Column(
                    children: [
                      Obx(
                        () => Text(
                          _formatTimer(c.secondsLeft.value),
                          style: AppTextStyles.smallText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Obx(
                        () => GestureDetector(
                          onTap: c.isResendEnabled.value ? c.resendCode : null,
                          child: Text(
                            'Resend Code',
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
              ],
            ),
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
