import 'package:collaby_app/view_models/services/notification_services/notification_service.dart';
import 'package:collaby_app/view_models/services/splash_services.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashServices splashScreen = SplashServices();
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);
    NotificationServices().handleForegroundNotification();
    splashScreen.isLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            opacity: _animate ? 1 : 0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              scale: _animate ? 1 : 0.92,
              child: Image.asset(
                ImageAssets.logoImage,
                width: 190.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
