import 'dart:developer';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
class AppleSignInResult {
  final bool success;
  final Map<String, dynamic>? userData;
  final String? errorMessage;
  AppleSignInResult({required this.success, this.userData, this.errorMessage});
}
class AppleSignInServices {
  static Future<AppleSignInResult> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (appleCredential.userIdentifier == null) {
        log("User cancelled Apple Sign-In");
        return AppleSignInResult(
          success: false,
          errorMessage: 'sign_in_cancelled'.tr,
        );
      }
      final userData = {
        'idToken': appleCredential.identityToken,
        'email': appleCredential.email,
        'givenName': appleCredential.givenName,
        'familyName': appleCredential.familyName,
        'userIdentifier': appleCredential.userIdentifier,
      };
      log("Apple Sign-In  Token: ${appleCredential.identityToken}");
      log("Apple Sign-In auth: ${appleCredential.identityToken}");
      log("Apple Sign-In auth: ${appleCredential.identityToken}");
      log("Apple Sign-In auth: ${appleCredential.identityToken}");
      return AppleSignInResult(success: true, userData: userData);
    } catch (e, stackTrace) {
      log('Apple Sign-In error: $e', stackTrace: stackTrace);
      return AppleSignInResult(
        success: false,
        errorMessage: 'an_unexpected_error'.tr,
      );
    }
  }
}

// Future<void> appleSignInFunction() async {
  //   LoadingIndicator.onStart(context: Get.context!);
  //   try {
  //     final AppleSignInResult appleSignInResult =
  //         await AppleSignInServices.signInWithApple();
  //     if (appleSignInResult.success) {
  //       log("google result ${appleSignInResult.userData}");
  //       final deviceToken = await FirebaseFunctions.getFcmToken();
  //       if (deviceToken.isEmpty) {
  //         CustomSnackBar.show(
  //           context: Get.context!,
  //           message: "an_unexpected_error".tr,
  //         );
  //         return;
  //       }
  //       JsonResponse response = await Api.appleSignIn(
  //         appleToken: appleSignInResult.userData!["idToken"],
  //         selectedLanguage: selectedLocale,
  //         deviceToken: deviceToken,
  //       );
  //       final token = response.data ?? "";
  //       if (response.statusCode == 200) {
  //         JsonResponse verifyTokenResponse = await Api.verifyTokenApi(
  //           selectedLanguage: selectedLocale,
  //           token: token,
  //         );
  //         await LoginDataBaseServices.updateFunction(
  //           isLoggedIn: true,
  //           loginToken: token,
  //           loginAsGuest: false,
  //           firebaseToken: deviceToken,
  //         );
  //         userDetails = UserResponseModel.fromJson(
  //           verifyTokenResponse.data["user"],
  //         );
  //         hostResponseDetails = HostResponseModel.fromJson(
  //           verifyTokenResponse.data["host"],
  //         );
  //         await HostDetailsDatabaseServices.updateFunction(
  //           categories: userDetails.category,
  //         );
  //         await UserDetailsDatabaseServices.updateFunction(
  //           firstName: userDetails.firstName,
  //           lastName: userDetails.lastName,
  //           email: userDetails.email,
  //           profilePicture: userDetails.profilePicture,
  //           followers: userDetails.followers,
  //           following: userDetails.following,
  //           followerCount: userDetails.followerCount,
  //           followingCount: userDetails.followingCount,
  //           likesCount: userDetails.likeCount,
  //           userId: userDetails.id,
  //           phoneNumber: userDetails.phoneNumber ?? "",
  //         );
  //         log("host status is ${hostResponseDetails.status}");
  //         if (hostResponseDetails.status == "APPROVED") {
  //           await HostDetailsDatabaseServices.updateFunction(
  //             id: hostResponseDetails.id,
  //             idCard: hostResponseDetails.idCard,
  //             selfieWithCard: hostResponseDetails.selfieWithCard,
  //             media: hostResponseDetails.media,
  //             status: hostResponseDetails.status,
  //           );
  //         } else {
  //           await HostDetailsDatabaseServices.updateFunction(
  //             status: hostResponseDetails.status,
  //           );
  //         }
  //         Get.offAllNamed(AppRoutes.dashboard);
  //       } else if (response.statusCode == 403) {
  //         LoadingIndicator.onStop(context: Get.context!);
  //         Get.dialog(
  //           CmnDialogWidget(
  //             text: "already_register_msg",
  //             cancelButtonText: "no",
  //             cancelButtonOnTap: () {
  //               Get.back();
  //             },
  //             acceptButtonText: "yes".tr,
  //             acceptButtonOnTap: () async {
  //               Get.back();
  //               await linkAppleSignInFunction(
  //                 deviceToken: deviceToken,
  //                 appleToken: appleSignInResult.userData!["idToken"],
  //               );
  //             },
  //           ),
  //         );
  //       } else {
  //         LoadingIndicator.onStop(context: Get.context!);
  //         CustomSnackBar.show(context: Get.context!, message: response.message);
  //       }
  //     } else {
  //       LoadingIndicator.onStop(context: Get.context!);
  //       CustomSnackBar.show(
  //         context: Get.context!,
  //         message: appleSignInResult.errorMessage ?? "some_thing_went_wrong".tr,
  //       );
  //     }
  //   } catch (error) {
  //     log("error $error");
  //     CustomSnackBar.show(context: Get.context!, message: error.toString());
  //   } finally {
  //     await Future.delayed(const Duration(milliseconds: 500));
  //     LoadingIndicator.onStop(context: Get.context!);
  //   }
  // }