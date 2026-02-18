import 'dart:developer';
import 'package:collaby_app/models/orders_model/earnings_models.dart';
import 'package:collaby_app/repository/withdrawal_repository/withdrawal_repository.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EarningsController extends GetxController {
  final _api = WithdrawalRepository();

  // Observable data
  final availableBalance = 0.0.obs;
  final totalBalance = 0.0.obs;
  final pendingAmount = 0.0.obs;
  final accounts = <BankAccount>[].obs;
  final payouts = <Payout>[].obs;
  final isConnectedAccount = false.obs;
  final isLoading = false.obs;
  final isLoadingWithdrawal = false.obs;

  final standardWithdrawalFee = 0.0.obs; // %
  final earlyReleaseFee = 0.0.obs; // extra % for instant
  final standardProcessingDays = 0.obs; // days
  final infoTexts = <String>[].obs;

  // Withdrawal form data
  final method = WithdrawalMethod.standard.obs;
  final amount = 0.0.obs;
  final selectedAccount = Rxn<BankAccount>();
  final amountController = TextEditingController();

  // double get fee => amount.value == 0 ? 0 : (amount.value * 0.20); // 20% fee

  bool get canProceedFromAmount {
    final amt = amount.value;
    return amt > 0 &&
        amt <= availableBalance.value &&
        selectedAccount.value != null;
  }

  @override
  void onInit() {
    super.onInit();
    loadWithdrawalHistory();
    loadWithdrawalFees();
  }

  double get fee {
    if (amount.value == 0) return 0;

    // if API not loaded yet, fallback to 20%
    final baseRate = standardWithdrawalFee.value == 0
        ? 20.0
        : standardWithdrawalFee.value;

    // extra fee for instant withdrawals (early_release_fee)
    final extraRate = method.value == WithdrawalMethod.instant
        ? earlyReleaseFee.value
        : 0.0;

    final totalRate = baseRate + extraRate;

    return amount.value * (totalRate / 100);
  }

  // Load withdrawal history and wallet data
  Future<void> loadWithdrawalHistory() async {
    isLoading.value = true;
    try {
      final response = await _api.getWithdrawalHistory();

      if (response != null && response['success'] == true) {
        final data = response['data'];

        // Update wallet balance
        final walletBalance = data['walletBalance'];
        availableBalance.value = (walletBalance['availableBalance'] ?? 0)
            .toDouble();
        totalBalance.value = (walletBalance['totalBalance'] ?? 0).toDouble();
        pendingAmount.value = (walletBalance['pendingAmount'] ?? 0).toDouble();

        // Update connected account status
        final user = data['user'];
        isConnectedAccount.value = user['isConnectedAccount'] ?? false;

        // Update withdrawal history
        final withdrawalsList = data['withdrawals'] as List? ?? [];
        payouts.value = withdrawalsList.map((e) => Payout.fromJson(e)).toList();

        // Load bank accounts if connected
        if (isConnectedAccount.value) {
          await loadBankAccounts();
        }
      }
    } catch (e) {
      log('âŒ Load History Error: $e');
      Utils.snackBar('Error', 'Failed to load withdrawal history');
    } finally {
      isLoading.value = false;
    }
  }

  // Load bank accounts
  Future<void> loadBankAccounts() async {
    try {
      final response = await _api.getBankAccounts();

      if (response != null && response['success'] == true) {
        final accountsList = response['data'] as List? ?? [];
        accounts.value = accountsList
            .map((e) => BankAccount.fromJson(e))
            .toList();

        // Select first account by default
        if (accounts.isNotEmpty) {
          selectedAccount.value = accounts.first;
        }
      }
    } catch (e) {
      log('âŒ Load Accounts Error: $e');
    }
  }

  Future<void> createConnectedAccount() async {
    isLoading.value = true;
    try {
      final response = await _api.createConnectedAccount();

      if (response != null && response['success'] == true) {
        final data = response['data'];
        final onboardingUrl = data['onboardingUrl'];
        log('data');
        log(response['data']);

        if (onboardingUrl != null &&
            onboardingUrl is String &&
            onboardingUrl.isNotEmpty) {
          final uri = Uri.parse(onboardingUrl);

          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // opens browser
          );

          if (!launched) {
            Utils.snackBar('Error', 'Could not open onboarding link');
          } else {
            // Optionally reload after user comes back to the app later
            await loadWithdrawalHistory();
          }
        }
      } else {
        Utils.snackBar(
          'Error',
          response?['message'] ?? 'Failed to create account',
        );
      }
    } catch (e) {
      log('âŒ Create Account Error: $e');
      Utils.snackBar('Error', 'Failed to create connected account');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWithdrawalFees() async {
    try {
      final response = await _api.getWithdrawalFees();

      if (response != null && response['success'] == true) {
        final data = response['data'] ?? {};

        standardWithdrawalFee.value = (data['standard_withdrawal_fee'] ?? 0)
            .toDouble();

        earlyReleaseFee.value = (data['early_release_fee'] ?? 0).toDouble();

        standardProcessingDays.value = (data['standard_processing_days'] ?? 0);

        final List<dynamic> texts = data['infoTexts'] ?? [];
        infoTexts.assignAll(texts.map((e) => e.toString()).toList());
        if (kDebugMode) {
          log(
            'âœ… Withdrawal fees loaded: '
            'commission=$standardWithdrawalFee, '
            'earlyRelease=$earlyReleaseFee, '
            'days=$standardProcessingDays',
          );
        }
      } else {
        log('âš ï¸ Failed to load withdrawal fees: ${response?['message']}');
      }
    } catch (e) {
      log('âŒ loadWithdrawalFees Error: $e');
    }
  }

  // Create connected account and open onboarding
  // Future<void> createConnectedAccount() async {
  //   isLoading.value = true;
  //   try {
  //     final response = await _api.createConnectedAccount();

  //     if (response != null && response['success'] == true) {
  //       final data = response['data'];
  //       final onboardingUrl = data['onboardingUrl'];

  //       if (onboardingUrl != null) {
  //         // Open webview
  //         await Get.to(() => StripeOnboardingWebView(url: onboardingUrl));

  //         // Reload data after onboarding
  //         await loadWithdrawalHistory();
  //       }
  //     } else {
  //       Utils.snackBar(
  //         'Error',
  //         response['message'] ?? 'Failed to create account',
  //       );
  //     }
  //   } catch (e) {
  //     log('âŒ Create Account Error: $e');
  //     Utils.snackBar('Error', 'Failed to create connected account');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Request withdrawal
  Future<bool> requestWithdrawal() async {
    if (!canProceedFromAmount) {
      Utils.snackBar('Error', 'Please enter a valid amount');
      return false;
    }

    isLoadingWithdrawal.value = true;
    try {
      final withdrawalType = method.value == WithdrawalMethod.standard
          ? 'standard'
          : 'instant';

      final response = await _api.requestWithdrawal(
        amount: amount.value,
        withdrawalType: withdrawalType,
      );

      if (response != null && response['success'] == true) {
        Utils.snackBar(
          'Success',
          response['message'] ?? 'Withdrawal request submitted',
        );

        // Reset form
        amount.value = 0.0;
        amountController.clear();

        // Reload data
        await loadWithdrawalHistory();

        return true;
      } else {
        Utils.snackBar('Error', response['message'] ?? 'Withdrawal failed');
        return false;
      }
    } catch (e) {
      log('âŒ Withdrawal Error: $e');
      Utils.snackBar('Error', 'Failed to process withdrawal');
      return false;
    } finally {
      isLoadingWithdrawal.value = false;
    }
  }

  void updateAmount(double newAmount) {
    amount.value = newAmount;
  }

  void selectAccount(BankAccount acc) {
    selectedAccount.value = acc;
  }

  // @override
  // void onClose() {
  //   amountController.dispose();
  //   super.onClose();
  // }
}

