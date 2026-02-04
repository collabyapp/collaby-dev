// import 'dart:async';
// import 'dart:developer';
// // import 'package:collaby_app/data/network/network_api_services.dart';
// import 'package:collaby_app/res/routes/routes_name.dart';
// import 'package:collaby_app/view/splash_screen.dart';
// import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';

// class SplashServices {
//   final UserPreference _userPref = UserPreference();
//   // final NetworkApiServices _apiService = NetworkApiServices();

//   Future<void> isLogin() async {
//     try {
//       final value = await _userPref.getUser();
//       final String? token = value['token'];
//       final bool? isLogin = value['isLogin'];

//       if (kDebugMode) {
//         log("Token: $token, isLogin: $isLogin", name: "SPLASH_SERVICE");
//       }

//       Timer(const Duration(seconds: 3), () async {
//         Get.offAllNamed(RouteName.onboardingView);

//         // if (token != null && isLogin == true) {
//         //   try {
//         //     // Get.offAllNamed(RouteName.bottomNavigation);
//         //   } catch (e) {
//         //     // Token verification failed, redirect to onboarding
//         //     // Get.to(SplashOne());
//         //     Get.offAllNamed(RouteName.onboardingView);
//         //   }
//         // } else {
//         //   // ❌ No valid token or not logged in
//         //   // Get.to(SplashOne());

//         //  Get.offAllNamed(RouteName.onboardingView);
//         // }
//       });
//     } catch (e) {
//       debugPrint("[SPLASH_SERVICE] Error in isLogin: $e");
//       Get.offAllNamed(RouteName.onboardingView); // Fallback
//     }
//   }
// }

import 'dart:developer';
import 'package:collaby_app/view_models/services/auth_service/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';

class SplashServices {
  final UserPreference _userPref = UserPreference();
  final AuthService _auth = AuthService();

  /// Checks if a user token exists. If yes, verifies it and routes accordingly.
  /// If no (or verification fails), routes to onboarding.
  Future<void> isLogin() async {
    try {
      // Read persisted session
      final value = await _userPref.getUser();
      final String? token = value['token'] as String?;
      final bool isLogin = (value['isLogin'] ?? false) as bool;

      if (kDebugMode) {
        log("Token: $token, isLogin: $isLogin", name: "SPLASH_SERVICE");
      }

      // Keep your splash visible for ~3 seconds
      await Future.delayed(const Duration(seconds: 2));

      // No token or not logged in -> Onboarding
      if (token == null || token.isEmpty || !isLogin) {
        Get.offAllNamed(RouteName.onboardingView);
        return;
      } else if (token.isNotEmpty && !isLogin) {
        Get.offAllNamed(RouteName.onboardingView);
        return;
      }

      // Token exists -> verify with backend
      try {
        final user = await _auth.verifyToken(token);

        // Persist (refresh) the session locally with the verified user
        await _auth.persistSession(token: token, user: user);

        // Decide where to go next (may trigger OTP route if email unverified)
        final decision = await _auth.decideNextRoute(
          user: user,
          // Try to pass a reasonable email for OTP flows
          emailForOtp:
              (user['email'] ?? user['username'] ?? '') as String? ?? '',
        );

        Get.offAllNamed(decision.route, arguments: decision.arguments);
      } catch (e, st) {
        // Verification failed -> treat as logged-out
        if (kDebugMode) {
          log('verifyToken failed: $e', stackTrace: st, name: 'SPLASH_SERVICE');
        }
        Get.offAllNamed(RouteName.onboardingView);
      }
    } catch (e, st) {
      // Any unexpected error -> Onboarding
      debugPrint("[SPLASH_SERVICE] Error in isLogin: $e");
      if (kDebugMode) {
        log('Splash error', error: e, stackTrace: st, name: 'SPLASH_SERVICE');
      }
      Get.offAllNamed(RouteName.onboardingView);
    }
  }
}
