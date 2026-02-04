class AdditionalFeature {
  final String id; // local UI id
  String name;
  double price;
  int extraDays;

  AdditionalFeature({
    required this.id,
    required this.name,
    required this.price,
    required this.extraDays,
  });

  /// ✅ Payload EXACTO que entiende NestJS
  Map<String, dynamic> toApiJson() => {
        "featureType": "script", // ✅ o "additionalRevision"
        "name": name,
        "price": price,
        "deliveryTimesIndays": extraDays, // ✅ FIX real
      };

  AdditionalFeature copyWith({
    String? id,
    String? name,
    double? price,
    int? extraDays,
  }) {
    return AdditionalFeature(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      extraDays: extraDays ?? this.extraDays,
    );
  }
}
