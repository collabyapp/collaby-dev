import 'dart:developer';

import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class SupportTicketRepository {
  final NetworkApiServices _apiService = NetworkApiServices();
  final UserPreference _userPref = UserPreference();

  Future<dynamic> createTicket({
    required String subject,
    required String description,
    String category = 'general',
    String? name,
    String? email,
    List<String>? attachmentUrls,
    String? relatedOrderId,
    String? relatedOrderNumber,
  }) async {
    try {
      final token = await _userPref.getToken();
      return _apiService.postApi(
        {
          'subject': subject,
          'description': description,
          'category': category,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          if (attachmentUrls != null && attachmentUrls.isNotEmpty)
            'attachmentUrls': attachmentUrls,
          if (relatedOrderId != null && relatedOrderId.trim().isNotEmpty)
            'relatedOrderId': relatedOrderId.trim(),
          if (relatedOrderNumber != null &&
              relatedOrderNumber.trim().isNotEmpty)
            'relatedOrderNumber': relatedOrderNumber.trim(),
        },
        AppUrl.createSupportTicket(),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      log('Error creating support ticket: $e');
      rethrow;
    }
  }

  Future<dynamic> getMyTickets({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      final token = await _userPref.getToken();
      final query = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (search != null && search.isNotEmpty) query['search'] = search;

      return _apiService.getApi(
        AppUrl.getMySupportTickets(query),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      log('Error fetching my support tickets: $e');
      rethrow;
    }
  }

  Future<dynamic> getMyTicket(String ticketId) async {
    try {
      final token = await _userPref.getToken();
      return _apiService.getApi(
        AppUrl.getMySupportTicket(ticketId),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      log('Error fetching support ticket detail: $e');
      rethrow;
    }
  }

  Future<dynamic> replyMyTicket({
    required String ticketId,
    required String message,
  }) async {
    try {
      final token = await _userPref.getToken();
      return _apiService.postApi(
        {'message': message},
        AppUrl.replyMySupportTicket(ticketId),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      log('Error sending support ticket reply: $e');
      rethrow;
    }
  }
}
