import 'package:collaby_app/models/boost_model/boost_model.dart';
import 'package:collaby_app/repository/boost_repository/boost_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/indicator.dart';
import 'package:get/get.dart';
import 'package:collaby_app/data/response/status.dart';
import 'package:flutter/material.dart';
import 'package:collaby_app/utils/utils.dart';

class BoostController extends GetxController {
  final _boostRepository = BoostRepository();

  // Observable variables
  final rxRequestStatus = Status.loading.obs;
  final boostPlans = <BoostPlan>[].obs;
  final autoRenewal = false.obs;

  // Track which boost type is currently being purchased
  final currentlyPurchasing = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchBoostPlans();
  }

  /// Set request status
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;

  /// Set boost plans
  void setBoostPlans(List<BoostPlan> value) => boostPlans.value = value;

  /// Toggle auto-renewal
  void toggleAutoRenewal(bool value) {
    autoRenewal.value = value;
  }

  /// Check if a specific boost type is being purchased
  bool isPurchasing(String boostType) {
    return currentlyPurchasing.value == boostType;
  }

  /// Fetch boost plans from API
  Future<void> fetchBoostPlans() async {
    try {
      setRxRequestStatus(Status.loading);

      final response = await _boostRepository.getBoostPlans();

      if (response != null) {
        final boostPlansResponse = BoostPlansResponse.fromJson(response);
        setBoostPlans(boostPlansResponse.data);
        setRxRequestStatus(Status.completed);
      } else {
        setRxRequestStatus(Status.error);
        Utils.snackBar('Error', 'Failed to fetch boost plans');
      }
    } catch (e) {
      setRxRequestStatus(Status.error);
      Utils.snackBar('Error', e.toString());
    }
  }

  /// Purchase boost plan
  Future<void> purchaseBoost(String boostType, BuildContext context) async {
    try {
      currentlyPurchasing.value = boostType;

      // Show loading indicator
      LoadingIndicator.onStart(context: context);

      final response = await _boostRepository.purchaseBoost(
        boostType: boostType,
        autoRenewal: autoRenewal.value,
      );

      // Hide loading indicator
      LoadingIndicator.onStop(context: context);
      currentlyPurchasing.value = null;

      if (response != null && response['statusCode'] == 201 ||response['statusCode'] == 200) {
        Utils.snackBar('Success', 'Boost purchased successfully!');
        // Navigate back
        Get.offAllNamed(
          RouteName.bottomNavigationView,
          arguments: {'index': 3},
        );
      } else {
        Utils.snackBar(
          'Error',
          response?['message'] ?? 'Failed to purchase boost',
        );
      }
    } catch (e) {
      LoadingIndicator.onStop(context: context);
      currentlyPurchasing.value = null;
      Utils.snackBar('Error', e.toString());
    }
  }

  /// Get badge color based on badge text
  int getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'popular':
        return 0xFF10B981; // Green
      case 'basic':
        return 0xFFFBBF24; // Yellow
      default:
        return 0xFF6B7280; // Gray
    }
  }
}
