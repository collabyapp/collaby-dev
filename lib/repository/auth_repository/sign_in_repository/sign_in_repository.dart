import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';

class SignInRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> signInApi(
    Map<String, dynamic> data, {
    String? fcmToken,
  }) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.login(),
      headers: {'x-fcm-token': fcmToken.toString(), 'x-role': 'creator'},
      sendJson: false,
    );

    return response;
  }

  Future<dynamic> signInWithGoogleApi(dynamic data, String? fcmToken) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.loginWithGoogle(),
      headers: {
        'x-fcm-token': fcmToken.toString(),
        'Content-Type': 'application/json',
      },
      sendJson: true,
    );
    return response;
  }

  Future<dynamic> signInWithAppleApi(dynamic data, String? fcmToken) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.loginWithApple(),
      headers: {
        'x-fcm-token': fcmToken.toString(),
        'Content-Type': 'application/json',
      },
      sendJson: true,
    );
    return response;
  }
}
