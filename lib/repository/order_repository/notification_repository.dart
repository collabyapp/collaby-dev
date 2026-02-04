import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class NotificationRepository {
  final _apiService = NetworkApiServices();
  final _userPref = UserPreference();

  Future<Map<String, dynamic>> fetchNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    final token = await _userPref.getToken();
    final url = AppUrl.notifications(page, limit);

    final response = await _apiService.getApi(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid notifications response format');
    }

    return response;
  }
}
