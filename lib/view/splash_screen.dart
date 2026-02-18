import 'package:collaby_app/view_models/services/notification_services/notification_service.dart';
import 'package:collaby_app/view_models/services/splash_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashServices splashScreen = SplashServices();
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);
    NotificationServices().handleForegroundNotification();
    splashScreen.isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: Colors.white,
        body: Lottie.asset(
          width: 500.w,

          'assets/json/splash_animation.json',
          repeat: false,
          // animate: true,
          // options:
          // frameRate: FrameRate.max,
          // delegates: LottieDelegates(values: [/* color overrides */]),
        ),
      ),
    );
  }
}
