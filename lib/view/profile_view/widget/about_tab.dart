import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/profile_controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AboutTab extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.profileData.value;
      if (profile == null) {
        return Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Bio', _buildBioContent(profile.description)),
              _buildSection('Age Group', _buildChip(profile.ageGroup)),
              _buildSection('Gender', _buildChip(profile.gender)),
              _buildSection(
                'Skills',
                _buildChipsList(
                  profile.niches
                      .map((e) => StringExtension(e).capitalize)
                      .toList(),
                ),
              ),
              _buildSection(
                'Languages',
                _buildChipsList(
                  profile.languages
                      .map((e) => '${e.language} (${e.level})')
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.normalTextBold),
        SizedBox(height: 8),
        content,
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBioContent(String bio) {
    return Text(bio, style: AppTextStyles.extraSmallText);
  }

  Widget _buildChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xff917DE5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTextStyles.extraSmallText.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildChipsList(List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => _buildChip(item)).toList(),
    );
  }
}

extension StringExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}

