import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';

class ForgotRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> forgotApi(var data) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.forgotPassword(),
      headers: {'Content-Type': 'application/json'},
      sendJson: true,
    );
    return response;
  }

  Future<dynamic> verifyForgotOTPApi(var data) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.verifyForgotOtp(),
      headers: {'Content-Type': 'application/json'},
      sendJson: true,
    );
    return response;
  }

  Future<dynamic> changePasswordApi(var data) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.resetPassword(),
      headers: {'Content-Type': 'application/json'},
      sendJson: true,
    );
    return response;
  }
}
