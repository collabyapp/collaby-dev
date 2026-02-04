class PaymentMethodModel {
  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final String country;
  final String funding;

  PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.country,
    required this.funding,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final card = json['card'] ?? {};
    return PaymentMethodModel(
      id: json['id'] ?? '',
      brand: card['brand'] ?? '',
      last4: card['last4'] ?? '',
      expMonth: card['exp_month'] ?? 0,
      expYear: card['exp_year'] ?? 0,
      country: card['country'] ?? '',
      funding: card['funding'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card': {
        'brand': brand,
        'last4': last4,
        'exp_month': expMonth,
        'exp_year': expYear,
        'country': country,
        'funding': funding,
      }
    };
  }

  String get displayBrand {
    return brand.toUpperCase();
  }

  String get expirationDate {
    return '${expMonth.toString().padLeft(2, '0')}/${expYear.toString().substring(2)}';
  }
}

// lib/data/models/bank_account_model.dart

class BankAccountModel {
  final String id;
  final String bankName;
  final String last4;
  final String routingNumber;
  final String? accountHolderName;
  final String? accountHolderType;
  final String currency;
  final String status;
  final bool defaultForCurrency;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.last4,
    required this.routingNumber,
    this.accountHolderName,
    this.accountHolderType,
    required this.currency,
    required this.status,
    required this.defaultForCurrency,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] ?? '',
      bankName: json['bankName'] ?? '',
      last4: json['last4'] ?? '',
      routingNumber: json['routingNumber'] ?? '',
      accountHolderName: json['accountHolderName'],
      accountHolderType: json['accountHolderType'],
      currency: json['currency'] ?? 'usd',
      status: json['status'] ?? '',
      defaultForCurrency: json['defaultForCurrency'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'last4': last4,
      'routingNumber': routingNumber,
      'accountHolderName': accountHolderName,
      'accountHolderType': accountHolderType,
      'currency': currency,
      'status': status,
      'defaultForCurrency': defaultForCurrency,
    };
  }

  String get maskedAccountNumber {
    return '****$last4';
  }

  bool get isVerified {
    return status.toLowerCase() == 'verified';
  }
}