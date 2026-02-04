class PackageModel {
  double price;
  String deliveryTime;
  int revisions;
  List<String> features;

  // Additional Revision fields
  double? extraRevisionPrice;
  int? extraRevisionDays;

  // Script fields (NEW - separate from Additional Revision)
  double? scriptPrice;
  int? scriptDays;

  PackageModel({
    this.price = 0,
    this.deliveryTime = '',
    this.revisions = 0,
    this.features = const [],
    this.extraRevisionPrice,
    this.extraRevisionDays,
    this.scriptPrice,
    this.scriptDays,
  });

  bool get hasAdditionalRevision => features.contains('Additional Revision');
  bool get hasScript => features.contains('Script');

  bool get isComplete {
    final baseOk =
        price > 0 &&
        deliveryTime.isNotEmpty &&
        revisions > 0 &&
        features.isNotEmpty;

    // Check Additional Revision completion if selected
    if (hasAdditionalRevision) {
      final extraRevisionOk =
          (extraRevisionPrice != null && extraRevisionPrice! > 0) &&
          (extraRevisionDays != null && extraRevisionDays! > 0);
      if (!extraRevisionOk) return false;
    }

    // Check Script completion if selected
    if (hasScript) {
      final scriptOk =
          (scriptPrice != null && scriptPrice! > 0) &&
          (scriptDays != null && scriptDays! > 0);
      if (!scriptOk) return false;
    }

    return baseOk;
  }

  // JSON serialization
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      price: (json['price'] ?? 0).toDouble(),
      deliveryTime: json['deliveryTime'] ?? '',
      revisions: json['revisions'] ?? 0,
      features: List<String>.from(json['features'] ?? []),
      extraRevisionPrice: json['extraRevisionPrice']?.toDouble(),
      extraRevisionDays: json['extraRevisionDays'],
      scriptPrice: json['scriptPrice']?.toDouble(),
      scriptDays: json['scriptDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'deliveryTime': deliveryTime,
      'revisions': revisions,
      'features': features,
      'extraRevisionPrice': extraRevisionPrice,
      'extraRevisionDays': extraRevisionDays,
      'scriptPrice': scriptPrice,
      'scriptDays': scriptDays,
    };
  }
}
