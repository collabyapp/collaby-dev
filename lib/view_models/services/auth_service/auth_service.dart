import 'package:collaby_app/repository/auth_repository/sign_in_repository/sign_in_repository.dart';
import 'package:collaby_app/repository/auth_repository/verify_token_repository/verify_token_repository.dart';
import 'package:collaby_app/repository/auth_repository/otp_verification_repository/otp_verification_repository.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view_models/services/notification_services/notification_service.dart';

/// Result used to decide where to go next.
class AuthRouteDecision {
  final String route;
  final Map<String, dynamic>? arguments;
  final bool otpSent;

  const AuthRouteDecision({
    required this.route,
    this.arguments,
    this.otpSent = false,
  });
}

class AuthService {
  // Repos
  final SignInRepository _signInRepo;
  final VerifyTokenRepository _verifyTokenRepo;
  final OtpVerificationRepository _otpRepo;
  final UserPreference _prefs;

  AuthService({
    SignInRepository? signInRepository,
    VerifyTokenRepository? verifyTokenRepository,
    OtpVerificationRepository? otpVerificationRepository,
    UserPreference? userPreference,
  }) : _signInRepo = signInRepository ?? SignInRepository(),
       _verifyTokenRepo = verifyTokenRepository ?? VerifyTokenRepository(),
       _otpRepo = otpVerificationRepository ?? OtpVerificationRepository(),
       _prefs = userPreference ?? UserPreference();

  /// Email/password sign-in -> returns token (string).
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    String? fcmToken = await NotificationServices.getDeviceToken();

    if (fcmToken == null || fcmToken.isEmpty) {
      Utils.snackBar(
        'Error',
        'Failed to retrieve device token. Please try again.',
      );
      throw 'Failed to retrieve device token';
    }

    print('fcmToken: $fcmToken');

    await _prefs.saveFCMToken(fcmToken);
    final resp = await _signInRepo.signInApi({
      'email': email,
      'password': password,
    }, fcmToken: fcmToken);

    // Check for error response first
    if (resp?['error'] != null) {
      final errorMessage = resp?['message'] ?? resp?['error'] ?? 'Login failed';
      print('errorMessage');
      print(errorMessage);
      throw errorMessage;
    }

    // Handle the response properly with type conversion
    final data = resp?['data'] != null
        ? Map<String, dynamic>.from(resp!['data'] as Map)
        : <String, dynamic>{};

    final token = (data['token'] ?? '') as String;

    print(data);
    if (token.isEmpty) {
      throw 'Login failed: token missing in response.';
    }
    return token;
  }

  Future<String> signInWithGoogle({required String idToken}) async {
    String? fcmToken = await NotificationServices.getDeviceToken();

    if (fcmToken == null || fcmToken.isEmpty) {
      Utils.snackBar(
        'Error',
        'Failed to retrieve device token. Please try again.',
      );
      throw 'Failed to retrieve device token';
    }

    print('fcmToken: $fcmToken');

    await _prefs.saveFCMToken(fcmToken);
    // If your server expects "id_token", change the key accordingly.
    final resp = await _signInRepo.signInWithGoogleApi({
      'idToken': idToken,
    }, fcmToken);

    if (resp is! Map) {
      throw Exception(
        'Google sign-in failed: unexpected response type ${resp.runtimeType}.',
      );
    }

    final int status = (resp['statusCode'] as int?) ?? 200;

    if (status != 200) {
      final serverMsg = resp['message']?.toString();
      throw serverMsg ?? 'Google sign-in failed.';
    }

    // token lives at data.token
    final token = (resp['data']?['token'] as String?)?.trim() ?? '';
    if (token.isEmpty) {
      throw 'Google sign-in failed: empty token from server.';
    }

    return token;
  }

  Future<String> signInWithApple({required String idToken}) async {
    String? fcmToken = await NotificationServices.getDeviceToken();

    if (fcmToken == null || fcmToken.isEmpty) {
      Utils.snackBar(
        'Error',
        'Failed to retrieve device token. Please try again.',
      );
      throw 'Failed to retrieve device token';
    }

    print('fcmToken: $fcmToken');

    await _prefs.saveFCMToken(fcmToken);
    // If your server expects "id_token", change the key accordingly.
    final resp = await _signInRepo.signInWithAppleApi({
      'idToken': idToken,
    }, fcmToken);

    if (resp is! Map) {
      throw Exception(
        'Google sign-in failed: unexpected response type ${resp.runtimeType}.',
      );
    }

    final int status = (resp['statusCode'] as int?) ?? 200;

    if (status != 200) {
      final serverMsg = resp['message']?.toString();
      throw serverMsg ?? 'Google sign-in failed.';
    }

    // token lives at data.token
    final token = (resp['data']?['token'] as String?)?.trim() ?? '';
    if (token.isEmpty) {
      throw 'Google sign-in failed: empty token from server.';
    }

    return token;
  }


  /// Verify a backend token, returns normalized user map.
  Future<Map<String, dynamic>> verifyToken(String token) async {
    final response = await _verifyTokenRepo.verifyToken(token);
    final user = response['data'] != null
        ? Map<String, dynamic>.from(response['data'] as Map)
        : <String, dynamic>{};
    print(response);
    if (user.isEmpty) {
      throw 'Verification succeeded but user data is empty.';
    }
    return user;
  }

  /// Persist both token and user locally.
  Future<void> persistSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _prefs.saveUser(
      token: token,
      email: user['email'],
      userId: user['_id'],
      isLogin: false,
    );
  }

  /// Decide next route based on verified user.
  /// If email is not verified, this will trigger OTP send and return OTP route + args.
  Future<AuthRouteDecision> decideNextRoute({
    required Map<String, dynamic> user,
    required String emailForOtp,
  }) async {
    final isEmailVerified = user['isEmailVerified'] == true;
    final profileStatus = (user['profileStatus'] ?? '')
        .toString()
        .toLowerCase();
    final role = (user['role'] ?? '').toString().toLowerCase();
    final isGigCreated = user['isGigCreated'] == true;

    // 1) Email not verified -> send OTP then navigate to OTP screen
    if (!isEmailVerified) {
      await _otpRepo.sendOTPApi({'email': emailForOtp});
      return AuthRouteDecision(
        route: RouteName.otpView,
        arguments: {'email': emailForOtp, 'isRecovery': false},
        otpSent: true,
      );
    }

    // 2) Incomplete profile
    if (profileStatus == 'pending') {
      return const AuthRouteDecision(route: RouteName.profileSetUpView);
    }

    // 3) Creator who hasn't created a gig
    if (role == 'creator' && !isGigCreated) {
      return const AuthRouteDecision(route: RouteName.createGigView);
    }

    // 4) Default home
    return const AuthRouteDecision(route: RouteName.bottomNavigationView);
  }

  /// Convenience: full email login flow (authenticate -> verify -> persist -> decide).
  Future<AuthRouteDecision> loginWithEmailFlow({
    required String email,
    required String password,
  }) async {
    final token = await signInWithEmail(email: email, password: password);
    final user = await verifyToken(token);
    await persistSession(token: token, user: user);
    return decideNextRoute(user: user, emailForOtp: email);
  }

  /// Convenience: full Google login flow (exchange -> verify -> persist -> decide).
  Future<AuthRouteDecision> loginWithGoogleFlow({
    required String googleIdToken,
    required String
    fallbackEmailForOtp, // use Google account email if you have it
  }) async {
    final token = await signInWithGoogle(idToken: googleIdToken);
    print('auth service token');
    print(token);
    final user = await verifyToken(token);
    await persistSession(token: token, user: user);
    return decideNextRoute(user: user, emailForOtp: fallbackEmailForOtp);
  }

  /// Convenience: full Google login flow (exchange -> verify -> persist -> decide).
  Future<AuthRouteDecision> loginWithAppleFlow({
    required String appleIdToken,
    required String
    fallbackEmailForOtp, // use Google account email if you have it
  }) async {
    final token = await signInWithApple(idToken: appleIdToken);
    print('auth service token');
    print(token);
    final user = await verifyToken(token);
    await persistSession(token: token, user: user);
    return decideNextRoute(user: user, emailForOtp: fallbackEmailForOtp);
  }


}
