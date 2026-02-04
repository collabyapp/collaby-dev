import 'dart:developer';
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
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        log("user cancel ");
        return GoogleSignInResult(
          success: false,
          errorMessage: 'Sign In Cancelled',
        );
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
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
        errorMessage: 'An Unexpected Error',
      );
    }
  }
  static Future<bool> signOutFromGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    log("sign out call");
    try {
      await googleSignIn.signOut();
      log('User signed out from Google');
      return true;
    } catch (error) {
      log('Error signing out: $error');
      return false;
    }
  }
}








