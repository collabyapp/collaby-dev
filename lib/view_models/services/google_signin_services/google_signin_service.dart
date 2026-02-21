import 'dart:developer';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in/google_sign_in.dart';
class GoogleSignInResult {
  final bool success;
  final Map<String, dynamic>? userData;
  final String? errorMessage;
  GoogleSignInResult({required this.success, this.userData, this.errorMessage});
}
class GoogleSignServices {
  static Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      if (kIsWeb &&
          (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1')) {
        return GoogleSignInResult(
          success: false,
          errorMessage:
              'Google login is not available in local web debug. Use mobile/emulator or deployed app.',
        );
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
      );
      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn().timeout(const Duration(seconds: 20));
      if (googleUser == null) {
        log("user cancel ");
        return GoogleSignInResult(
          success: false,
          errorMessage: 'Sign In Cancelled',
        );
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication.timeout(const Duration(seconds: 20));

      if ((googleAuth.idToken ?? '').isEmpty) {
        return GoogleSignInResult(
          success: false,
          errorMessage: 'Google ID token is missing',
        );
      }

      log("google auth ${googleAuth.idToken}");
      final userData = {
        'idToken': googleAuth.idToken,
        'email': googleUser.email,
      };
      return GoogleSignInResult(success: true, userData: userData);
    } catch (e, stackTrace) {
      log('Google Sign-In error: $e', stackTrace: stackTrace);
      return GoogleSignInResult(
        success: false,
        errorMessage: e is TimeoutException
            ? 'Google sign-in timed out. Please try again.'
            : 'An Unexpected Error',
      );
    }
  }
  static Future<bool> signOutFromGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    log("sign out call");
    try {
      await googleSignIn.signOut().timeout(const Duration(seconds: 10));
      log('User signed out from Google');
      return true;
    } catch (error) {
      log('Error signing out: $error');
      return false;
    }
  }
}







