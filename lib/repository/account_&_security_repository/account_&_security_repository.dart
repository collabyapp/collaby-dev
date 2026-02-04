import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class AccountSecurityRepository {
  final _apiService = NetworkApiServices();
  final _userPref = UserPreference();

  Future<dynamic> sendOTPApi(var data) async {
    final token = await _userPref.getToken();
    print(token);
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.phoneOtpSend(),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      sendJson: true,
    );
    return response;
  }

  Future<dynamic> verifyOTPApi(var data) async {
    final token = await _userPref.getToken();
    print(token);
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.phoneVerifyOtp(),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}
