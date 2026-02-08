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
          Text('overview_title'.tr, style: AppTextStyles.h6Bold),
          const SizedBox(height: 6),
          Text(
            'overview_subtitle'.tr,
            style: AppTextStyles.extraSmallText.copyWith(color: const Color(0xff77787A)),
          ),
          const SizedBox(height: 18),

          // Traits questions
          Obx(() {
            return Column(
              children: controller.creatorTraits.map((t) => _traitItem(t)).toList(),
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
              'overview_info'.tr,
              style: AppTextStyles.extraSmallText.copyWith(color: const Color(0xff77787A)),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _traitItem(String text) {
    final selected = controller.selectedTraits.contains(text);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF3EFFF) : const Color(0xffF4F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color(0xFF917DE5) : Colors.grey.shade300,
        ),
      ),
      child: CheckboxListTile(
        value: selected,
        onChanged: (_) => controller.toggleTrait(text),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          text.tr,
          style: AppTextStyles.extraSmallMediumText.copyWith(
            color: const Color(0xff3F4146),
          ),
        ),
        activeColor: const Color(0xFF917DE5),
        dense: true,
      ),
    );
  }
}
