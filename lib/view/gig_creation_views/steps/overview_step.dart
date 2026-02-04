import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/gig_creation_controller/create_gig_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverviewStep extends GetView<CreateGigController> {
  const OverviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Overview', style: AppTextStyles.h6Bold),
          const SizedBox(height: 6),
          Text(
            "What describes you best? (optional)\nSelect everything that applies.",
            style: AppTextStyles.extraSmallText.copyWith(color: const Color(0xff77787A)),
          ),
          const SizedBox(height: 18),

          // Traits chips
          Obx(() {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.creatorTraits.map((t) {
                final selected = controller.selectedTraits.contains(t);

                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => controller.toggleTrait(t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF917DE5) : const Color(0xffF4F7FF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected ? const Color(0xFF917DE5) : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      t,
                      style: AppTextStyles.extraSmallMediumText.copyWith(
                        color: selected ? Colors.white : const Color(0xff3F4146),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 18),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF4F7FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              "If you don't select anything, you'll be listed as a general UGC creator by default.",
              style: AppTextStyles.extraSmallText.copyWith(color: const Color(0xff77787A)),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
