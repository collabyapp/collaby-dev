import 'dart:developer';

import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class LogoutRepository {
  final _userPref = UserPreference();
  final _apiService = NetworkApiServices();

  Future<dynamic> logoutApi() async {
    final token = await _userPref.getToken();
    final fcmToken = await _userPref.getFMCToken();
    // log('Token: $token');
    // log('FCM Token: $fcmToken');

    try {
      final response = await _apiService.postApi(
        {},
        AppUrl.logout(),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          if (fcmToken != null) 'x-fcm-token': fcmToken,
        },
      );

      return response;
    } catch (e) {
      log('âŒ Logout Error: $e');
      rethrow;
    }
  }
}

