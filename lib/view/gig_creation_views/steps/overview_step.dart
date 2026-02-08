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
          Text('service_niches_title'.tr, style: AppTextStyles.h6Bold),
          const SizedBox(height: 6),
          Text(
            'service_niches_hint'.tr,
            style: AppTextStyles.extraSmallText.copyWith(color: const Color(0xff77787A)),
          ),
          const SizedBox(height: 16),

          Obx(() {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.allServiceNiches
                  .map((niche) => _nicheChip(niche))
                  .toList(),
            );
          }),

          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF4F7FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              'service_niches_note'.tr,
              style: AppTextStyles.extraSmallText.copyWith(color: const Color(0xff77787A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nicheChip(String niche) {
    final selected = controller.selectedServiceNiches.contains(niche);
    return GestureDetector(
      onTap: () => controller.toggleServiceNiche(niche),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff917DE5) : const Color(0xff898A8D).withOpacity(0.10),
          borderRadius: BorderRadius.circular(60),
        ),
        child: Text(
          niche.tr,
          style: AppTextStyles.extraSmallText.copyWith(
            color: selected ? Colors.white : const Color(0xff5E5E5E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
