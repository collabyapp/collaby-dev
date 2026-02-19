import 'package:collaby_app/models/orders_model/earnings_models.dart';
import 'package:collaby_app/utils/currency_utils.dart';
import 'package:collaby_app/view_models/controller/order_controller/earning_controller.dart';
import 'package:collaby_app/view_models/controller/settings_controller/currency_preference_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionsHistoryView extends GetView<EarningsController> {
  const TransactionsHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyController = Get.put(CurrencyPreferenceController());
    return Scaffold(
      appBar: AppBar(title: Text('transactions_title'.tr)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.payouts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = controller.payouts[i];
          return GestureDetector(
            onTap: () => {
              // Get.to(TransactionsHistoryView(), arguments: {'payout': p}),
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            formatAmountInPreferredCurrency(
                              p.amount,
                              sourceCurrency: 'USD',
                              preferredCurrency:
                                  currencyController.preferredCurrency.value,
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.status == PayoutStatus.completed
                              ? 'Completed'
                              : (p.message ?? 'Processing'),
                          style: TextStyle(
                            color: p.status == PayoutStatus.completed
                                ? const Color(0xFF2DBE60)
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _fmtDate(p.date),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
