class BankAccount {
  final String id;
  final String bankName;
  final String routingNumber;
  final String accountNumber;
  final String accountType;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.routingNumber,
    required this.accountNumber,
    required this.accountType,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] ?? '',
      bankName: json['bankName'] ?? json['bank_name'] ?? 'Bank',
      routingNumber: json['routingNumber'] ?? json['routing_number'] ?? '',
      accountNumber:
          json['accountNumber'] ??
          json['account_number'] ??
          json['last4'] ??
          '',
      accountType: json['accountType'] ?? json['account_type'] ?? 'checking',
    );
  }

  String get masked =>
      '$bankName  ${accountNumber.length > 6 ? accountNumber.substring(0, 8) : accountNumber}…';
}

enum PayoutStatus { completed, processing, approved, rejected, failed }

class Payout {
  final double amount;
  final DateTime date;
  final PayoutStatus status;
  final String? message;
  final String id;
  final String? description;

  Payout({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    this.message,
    this.description,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    PayoutStatus getStatus(String? status) {
      switch (status?.toLowerCase()) {
        case 'completed':
          return PayoutStatus.completed;
        case 'approved':
          return PayoutStatus.approved;
        case 'failed':
          return PayoutStatus.failed;
        case 'processing':
        default:
          return PayoutStatus.processing;
      }
    }

    return Payout(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(
        json['date'] ?? json['processedAt'] ?? DateTime.now().toIso8601String(),
      ),
      status: getStatus(json['status']),
      message: json['message'],
      description: json['description'],
    );
  }
}

enum WithdrawalMethod { standard, instant }
