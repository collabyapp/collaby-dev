import 'package:collaby_app/repository/log_out_repository/log_out_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogoutController extends GetxController {
  final _api = LogoutRepository();
  final _userPref = UserPreference();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void setLoading(bool value) => _isLoading.value = value;

  /// Show logout confirmation dialog
  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Color(0xFF6366F1), size: 28),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close confirmation dialog
              logout(); // Proceed with logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Perform logout
  Future<void> logout({String? fcmToken}) async {
    setLoading(true);

    try {
      final response = await _api.logoutApi();
      final bool ok =
          (response is Map) &&
          (response['statusCode'] == 200 ||
              response['message'] == 'Logout successful' ||
              (response['data'] is Map &&
                  response['data']['message'] == 'Logout successful'));

      if (ok) {
        await _userPref.clearUserData();

        // Show success message
        Utils.snackBar('Success', 'Logged out successfully');

        // Navigate to login and clear all routes
        Get.offAllNamed(RouteName.logInView);
      } else {
        Utils.snackBar('Logout Failed', 'Unexpected response from server');
      }
    } catch (e) {
      Utils.snackBar('Error', 'Logout failed. Please try again.');
      debugPrint('âŒ Logout Exception: $e');
    } finally {
      setLoading(false);
    }
  }
}

// import 'package:collaby_app/repository/log_out_repository/log_out_repository.dart';
// import 'package:collaby_app/res/routes/routes_name.dart';
// import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class LogoutController extends GetxController {
//   final _api = LogoutRepository();
//   final _userPref = UserPreference();

//   final _isLoading = false.obs;
//   bool get isLoading => _isLoading.value;

//   void setLoading(bool value) => _isLoading.value = value;

//   Future<void> logout({String? fcmToken}) async {
//     setLoading(true);
//     try {
//       // If your API supports it, pass the token along:
//       final response = await _api.logoutApi();
//       final bool ok =
//           (response is Map) &&
//           (response['statusCode'] == 200 || // <-- correct place
//               response['message'] == 'Logout successful' || // fallback
//               (response['data'] is Map &&
//                   response['data']['message'] == 'Logout successful'));

//       if (ok) {
//         await _userPref.clearUserData();
//         // Optional: show a quick toast/snackbar (won't block navigation)
//         Utils.snackBar(
//           'Success',
//           'Logged out successfully',
       
//         );

//         // Navigate to login and clear all routes
//         Get.offAllNamed(RouteName.logInView);
//       } else {
//         Utils.snackBar('Logout failed', 'Unexpected response from server');
//       }
//     } catch (e) {
//       Utils.snackBar(
//         'Error',
//         'Logout failed. Please try again.',
     
//       );
//       debugPrint('âŒ Logout Exception: $e');
//     } finally {
//       setLoading(false);
//     }
//   }
// }



