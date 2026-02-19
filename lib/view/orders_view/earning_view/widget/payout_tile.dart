import 'package:collaby_app/models/orders_model/earnings_models.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/utils/currency_utils.dart';
import 'package:collaby_app/view_models/controller/settings_controller/currency_preference_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayoutTile extends StatelessWidget {
  final Payout payout;

  const PayoutTile({required this.payout});

  @override
  Widget build(BuildContext context) {
    final currencyController = Get.put(CurrencyPreferenceController());
    String subtitle;
    Color subtitleColor;

    switch (payout.status) {
      case PayoutStatus.completed:
        subtitle = 'Completed';
        subtitleColor = const Color(0xFF2DBE60);
        break;
      case PayoutStatus.approved:
        subtitle = 'Approved';
        subtitleColor = const Color(0xFF2DBE60);
        break;

      case PayoutStatus.failed:
        subtitle = 'Failed';
        subtitleColor = Colors.red;
        break;

      case PayoutStatus.processing:
      default:
        subtitle = payout.message ?? 'Processing';
        subtitleColor = Colors.orange;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        formatAmountInPreferredCurrency(
                          payout.amount,
                          sourceCurrency: 'USD',
                          preferredCurrency:
                              currencyController.preferredCurrency.value,
                        ),
                        style: AppTextStyles.h5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: AppTextStyles.extraSmallText.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(_fmtDate(payout.date), style: AppTextStyles.normalText),
            ],
          ),
          if (payout.description != null) ...[
            const SizedBox(height: 8),
            Text(
              payout.description!,
              style: AppTextStyles.extraSmallText.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
