import 'package:intl/intl.dart';

const Map<String, double> kEurBaseRates = <String, double>{
  'EUR': 1,
  'USD': 1.08,
  'GBP': 0.86,
  'AUD': 1.66,
  'CAD': 1.46,
  'SEK': 11.3,
  'NZD': 1.8,
  'CHF': 0.95,
  'MXN': 18.5,
  'COP': 4300,
};

String normalizeCurrencyCode(String? currency) {
  final normalized = (currency ?? 'EUR').trim().toUpperCase();
  return kEurBaseRates.containsKey(normalized) ? normalized : 'EUR';
}

double convertCurrencyAmount(
  double amount, {
  String fromCurrency = 'EUR',
  String toCurrency = 'EUR',
}) {
  final from = normalizeCurrencyCode(fromCurrency);
  final to = normalizeCurrencyCode(toCurrency);

  if (from == to) return _round(amount);

  final amountInEur = amount / (kEurBaseRates[from] ?? 1);
  final converted = amountInEur * (kEurBaseRates[to] ?? 1);
  return _round(converted);
}

String currencySymbol(String currency) {
  switch (normalizeCurrencyCode(currency)) {
    case 'EUR':
      return '€';
    case 'USD':
      return r'$';
    case 'GBP':
      return '£';
    case 'AUD':
      return r'A$';
    case 'CAD':
      return r'C$';
    case 'SEK':
      return 'kr';
    case 'NZD':
      return r'NZ$';
    case 'CHF':
      return 'CHF';
    case 'MXN':
      return r'MX$';
    case 'COP':
      return r'COL$';
    default:
      return currency.toUpperCase();
  }
}

String formatAmountInPreferredCurrency(
  double amount, {
  String sourceCurrency = 'USD',
  required String preferredCurrency,
  String? locale,
}) {
  final target = normalizeCurrencyCode(preferredCurrency);
  final source = normalizeCurrencyCode(sourceCurrency);
  final converted = convertCurrencyAmount(
    amount,
    fromCurrency: source,
    toCurrency: target,
  );

  final decimalDigits = converted == converted.truncateToDouble() ? 0 : 2;
  return NumberFormat.currency(
    locale: locale,
    symbol: currencySymbol(target),
    decimalDigits: decimalDigits,
  ).format(converted);
}

double _round(double value) =>
    (value * 100 + double.minPositive).roundToDouble() / 100;
