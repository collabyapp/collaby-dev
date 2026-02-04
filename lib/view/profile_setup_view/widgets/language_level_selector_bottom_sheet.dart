import 'package:collaby_app/view_models/controller/profile_setup_controller/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageLevelSelectorBottomSheet extends StatelessWidget {
  final String language;

  const LanguageLevelSelectorBottomSheet({required this.language});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileSetUpController>();
    controller.selectedLanguages
        .firstWhere((lang) => lang.name == language)
        .level;

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Select Level',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            language,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),

          Obx(
            () => Column(
              children: controller.languageLevels.map((level) {
                final isSelected =
                    controller.selectedLanguages
                        .firstWhere((lang) => lang.name == language)
                        .level ==
                    level;
                return ListTile(
                  splashColor: Colors.transparent,
                  title: Text(level),
                  trailing: isSelected
                      ? Icon(
                          Icons.radio_button_checked,
                          color: Color(0xFF4C1CAE),
                        )
                      : Icon(
                          Icons.radio_button_unchecked,
                          color: Color(0xFF4C1CAE),
                        ),
                  onTap: () {
                    controller.updateLanguageLevel(language, level);
                  },
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
