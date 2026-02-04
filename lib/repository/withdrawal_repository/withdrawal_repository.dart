import 'dart:convert';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:http/http.dart' as http;

class WithdrawalRepository {
  final _userPref = UserPreference();

  // Get withdrawal history
  Future<dynamic> getWithdrawalHistory({int page = 1, int limit = 10}) async {
    final token = await _userPref.getToken();
    
    try {
      final url = AppUrl.withdrawalHistory(page: page, limit: limit);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📊 Withdrawal History Status: ${response.statusCode}');
      print('📊 Withdrawal History Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': 200,
          'data': responseData['data'],
        };
      } else {
        return {
          'error': true,
          'statusCode': response.statusCode,
          'message': responseData['message'] ?? 'Failed to get history',
        };
      }
    } catch (e) {
      print('❌ Withdrawal History Error: $e');
      rethrow;
    }
  }

  // Get bank accounts
  Future<dynamic> getBankAccounts() async {
    final token = await _userPref.getToken();
    
    try {
      final url = AppUrl.bankAccounts();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('🏦 Bank Accounts Status: ${response.statusCode}');
      print('🏦 Bank Accounts Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': 200,
          'data': responseData['data'],
        };
      } else {
        return {
          'error': true,
          'statusCode': response.statusCode,
          'message': responseData['message'] ?? 'Failed to get accounts',
        };
      }
    } catch (e) {
      print('❌ Bank Accounts Error: $e');
      rethrow;
    }
  }

  // Create connected account
  Future<dynamic> createConnectedAccount() async {
    final token = await _userPref.getToken();
    
    try {
      final url = AppUrl.connectedAccount();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({}),
      );

      print('🔗 Connected Account Status: ${response.statusCode}');
      print('🔗 Connected Account Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': responseData['data'],
        };
      } else {
        return {
          'error': true,
          'statusCode': response.statusCode,
          'message': responseData['message'] ?? 'Failed to create account',
        };
      }
    } catch (e) {
      print('❌ Connected Account Error: $e');
      rethrow;
    }
  }

  // Request withdrawal
  Future<dynamic> requestWithdrawal({
    required double amount,
    required String withdrawalType, // 'standard' or 'instant'
  }) async {
    final token = await _userPref.getToken();
    
    try {
      final url = AppUrl.withdraw();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'amount': amount,
          'withdrawalType': withdrawalType,
        }),
      );

      print('💸 Withdrawal Request Status: ${response.statusCode}');
      print('💸 Withdrawal Request Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        return {
          'error': true,
          'statusCode': response.statusCode,
          'message': responseData['message'] ?? 'Withdrawal failed',
        };
      }
    } catch (e) {
      print('❌ Withdrawal Request Error: $e');
      rethrow;
    }
  }

// Get withdrawal fees & info
Future<dynamic> getWithdrawalFees() async {
  final token = await _userPref.getToken();

  try {
    final url = AppUrl.withdrawalFees();
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('💰 Withdrawal Fees Status: ${response.statusCode}');
    print('💰 Withdrawal Fees Body: ${response.body}');

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': responseData['data'],
        'message': responseData['message'],
      };
    } else {
      return {
        'error': true,
        'statusCode': response.statusCode,
        'message':
            responseData['message'] ?? 'Failed to get withdrawal fees',
      };
    }
  } catch (e) {
    print('❌ Withdrawal Fees Error: $e');
    rethrow;
  }
}


}