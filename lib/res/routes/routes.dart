import 'package:get/get.dart';

import 'package:collaby_app/view/splash_screen.dart';
import 'package:collaby_app/view/auth_view/login_view/login_view.dart';
import 'package:collaby_app/view/auth_view/signup_view/signup_view.dart';
import 'package:collaby_app/view/bottom_navigation/bottom_navigation_view.dart';

class AppRoutes {
  static List<GetPage> appRoutes() => [
        GetPage(
          name: '/',
          page: () => SplashScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => LoginView(),
        ),
        GetPage(
          name: '/signup',
          page: () => SignUpView(),
        ),
        GetPage(
          name: '/home',
          page: () => BottomNavigationView(),
        ),
      ];
}
