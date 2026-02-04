import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/order_controller/earning_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EnterAmountSheet extends GetView<EarningsController> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (ctx, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Available Balance', style: AppTextStyles.smallText),

                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '\$${controller.availableBalance.value.toStringAsFixed(2)}',
                          style: AppTextStyles.normalTextMedium.copyWith(
                            color: Color(0xff4C1CAE),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount input card (editable)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter your amount',
                              style: AppTextStyles.extraSmallText.copyWith(
                                color: const Color(0xff606A79),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 24,
                                  color: Color(0xff4C4C54),
                                ),
                                const SizedBox(width: 8),
                                Text('USD', style: AppTextStyles.normalText),
                                const SizedBox(width: 16),
                                Text('\$', style: AppTextStyles.normalText),
                                const SizedBox(width: 6),

                                Expanded(
                                  child: TextField(
                                    controller: controller.amountController,
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    textInputAction: TextInputAction.done,
                                    cursorColor: Colors.black,
                                    style: AppTextStyles.normalText,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (v) {
                                      // Update the reactive amount value as user types
                                      controller.amount.value =
                                          double.tryParse(v.trim()) ?? 0.0;
                                    },
                                    onSubmitted: (_) {
                                      // Optional: This also handles final submission and update
                                      controller.amount.value =
                                          double.tryParse(
                                            controller.amountController.text
                                                .trim(),
                                          ) ??
                                          0.0;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_downward_rounded),
                          const SizedBox(width: 12),
                          Text(
                            'Deposit to',
                            style: TextStyle(
                              color: Colors.black.withOpacity(.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Obx(() {
                      //   final acc = controller.selectedAccount.value;
                      //   return GestureDetector(
                      //     onTap: () async {
                      //       final sel = await Get.bottomSheet<BankAccount>(
                      //         const SelectAccountSheet(),
                      //         isScrollControlled: true,
                      //         backgroundColor: Colors.transparent,
                      //       );
                      //       if (sel != null) controller.selectAccount(sel);
                      //     },
                      //     child:
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.selectedAccount.value == null
                                    ? 'Bank Of America   CA09932343…'
                                    : controller.selectedAccount.value!.masked,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //   );
                      // }),
                      const SizedBox(height: 16),
                      Obx(() {
                        return CustomButton(
                          title: 'Next',
                          isDisabled: !controller
                              .canProceedFromAmount, // This now reacts to changes
                          onPressed: () {
                            // Update amount based on TextField
                            final newAmount =
                                double.tryParse(
                                  controller.amountController.text.trim(),
                                ) ??
                                0;
                            controller.updateAmount(newAmount);

                            // Proceed to next step
                            Get.back(result: true);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
