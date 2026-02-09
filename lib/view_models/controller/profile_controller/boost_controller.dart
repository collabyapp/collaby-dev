import 'package:collaby_app/models/profile_model/boost_model.dart';
import 'package:collaby_app/repository/boost_repository/boost_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BoostProfileController extends GetxController {
  final _boostRepository = BoostRepository();

  final Rx<BoostData?> boostData = Rx<BoostData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAutoRenewalUpdating = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBoostProfile();
  }

  /// Fetch boost profile data
  Future<void> fetchBoostProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _boostRepository.getBoostProfile();

      if (response != null) {
        final boostResponse = BoostProfileResponse.fromJson(response);
        boostData.value = boostResponse.data;
      }
    } catch (e) {
      errorMessage.value = '${'boost_profile_load_failed'.tr}: $e';
      Utils.snackBar('error'.tr, 'boost_profile_load_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle auto-renewal
  Future<void> toggleAutoRenewal() async {
    if (boostData.value == null) return;

    try {
      isAutoRenewalUpdating.value = true;

      final currentAutoRenewal = boostData.value!.subscription.autoRenewal;

      if (currentAutoRenewal) {
        // Cancel auto-renewal
        await _boostRepository.cancelAutoRenewal();
        Utils.snackBar('success'.tr, 'auto_renew_cancelled'.tr);
        // Navigate back
        Get.offAllNamed(
          RouteName.bottomNavigationView,
          arguments: {'index': 3},
        );
      } else {
        // Enable auto-renewal
        // await _boostRepository.enableAutoRenewal();
        // Utils.snackBar(
        //   'Success',
        //   'Auto-renewal has been enabled',

        // );
      }

      // Update local state
      final updatedSubscription = boostData.value!.subscription.copyWith(
        autoRenewal: !currentAutoRenewal,
      );

      boostData.value = BoostData(
        subscription: updatedSubscription,
        analytics: boostData.value!.analytics,
        performanceGraph: boostData.value!.performanceGraph,
      );
    } catch (e) {
      Utils.snackBar('error'.tr, '${'auto_renew_update_failed'.tr}: $e');
    } finally {
      isAutoRenewalUpdating.value = false;
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    await fetchBoostProfile();
  }

  /// Get formatted dates
  String getFormattedStartDate() {
    if (boostData.value == null) return '';
    try {
      final date = DateTime.parse(
        boostData.value!.subscription.subscriptionStartDate,
      );
      final locale = Get.locale?.toString();
      return DateFormat.yMMMd(locale).format(date);
    } catch (e) {
      return '';
    }
  }

  String getFormattedEndDate() {
    if (boostData.value == null) return '';
    try {
      final date = DateTime.parse(boostData.value!.subscription.expiresAt);
      final locale = Get.locale?.toString();
      return DateFormat.yMMMd(locale).format(date);
    } catch (e) {
      return '';
    }
  }

  /// Get formatted analytics period
  String getAnalyticsPeriod() {
    if (boostData.value == null) return '';
    return 'analytics_period_days'
        .tr
        .replaceAll(
          '@days',
          boostData.value!.analytics.period.days.toString(),
        );
  }

  /// Format large numbers (e.g., 2400 -> 2.4k)
  String formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
