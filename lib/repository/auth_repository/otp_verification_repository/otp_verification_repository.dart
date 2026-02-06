import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';

class OtpVerificationRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> sendOTPApi(dynamic data) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.otpSend(),
      headers: {'Content-Type': 'application/json'},
      sendJson: true,
    );
    return response;
  }

  Future<dynamic> verifyOTPApi(dynamic data) async {
    dynamic response = await _apiService.postApi(data, AppUrl.verifyOtp());
    return response;
  }
}
