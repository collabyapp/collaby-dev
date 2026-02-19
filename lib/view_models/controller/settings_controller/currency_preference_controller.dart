import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:get/get.dart';

class CurrencyPreferenceController extends GetxController {
  final UserPreference _userPreference = UserPreference();

  static const List<String> supportedCurrencies = <String>[
    'EUR',
    'USD',
    'GBP',
    'AUD',
    'CAD',
    'SEK',
    'NZD',
    'CHF',
    'MXN',
    'COP',
  ];

  final RxString preferredCurrency = 'EUR'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPreferredCurrency();
  }

  Future<void> loadPreferredCurrency() async {
    isLoading.value = true;
    try {
      final stored = await _userPreference.getPreferredCurrency();
      preferredCurrency.value = supportedCurrencies.contains(stored)
          ? stored
          : 'EUR';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeCurrency(String currency) async {
    final normalized = currency.toUpperCase();
    final selected = supportedCurrencies.contains(normalized)
        ? normalized
        : 'EUR';
    preferredCurrency.value = selected;
    await _userPreference.savePreferredCurrency(selected);
  }
}
