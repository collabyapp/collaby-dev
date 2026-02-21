import 'dart:async';

import 'package:collaby_app/firebase_options.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes.dart';
import 'package:collaby_app/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'bootstrap/stripe_bootstrap.dart';
import 'res/localization/app_translations.dart';
import 'view_models/services/notification_services/awesome_notification_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Arranca UI SIEMPRE; la init pesada corre dentro del widget.
  runApp(const BootstrapApp());
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  Object? initError;
  bool initialized = false;
  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    _watchdog = Timer(const Duration(seconds: 25), () {
      if (!mounted || initialized || initError != null) return;
      setState(() {
        initError =
            TimeoutException('Init took too long. Check network/services.');
      });
    });
    _init();
  }

  Future<void> _init() async {
    try {
      // Stripe
      await initializeStripe().timeout(const Duration(seconds: 10));

      // Firebase (skip on web local debug if not configured)
      if (!kIsWeb) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 15));
      }

      // Notificaciones
      if (!kIsWeb) {
        await AwsomeNotificationService()
            .initializeNotification()
            .timeout(const Duration(seconds: 15));
      }

      initialized = true;
    } catch (e) {
      initError = e;
    } finally {
      _watchdog?.cancel();
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: GetMaterialApp(
        title: 'Collaby',
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: Get.deviceLocale,
        fallbackLocale: AppTranslations.fallbackLocale,
        localizationsDelegates: const [
          FlutterQuillLocalizations.delegate, // <- required
        ],
        home: initError != null
            ? _InitErrorScreen(error: initError)
            : (initialized ? SplashScreen() : const _LoadingScreen()),
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xffF4F7FF),
          appBarTheme: AppBarTheme(
            surfaceTintColor: Color(0xffF4F7FF),
            backgroundColor: Color(0xffF4F7FF),
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: AppTextStyles.normalTextBold,
          ),
        ),
        getPages: AppRoutes.appRoutes(),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _InitErrorScreen extends StatelessWidget {
  final Object? error;
  const _InitErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Init error:\n$error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
