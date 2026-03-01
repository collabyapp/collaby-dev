import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/components/MilestoneProgreaaBar.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/profile_setup_view/common/TextInputField.dart';
import 'package:collaby_app/view_models/controller/profile_setup_controller/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class ProfileSetupView extends StatelessWidget {
  final bool isEdit;

  ProfileSetupView({Key? key})
    : isEdit =
          (Get.arguments?['isEdit'] as bool?) ??
          (Get.parameters['isEdit'] == 'true'),
      super(key: key);

  @override
  Widget build(BuildContext context) {
    ProfileSetUpController controller = Get.put(ProfileSetUpController());
    controller.ensureMode(isEdit);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          isEdit ? 'profile_edit_title'.tr : 'profile_setup_title'.tr,
        ),
      ),
      body: !isEdit
          ? GetBuilder<ProfileSetUpController>(
              builder: (controller) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MilestonedProgressBar(
                      progress: 0.37,
                      milestones: [0.35, 0.65],
                      showProgressHeadDot: false,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'profile_personal_info'.tr,
                      style: AppTextStyles.smallTextBold,
                    ),
                    SizedBox(height: 24),

                    // Profile Image
                    Center(
                      child: GestureDetector(
                        onTap: controller.pickProfileImage,
                        child: Stack(
                          children: [
                            Obx(() {
                              ImageProvider? provider;

                              if (controller.profileImageUrl.value.isNotEmpty) {
                                provider = NetworkImage(
                                  controller.profileImageUrl.value,
                                );
                              } else if (controller
                                  .profileImageLocal
                                  .value
                                  .isNotEmpty) {
                                provider = FileImage(
                                  File(controller.profileImageLocal.value),
                                );
                              }

                              return CircleAvatar(
                                radius: 50,
                                backgroundImage: provider,
                                backgroundColor: Colors.grey[200],
                                child: provider == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey[400],
                                      )
                                    : null,
                              );
                            }),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  ImageAssets.cameraIcon,
                                  width: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Form Fields
                    buildTextField(
                      label: 'profile_first_name'.tr,
                      controller: controller.firstNameController,
                      placeholder: 'profile_first_name_hint'.tr,
                    ),
                    SizedBox(height: 20),
                    buildTextField(
                      label: 'profile_last_name'.tr,
                      controller: controller.lastNameController,
                      placeholder: 'profile_last_name_hint'.tr,
                    ),
                    SizedBox(height: 20),
                    buildTextField(
                      label: 'profile_display_name'.tr,
                      controller: controller.displayNameController,
                      placeholder: 'profile_display_name_hint'.tr,
                    ),
                    SizedBox(height: 20),
                    buildTextField(
                      label: 'profile_bio'.tr,
                      controller: controller.descriptionController,
                      placeholder: 'description_placeholder'.tr,
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    SizedBox(height: 20),
                    // Age Group & Gender Section
                    Text(
                      'profile_age_gender'.tr,
                      style: AppTextStyles.normalText,
                    ),
                    SizedBox(height: 12),
                    _buildSelectionTile(
                      title: controller.ageGroup.isEmpty
                          ? 'select_age_group'.tr
                          : _ageGroupLabel(controller.ageGroup),
                      isPlaceholder: controller.ageGroup.isEmpty,
                      onTap: controller.showAgeGroupSelector,
                    ),
                    SizedBox(height: 12),
                    _buildSelectionTile(
                      title: controller.gender.isEmpty
                          ? 'select_gender'.tr
                          : _genderLabel(controller.gender),
                      isPlaceholder: controller.gender.isEmpty,
                      onTap: controller.showGenderSelector,
                    ),
                    SizedBox(height: 20),

                    // Country Section
                    Text('profile_country'.tr, style: AppTextStyles.normalText),
                    SizedBox(height: 12),
                    _buildSelectionTile(
                      title: controller.country.isEmpty
                          ? 'select_country'.tr
                          : controller.country,
                      isPlaceholder: controller.country.isEmpty,
                      onTap: controller.showCountrySelector,
                    ),
                    SizedBox(height: 20),

                    // Language Section
                    _buildLanguageSection(controller),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            )
          : Obx(() {
              // Show loading when fetching profile data in edit mode
              if (isEdit && controller.isLoadingProfile.value) {
                return Center(child: CircularProgressIndicator());
              }
              return GetBuilder<ProfileSetUpController>(
                builder: (controller) => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !isEdit
                          ? MilestonedProgressBar(
                              progress: 0.37,
                              milestones: [0.35, 0.65],
                              showProgressHeadDot: false,
                            )
                          : SizedBox.shrink(),
                      isEdit ? SizedBox.shrink() : SizedBox(height: 16),
                      isEdit
                          ? SizedBox.shrink()
                          : Text(
                              'profile_personal_info'.tr,
                              style: AppTextStyles.smallTextBold,
                            ),
                      isEdit ? SizedBox.shrink() : SizedBox(height: 24),

                      // Profile Image
                      Center(
                        child: GestureDetector(
                          onTap: controller.pickProfileImage,
                          child: Stack(
                            children: [
                              Obx(() {
                                ImageProvider? provider;

                                if (controller
                                    .profileImageUrl
                                    .value
                                    .isNotEmpty) {
                                  provider = NetworkImage(
                                    controller.profileImageUrl.value,
                                  );
                                } else if (controller
                                    .profileImageLocal
                                    .value
                                    .isNotEmpty) {
                                  provider = FileImage(
                                    File(controller.profileImageLocal.value),
                                  );
                                }

                                return CircleAvatar(
                                  radius: 50,
                                  backgroundImage: provider,
                                  backgroundColor: Colors.grey[200],
                                  child: provider == null
                                      ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey[400],
                                        )
                                      : null,
                                );
                              }),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    ImageAssets.cameraIcon,
                                    width: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32),

                      // Form Fields
                      buildTextField(
                        label: 'profile_first_name'.tr,
                        controller: controller.firstNameController,
                        placeholder: 'profile_first_name_hint'.tr,
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        label: 'profile_last_name'.tr,
                        controller: controller.lastNameController,
                        placeholder: 'profile_last_name_hint'.tr,
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        label: 'profile_display_name'.tr,
                        controller: controller.displayNameController,
                        placeholder: 'profile_display_name_hint'.tr,
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        label: 'profile_bio'.tr,
                        controller: controller.descriptionController,
                        placeholder: 'description_placeholder'.tr,
                        maxLines: 4,
                        maxLength: 500,
                      ),
                      SizedBox(height: 20),

                      // Age Group & Gender Section
                      Text(
                        'profile_age_gender'.tr,
                        style: AppTextStyles.normalText,
                      ),
                      SizedBox(height: 12),
                      _buildSelectionTile(
                        title: controller.ageGroup.isEmpty
                            ? 'select_age_group'.tr
                            : _ageGroupLabel(controller.ageGroup),
                        isPlaceholder: controller.ageGroup.isEmpty,
                        onTap: controller.showAgeGroupSelector,
                      ),
                      SizedBox(height: 12),
                      _buildSelectionTile(
                        title: controller.gender.isEmpty
                            ? 'select_gender'.tr
                            : _genderLabel(controller.gender),
                        isPlaceholder: controller.gender.isEmpty,
                        onTap: controller.showGenderSelector,
                      ),
                      SizedBox(height: 20),

                      // Country Section
                      Text(
                        'profile_country'.tr,
                        style: AppTextStyles.normalText,
                      ),
                      SizedBox(height: 12),
                      _buildSelectionTile(
                        title: controller.country.isEmpty
                            ? 'select_country'.tr
                            : controller.country,
                        isPlaceholder: controller.country.isEmpty,
                        onTap: controller.showCountrySelector,
                      ),
                      SizedBox(height: 20),

                      // Language Section
                      _buildLanguageSection(controller),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 5,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(() {
                final isDisabled =
                    !controller.isProfileValid.value ||
                    controller.isSubmittingProfile.value;

                return CustomButton(
                  title: isEdit ? 'update_profile'.tr : 'next'.tr,
                  isDisabled: isDisabled,
                  onPressed: () {
                    if (controller.isSubmittingProfile.value) return;

                    if (isEdit) {
                      controller.updateProfile();
                    } else {
                      controller.submitProfile();
                    }
                  },
                  isLoading: controller.isSubmittingProfile.value,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.normalText.copyWith(
                  color: isPlaceholder ? Colors.grey[400] : Colors.black,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xff3F4146)),
          ],
        ),
      ),
    );
  }
}

Widget _buildLanguageSection(ProfileSetUpController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('profile_language'.tr, style: AppTextStyles.normalText),
      SizedBox(height: 12),
      Obx(
        () => Column(
          children: controller.selectedLanguages
              .map(
                (language) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xffF5F6FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            language.name,
                            style: AppTextStyles.normalTextMedium,
                          ),
                          Spacer(),
                          if (controller.selectedLanguages.length > 1)
                            TextButton(
                              onPressed: () =>
                                  controller.removeLanguage(language.name),
                              child: Text(
                                'remove'.tr,
                                style: AppTextStyles.extraSmallMediumText
                                    .copyWith(color: Color(0xffFF2222)),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'select_level'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontFamily: AppFonts.OpenSansRegular,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: controller.languageLevels.map((level) {
                          final isSelected = language.level == level;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => controller.updateLanguageLevel(
                                language.name,
                                level,
                              ),
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: level == 'Advanced' ? 0 : 8,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFF6C5CE7)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    _languageLevelLabel(level),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
      GestureDetector(
        onTap: controller.showLanguageSelector,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Obx(
                () => Text(
                  controller.selectedLanguages.isNotEmpty
                      ? 'add_another_language'.tr
                      : 'select_language'.tr,
                  style: AppTextStyles.normalText.copyWith(
                    color: Color(0XFFA0AEC0),
                  ),
                ),
              ),
              Spacer(),
              Icon(Icons.chevron_right, color: Colors.black),
            ],
          ),
        ),
      ),
    ],
  );
}

String _languageLevelLabel(String level) {
  switch (level.toLowerCase()) {
    case 'beginner':
    case 'basic':
      return 'language_level_basic'.tr;
    case 'intermediate':
    case 'conversational':
      return 'language_level_conversational'.tr;
    case 'advanced':
      return 'language_level_advanced'.tr;
    case 'fluent':
      return 'language_level_fluent'.tr;
    case 'native':
      return 'language_level_native'.tr;
    default:
      return level;
  }
}

String _ageGroupLabel(String value) {
  final v = value.toLowerCase();
  if (v.contains('18') || v.contains('24')) return 'age_group_18_24'.tr;
  if (v.contains('25') || v.contains('39')) return 'age_group_25_39'.tr;
  if (v.contains('40')) return 'age_group_40_plus'.tr;
  return value;
}

String _genderLabel(String value) {
  final v = value.toLowerCase();
  if (v.contains('female')) return 'gender_female'.tr;
  if (v.contains('male')) return 'gender_male'.tr;
  if (v.contains('non')) return 'gender_non_binary'.tr;
  return value;
}
