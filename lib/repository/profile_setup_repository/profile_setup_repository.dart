import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class ProfileSetupRepository {
  final _apiService = NetworkApiServices();
  final _userPref = UserPreference();
  Future<dynamic> profileSetupApi(var data) async {
    final token = await _userPref.getToken();
    // print(token);
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
