import 'dart:developer';
import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class ProfileRepository {
  final _apiServices = NetworkApiServices();
  final _userPref = UserPreference();

  Future<dynamic> getCreatorProfileApi() async {
    final token = await _userPref.getToken();
    // log(token);
    dynamic response = await _apiServices.getApi(
      AppUrl.creatorProfileUrl,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  /// Update creator profile
  Future<dynamic> updateCreatorProfileApi(Map<String, dynamic> data) async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiServices.patchApi(
        AppUrl.updateCreatorProfile,
        data: data,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // log(data);

      return response;
    } catch (e) {
      log('Error updating creator profile: $e');
      rethrow;
    }
  }

  Future<dynamic> hidePortfolioItemApi(String url) async {
    final token = await _userPref.getToken();
    return _apiServices.postApi(
      {'url': url},
      AppUrl.hidePortfolioItemUrl,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}
