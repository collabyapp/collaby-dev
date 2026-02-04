import 'package:collaby_app/firebase_options.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'view_models/services/notification_services/awesome_notification_services.dart';
import 'view_models/services/notification_services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    // Initialize Stripe
  Stripe.publishableKey = 'pk_test_51SXGtqEC0R7ZrnKnZCRrvuGK7lBeUFefObcBR5PToQy2VX8oV7iVIcbrsUoaEYb1ERLrun8Ot63EiYHx1O33K2o900hw6b7jTs'; // Replace with your key
  
  
    await Stripe.instance.applySettings();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AwsomeNotificationService().initializeNotification();
  // FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: GetMaterialApp(
        title: 'Collaby',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          FlutterQuillLocalizations.delegate, // <- required
        ],
        // translations: Languages(),
        // locale: locale,
        // fallbackLocale: const Locale('en', 'US'),
        theme: ThemeData(
          scaffoldBackgroundColor: Color(0xffF4F7FF),
          appBarTheme: AppBarTheme(
            surfaceTintColor: Color(0xffF4F7FF),
            color: Color(0xffF4F7FF),
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
