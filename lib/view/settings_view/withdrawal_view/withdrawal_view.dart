import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/settings_view/withdrawal_view/widget/bank_account.dart';
import 'package:collaby_app/view/settings_view/withdrawal_view/widget/empty_card_view.dart';
import 'package:collaby_app/view/settings_view/withdrawal_view/widget/info_card.dart';
import 'package:collaby_app/view/settings_view/withdrawal_view/widget/payment_method_card.dart';
import 'package:collaby_app/view_models/controller/settings_controller/withdrawal_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillingWithdrawalScreen extends StatelessWidget {
  final controller = Get.put(BillingController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Billing & Withdrawal',
          style: AppTextStyles.normalTextBold.copyWith(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.bankAccounts.isEmpty &&
            controller.paymentMethods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading payment information...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: Color(0xFF6366F1),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bank Accounts Section
                if (controller.bankAccounts.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Bank Account',
                    subtitle: 'For withdrawals',
                    icon: Icons.account_balance_outlined,
                  ),
                  SizedBox(height: 16),
                  ...controller.bankAccounts.map(
                    (account) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BankAccountCard(account: account),
                    ),
                  ),
                  SizedBox(height: 32),
                ],

                // Payment Methods (Cards) Section
                _SectionHeader(
                  title: 'Payment Method',
                  subtitle: controller.hasAttachedCard
                      ? 'Active payment card'
                      : 'No card attached',
                  icon: Icons.credit_card_outlined,
                ),
                SizedBox(height: 16),

                Obx(() {
                  if (controller.paymentMethods.isEmpty) {
                    return EnhancedEmptyCardPlaceholder(
                      onAddCard: () => controller.showAddCardBottomSheet(),
                    );
                  }

                  return Column(
                    children: controller.paymentMethods
                        .map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PaymentMethodCard(
                              paymentMethod: card,
                              onDelete: () => controller.deleteCard(card.id),
                              isDeleting: controller.isDeleting.value,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),

                // Add Card Button (only if no card attached)
                // Obx(() {
                //   if (controller.hasAttachedCard) {
                //     return SizedBox.shrink();
                //   }

                //   return Padding(
                //     padding: const EdgeInsets.only(top: 8),
                //     child: EnhancedAddPaymentButton(
                //       onTap: () => controller.showAddCardBottomSheet(),
                //       isLoading: controller.isSaving.value,
                //     ),
                //   );
                // }),
                SizedBox(height: 32),

                // Enhanced Info Card
                InfoCard(),

                SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ==================== SECTION HEADER ====================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Color(0xFF6366F1), size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.normalTextBold.copyWith(fontSize: 16),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

