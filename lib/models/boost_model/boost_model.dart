class BoostPlan {
  final String boostType;
  final String name;
  final String badge;
  final List<String> features;
  final double price;
  final String currency;
  final int duration;
  final String description;
  final double multiplier;

  BoostPlan({
    required this.boostType,
    required this.name,
    required this.badge,
    required this.features,
    required this.price,
    required this.currency,
    required this.duration,
    required this.description,
    required this.multiplier,
  });

  factory BoostPlan.fromJson(Map<String, dynamic> json) {
    return BoostPlan(
      boostType: json['boostType'] ?? '',
      name: json['name'] ?? '',
      badge: json['badge'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      duration: json['duration'] ?? 0,
      description: json['description'] ?? '',
      multiplier: (json['multiplier'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boostType': boostType,
      'name': name,
      'badge': badge,
      'features': features,
      'price': price,
      'currency': currency,
      'duration': duration,
      'description': description,
      'multiplier': multiplier,
    };
  }
}

class BoostPlansResponse {
  final List<BoostPlan> data;
  final int statusCode;
  final String message;
  final String timestamp;

  BoostPlansResponse({
    required this.data,
    required this.statusCode,
    required this.message,
    required this.timestamp,
  });

  factory BoostPlansResponse.fromJson(Map<String, dynamic> json) {
    return BoostPlansResponse(
      data: (json['data'] as List?)
              ?.map((item) => BoostPlan.fromJson(item))
              .toList() ??
          [],
      statusCode: json['statusCode'] ?? 200,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}