import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/profile_setup_controller/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSelectorBottomSheet extends StatelessWidget {
  const LanguageSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileSetUpController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Language',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          // Search (no local state)
          TextField(
            onChanged: controller.filterLanguages,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: AppTextStyles.extraSmallText.copyWith(
                color: Color(0xff000000).withOpacity(0.41),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: 13,
                  child: Image.asset(ImageAssets.searchIcon, width: 10),
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xffE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.primaryColor),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 20),

          // Language list (rebuilds only when id 'lang_list' updated)
          Expanded(
            child: GetBuilder<ProfileSetUpController>(
              id: 'lang_list',
              builder: (c) {
                // Show loading indicator while data is being fetched
                if (c.isLoadingData.value) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                  );
                }

                // Show message if no languages loaded
                if (c.filteredLanguages.isEmpty) {
                  return Center(child: Text('No languages available'));
                }

                return ListView.builder(
                  itemCount: c.filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final language = c.filteredLanguages[index];

                    // Use Obx to react to selectedLanguages (RxList)
                    return Obx(() {
                      final isSelected = c.selectedLanguages.any(
                        (lang) =>
                            lang.code == language.code, // ✅ Compare by code
                      );

                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffF4F7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            splashColor: Colors.transparent,
                            title: Text(
                              language.name,
                            ), // ✅ Display language name
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF6C5CE7),
                                  )
                                : const Icon(
                                    Icons.radio_button_unchecked,
                                    color: Color(0xFF6C5CE7),
                                  ),
                            onTap: () {
                              if (isSelected) {
                                c.removeLanguage(
                                  language.code,
                                ); // ✅ Remove by code
                              } else {
                                c.addLanguage(
                                  language.code, // ✅ First parameter: code
                                  language.name, // ✅ Second parameter: name
                                  'Beginner', // ✅ Third parameter: level
                                );
                              }
                            },
                          ),
                        ),
                      );
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
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
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
