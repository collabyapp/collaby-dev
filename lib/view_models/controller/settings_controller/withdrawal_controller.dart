import 'dart:developer';
// lib/view_models/controller/settings_controller/withdrawal_controller.dart

import 'package:collaby_app/models/payment_models/payment_models.dart';
import 'package:collaby_app/repository/payment_repository/payment_repository.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BillingController extends GetxController {
  final _paymentRepository = PaymentRepository();

  // Observable lists
  final bankAccounts = <BankAccountModel>[].obs;
  final paymentMethods = <PaymentMethodModel>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isDeleting = false.obs;

  // Computed property to check if card is attached
  bool get hasAttachedCard => paymentMethods.isNotEmpty;

  PaymentMethodModel? get attachedCard =>
      paymentMethods.isNotEmpty ? paymentMethods.first : null;

  @override
  void onInit() {
    super.onInit();
    loadPaymentData();
  }

  // ==================== API METHODS ====================

  /// Load all payment data (bank accounts and cards)
  Future<void> loadPaymentData() async {
    try {
      isLoading.value = true;

      // Load both in parallel
      await Future.wait([_loadBankAccounts(), _loadPaymentMethods()]);
    } catch (e) {
      _showErrorSnackbar('settings_load_payment_failed'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Load bank accounts
  Future<void> _loadBankAccounts() async {
    try {
      final accounts = await _paymentRepository.getBankAccounts();
      bankAccounts.value = accounts;
    } catch (e) {
      log('Error loading bank accounts: $e');
      // Don't show error for individual failures
    }
  }

  /// Load payment methods (cards)
  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await _paymentRepository.getPaymentMethods();
      paymentMethods.value = methods;
    } catch (e) {
      log('Error loading payment methods: $e');
      // Don't show error for individual failures
    }
  }

  /// Show bottom sheet to add card
  Future<void> showAddCardBottomSheet() async {
    if (hasAttachedCard) {
      Utils.snackBar(
        'settings_card_already_attached'.tr,
        'settings_remove_existing_card'.tr,
        // snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: Colors.orange[50],
        // colorText: Colors.orange[900],
        // icon: Icon(Icons.warning_amber_rounded, color: Colors.orange),
        // borderRadius: 12,
        // margin: EdgeInsets.all(16),
      );
      return;
    }

    Get.bottomSheet(
      AddCardBottomSheet(onCardAdded: (token) => _attachCardWithToken(token)),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Attach card using Stripe token
  Future<void> _attachCardWithToken(String token) async {
    try {
      isSaving.value = true;

      final success = await _paymentRepository.attachPaymentMethodWithToken(
        token,
      );

      if (success) {
        // Reload payment methods
        await _loadPaymentMethods();

        Get.back(); // Close bottom sheet

        Utils.snackBar(
          'success'.tr,
          'settings_card_added'.tr,
          // snackPosition: SnackPosition.BOTTOM,
          // backgroundColor: Colors.green[50],
          // colorText: Colors.green[900],
          // icon: Icon(Icons.check_circle, color: Colors.green),
          // borderRadius: 12,
          // margin: EdgeInsets.all(16),
        );
      } else {
        throw Exception('Failed to attach card');
      }
    } catch (e) {
      _showErrorSnackbar('settings_add_card_failed'.tr, e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete card
  Future<void> deleteCard(String paymentMethodId) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text('settings_remove_card'.tr),
            ],
          ),
          content: Text(
            'settings_remove_card_confirm'.tr,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr, style: TextStyle(color: Colors.grey[700])),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('settings_remove'.tr),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isDeleting.value = true;

      final success = await _paymentRepository.deletePaymentMethod(
        paymentMethodId,
      );

      if (success) {
        // Remove from local list
        paymentMethods.removeWhere((pm) => pm.id == paymentMethodId);

        Utils.snackBar(
          'success'.tr,
          'settings_card_removed'.tr,

          // backgroundColor: Colors.green[50],
          // colorText: Colors.green[900],
          // icon: Icon(Icons.check_circle, color: Colors.green),
          // borderRadius: 12,
          // margin: EdgeInsets.all(16),
        );
      } else {
        throw Exception('Failed to delete payment method');
      }
    } catch (e) {
      _showErrorSnackbar('settings_remove_card_failed'.tr, e.toString());
    } finally {
      isDeleting.value = false;
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadPaymentData();
  }

  // ==================== HELPER METHODS ====================

  void _showErrorSnackbar(String title, String message) {
    Utils.snackBar(
      title,
      message,

      // backgroundColor: Colors.red[50],
      // colorText: Colors.red[900],
      // icon: Icon(Icons.error_outline, color: Colors.red),
      // borderRadius: 12,
      // margin: EdgeInsets.all(16),
    );
  }

  String getCardIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'assets/icons/visa.png';
      case 'mastercard':
        return 'assets/icons/mastercard.png';
      case 'amex':
        return 'assets/icons/amex.png';
      default:
        return 'assets/icons/card.png';
    }
  }

  Color getCardColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Color(0xFF1A1F71);
      case 'mastercard':
        return Color(0xFFEB001B);
      case 'amex':
        return Color(0xFF006FCF);
      default:
        return Color(0xFF6366F1);
    }
  }
}

// ==================== ENHANCED BOTTOM SHEET WIDGET ====================

class AddCardBottomSheet extends StatefulWidget {
  final Function(String token) onCardAdded;

  const AddCardBottomSheet({Key? key, required this.onCardAdded})
    : super(key: key);

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final CardFormEditController _cardFormController = CardFormEditController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardFormController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Create token from card details
      final tokenData = await Stripe.instance.createToken(
        CreateTokenParams.card(params: CardTokenParams()),
      );

      if (tokenData.id.isEmpty) {
        throw Exception('Failed to create card token');
      }

      // Pass token to controller
      await widget.onCardAdded(tokenData.id);
    } on StripeException catch (e) {
      Utils.snackBar(
        'settings_card_error'.tr,
        e.error.localizedMessage ?? 'settings_invalid_card'.tr,

        
      );
    } catch (e) {
      Utils.snackBar(
        'error'.tr,
        'settings_card_process_failed'.trParams({'error': e.toString()}),

    
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6366F1).withOpacity(0.1),
                            Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'settings_add_payment_card'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'settings_secure_add_card'.tr,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                SizedBox(height: 28),

                // Stripe Card Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: CardFormField(
                    controller: _cardFormController,
                    style: CardFormStyle(
                      borderColor: Colors.transparent,
                      textColor: Colors.black87,
                      fontSize: 16,
                      placeholderColor: Colors.grey[500],
                      cursorColor: Color(0xFF6366F1),
                    ),
                    enablePostalCode: true,
                  ),
                ),
                SizedBox(height: 24),

                // Security Features
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF10B981).withOpacity(0.08),
                        Color(0xFF059669).withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF10B981).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'settings_secure_payment'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'settings_card_encrypted'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28),

                // Add Card Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleAddCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                      shadowColor: Color(0xFF6366F1).withOpacity(0.3),
                    ),
                    child: _isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'settings_processing'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'settings_add_card'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 20),

                // Powered by Stripe
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'settings_secured_by'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Stripe',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF635BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.verified_user,
                        size: 14,
                        color: Color(0xFF635BFF),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

