import 'package:shared_preferences/shared_preferences.dart';

class UserPreference {
  static const String _preferredCurrencyKey = 'preferredCurrency';
  Future<void> saveUser({
    String? token,
    String? email,
    String? phoneNumber,
    String? userId,
    bool? isLogin,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final futures = <Future<bool>>[];

    if (token != null) futures.add(sp.setString('token', token));
    if (email != null) futures.add(sp.setString('email', email));
    if (phoneNumber != null)
      futures.add(sp.setString('phoneNumber', phoneNumber));
    if (userId != null) futures.add(sp.setString('userId', userId));
    if (isLogin != null) futures.add(sp.setBool('isLogin', isLogin));

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final sp = await SharedPreferences.getInstance();
    return {
      'token': sp.getString('token'),
      'email': sp.getString('email'),
      'phoneNumber': sp.getString('phoneNumber'),
      'userId': sp.getString('userId'),
      'isLogin': sp.getBool('isLogin') ?? false,
    };
  }

  Future<void> clearUser() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token');
    await sp.remove('email');
    await sp.remove('userId');
    await sp.remove('isLogin');
  }

  Future<void> savePreferredCurrency(String currency) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_preferredCurrencyKey, currency.toUpperCase());
  }

  Future<String> getPreferredCurrency() async {
    final sp = await SharedPreferences.getInstance();
    final stored = (sp.getString(_preferredCurrencyKey) ?? 'EUR')
        .trim()
        .toUpperCase();
    return stored.isEmpty ? 'EUR' : stored;
  }

  Future<String?> getToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('token');
  }

  Future<void> removeUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();
  }

  Future<void> saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token);
  }

  Future<String?> getFMCToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('fcmToken');
  }

  // Method to clear all user data (for logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.remove('token');
    // await prefs.remove('isLogin');
    // await prefs.remove('user_id');
    // await prefs.remove('username');
    // await prefs.remove('user_categories');
    // await prefs.remove('fcmToken');
  }
}
