import 'dart:async';

import 'package:collaby_app/firebase_options.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes.dart';
import 'package:collaby_app/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'res/localization/app_translations.dart';
import 'view_models/controller/settings_controller/app_language_controller.dart';
import 'view_models/controller/user_preference/user_preference_view_model.dart';
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
  Locale? _appLocale;
  final AppLanguageController _appLanguageController = Get.put(AppLanguageController());

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
      final savedLocaleMap = await UserPreference().getAppLocale();
      if (savedLocaleMap != null) {
        _appLocale = _appLanguageController.normalizeLocale(
          Locale(
            savedLocaleMap['languageCode'] ?? 'en',
            savedLocaleMap['countryCode'] ?? 'US',
          ),
        );
      } else {
        _appLocale = _appLanguageController.normalizeLocale(Get.deviceLocale);
      }
    } catch (e) {
      initError = e;
    }

    try {
      Stripe.publishableKey =
          'pk_test_51SXGtqEC0R7ZrnKnZCRrvuGK7lBeUFefObcBR5PToQy2VX8oV7iVIcbrsUoaEYb1ERLrun8Ot63EiYHx1O33K2o900hw6b7jTs';
      await Stripe.instance
          .applySettings()
          .timeout(const Duration(seconds: 10));
    } catch (_) {}

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 15));
    } catch (_) {}

    try {
      await AwsomeNotificationService()
          .initializeNotification()
          .timeout(const Duration(seconds: 15));
    } catch (_) {}

    initialized = true;
    _watchdog?.cancel();
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
        locale: _appLocale ?? _appLanguageController.normalizeLocale(Get.deviceLocale),
        fallbackLocale: AppTranslations.fallbackLocale,
        supportedLocales: _appLanguageController.supportedLocales,
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          ImageAssets.logoImage,
          width: 190.w,
          fit: BoxFit.contain,
        ),
      ),
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
