import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/authentication_views/login_view.dart';
import 'package:collaby_app/view/authentication_views/signup_view.dart';
import 'package:collaby_app/view/gig_creation_views/create_gig_view.dart';
import 'package:collaby_app/view/gig_creation_views/gig_success_view.dart';
import 'package:collaby_app/view/home/bottom_navigation_view.dart';
import 'package:get/get.dart';

import 'bindings/create_gig_binding.dart';

class AppRoutes {
  static appRoutes() => <GetPage>[
        // ✅ AUTH ROUTES
        GetPage(
          name: RouteName.logInView,
          page: () => const LoginView(),
        ),

        GetPage(
          name: RouteName.signUpView,
          page: () => const SignUpView(),
        ),

        // ✅ CREATE / EDIT GIG ROUTE
        GetPage(
          name: RouteName.createGigView,
          page: () => const CreateGigView(),
          binding: CreateGigBinding(),
          transition: Transition.rightToLeft,
        ),

        // ✅ SUCCESS
        GetPage(
          name: RouteName.gigSuccessView,
          page: () => const GigSuccessView(),
          transition: Transition.fadeIn,
        ),

        // ✅ MAIN NAVIGATION
        GetPage(
          name: RouteName.bottomNavigationView,
          page: () => const BottomNavigationView(),
        ),
      ];
}
