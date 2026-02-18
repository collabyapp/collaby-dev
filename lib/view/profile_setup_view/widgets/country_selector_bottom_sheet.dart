import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/profile_setup_controller/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountrySelectorBottomSheet extends StatelessWidget {
  CountrySelectorBottomSheet({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileSetUpController>();

    return Container(
      height: Get.height * 0.8,
      // height: MediaQuery.of(context).size.height * 0.8,
      // color: Colors.white,
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
          Text(
            'select_country'.tr,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: searchController,
            onChanged: ctrl.filterCountries,
            // << GetX method
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              hintText: 'search'.tr,

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
          const SizedBox(height: 10),

          Expanded(
            child: GetBuilder<ProfileSetUpController>(
              builder: (c) => ListView.builder(
                itemCount: c.filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = c.filteredCountries[index];
                  final isSelected = c.country == country;

                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(
                          0xffF4F7FF,
                        ), // Background color of the tile
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Circular radius
                      ),

                      child: ListTile(
                        splashColor: Colors.transparent,
                        // tileColor: Color(0xffF4F7FF),
                        title: Text(country),
                        trailing: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? Color(0xFF4C1CAE)
                              : Color(0xFF4C1CAE),
                        ),
                        onTap: () => c.updateCountry(country),
                      ),
                    ),
                  );
                },
              ),
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
              child: Text('done'.tr, style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
