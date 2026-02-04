class ProfileModel {
  String firstName;
  String lastName;
  String displayName;
  String description;
  String ageGroup;
  String gender;
  String country;
  List<LanguageModel> languages;
  String? profileImagePath;
  String? profileImageUrl;
  ProfileModel({
    this.firstName = '',
    this.lastName = '',
    this.displayName = '',
    this.description = '',
    this.ageGroup = '',
    this.gender = '',
    this.country = '',
    this.languages = const [],
    this.profileImagePath,
    this.profileImageUrl,
  });
}

// ✅ NEW: Language data model
class LanguageModel {
  final String code;
  final String name;
  final String level;

  LanguageModel({
    required this.code,
    required this.name,
    this.level = 'Beginner',
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'].toString(),
      name: json['name'].toString(),
      level: json['level'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'level': level};
  }
}
