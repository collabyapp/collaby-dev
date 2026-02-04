import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/gig_creation_controller/create_gig_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showSelectVideoStyleSheet(BuildContext context) async {
  final c = Get.find<CreateGigController>();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xffD1D5DB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Text('Select Video Style', style: AppTextStyles.h6),
              const SizedBox(height: 4),
              Text(
                'You can select maximum 3 Video styles',
                style: AppTextStyles.extraSmallText.copyWith(
                  color: Color(0xff77787A),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final style = c.videoStyles[index];
                    // final checked = c.selectedStyles.contains(style);

                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Color(0xffF4F7FF),
                      title: Text(style),
                      trailing: Obx(() {
                        final checked = c.selectedStyles.contains(
                          style,
                        ); // Get current selection state
                        return Icon(
                          checked
                              ? Icons.check_circle
                              // Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: checked
                              ? Color(0xFF4C1CAE)
                              : Color(0xFF4C1CAE),
                        );

                        //  Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: SizedBox(
                        //     width: 40, // Fixed width for trailing widget
                        //     child: Checkbox(
                        //       value: checked,
                        //       onChanged: (_) => c.toggleStyle(
                        //         style,
                        //       ), // Update selection when clicked
                        //     ),
                        //   ),
                        // );
                      }),

                      // ),
                      onTap: () => c.toggleStyle(style),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: c.videoStyles.length,
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: CustomButton(
                      title: 'Done',
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
