import 'package:collaby_app/view_models/controller/profile_setup_controller/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenderSelectorBottomSheet extends StatelessWidget {
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
            'Select Gender',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20),

          GetBuilder<ProfileSetUpController>(
            builder: (ctrl) => Column(
              children: controller.genders.map((gender) {
                final isSelected = ctrl.gender == gender;
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
                      title: Text(gender),
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
                        ctrl.updateGender(gender);
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
              child: Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
