import 'dart:developer';
import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/models/payment_models/payment_models.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class PaymentRepository {
  final _apiService = NetworkApiServices();
  final _userPref = UserPreference();

  /// Get all payment methods (cards)
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiService.getApi(
        '${AppUrl.baseUrl}/stripe/payment-methods',
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      log('Get payment methods response: $response');

      // Handle error response
      if (response is Map && response['error'] == true) {
        throw Exception(
          response['message'] ?? 'Failed to load payment methods',
        );
      }

      // Check for data in response
      if (response is Map) {
        final data = response['data'];
        if (data != null) {
          List<PaymentMethodModel> methods = [];
          if (data is List) {
            for (var item in data) {
              methods.add(PaymentMethodModel.fromJson(item));
            }
          }
          return methods;
        }
      }

      return [];
    } catch (e) {
      log('Error fetching payment methods: $e');
      rethrow;
    }
  }

  /// Get all bank accounts
  Future<List<BankAccountModel>> getBankAccounts() async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiService.getApi(
        '${AppUrl.baseUrl}/payment/wallet/bank-accounts',
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      log('Get bank accounts response: $response');

      // Handle error response
      if (response is Map && response['error'] == true) {
        throw Exception(response['message'] ?? 'Failed to load bank accounts');
      }

      // Check for data in response
      if (response is Map) {
        final data = response['data'];
        if (data != null) {
          List<BankAccountModel> accounts = [];
          if (data is List) {
            for (var item in data) {
              accounts.add(BankAccountModel.fromJson(item));
            }
          }
          return accounts;
        }
      }

      return [];
    } catch (e) {
      log('Error fetching bank accounts: $e');
      rethrow;
    }
  }

  /// Attach payment method (card) to customer using token
  Future<bool> attachPaymentMethodWithToken(String token) async {
    try {
      final authToken = await _userPref.getToken();

      dynamic response = await _apiService.postApi(
        {'token': token},
        '${AppUrl.baseUrl}/stripe/attach-method?type=token',
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      log('Repository response: $response');

      // Handle error response
      if (response is Map && response['error'] == true) {
        throw Exception(
          response['message'] ?? 'Failed to attach payment method',
        );
      }

      // Check for success in nested data structure
      if (response is Map) {
        // Check statusCode (201 or 200 means success)
        final statusCode = response['statusCode'];
        if (statusCode == 200 || statusCode == 201) {
          return true;
        }

        // Check data.success
        final data = response['data'];
        if (data is Map && data['success'] == true) {
          return true;
        }

        // Check direct success field
        if (response['success'] == true) {
          return true;
        }
      }

      return false;
    } catch (e) {
      log('Error attaching payment method: $e');
      rethrow;
    }
  }

  /// Delete payment method (card)
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiService.deleteApi(
        '${AppUrl.baseUrl}/stripe/payment-methods/$paymentMethodId',
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      log('Delete payment method response: $response');

      // Handle error response
      if (response is Map && response['error'] == true) {
        throw Exception(
          response['message'] ?? 'Failed to delete payment method',
        );
      }

      // Check for success in response
      if (response is Map) {
        // Check statusCode (200, 201, or 204 means success)
        final statusCode = response['statusCode'];
        if (statusCode == 200 || statusCode == 201 || statusCode == 204) {
          return true;
        }

        // Check data.success
        final data = response['data'];
        if (data is Map && data['success'] == true) {
          return true;
        }

        // Check direct success field
        if (response['success'] == true) {
          return true;
        }
      }

      return false;
    } catch (e) {
      log('Error deleting payment method: $e');
      rethrow;
    }
  }

  /// Create setup intent for card collection
  Future<String?> createSetupIntent() async {
    try {
      final token = await _userPref.getToken();

      dynamic response = await _apiService.postApi(
        {},
        '${AppUrl.baseUrl}/stripe/create-setup-intent',
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // Handle error response
      if (response is Map && response['error'] == true) {
        throw Exception(response['message'] ?? 'Failed to create setup intent');
      }

      return response['data']?['clientSecret'] ?? response['clientSecret'];
    } catch (e) {
      log('Error creating setup intent: $e');
      rethrow;
    }
  }
}

