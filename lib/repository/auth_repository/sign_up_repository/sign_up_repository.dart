import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';

class SignUpRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> signUpApi(dynamic data) async {
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.register(),
      headers: {'Content-Type': 'application/json'},
      sendJson: true,
    );
    return response;
  }
}
