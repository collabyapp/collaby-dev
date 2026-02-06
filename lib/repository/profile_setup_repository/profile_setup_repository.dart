import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class ProfileSetupRepository {
  final NetworkApiServices _apiService = NetworkApiServices();
  final UserPreference _userPref = UserPreference();
  Future<dynamic> profileSetupApi(dynamic data) async {
    final token = await _userPref.getToken();
    // log(token);
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.profileSetup(),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      sendJson: true,
    );
    return response;
  }
}




