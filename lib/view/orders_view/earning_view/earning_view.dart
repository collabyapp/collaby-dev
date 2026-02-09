import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/orders_view/earning_view/transaction_history_view.dart';
import 'package:collaby_app/view/orders_view/earning_view/widget/amount_sheet.dart';
import 'package:collaby_app/view/orders_view/earning_view/widget/available_balance_card.dart';
import 'package:collaby_app/view/orders_view/earning_view/widget/connected_account_card.dart';
import 'package:collaby_app/view/orders_view/earning_view/widget/payout_tile.dart';
import 'package:collaby_app/view/orders_view/earning_view/widget/view_transaction_tile.dart';
import 'package:collaby_app/view/orders_view/earning_view/withdraw_receipt_review.dart';
import 'package:collaby_app/view_models/controller/order_controller/earning_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EarningsView extends StatelessWidget {
  final EarningsController controller = Get.put(EarningsController());

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
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.offAllNamed(
                RouteName.bottomNavigationView,
                arguments: {'index': 1},
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text('earnings_title'.tr),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => controller.loadWithdrawalHistory(),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.loadWithdrawalHistory(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        AvailableBalanceCard(),
                        const SizedBox(height: 12),

                        // Show connect account button if not connected
                        if (!controller.isConnectedAccount.value)
                          ConnectAccountCard(),

                        if (!controller.isConnectedAccount.value)
                          const SizedBox(height: 12),

                        // Withdrawal history
                        if (controller.payouts.isNotEmpty)
                          ...controller.payouts.map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PayoutTile(payout: p),
                            ),
                          ),

                        if (controller.payouts.isEmpty &&
                            controller.isConnectedAccount.value)
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No withdrawal history yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                        const SizedBox(height: 8),
                        ViewTransactionsTile(
                          onTap: () => Get.to(() => TransactionsHistoryView()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar: Obx(() {
          // Only show withdraw button if account is connected
          if (!controller.isConnectedAccount.value) {
            return SizedBox.shrink();
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.availableBalance.value > 0
                      ? () async {
                          // 1) Amount / account select sheet
                          final ok = await Get.bottomSheet<bool>(
                            EnterAmountSheet(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                          if (ok != true) return;

                          // 2) Review screen
                          Get.to(() => WithdrawReceiptReviewView());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
