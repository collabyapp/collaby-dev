import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class VerifyTokenRepository {
  final _apiService = NetworkApiServices();
  final _userPref = UserPreference();
  Future<dynamic> verifyToken(String token) async {
    final fcmToken = await _userPref.getFMCToken();
    dynamic response = await _apiService.getApi(
      AppUrl.verifyToken(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'x-fcm-token': fcmToken.toString(),
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}
