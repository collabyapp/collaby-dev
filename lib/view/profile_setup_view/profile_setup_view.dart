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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(isEdit ? 'Edit Profile' : 'Profile Setup'),
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
                    Text('Personal Info', style: AppTextStyles.smallTextBold),
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
                      label: 'First Name*',
                      controller: controller.firstNameController,
                      placeholder: 'Enter your first name',
                    ),
                    SizedBox(height: 20),
                    buildTextField(
                      label: 'Last Name*',
                      controller: controller.lastNameController,
                      placeholder: 'Enter your Last name',
                    ),
                    SizedBox(height: 20),
                    buildTextField(
                      label: 'Display Name*',
                      controller: controller.displayNameController,
                      placeholder: 'Enter your display name',
                    ),
                    SizedBox(height: 20),
                    Stack(
                      children: [
                        buildTextField(
                          label: 'Description',
                          controller: controller.descriptionController,
                          placeholder:
                              'Share a bit about your work experience, cool projects you\'ve completed, and your area of expertise.',
                          maxLines: 6,
                          maxLength: 600,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 10,
                          child: Text(
                            'min. 150 characters',
                            style: AppTextStyles.extraSmallText.copyWith(
                              color: Color(0xff969FAE),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Age Group & Gender Section
                    Text('Age Group & Gender', style: AppTextStyles.normalText),
                    SizedBox(height: 12),
                    _buildSelectionTile(
                      title: controller.ageGroup.isEmpty
                          ? 'Select Age Group'
                          : controller.ageGroup,
                      onTap: controller.showAgeGroupSelector,
                    ),
                    SizedBox(height: 12),
                    _buildSelectionTile(
                      title: controller.gender.isEmpty
                          ? 'Select Gender'
                          : controller.gender,
                      onTap: controller.showGenderSelector,
                    ),
                    SizedBox(height: 20),

                    // Country Section
                    Text('Country', style: AppTextStyles.normalText),
                    SizedBox(height: 12),
                    _buildSelectionTile(
                      title: controller.country.isEmpty
                          ? 'Select Country'
                          : controller.country,
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
                              'Personal Info',
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
                        label: 'First Name*',
                        controller: controller.firstNameController,
                        placeholder: 'Enter your first name',
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        label: 'Last Name*',
                        controller: controller.lastNameController,
                        placeholder: 'Enter your Last name',
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        label: 'Display Name*',
                        controller: controller.displayNameController,
                        placeholder: 'Enter your display name',
                      ),
                      SizedBox(height: 20),
                      Stack(
                        children: [
                          buildTextField(
                            label: 'Description*',
                            controller: controller.descriptionController,
                            placeholder:
                                'Share a bit about your work experience, cool projects you\'ve completed, and your area of expertise.',
                            maxLines: 6,
                            maxLength: 600,
                            minLength: 150,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),

                      Text(
                        'min. 150 characters',
                        style: AppTextStyles.extraSmallText.copyWith(
                          color: Color(0xff969FAE),
                        ),
                      ),

                      SizedBox(height: 15),

                      // Age Group & Gender Section
                      Text(
                        'Age Group & Gender',
                        style: AppTextStyles.normalText,
                      ),
                      SizedBox(height: 12),
                      _buildSelectionTile(
                        title: controller.ageGroup.isEmpty
                            ? 'Select Age Group'
                            : controller.ageGroup,
                        onTap: controller.showAgeGroupSelector,
                      ),
                      SizedBox(height: 12),
                      _buildSelectionTile(
                        title: controller.gender.isEmpty
                            ? 'Select Gender'
                            : controller.gender,
                        onTap: controller.showGenderSelector,
                      ),
                      SizedBox(height: 20),

                      // Country Section
                      Text('Country', style: AppTextStyles.normalText),
                      SizedBox(height: 12),
                      _buildSelectionTile(
                        title: controller.country.isEmpty
                            ? 'Select Country'
                            : controller.country,
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
                  title: isEdit ? 'Update Profile' : 'Next',
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
                  color: title.startsWith('Select')
                      ? Colors.grey[400]
                      : Colors.black,
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
      Text('Language*', style: AppTextStyles.normalText),
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
                                'Remove',
                                style: AppTextStyles.extraSmallMediumText
                                    .copyWith(color: Color(0xffFF2222)),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'Select Level',
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
                                    level,
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
                      ? 'Add another Language'
                      : 'Select Language',
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
