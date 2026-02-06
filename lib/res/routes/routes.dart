import 'package:get/get.dart';

import 'package:collaby_app/res/bindings/create_gig_binding.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/splash_screen.dart';
import 'package:collaby_app/view/auth_view/login_view/login_view.dart';
import 'package:collaby_app/view/auth_view/signup_view/signup_view.dart';
import 'package:collaby_app/view/auth_view/verification_code/verification_code_view.dart';
import 'package:collaby_app/view/auth_view/account_created_view/account_created_view.dart';
import 'package:collaby_app/view/auth_view/forgot_password/forgot_password_view.dart';
import 'package:collaby_app/view/auth_view/password_recovery_view/password_recovery_view.dart';
import 'package:collaby_app/view/onboarding_view/onboarding_view.dart';
import 'package:collaby_app/view/profile_setup_view/profile_setup_view.dart';
import 'package:collaby_app/view/profile_setup_view/shipping_address_view.dart';
import 'package:collaby_app/view/profile_setup_view/account_security_view/account_security_view.dart';
import 'package:collaby_app/view/profile_setup_view/account_security_view/phone_number_view.dart';
import 'package:collaby_app/view/profile_setup_view/account_security_view/phone_verification.dart';
import 'package:collaby_app/view/profile_setup_view/niche_selection_screen.dart';
import 'package:collaby_app/view/profile_setup_view/profile_setup_created_view.dart';
import 'package:collaby_app/view/gig_creation_views/create_gig_view.dart';
import 'package:collaby_app/view/gig_creation_views/gig_created_view/gig_created_view.dart';
import 'package:collaby_app/view/bottom_navigation/bottom_navigation_view.dart';
import 'package:collaby_app/view/jobs_view/job_details_view.dart';
import 'package:collaby_app/view/settings_view/setting_view.dart';
import 'package:collaby_app/view/settings_view/withdrawal_view/withdrawal_view.dart';
import 'package:collaby_app/view/profile_view/gig_details_view.dart';

class AppRoutes {
  static List<GetPage> appRoutes() => [
        GetPage(
          name: RouteName.splashScreen,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: RouteName.onboardingView,
          page: () => const OnboardingView(),
        ),
        GetPage(
          name: RouteName.logInView,
          page: () => const LoginView(),
        ),
        GetPage(
          name: RouteName.signUpView,
          page: () => const SignUpView(),
        ),
        GetPage(
          name: RouteName.otpView,
          page: () => const VerificationCodeView(),
        ),
        GetPage(
          name: RouteName.accountCreatedView,
          page: () => const AccountCreatedView(),
        ),
        GetPage(
          name: RouteName.forgotPasswordView,
          page: () => const ForgotPasswordView(),
        ),
        GetPage(
          name: RouteName.passwordRecoveryView,
          page: () => const PasswordRecoveryView(),
        ),
        GetPage(
          name: RouteName.profileSetUpView,
          page: () => ProfileSetupView(),
        ),
        GetPage(
          name: RouteName.shippingAddressView,
          page: () => ShippingAddressView(),
        ),
        GetPage(
          name: RouteName.accountSecurityView,
          page: () => AccountSecurityView(),
        ),
        GetPage(
          name: RouteName.phoneNumberView,
          page: () => PhoneNumberView(),
        ),
        GetPage(
          name: RouteName.phoneVerificationView,
          page: () => const PhoneVerificationView(),
        ),
        GetPage(
          name: RouteName.nicheSelectionView,
          page: () => NicheSelectionScreen(),
        ),
        GetPage(
          name: RouteName.profileSetupCreatedView,
          page: () => const ProfileSetupCreatedView(),
        ),
        GetPage(
          name: RouteName.createGigView,
          page: () => CreateGigView(),
          binding: CreateGigBinding(),
        ),
        GetPage(
          name: RouteName.gigSuccessView,
          page: () => const GigSuccessView(),
        ),
        GetPage(
          name: RouteName.bottomNavigationView,
          page: () => BottomNavigationView(),
        ),
        GetPage(
          name: RouteName.jobDetailsView,
          page: () => JobDetailsView(
            jobId: (Get.arguments?['jobId'] ?? '').toString(),
          ),
        ),
        GetPage(
          name: RouteName.settingsView,
          page: () => SettingsView(),
        ),
        GetPage(
          name: RouteName.withdrawalView,
          page: () => BillingWithdrawalScreen(),
        ),
        GetPage(
          name: RouteName.gigDetailView,
          page: () => const GigDetailView(),
        ),
      ];
}
