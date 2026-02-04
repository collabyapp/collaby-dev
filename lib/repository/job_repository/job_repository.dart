import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class JobRepository {
  final _api = NetworkApiServices();
  final _userPref = UserPreference();

  /// Fetch all jobs with pagination and filters
  Future<Map<String, dynamic>> fetchJobs({
    int page = 1,
    int limit = 10,
    bool showFavs = false,
    bool showSubmittedInterest = false,
    String? search,
  }) async {
    try {
      final token = await _userPref.getToken();
      final url = AppUrl.jobsAll();

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (showFavs) 'showFavs': 'true',
        if (showSubmittedInterest) 'showSubmittedInterest': 'true',
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _api.getApi(
        url,
        queryParameters: queryParams,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return {
        'success': true,
        'data': response['data'] ?? [],
        'totalPages': response['totalPages'] ?? 1,
        'totalData': response['totalData'] ?? 0,
        'pageNumber': response['pageNumber'] ?? 1,
        'message': response['message'] ?? 'Jobs fetched successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': [],
        'totalPages': 0,
        'totalData': 0,
        'pageNumber': 1,
      };
    }
  }

  /// Fetch single job details by ID
  Future<Map<String, dynamic>> fetchJobDetails(String jobId) async {
    try {
      final token = await _userPref.getToken();
      final url = AppUrl.jobDetails(jobId); // Assuming you have this in AppUrl

      final response = await _api.getApi(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return {
        'success': true,
        'data': response['data'],
        'message': response['message'] ?? 'Job details fetched successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'data': null};
    }
  }

  /// Add job to favorites
  Future<Map<String, dynamic>> addToFavorites(String jobId) async {
    try {
      final token = await _userPref.getToken();
      final url = AppUrl.addFavorite(jobId);

      final response = await _api.postApi(
        {},
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Job added to favorites',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Remove job from favorites
  Future<Map<String, dynamic>> withdrawInterest(String jobId) async {
    try {
      final token = await _userPref.getToken();
      final url = AppUrl.submitInterest(jobId);

      final response = await _api.deleteApi(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Remove job from favorites
  Future<Map<String, dynamic>> removeFromFavorites(String jobId) async {
    try {
      final token = await _userPref.getToken();
      final url = AppUrl.removeFavorite(jobId);

      final response = await _api.deleteApi(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Job removed from favorites',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Submit interest for a job
  Future<Map<String, dynamic>> submitInterest(String jobId) async {
    try {
      final token = await _userPref.getToken();
      final url = AppUrl.submitInterest(jobId);

      final response = await _api.postApi(
        {},
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Interest submitted successfully',
        'data': response['data'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
