import 'dart:developer';
import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class OrdersRepository {
  final _apiService = NetworkApiServices();
  final _userPref = UserPreference();

  /// Fetch creator orders from API
  Future<dynamic> getCreatorOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final token = await _userPref.getToken();

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      dynamic response = await _apiService.getApi(
        AppUrl.getCreatorOrders(queryParams),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      log('Error fetching orders: $e');
      rethrow;
    }
  }

  /// Get order details for request view
  Future<Map<String, dynamic>?> getOrderRequestDetails(String orderId) async {
    final token = await _userPref.getToken();
    try {
      final response = await _apiService.getApi(
        AppUrl.getOrderRequest(orderId),

        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      log('Error in getOrderRequestDetails: $e');
      return null;
    }
  }

  /// Accept order - Update status to Active
  Future<Map<String, dynamic>?> acceptOrder(String orderId) async {
    try {
      final token = await _userPref.getToken();
      final response = await _apiService.putApi(
        AppUrl.acceptOrder(orderId),
        data: {'status': 'Active'},
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      log('Error in acceptOrder: $e');
      return null;
    }
  }

  /// Decline order with reason
  Future<Map<String, dynamic>?> declineOrder(
    String orderId,
    String reason,
  ) async {
    try {
      final token = await _userPref.getToken();
      final response = await _apiService.putApi(
        AppUrl.declineOrder(orderId),
        data: {'status': 'Declined', 'declinedReason': reason},
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      log('Error in declineOrder: $e');
      return null;
    }
  }

  /// Get order details
  Future<dynamic> getOrderDetails(String orderId) async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiService.getApi(
        AppUrl.getOrderDetails(orderId),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      log('Error fetching order details: $e');
      rethrow;
    }
  }

  // NEW: Fetch Activity Timeline
  Future<dynamic> getOrderActivity(String orderId) async {
    try {
      final token = await _userPref.getToken();

      final response = await _apiService.getApi(
        AppUrl.getOrderTimeLines(orderId),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // NEW: Deliveries API
  Future<dynamic> getOrderDeliveries(String orderId) async {
    try {
      final token = await _userPref.getToken();

      final response = await _apiService.getApi(
        AppUrl.getOrderDeliveries(orderId),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // NEW: Deliver Order
  Future<dynamic> deliverOrder(
    String orderId, {
    required String workDescription,
    required List<Map<String, dynamic>> deliveryFiles,
  }) async {
    try {
      final token = await _userPref.getToken();
      
      final response = await _apiService.postApi(
         {
          'workDescription': workDescription,
          'deliveryFiles': deliveryFiles,
        },
        AppUrl.deliverOrder(orderId),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      log('Error in deliverOrder: $e');
      rethrow;
    }
  }
}

