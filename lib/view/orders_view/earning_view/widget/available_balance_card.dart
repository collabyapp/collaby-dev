import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/utils/currency_utils.dart';
import 'package:collaby_app/view_models/controller/order_controller/earning_controller.dart';
import 'package:collaby_app/view_models/controller/settings_controller/currency_preference_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailableBalanceCard extends GetView<EarningsController> {
  final CurrencyPreferenceController currencyController = Get.put(
    CurrencyPreferenceController(),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E9F2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B61FF).withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('available_balance'.tr, style: AppTextStyles.smallText),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    formatAmountInPreferredCurrency(
                      controller.availableBalance.value,
                      sourceCurrency: 'USD',
                      preferredCurrency:
                          currencyController.preferredCurrency.value,
                    ),
                    style: AppTextStyles.normalTextMedium.copyWith(
                      color: Color(0XFF4C1CAE),
                    ),
                  ),
                ),
                if (controller.pendingAmount.value > 0) ...[
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      'Pending: ${formatAmountInPreferredCurrency(controller.pendingAmount.value, sourceCurrency: 'USD', preferredCurrency: currencyController.preferredCurrency.value)}',
                      style: AppTextStyles.extraSmallText.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset(ImageAssets.balanceIcon, width: 54),
        ],
      ),
    );
  }
}
