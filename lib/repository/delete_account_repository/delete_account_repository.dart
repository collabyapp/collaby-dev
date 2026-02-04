import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeleteAccountRepository {
  final _apiService = NetworkApiServices();
  final _userPref = UserPreference();

  Future<dynamic> deleteAccountApi() async {
    final token = await _userPref.getToken();
    print('Token: $token');

    try {
      // Make direct HTTP call to get full response
      final url = AppUrl.deleteAccount();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({}),
      );

      print('📈 Response Status: ${response.statusCode}');
      print('📈 Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Success
        return {'success': true, 'statusCode': 200, 'data': responseData};
      } else if (response.statusCode == 400) {
        // Error with details
        return {
          'error': true,
          'statusCode': 400,
          'message': responseData['message'] ?? 'Failed to delete account',
          'details': responseData['details'],
          'short': responseData['short'],
        };
      } else {
        // Other errors
        return {
          'error': true,
          'statusCode': response.statusCode,
          'message': responseData['message'] ?? 'An error occurred',
        };
      }
    } catch (e) {
      print('❌ Delete Account Error: $e');
      rethrow;
    }
  }
}
