import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildTextField({
  required String label,
  required TextEditingController controller,
  required String placeholder,
  int maxLines = 1,
  int? maxLength,
  int minLength = 0,
  bool readOnly = false,
  VoidCallback? onTap,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      // Listen to controller changes
      controller.addListener(() {
        setState(() {});
      });

      final currentLength = controller.text.length;
      final isMinLengthMet = minLength > 0 && currentLength >= minLength;
      final remaining = minLength > 0 ? minLength - currentLength : 0;

      // Determine border color
      Color borderColor;
      if (minLength > 0) {
        if (currentLength == 0) {
          borderColor = Colors.grey[300]!;
        } else if (currentLength < minLength) {
          borderColor = Colors.red;
        } else {
          borderColor = AppColor.primaryColor;
        }
      } else {
        borderColor = Colors.grey[300]!;
      }

      // Determine counter text color
      Color counterColor;
      if (remaining > 100) {
        counterColor = Colors.red;
      } else if (remaining > 50) {
        counterColor = Colors.orange;
      } else if (remaining > 0) {
        counterColor = Color(0xff969FAE);
      } else {
        counterColor = AppColor.primaryColor;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.smallText.copyWith(color: Color(0xff172B4D)),
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              TextField(
                controller: controller,
                maxLines: maxLines,
                maxLength: maxLength,
                readOnly: readOnly,
                onTap: onTap,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: AppTextStyles.normalText.copyWith(
                    color: Color(0xffA0AEC0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: minLength > 0 && !isMinLengthMet
                          ? Colors.red
                          : AppColor.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(16),
                  counterText: '', // Hide default counter
                ),
              ),
              if (minLength > 0)
                Positioned(
                  bottom: 5,
                  right: 16,
                  child: Text(
                    remaining > 0
                        ? 'characters_remaining'.tr.replaceAll(
                            '@count',
                            remaining.toString(),
                          )
                        : 'characters_over_minimum'.tr.replaceAll(
                            '@count',
                            (currentLength - minLength).toString(),
                          ),
                    style: AppTextStyles.extraSmallText.copyWith(
                      color: counterColor,
                      fontWeight: remaining > 0
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    },
  );
}
// import 'package:collaby_app/res/colors/app_color.dart';
// import 'package:collaby_app/res/fonts/app_fonts.dart';
// import 'package:flutter/material.dart';

// Widget buildTextField({
//   required String label,
//   required TextEditingController controller,
//   required String placeholder,
//   int maxLines = 1,
//   int? maxLength,
//   int minLength = 150,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: AppTextStyles.smallText.copyWith(color: Color(0xff172B4D)),
//       ),
//       SizedBox(height: 8),
//       TextField(
//         controller: controller,
//         maxLines: maxLines,
//         maxLength: maxLength,
//         onTapOutside: (event) {
//           FocusManager.instance.primaryFocus?.unfocus();
//         },
//         decoration: InputDecoration(
//           hintText: placeholder,
//           hintStyle: AppTextStyles.normalText.copyWith(
//             color: Color(0xffA0AEC0),
//           ),

//           // filled: true,
//           // fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Color(0xffE2E8F0)),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: AppColor.primaryColor),
//           ),
//           contentPadding: EdgeInsets.all(16),
//         ),
//       ),
//     ],
//   );
// }
