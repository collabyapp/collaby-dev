import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';

class SignInRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Map<String, String> _authHeaders({
    String? fcmToken,
    bool includeRole = false,
    bool json = false,
  }) {
    final headers = <String, String>{};
    if (includeRole) {
      headers['x-role'] = 'creator';
    }
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    if (fcmToken != null && fcmToken.trim().isNotEmpty) {
      headers['x-fcm-token'] = fcmToken;
    }
    return headers;
  }

  Future<dynamic> signInApi(
    Map<String, dynamic> data, {
    String? fcmToken,
  }) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.login(),
      headers: _authHeaders(fcmToken: fcmToken, includeRole: true),
      sendJson: false,
    );

    return response;
  }

  Future<dynamic> signInWithGoogleApi(dynamic data, String? fcmToken) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.loginWithGoogle(),
      headers: _authHeaders(fcmToken: fcmToken, json: true),
      sendJson: true,
    );
    return response;
  }

  Future<dynamic> signInWithAppleApi(dynamic data, String? fcmToken) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.loginWithApple(),
      headers: _authHeaders(fcmToken: fcmToken, json: true),
      sendJson: true,
    );
    return response;
  }
}
