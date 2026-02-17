import 'package:collaby_app/models/orders_model/earnings_models.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/orders_view/earning_view/widget/method_tile.dart';
import 'package:collaby_app/view/orders_view/earning_view/widget/summary_card.dart';
import 'package:collaby_app/view_models/controller/order_controller/earning_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawReceiptReviewView extends GetView<EarningsController> {
  const WithdrawReceiptReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(
          RouteName.bottomNavigationView,
          arguments: {'index': 1},
        );
        return true; // prevent default behavior (app close)
      },
      child: Scaffold(
        appBar: AppBar(title: Text('withdraw_to_bank'.tr)),
        body: Obx(() {
          if (controller.isLoadingWithdrawal.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Obx(
                  () => SummaryCard(
                    amount: controller.amount.value,
                    fee: controller.fee,
                    account: controller.selectedAccount.value,
                  ),
                ),

                const SizedBox(height: 16),
                Obx(
                  () => MethodTile(
                    title: 'withdraw_method_standard'.tr,
                    subtitle: controller.infoTexts.isNotEmpty
                        ? controller.infoTexts[0]
                        : (controller.standardProcessingDays.value > 0
                              ? 'withdraw_method_standard_dynamic'.trParams({
                                  'days': controller.standardProcessingDays.value
                                      .toString(),
                                })
                              : 'withdraw_method_standard_default'.tr),
                    selected:
                        controller.method.value == WithdrawalMethod.standard,
                    onTap: () =>
                        controller.method.value = WithdrawalMethod.standard,
                  ),
                ),

                const SizedBox(height: 10),
                Obx(
                  () => MethodTile(
                    title: 'withdraw_method_instant'.tr,
                    subtitle: controller.infoTexts.length > 1
                        ? controller.infoTexts[1]
                        : 'withdraw_method_instant_default'.tr,
                    selected:
                        controller.method.value == WithdrawalMethod.instant,
                    enabled: controller.instantWithdrawalEnabled.value,
                    onTap: () =>
                        controller.method.value = WithdrawalMethod.instant,
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        }),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Obx(() {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoadingWithdrawal.value
                      ? null
                      : () async {
                          final success = await controller.requestWithdrawal();
                          if (success) {
                            Get.offAllNamed(
                              RouteName.bottomNavigationView,
                              arguments: {'index': 1},
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    'withdraw_action'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
