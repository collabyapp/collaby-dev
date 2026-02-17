import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLanguageController extends GetxController {
  final UserPreference _userPreference = UserPreference();

  final supportedLocales = const <Locale>[
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('de', 'DE'),
    Locale('fr', 'FR'),
    Locale('pt', 'PT'),
    Locale('it', 'IT'),
    Locale('nl', 'NL'),
  ];

  Locale normalizeLocale(Locale? locale) {
    if (locale == null) return const Locale('en', 'US');
    for (final item in supportedLocales) {
      if (item.languageCode.toLowerCase() == locale.languageCode.toLowerCase()) {
        return item;
      }
    }
    return const Locale('en', 'US');
  }

  Future<void> changeLanguage(Locale locale) async {
    final normalized = normalizeLocale(locale);
    await Get.updateLocale(normalized);
    await _userPreference.saveAppLocale(
      languageCode: normalized.languageCode,
      countryCode: normalized.countryCode ?? '',
    );
  }
}

