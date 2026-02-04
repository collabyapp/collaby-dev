import 'dart:convert';
import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/models/profile_model.dart';
import 'package:collaby_app/repository/profile_repository/profile_repository.dart';
import 'package:collaby_app/repository/profile_setup_repository/profile_setup_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view/profile_setup_view/widgets/age_group_selector_bottom_sheet.dart';
import 'package:collaby_app/view/profile_setup_view/widgets/country_selector_bottom_sheet.dart';
import 'package:collaby_app/view/profile_setup_view/widgets/gender_selector_bottom_sheet.dart';
import 'package:collaby_app/view/profile_setup_view/widgets/language_level_selector_bottom_sheet.dart';
import 'package:collaby_app/view/profile_setup_view/widgets/language_selector_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetUpController extends GetxController {
  final ProfileModel _profile = ProfileModel();
  final ImagePicker _picker = ImagePicker();
  final ProfileSetupRepository profileSetUpRepo = ProfileSetupRepository();
  final ProfileRepository profileRepository = ProfileRepository();

  // Text Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final displayNameController = TextEditingController();

  // Reactive variables
  var selectedLanguages = <LanguageModel>[].obs;
  final profileImageUrl = ''.obs;
  final isSubmittingProfile = false.obs;
  final isLoadingProfile = false.obs;

  var isProfileValid = false.obs;
  final hasChanges = false.obs;

  // Store original data for comparison (only in edit mode)
  Map<String, dynamic> originalData = {};

  // Getters
  ProfileModel get profile => _profile;

  String get gender => _profile.gender;
  String get country => _profile.country;

  final streetController = TextEditingController().obs;
  final cityController = TextEditingController().obs;
  final zipCodeController = TextEditingController().obs;
  final countryController = TextEditingController().obs;

  final isShippingValid = false.obs;

  // Niches (opcional)
  final selectedNiches = <String>[].obs;
  final searchQuery = ''.obs;
  final RxBool isEdit = false.obs;

  var countries = <String>[].obs;
  var languagesData = <LanguageModel>[].obs;
  var isLoadingData = true.obs;

  final List<String> genders = ['Male', 'Female', 'Non_Binary'];

  final List<String> ageGroups = [
    'Young (18-24)',
    'Middle Aged (25-39)',
    'Adult (40+)',
  ];

  List<String> filteredCountries = [];
  List<LanguageModel> filteredLanguages = [];

  final List<String> languageLevels = [
    'Beginner',
    'Intermediate',
    'Native',
    'Advanced',
  ];

  final List<String> allNiches = [
    'Beauty & Personal Care',
    'Fashion',
    'Technology',
    'Home & Garden',
    'Sports & Outdoor',
    'Pets',
    'Kids & Toys',
    'Travel',
    'Food & Recipes',
    'Finance & Trading',
    'Education & Courses',
    'Video Games',
  ];

  void toggleNiche(String niche) {
    if (selectedNiches.contains(niche)) {
      selectedNiches.remove(niche);
    } else {
      selectedNiches.add(niche);
    }
    if (isEdit.value) _onFormChange();
  }

  List<String> get filteredNiches => allNiches
      .where((n) => n.toLowerCase().contains(searchQuery.value.toLowerCase()))
      .toList();

  void _validateShipping() {
    final ok =
        streetController.value.text.trim().isNotEmpty &&
        cityController.value.text.trim().isNotEmpty &&
        zipCodeController.value.text.trim().isNotEmpty &&
        countryController.value.text.trim().isNotEmpty;

    isShippingValid.value = ok;

    if (isEdit.value) _onFormChange();
  }

  @override
  void onInit() {
    super.onInit();

    _loadJsonData();

    firstNameController.addListener(_onFormChange);
    lastNameController.addListener(_onFormChange);
    displayNameController.addListener(_onFormChange);

    selectedLanguages.listen((_) => _onFormChange());

    isEdit.value = Get.arguments?['isEdit'] ?? false;

    streetController.value.addListener(_validateShipping);
    cityController.value.addListener(_validateShipping);
    zipCodeController.value.addListener(_validateShipping);
    countryController.value.addListener(_validateShipping);

    _validateShipping();

    if (isEdit.value) {
      _loadProfileForEdit();
    } else {
      _validateForm();
    }
  }

  Future<void> _loadProfileForEdit() async {
    try {
      isLoadingProfile.value = true;

      final response = await profileRepository.getCreatorProfileApi();

      if (response['statusCode'] == 200) {
        final profileData = response['data'];

        firstNameController.text = profileData['firstName'] ?? '';
        lastNameController.text = profileData['lastName'] ?? '';
        displayNameController.text = profileData['displayName'] ?? '';

        profileImageUrl.value = profileData['imageUrl'] ?? '';

        // age group
        String ageGroupValue = profileData['ageGroup'] ?? '';
        _profile.ageGroup = _matchAgeGroup(ageGroupValue);

        // gender
        String genderValue = profileData['gender'] ?? '';
        _profile.gender = genderValue.isNotEmpty
            ? '${genderValue[0].toUpperCase()}${genderValue.substring(1)}'
            : '';

        // country
        _profile.country = profileData['country'] ?? '';

        // languages
        final languages = profileData['languages'] as List?;
        if (languages != null) {
          selectedLanguages.value = languages
              .map((lang) => LanguageModel(
                    code: lang['language'] ?? '',
                    name: lang['language'] ?? '',
                    level: lang['level'] ?? 'Beginner',
                  ))
              .toList();
        }

        // shipping
        final shippingAddress = profileData['shippingAddress'] as Map<String, dynamic>?;
        if (shippingAddress != null) {
          streetController.value.text = shippingAddress['street'] ?? '';
          cityController.value.text = shippingAddress['city'] ?? '';
          zipCodeController.value.text = shippingAddress['zipCode'] ?? '';
          countryController.value.text = shippingAddress['country'] ?? '';
        }

        // niches
        final niches = profileData['niches'] as List?;
        if (niches != null) {
          selectedNiches.value = niches.cast<String>();
        }

        originalData = {
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'displayName': displayNameController.text,
          'imageUrl': profileImageUrl.value,
          'ageGroup': _profile.ageGroup,
          'gender': _profile.gender,
          'country': _profile.country,
          'languages': selectedLanguages.map((e) => e.toJson()).toList(),
          'shippingAddress': {
            'street': streetController.value.text,
            'city': cityController.value.text,
            'zipCode': zipCodeController.value.text,
            'country': countryController.value.text,
          },
          'niches': selectedNiches.toList(),
        };

        hasChanges.value = false;
        _validateForm();
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to load profile: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  String _matchAgeGroup(String value) {
    if (value.contains('18') || value.contains('24')) return 'Young (18-24)';
    if (value.contains('25') || value.contains('39')) return 'Middle Aged (25-39)';
    if (value.contains('40')) return 'Adult (40+)';
    return value;
  }

  void _onFormChange() {
    if (isEdit.value && originalData.isNotEmpty) {
      final currentData = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'displayName': displayNameController.text,
        'imageUrl': profileImageUrl.value,
        'ageGroup': _profile.ageGroup,
        'gender': _profile.gender,
        'country': _profile.country,
        'languages': selectedLanguages.map((e) => e.toJson()).toList(),
        'shippingAddress': {
          'street': streetController.value.text,
          'city': cityController.value.text,
          'zipCode': zipCodeController.value.text,
          'country': countryController.value.text,
        },
        'niches': selectedNiches.toList(),
      };

      hasChanges.value = !_mapsAreEqual(originalData, currentData);
    }
    _validateForm();
  }

  bool _mapsAreEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.keys.length != map2.keys.length) return false;

    for (var key in map1.keys) {
      if (!map2.containsKey(key)) return false;

      var val1 = map1[key];
      var val2 = map2[key];

      if (val1 is List && val2 is List) {
        if (val1.length != val2.length) return false;
        for (int i = 0; i < val1.length; i++) {
          if (val1[i].toString() != val2[i].toString()) return false;
        }
      } else if (val1 != val2) {
        return false;
      }
    }
    return true;
  }

  Future<void> _loadJsonData() async {
    try {
      isLoadingData.value = true;

      final countriesJson = await rootBundle.loadString('assets/json/countries.json');
      final countriesList = json.decode(countriesJson) as List;
      countries.value = countriesList.cast<String>();
      filteredCountries = List.from(countries);

      final languagesJson = await rootBundle.loadString('assets/json/languages.json');
      final languagesList = json.decode(languagesJson) as List;

      languagesData.value = languagesList
          .map((item) {
            try {
              return LanguageModel.fromJson(item as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<LanguageModel>()
          .toList();

      filteredLanguages = List.from(languagesData);
    } catch (e) {
      Utils.snackBar('Error', 'Failed to load data: $e');
    } finally {
      isLoadingData.value = false;
    }
  }

  void _validateForm() {
    isProfileValid.value = _isFormValid();
  }

  bool _isFormValid() {
    final basicValidation =
        firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        displayNameController.text.trim().isNotEmpty &&
        selectedLanguages.isNotEmpty;

    if (isEdit.value) return basicValidation && hasChanges.value;
    return basicValidation;
  }

  void filterCountries(String query) {
    final q = query.trim().toLowerCase();
    filteredCountries = q.isEmpty
        ? List.from(countries)
        : countries.where((c) => c.toLowerCase().contains(q)).toList();
    update();
  }

  void filterLanguages(String query) {
    final q = query.trim().toLowerCase();
    filteredLanguages = q.isEmpty
        ? List.from(languagesData)
        : languagesData.where((l) => l.name.toLowerCase().contains(q)).toList();
    update(['lang_list']);
  }

  @override
  void onClose() {
    firstNameController.removeListener(_onFormChange);
    lastNameController.removeListener(_onFormChange);
    displayNameController.removeListener(_onFormChange);

    firstNameController.dispose();
    lastNameController.dispose();
    displayNameController.dispose();

    streetController.value.dispose();
    cityController.value.dispose();
    zipCodeController.value.dispose();
    countryController.value.dispose();
    super.onClose();
  }

  void updateAgeGroup(String value) {
    _profile.ageGroup = value;
    _onFormChange();
    update();
  }

  void updateGender(String value) {
    _profile.gender = value;
    _onFormChange();
    update();
  }

  void updateCountry(String value) {
    _profile.country = value;
    _onFormChange();
    update();
  }

  void updateLanguageLevel(String languageName, String newLevel) {
    final index = selectedLanguages.indexWhere((lang) => lang.name == languageName);
    if (index != -1) {
      selectedLanguages[index] = LanguageModel(
        code: selectedLanguages[index].code,
        name: languageName,
        level: newLevel,
      );
      _validateForm();
    }
  }

  void addLanguage(String languageCode, String languageName, String level) {
    if (!selectedLanguages.any((lang) => lang.code == languageCode)) {
      selectedLanguages.add(LanguageModel(code: languageCode, name: languageName, level: level));
      _validateForm();
    }
  }

  void removeLanguage(String languageCode) {
    if (selectedLanguages.length > 1) {
      selectedLanguages.removeWhere((lang) => lang.name == languageCode);
      _validateForm();
    } else {
      Utils.snackBar('Cannot Remove', 'At least one language is required');
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final uploadedUrl = await NetworkApiServices().uploadAnyFile(filePath: image.path);

      profileImageUrl.value = uploadedUrl;
      _profile.profileImagePath = uploadedUrl;
      _onFormChange();
    } catch (_) {
      Utils.snackBar('Error', 'Failed to upload image');
    }
  }

  void showLanguageSelector() {
    Get.bottomSheet(
      LanguageSelectorBottomSheet(),
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void showCountrySelector() {
    Get.bottomSheet(
      CountrySelectorBottomSheet(),
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void showGenderSelector() {
    Get.bottomSheet(
      GenderSelectorBottomSheet(),
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void showAgeGroupSelector() {
    Get.bottomSheet(
      AgeGroupSelectorBottomSheet(),
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void showLanguageLevelSelector(String languageCode) {
    Get.bottomSheet(
      LanguageLevelSelectorBottomSheet(language: languageCode),
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  bool validateProfile() {
    if (firstNameController.text.trim().isEmpty) {
      Utils.snackBar('Error', 'First name is required');
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      Utils.snackBar('Error', 'Last name is required');
      return false;
    }
    if (displayNameController.text.trim().isEmpty) {
      Utils.snackBar('Error', 'Display name is required');
      return false;
    }
    if (selectedLanguages.isEmpty) {
      Utils.snackBar('Error', 'At least one language is required');
      return false;
    }
    return true;
  }

  void submitProfile() {
    _profile.firstName = firstNameController.text.trim();
    _profile.lastName = lastNameController.text.trim();
    _profile.displayName = displayNameController.text.trim();
    _profile.languages = selectedLanguages.toList();

    if (validateProfile()) {
      Get.toNamed(RouteName.shippingAddressView);
    }
  }

  String _ageRangeValue(String label) {
    final m = RegExp(r'\(([^)]+)\)').firstMatch(label);
    if (m != null) return m.group(1)!.trim();

    final m2 = RegExp(r'(\d+\s*[-–]\s*\d+|\d+\+)').firstMatch(label);
    if (m2 != null) return m2.group(1)!.replaceAll(' ', '');

    return label;
  }

  List<Map<String, String>> _mapLanguages() {
    return selectedLanguages
        .map((lang) {
          final name = (lang.name).trim();
          final level = (lang.level).trim();
          return {"language": name, "level": level};
        })
        .where((e) => e["language"]!.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> generateApiPayload() {
    return {
      "imageUrl": profileImageUrl.value.isNotEmpty ? profileImageUrl.value : "",
      "firstName": firstNameController.text.trim(),
      "lastName": lastNameController.text.trim(),
      "displayName": displayNameController.text.trim(),
      "gender": gender.toLowerCase(),
      "ageGroup": _ageRangeValue(_profile.ageGroup),
      "country": _profile.country,
      "languages": _mapLanguages(),
      "shippingAddress": {
        "street": streetController.value.text.trim(),
        "city": cityController.value.text.trim(),
        "zipCode": zipCodeController.value.text.trim(),
        "country": countryController.value.text.trim(),
      },
      "niches": selectedNiches.toList(), // opcional
    };
  }

  Map<String, dynamic> generateUpdatePayload() {
    Map<String, dynamic> payload = {};

    if (firstNameController.text.trim() != originalData['firstName']) {
      payload['firstName'] = firstNameController.text.trim();
    }
    if (lastNameController.text.trim() != originalData['lastName']) {
      payload['lastName'] = lastNameController.text.trim();
    }
    if (displayNameController.text.trim() != originalData['displayName']) {
      payload['displayName'] = displayNameController.text.trim();
    }
    if (profileImageUrl.value != originalData['imageUrl']) {
      payload['imageUrl'] = profileImageUrl.value;
    }
    if (_profile.gender.toLowerCase() != originalData['gender']?.toLowerCase()) {
      payload['gender'] = _profile.gender.toLowerCase();
    }
    if (_ageRangeValue(_profile.ageGroup) != _ageRangeValue(originalData['ageGroup'] ?? '')) {
      payload['ageGroup'] = _ageRangeValue(_profile.ageGroup);
    }
    if (_profile.country != originalData['country']) {
      payload['country'] = _profile.country;
    }

    final currentLangs = _mapLanguages();
    if (currentLangs.toString() != originalData['languages'].toString()) {
      payload['languages'] = currentLangs;
    }

    // shipping changes
    final originalShipping = originalData['shippingAddress'] as Map<String, dynamic>?;
    final currentShipping = {
      'street': streetController.value.text.trim(),
      'city': cityController.value.text.trim(),
      'zipCode': zipCodeController.value.text.trim(),
      'country': countryController.value.text.trim(),
    };

    if (originalShipping == null ||
        originalShipping['street'] != currentShipping['street'] ||
        originalShipping['city'] != currentShipping['city'] ||
        originalShipping['zipCode'] != currentShipping['zipCode'] ||
        originalShipping['country'] != currentShipping['country']) {
      payload['shippingAddress'] = currentShipping;
    }

    // niches changes
    final originalNiches = originalData['niches'] as List?;
    final currentNiches = selectedNiches.toList();
    if (originalNiches == null || originalNiches.length != currentNiches.length || !_listsAreEqual(originalNiches, currentNiches)) {
      payload['niches'] = currentNiches;
    }

    return payload;
  }

  bool _listsAreEqual(List list1, List list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!list2.contains(list1[i])) return false;
    }
    return true;
  }

  Future<void> updateProfile() async {
    if (!validateProfile()) return;

    if (!hasChanges.value) {
      Utils.snackBar('Info', 'No changes to save');
      return;
    }

    final payload = generateUpdatePayload();
    if (payload.isEmpty) {
      Utils.snackBar('Info', 'No changes to save');
      return;
    }

    try {
      isSubmittingProfile.value = true;

      final res = await profileRepository.updateCreatorProfileApi(payload);

      if (res == null) {
        Utils.snackBar('Error', 'No response from server');
        return;
      }

      final statusCode = res['statusCode'] as int?;
      final message = res['message'] as String?;

      if (statusCode == 200 || statusCode == 201) {
        originalData = {
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'displayName': displayNameController.text,
          'imageUrl': profileImageUrl.value,
          'ageGroup': _profile.ageGroup,
          'gender': _profile.gender,
          'country': _profile.country,
          'languages': selectedLanguages.map((e) => e.toJson()).toList(),
          'shippingAddress': {
            'street': streetController.value.text,
            'city': cityController.value.text,
            'zipCode': zipCodeController.value.text,
            'country': countryController.value.text,
          },
          'niches': selectedNiches.toList(),
        };

        hasChanges.value = false;
        Utils.snackBar('Success', message ?? 'Profile updated successfully');

        Get.offAllNamed(RouteName.bottomNavigationView, arguments: {'index': 3});
      } else {
        Utils.snackBar('Error', message ?? 'Failed to update profile');
      }
    } catch (e) {
      debugPrint('updateProfile error: $e');
      Utils.snackBar('Error', 'Failed to update profile');
    } finally {
      isSubmittingProfile.value = false;
    }
  }

  Future<void> submitToApi() async {
    if (!validateProfile()) return;

    if (!isShippingValid.value) {
      Utils.snackBar('Error', 'Please complete shipping address');
      return;
    }

    // ✅ niches opcional: NO bloquear si viene vacío

    final payload = generateApiPayload();

    try {
      isSubmittingProfile.value = true;

      final res = await profileSetUpRepo.profileSetupApi(payload);

      if (res == null) {
        Utils.snackBar('Error', 'No response from server. Please try again.');
        return;
      }

      final statusCode = res['statusCode'] as int?;
      final message = res['message'] as String?;
      final data = res['data'] as Map<String, dynamic>?;

      if (statusCode == 201) {
        Utils.snackBar('Success', message ?? 'Creator profile setup completed');

        // ✅ aquí es donde tú enlazas “seguidito” al Servicio:
        // Cambia esta ruta a la que uses para CreateGigView renombrada como Servicio.
        Get.offAllNamed(RouteName.createServiceView, arguments: {
          'fromOnboarding': true,
          'profileData': data,
        });
      } else {
        Utils.snackBar('Error', 'Failed to submit profile: ${message ?? 'Unknown error'}');
      }
    } catch (e, st) {
      debugPrint('submitToApi error: $e');
      debugPrintStack(stackTrace: st);

      String errorMessage = 'Failed to submit profile. Please try again.';
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again.';
      }
      Utils.snackBar('Error', errorMessage);
    } finally {
      isSubmittingProfile.value = false;
    }
  }
}
