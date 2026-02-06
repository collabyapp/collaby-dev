import 'package:collaby_app/models/create_gig_model/additional_feature.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/gig_creation_controller/create_gig_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdditionalFeaturesStep extends GetView<CreateGigController> {
  const AdditionalFeaturesStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Additional Features',
            style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Add button
          GestureDetector(
            onTap: () => _showFeaturePicker(context),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFF5F9FF),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Color(0xffF1EDF9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.add, color: AppColor.primaryColor),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Add Additional Features",
                    style: AppTextStyles.normalTextMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // List of added features
          Obx(() {
            final list = controller.additionalFeatures;
            if (list.isEmpty) {
              return const Text(
                "No additional features added yet.",
                style: TextStyle(color: Colors.grey),
              );
            }
            return Column(
              children: list.map((f) => _FeatureCard(feature: f)).toList(),
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final AdditionalFeature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CreateGigController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                feature.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => c.removeAdditionalFeature(feature.id),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Image.asset(ImageAssets.dollarIcon, height: 12),

              const SizedBox(width: 6),
              Text("\$${feature.price.toStringAsFixed(0)}"),
              if (feature.revisions > 0) ...[
                const SizedBox(width: 12),
                Image.asset(ImageAssets.revisionIcon, height: 12),

                const SizedBox(width: 4),
                Text("${feature.revisions} Revisions"),
              ],
              if (feature.extraDays > 0) ...[
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 12),
                const SizedBox(width: 4),
                Text("+${feature.extraDays} day(s)"),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

void _showFeatureDetails(String featureName) {
  final c = Get.find<CreateGigController>();
  final priceCtrl = TextEditingController();
  final revCtrl = TextEditingController();
  final daysCtrl = TextEditingController();
  final isRevisionFeature = featureName.toLowerCase().contains('revision');

  Get.bottomSheet(
    Container(
      height: 550.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Center(
            child: Text(
              "Add Additional Features",
              style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Feature name
          const Text("Select Feature"),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 54,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColor.hintTextColor),
            ),
            child: Text(
              featureName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Price',
            style: AppTextStyles.extraSmallText.copyWith(
              color: Color(0xff606A79),
            ),
          ),
          const SizedBox(height: 10),

          // Price
          TextField(
            controller: priceCtrl,
            decoration: const InputDecoration(
              hintText: "Your Price (USD)",
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),

          // Revisions only for Additional Revision
          if (isRevisionFeature)
            Text(
              'Number of Revisions',
              style: AppTextStyles.extraSmallText.copyWith(
                color: Color(0xff606A79),
              ),
            ),
          const SizedBox(height: 10),
          if (isRevisionFeature)
            TextField(
              controller: revCtrl,
              decoration: const InputDecoration(
                hintText: "Number of Revisions",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

          const SizedBox(height: 16),

          Text(
            'Extra Delivery Days',
            style: AppTextStyles.extraSmallText.copyWith(
              color: Color(0xff606A79),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: daysCtrl,
            decoration: const InputDecoration(
              hintText: "Extra days (e.g. 2)",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),

          Spacer(),
          CustomButton(
            title: 'Add',
            onPressed: () {
              final f = AdditionalFeature(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: featureName,
                price: double.tryParse(priceCtrl.text) ?? 0,
                extraDays: int.tryParse(daysCtrl.text) ?? 0,
                revisions: isRevisionFeature ? int.tryParse(revCtrl.text) ?? 0 : 0,
              );
              c.addAdditionalFeature(f);
              Get.back();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

void _showFeaturePicker(BuildContext context) {
  final c = Get.find<CreateGigController>();
  c.resetFeaturePicker(); // start clean each time

  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: GetBuilder<CreateGigController>(
        id: 'featurePicker',
        builder: (ctrl) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Features",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            ...ctrl.featureOptions.map(
              (f) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: const Color(0xFF0A2C8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text(f, style: const TextStyle(color: Colors.black)),
                  trailing: Radio<String>(
                    value: f,
                    groupValue: ctrl.selectedFeature.value,
                    onChanged: (v) => ctrl.selectFeature(v),
                  ),
                  onTap: () => ctrl.selectFeature(f),
                ),
              ),
            ),

            const SizedBox(height: 16),
            CustomButton(
              title: 'Done',
              isDisabled: ctrl.selectedFeature.value == null,
              onPressed: () {
                final sel = ctrl.selectedFeature.value;
                if (sel != null) {
                  Get.back(); // close picker sheet
                  ctrl.resetFeaturePicker();
                  _showFeatureDetails(sel); // open details sheet
                }
              },
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
