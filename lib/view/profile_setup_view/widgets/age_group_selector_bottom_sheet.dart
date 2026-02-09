import 'package:collaby_app/view_models/controller/profile_setup_controller/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgeGroupSelectorBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileSetUpController>();

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
            'select_age_group'.tr,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20),

          GetBuilder<ProfileSetUpController>(
            builder: (ctrl) => Column(
              children: controller.ageGroups.map((ageGroup) {
                final isSelected = ctrl.ageGroup == ageGroup;
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffF4F7FF), // Background color of the tile
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Circular radius
                    ),
                    child: ListTile(
                      splashColor: Colors.transparent,

                      title: Text(_ageGroupLabel(ageGroup)),
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
                        ctrl.updateAgeGroup(ageGroup);
                      },
                    ),
                  ),
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
              child: Text('done'.tr, style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

String _ageGroupLabel(String value) {
  final v = value.toLowerCase();
  if (v.contains('18') || v.contains('24')) return 'age_group_18_24'.tr;
  if (v.contains('25') || v.contains('39')) return 'age_group_25_39'.tr;
  if (v.contains('40')) return 'age_group_40_plus'.tr;
  return value;
}
