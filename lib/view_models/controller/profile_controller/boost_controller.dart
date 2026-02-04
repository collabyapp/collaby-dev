import 'package:collaby_app/models/profile_model/boost_model.dart';
import 'package:collaby_app/repository/boost_repository/boost_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:get/get.dart';

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
      errorMessage.value = 'Failed to load boost profile: $e';
      Utils.snackBar('Error', 'Failed to load boost profile');
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
        Utils.snackBar('Success', 'Auto-renewal has been cancelled');
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
      Utils.snackBar('Error', 'Failed to update auto-renewal: $e');
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
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return '';
    }
  }

  String getFormattedEndDate() {
    if (boostData.value == null) return '';
    try {
      final date = DateTime.parse(boostData.value!.subscription.expiresAt);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return '';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Get formatted analytics period
  String getAnalyticsPeriod() {
    if (boostData.value == null) return '';
    return 'Last ${boostData.value!.analytics.period.days} Days';
  }

  /// Format large numbers (e.g., 2400 -> 2.4k)
  String formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
