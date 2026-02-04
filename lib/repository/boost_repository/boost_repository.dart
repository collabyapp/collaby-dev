import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class BoostRepository {
  final _apiService = NetworkApiServices();
  final _userPref = UserPreference();

  /// Fetch available boost plans
  Future<dynamic> getBoostPlans() async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiService.getApi(
        AppUrl.getBoostPlans,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      // print('Error fetching boost plans: $e');
      rethrow;
    }
  }

  /// Purchase a boost plan
  Future<dynamic> purchaseBoost({
    required String boostType,
    required bool autoRenewal,
  }) async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiService.postApi(
        {'boostType': boostType, 'autoRenewal': autoRenewal},
        AppUrl.purchaseBoost,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      // print('Error purchasing boost: $e');
      rethrow;
    }
  }

  /// Fetch boost profile data
  Future<dynamic> getBoostProfile() async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiService.getApi(
        AppUrl.boostProfile, // Add this to your AppUrl class
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      // print('Error fetching boost profile: $e');
      rethrow;
    }
  }

  /// Cancel auto-renewal
  Future<dynamic> cancelAutoRenewal() async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiService.deleteApi(
        AppUrl.boostCancel, // Add this to your AppUrl class
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      // print('Error canceling auto-renewal: $e');
      rethrow;
    }
  }
}
