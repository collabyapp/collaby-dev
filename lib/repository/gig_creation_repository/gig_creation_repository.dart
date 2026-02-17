import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:flutter/foundation.dart';

class GigCreationRepository {
  final NetworkApiServices _apiService = NetworkApiServices();
  final UserPreference _userPref = UserPreference();

  Future<Map<String, dynamic>?> updateGigApi(
    String gigId,
    Map<String, dynamic> data,
  ) async {
    final token = await _userPref.getToken();

    try {
      debugPrint('Updating gig with ID: $gigId');
      final sanitizedData = Map<String, dynamic>.from(data)
        ..remove('videoStyle')
        ..remove('videoStyles')
        ..remove('pricing');

      final response = await _apiService.putApi(
        AppUrl.updateGig(gigId),
        data: sanitizedData,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        sendJson: true,
      );

      if (response == null) {
        throw Exception('No response from server');
      }

      debugPrint('Update gig response: $response');
      return response;
    } catch (e) {
      debugPrint('Error updating gig: $e');
      rethrow;
    }
  }

  Future<dynamic> createGigApi(dynamic data) async {
    final token = await _userPref.getToken();
    // log(token);
    dynamic response = await _apiService.postApi(
      data,
      AppUrl.gigCreationAfterSetUp(),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      sendJson: true,
    );
    return response;
  }

  Future<dynamic> getMyGigsApi({int? pageNumber, int? pageSize}) async {
    final token = await _userPref.getToken();

    dynamic response = await _apiService.getApi(
      AppUrl.myGigs(),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    // log('response');
    // log(response);
    return response;
  }

  /// Fetch gig details by ID
  /// GET /gig/:gigId
  Future<dynamic> getGigDetailApi(String gigId) async {
    final token = await _userPref.getToken();

    dynamic response = await _apiService.getApi(
      AppUrl.gigDetail(gigId),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  /// Update gig status (Active/Inactive)
  /// PATCH /gig/:gigId/status
  Future<dynamic> updateGigStatusApi(String gigId, String status) async {
    final token = await _userPref.getToken();

    dynamic response = await _apiService.patchApi(
      AppUrl.updateGigStatus(gigId),
      data: {'gigStatus': status},
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      // sendJson: true,
    );
    return response;
  }
}





