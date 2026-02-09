import 'package:collaby_app/repository/delete_account_repository/delete_account_repository.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteAccountController extends GetxController {
  final _api = DeleteAccountRepository();
  final _userPref = UserPreference();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void setLoading(bool value) {
    _isLoading.value = value;
  }

  Future<void> deleteAccount() async {
    setLoading(true);
    try {
      final response = await _api.deleteAccountApi();
      setLoading(false);

      debugPrint('ðŸ”¥ Delete Account Response: $response');

      // Check if response contains error
      if (response != null && response['error'] == true) {
        // Error case - show error dialog with details
        String errorMessage =
            response['message'] ?? 'settings_delete_failed'.tr;
        List<String> reasons = [];

        // Extract reasons from details if available
        if (response['details'] != null &&
            response['details']['reasons'] != null) {
          reasons = List<String>.from(response['details']['reasons']);
        }

        // If no detailed reasons but have short message, use that
        if (reasons.isEmpty && response['short'] != null) {
          errorMessage = response['short'];
        }

        _showErrorDialog(errorMessage, reasons);
      } else if (response != null &&
          (response['statusCode'] == 200 ||
              response['statusCode'] == 201 ||
              response['success'] == true)) {
        // Success case
        await _userPref.clearUserData();

        Utils.snackBar('success'.tr, 'settings_delete_success'.tr);

        Get.offAllNamed(RouteName.logInView);
      } else {
        // Unexpected response
        _showErrorDialog('settings_delete_failed_retry'.tr, []);
      }
    } catch (error) {
      setLoading(false);
      debugPrint('âŒ Delete Account Exception: $error');

      // Handle exception
      String errorMessage = 'settings_generic_error'.tr;

      _showErrorDialog(errorMessage, []);
    }
  }

  void _showErrorDialog(String message, List<String> reasons) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'settings_cannot_delete'.tr,
                style: AppTextStyles.h6,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reasons.isNotEmpty) ...[
                Text(
                  'settings_resolve_following'.tr,
                  style: AppTextStyles.normalTextMedium,
                ),
                SizedBox(height: 12),
                ...reasons.map(
                  (reason) => Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Text(message, style: AppTextStyles.smallText),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('ok'.tr, style: AppTextStyles.normalTextMedium),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}



