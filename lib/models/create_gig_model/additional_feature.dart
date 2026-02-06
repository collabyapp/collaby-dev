class AdditionalFeature {
  final String id;
  final String name;
  final double price;
  final int extraDays;
  final int revisions;

  AdditionalFeature({
    required this.id,
    required this.name,
    required this.price,
    required this.extraDays,
    this.revisions = 0,
  });

  AdditionalFeature copyWith({
    String? id,
    String? name,
    double? price,
    int? extraDays,
    int? revisions,
  }) {
    return AdditionalFeature(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      extraDays: extraDays ?? this.extraDays,
      revisions: revisions ?? this.revisions,
    );
  }
}
