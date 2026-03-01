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
              _buildSection(
                'profile_bio'.tr,
                _buildBioContent(profile.description),
              ),
              _buildSection(
                'profile_age_group'.tr,
                _buildChip(_fallbackText(profile.ageGroup)),
              ),
              _buildSection(
                'profile_gender'.tr,
                _buildChip(_localizedGender(profile.gender)),
              ),
              _buildSection(
                'profile_skills'.tr,
                _buildChipsList(
                  profile.niches
                      .map(_capitalize)
                      .where((e) => e.trim().isNotEmpty)
                      .toList(),
                ),
              ),
              _buildSection(
                'profile_languages'.tr,
                _buildChipsList(
                  profile.languages.map((e) {
                    final language = _normalizeValue(e.language);
                    if (language.isEmpty) return '';
                    final level = _normalizeValue(e.level);
                    return level.isEmpty
                        ? language
                        : '$language (${level.capitalize})';
                  }).toList(),
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
    return Text(_fallbackText(bio), style: AppTextStyles.extraSmallText);
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
    final cleanItems = items
        .map(_normalizeValue)
        .where((e) => e.isNotEmpty)
        .toList();
    if (cleanItems.isEmpty) return _buildChip('-');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cleanItems.map((item) => _buildChip(item)).toList(),
    );
  }

  String _fallbackText(String value) {
    final v = _normalizeValue(value);
    return v.isEmpty ? '-' : v;
  }

  String _normalizeValue(String value) {
    final v = value.trim();
    if (v.isEmpty) return '';
    final lower = v.toLowerCase();
    if (lower == '-' || lower == 'null' || lower == 'n/a') return '';
    return v;
  }

  String _localizedGender(String value) {
    final v = _normalizeValue(value).toLowerCase();
    if (v.isEmpty) return '-';
    if (v.contains('female') || v.contains('mujer')) return 'gender_female'.tr;
    if (v.contains('male') || v.contains('hombre')) return 'gender_male'.tr;
    if (v.contains('non')) return 'gender_non_binary'.tr;
    return _capitalize(value);
  }

  String _capitalize(String value) {
    final v = value.trim();
    if (v.isEmpty) return '';
    return '${v[0].toUpperCase()}${v.substring(1)}';
  }
}
