import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/boost_controller/boost_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collaby_app/data/response/status.dart';

class BoostProfileScreen extends StatelessWidget {
  BoostProfileScreen({super.key});

  final BoostController controller = Get.put(BoostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('boost_profile_title'.tr), centerTitle: false),
      body: Obx(() {
        if (controller.rxRequestStatus.value == Status.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        if (controller.rxRequestStatus.value == Status.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('boost_plans_load_failed'.tr),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchBoostPlans,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Boost Plan Cards
              ...controller.boostPlans.map(
                (plan) => _buildBoostCard(context, plan),
              ),

              const SizedBox(height: 10),

              // Auto-Boost Monthly Toggle
              _buildAutoRenewalCard(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBoostCard(BuildContext context, dynamic plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Badge
          Row(
            children: [
              Text(plan.name, style: AppTextStyles.h6),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Color(
                    controller.getBadgeColor(plan.badge),
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plan.badge,
                  style: AppTextStyles.extraSmallMediumText.copyWith(
                    color: Color(controller.getBadgeColor(plan.badge)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Features
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 18, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(feature, style: AppTextStyles.extraSmallText),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Price and Button
          Row(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(ImageAssets.dollarIcon),
                  const SizedBox(width: 4),
                  Text('\$${plan.price.toInt()}', style: AppTextStyles.h6),
                ],
              ),
              const Spacer(),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isPurchasing(plan.boostType)
                      ? null
                      : () => _showPurchaseConfirmation(context, plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'boost_now'.tr,
                    style: AppTextStyles.extraSmallText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoRenewalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'auto_boost_monthly'.tr,
                  style: AppTextStyles.normalTextMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'auto_boost_discount'.tr,
                  style: AppTextStyles.extraSmallText,
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: controller.autoRenewal.value,
              onChanged: controller.toggleAutoRenewal,
              activeColor: Colors.black,
              activeTrackColor: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseConfirmation(BuildContext context, dynamic plan) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'confirm_purchase'.tr,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'confirm_purchase_desc'.tr.replaceAll('@plan', plan.name),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'amount_label'.tr,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${plan.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (controller.autoRenewal.value) ...[
              const SizedBox(height: 8),
              Text(
                'auto_renew_enabled'.tr,
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.purchaseBoost(plan.boostType, context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }
}
