import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collaby_app/view_models/controller/profile_setup_controller/account_security_controller.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/components/Button.dart';

class PhoneNumberView extends StatefulWidget {
  @override
  State<PhoneNumberView> createState() => _PhoneNumberViewState();
}

class _PhoneNumberViewState extends State<PhoneNumberView> {
  final AccountSecurityController authController = Get.find();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    phoneFocusNode.addListener(() {
      setState(() => isFocused = phoneFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    phoneFocusNode.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true, // shows +971 etc next to country in the list
      onSelect: (Country c) {
        authController.setCountry(c);
        // keep focus on phone field
        FocusScope.of(context).requestFocus(phoneFocusNode);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Phone Number', style: AppTextStyles.h3),
              Text(
                'Please add your phone number',
                style: AppTextStyles.smallText,
              ),
              const SizedBox(height: 20),

              // Input with country picker prefix
              Container(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFocused
                        ? AppColor.primaryColor
                        : const Color(0xFFE7E7EE),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff606A79),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Tappable country code chip
                        InkWell(
                          onTap: _pickCountry,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Tiny flag via emoji (country_picker exposes emoji flag)
                                // Text(
                                // quick emoji from ISO
                                // Country.parse(
                                //   authController.countryIso.value,
                                // ).flagEmoji,
                                // style: const TextStyle(fontSize: 18),
                                // ),
                                const SizedBox(width: 6),
                                Text(
                                  authController
                                      .countryDialCode
                                      .value, // e.g. +92
                                  style: AppTextStyles.smallText.copyWith(
                                    color: const Color(0xff1A1A1A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // National number field
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            focusNode: phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: InputDecoration(
                              hintText: 'Phone number',
                              hintStyle: AppTextStyles.smallText.copyWith(
                                color: const Color(0xff606A79),
                              ),
                              border: InputBorder.none,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) {
                              authController.setPhoneNumber(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // // Preview of the final number (+code + national)
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 14),
                    //   child: Text(
                    //     authController.fullPhone, // e.g. +971501234567
                    //     style: AppTextStyles.extraSmallText.copyWith(
                    //       color: const Color(0xFF8A8F98),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                  ],
                ),
              ),

              const Spacer(),

              // Verify button uses the combined number
              CustomButton(
                title: 'Verify',
                isLoading: authController.isSendingOtp.value,
                isDisabled: authController.phoneNumber.value.isEmpty,
                onPressed: () async {
                  // ensure controller has latest input
                  authController.setPhoneNumber(authController.fullPhone);
                  await authController.requestOtp();
                },
              ),
              const SizedBox(height: 30),
            ],
          );
        }),
      ),
    );
  }
}
