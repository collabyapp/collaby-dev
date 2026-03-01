import 'dart:developer';

import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class SupportTicketRepository {
  final NetworkApiServices _apiService = NetworkApiServices();
  final UserPreference _userPref = UserPreference();

  bool _isMissingSupportRoute(dynamic response) {
    final status = int.tryParse('${response?['statusCode'] ?? ''}') ?? 0;
    final raw = response?['message'] ?? response?['error'];
    final msg = raw is List
        ? raw.map((e) => e.toString()).join(' ').toLowerCase()
        : (raw ?? response ?? '').toString().toLowerCase();
    if (msg.contains('cannot get /support-tickets') ||
        msg.contains('cannot get /api/support-tickets') ||
        msg.contains('/support-tickets/me')) {
      return true;
    }
    final mentionsSupport =
        msg.contains('/support-tickets') ||
        msg.contains('support-tickets') ||
        msg.contains('/support-ticket') ||
        msg.contains('support-ticket') ||
        msg.contains('support ticket');
    final missingRoute = msg.contains('cannot get') || msg.contains('not found');
    final badGateway = msg.contains('bad gateway') || msg.contains('status 502');
    final missingOrGateway = missingRoute || badGateway;
    // For support endpoints, treat 502 as unavailable even when body is generic.
    if (status == 502) return true;
    if (status == 404) return true;
    if (!mentionsSupport || !missingOrGateway) return false;
    // Some gateways return plain text without a statusCode in JSON body.
    return status == 0;
  }

  String _withApiPrefix(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.path.startsWith('/api/')) return url;
    final nextPath = '/api${uri.path.startsWith('/') ? '' : '/'}${uri.path}';
    return uri.replace(path: nextPath).toString();
  }

  bool _shouldRetryWithApiPrefixFromError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('cannot get /support-tickets') ||
        message.contains('cannot get /api/support-tickets')) {
      return true;
    }
    final mentionsSupport =
        message.contains('/support-tickets') ||
        message.contains('support-tickets') ||
        message.contains('support ticket');
    final missingRoute =
        message.contains('cannot get') ||
        message.contains('not found') ||
        message.contains('404');
    final gateway =
        message.contains('502') ||
        message.contains('bad gateway') ||
        message.contains('upstream');
    if (message.contains('error code: 404') || message.contains('statuscode: 404')) {
      return true;
    }
    if (message.contains('error code: 502') || message.contains('statuscode: 502')) {
      return true;
    }
    return mentionsSupport && (missingRoute || gateway);
  }

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
      final url = AppUrl.createSupportTicket();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final primary = await _apiService.postApi(
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
        url,
        headers: headers,
      );
      if (_isMissingSupportRoute(primary)) {
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
          _withApiPrefix(url),
          headers: headers,
        );
      }
      return primary;
    } catch (e) {
      log('Error creating support ticket: $e');
      if (_shouldRetryWithApiPrefixFromError(e)) {
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
          _withApiPrefix(AppUrl.createSupportTicket()),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );
      }
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

      final url = AppUrl.getMySupportTickets(query);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final primary = await _apiService.getApi(
        url,
        headers: headers,
      );
      if (_isMissingSupportRoute(primary)) {
        return _apiService.getApi(_withApiPrefix(url), headers: headers);
      }
      return primary;
    } catch (e) {
      log('Error fetching my support tickets: $e');
      if (_shouldRetryWithApiPrefixFromError(e)) {
        final token = await _userPref.getToken();
        final query = <String, dynamic>{
          'page': page.toString(),
          'limit': limit.toString(),
        };
        if (status != null && status.isNotEmpty) query['status'] = status;
        if (search != null && search.isNotEmpty) query['search'] = search;
        return _apiService.getApi(
          _withApiPrefix(AppUrl.getMySupportTickets(query)),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );
      }
      rethrow;
    }
  }

  Future<dynamic> getMyTicket(String ticketId) async {
    try {
      final token = await _userPref.getToken();
      final url = AppUrl.getMySupportTicket(ticketId);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final primary = await _apiService.getApi(
        url,
        headers: headers,
      );
      if (_isMissingSupportRoute(primary)) {
        return _apiService.getApi(_withApiPrefix(url), headers: headers);
      }
      return primary;
    } catch (e) {
      log('Error fetching support ticket detail: $e');
      if (_shouldRetryWithApiPrefixFromError(e)) {
        final token = await _userPref.getToken();
        return _apiService.getApi(
          _withApiPrefix(AppUrl.getMySupportTicket(ticketId)),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );
      }
      rethrow;
    }
  }

  Future<dynamic> replyMyTicket({
    required String ticketId,
    required String message,
  }) async {
    try {
      final token = await _userPref.getToken();
      final url = AppUrl.replyMySupportTicket(ticketId);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final primary = await _apiService.postApi(
        {'message': message},
        url,
        headers: headers,
      );
      if (_isMissingSupportRoute(primary)) {
        return _apiService.postApi(
          {'message': message},
          _withApiPrefix(url),
          headers: headers,
        );
      }
      return primary;
    } catch (e) {
      log('Error sending support ticket reply: $e');
      if (_shouldRetryWithApiPrefixFromError(e)) {
        final token = await _userPref.getToken();
        return _apiService.postApi(
          {'message': message},
          _withApiPrefix(AppUrl.replyMySupportTicket(ticketId)),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );
      }
      rethrow;
    }
  }
}
