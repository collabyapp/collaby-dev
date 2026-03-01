import 'package:collaby_app/models/profile_model/profile_model.dart';
import 'package:collaby_app/models/profile_model/user_model.dart';
import 'package:collaby_app/repository/gig_creation_repository/gig_creation_repository.dart';
import 'package:collaby_app/repository/profile_repository/profile_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final _gigRepository = GigCreationRepository();
  final _profileRepository = ProfileRepository();
  final _userPref = UserPreference();

  late TabController tabController;
  final currentIndex = 0.obs;
  final tabs = ['tab_portfolio', 'tab_services', 'tab_about', 'tab_reviews'];

  // Profile data
  final isLoadingProfile = false.obs;
  final profileData = Rx<ProfileModel?>(null);
  final fallbackEmail = ''.obs;

  // Gigs data
  final myGigs = <MyGigModel>[].obs;
  final servicePortfolioItems = <PortfolioItem>[].obs;
  final isLoadingGigs = false.obs;
  final currentPage = 1.obs;
  final hasMoreGigs = true.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      currentIndex.value = tabController.index;

      // Load gigs when Gigs tab is selected
      if (currentIndex.value == 1 && myGigs.isEmpty) {
        fetchMyGigs();
      }
      if (currentIndex.value == 0 || currentIndex.value == 2) {
        fetchProfileData(refresh: true);
      }
      if (currentIndex.value == 0) {
        fetchMyGigs(refresh: true);
      }
    });

    // Fetch profile data on init
    _loadLocalIdentity();
    fetchProfileData();
    // Preload gigs so the services CTA doesn't flicker
    fetchMyGigs();
  }

  Future<void> _loadLocalIdentity() async {
    final user = await _userPref.getUser();
    fallbackEmail.value = (user['email'] as String? ?? '').trim();
  }

  /// Fetch profile data from API
  Future<void> fetchProfileData({bool refresh = false}) async {
    if (isLoadingProfile.value && !refresh) return;

    isLoadingProfile.value = true;

    try {
      final response = await _profileRepository.getCreatorProfileApi();
      final root = response is Map<String, dynamic>
          ? response
          : <String, dynamic>{};
      final responseData = root['data'] is Map<String, dynamic>
          ? root['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      final profileJson = _extractProfileJson(root);
      final phone =
          responseData['phoneNumber'] ??
          root['phoneNumber'] ??
          profileJson['phoneNumber'];
      final email =
          responseData['email'] ?? root['email'] ?? profileJson['email'];

      if (profileJson.isNotEmpty) {
        profileData.value = ProfileModel.fromJson(profileJson);
      }
      if (phone != null) {
        await _userPref.saveUser(phoneNumber: phone.toString());
      }
      if (email != null) {
        await _userPref.saveUser(email: email.toString());
        fallbackEmail.value = email.toString().trim();
      }
    } catch (e) {
      Utils.snackBar('error'.tr, e.toString());
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Check if user has active subscription
  bool get hasActiveSubscription {
    return profileData.value?.subscription?.hasActiveSubscription ?? false;
  }

  /// Get analytics data
  AnalyticsModel? get analytics => profileData.value?.analytics;

  /// Get portfolio items
  List<PortfolioItem> get portfolioItems {
    final fromProfile = (profileData.value?.portfolio ?? <PortfolioItem>[])
        .where((item) => item.deliveryFile.url.trim().isNotEmpty)
        .toList();
    final serviceOnly = servicePortfolioItems
        .where((item) => item.deliveryFile.url.trim().isNotEmpty)
        .toList();

    if (fromProfile.isEmpty && serviceOnly.isEmpty)
      return const <PortfolioItem>[];

    final serviceUrls = serviceOnly
        .map((e) => e.deliveryFile.url.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    final merged = <PortfolioItem>[];
    final seenUrls = <String>{};

    // Service gallery items must always be visible and never hideable.
    for (final item in serviceOnly) {
      final key = item.deliveryFile.url.trim();
      if (key.isNotEmpty && seenUrls.contains(key)) continue;
      if (key.isNotEmpty) seenUrls.add(key);
      merged.add(_withCanHide(item, false));
    }

    for (final item in fromProfile) {
      final key = item.deliveryFile.url.trim();
      if (key.isEmpty || seenUrls.contains(key)) continue;
      seenUrls.add(key);
      final shouldHide = serviceUrls.contains(key) ? false : item.canHide;
      merged.add(_withCanHide(item, shouldHide));
    }

    return merged;
  }

  /// Get reviews
  List<GigReviewModel> get reviews {
    return profileData.value?.reviews ?? [];
  }

  /// Get creator review stats
  CreatorReviewStats? get reviewStats {
    return profileData.value?.creatorReviewStats;
  }

  void changeTab(int index) => tabController.animateTo(index);

  /// Fetch user's gigs
  Future<void> fetchMyGigs({bool refresh = false}) async {
    if (isLoadingGigs.value) return;

    if (refresh) {
      currentPage.value = 1;
      myGigs.clear();
      hasMoreGigs.value = true;
    }

    if (!hasMoreGigs.value) return;

    isLoadingGigs.value = true;

    try {
      final response = await _gigRepository.getMyGigsApi(
        pageNumber: currentPage.value,
        pageSize: 10,
      );

      final gigsResponse = MyGigsResponseModel.fromJson(response);

      if (refresh) {
        myGigs.value = gigsResponse.data;
      } else {
        myGigs.addAll(gigsResponse.data);
      }

      hasMoreGigs.value = currentPage.value < gigsResponse.totalPages;
      if (hasMoreGigs.value) {
        currentPage.value++;
      }

      await _hydrateServicePortfolioItems();
    } catch (e) {
      Utils.snackBar('error'.tr, e.toString());
    } finally {
      isLoadingGigs.value = false;
    }
  }

  Future<void> _hydrateServicePortfolioItems() async {
    if (myGigs.isEmpty) {
      servicePortfolioItems.clear();
      return;
    }

    final built = <PortfolioItem>[];
    final seenUrls = <String>{};
    GigDetailModel? firstUsableDetail;
    MyGigModel? firstUsableGig;

    for (final gig in myGigs) {
      if (gig.gigId.trim().isEmpty) continue;
      try {
        final response = await _gigRepository.getGigDetailApi(gig.gigId);
        final root = response is Map<String, dynamic>
            ? response
            : <String, dynamic>{};
        final data = _extractGigDetailJson(root);
        if (data == null) continue;

        final detail = GigDetailModel.fromJson(data);
        if (firstUsableDetail == null) {
          firstUsableDetail = detail;
          firstUsableGig = gig;
        }
        for (final media in detail.gallery) {
          final url = media.url.trim();
          if (url.isEmpty || seenUrls.contains(url)) continue;
          seenUrls.add(url);

          built.add(
            PortfolioItem(
              galleryItemId: media.id,
              gigId: detail.id,
              gigTitle: detail.title.isNotEmpty ? detail.title : gig.gigTitle,
              deliveryFile: DeliveryFile(
                name: media.name,
                type: media.type,
                url: media.url,
                thumbnail: media.thumbnail,
              ),
              canHide: false,
            ),
          );
        }
      } catch (_) {
        // Non-blocking: service list should still render even if one detail fails.
      }
    }

    servicePortfolioItems.value = built;
    if (firstUsableDetail != null && firstUsableGig != null) {
      _patchProfileFromServiceFallback(firstUsableDetail, firstUsableGig);
    }
  }

  /// Load more gigs (pagination)
  Future<void> loadMoreGigs() async {
    if (!isLoadingGigs.value && hasMoreGigs.value) {
      await fetchMyGigs();
    }
  }

  /// Navigate to gig detail
  void navigateToGigDetail(MyGigModel gig, int index) {
    if (gig.gigId.toString().isEmpty) {
      Utils.snackBar('error'.tr, 'error_no_service'.tr);
      return;
    }
    Get.toNamed(
      RouteName.gigDetailView,
      arguments: {'gigId': gig.gigId, 'gigIndex': index},
    );
  }

  /// Edit service (open create gig flow prefilled)
  Future<void> editService(MyGigModel gig) async {
    if (gig.gigId.toString().isEmpty) {
      Utils.snackBar('error'.tr, 'error_no_service'.tr);
      return;
    }
    try {
      final response = await _gigRepository.getGigDetailApi(
        gig.gigId.toString(),
      );
      final root = response is Map<String, dynamic>
          ? response
          : <String, dynamic>{};
      final data = _extractGigDetailJson(root);
      if (data == null) {
        Utils.snackBar('error'.tr, 'error_no_service'.tr);
        return;
      }
      await Get.toNamed(
        RouteName.createGigView,
        arguments: {
          'isEditMode': true,
          'gigId': gig.gigId.toString(),
          'gigData': data,
        },
      );
      await refreshAll();
    } catch (e) {
      Utils.snackBar('error'.tr, e.toString());
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      fetchProfileData(refresh: true),
      fetchMyGigs(refresh: true),
    ]);
  }

  Future<void> hidePortfolioItem(PortfolioItem item) async {
    if (!item.canHide) return;
    final url = item.deliveryFile.url.trim();
    if (url.isEmpty) return;

    try {
      await _profileRepository.hidePortfolioItemApi(url);
      final current = profileData.value;
      if (current != null) {
        final nextPortfolio = current.portfolio
            .where((p) => p.deliveryFile.url != url)
            .toList();
        profileData.value = ProfileModel(
          role: current.role,
          status: current.status,
          badge: current.badge,
          userId: current.userId,
          imageUrl: current.imageUrl,
          firstName: current.firstName,
          lastName: current.lastName,
          displayName: current.displayName,
          description: current.description,
          ageGroup: current.ageGroup,
          gender: current.gender,
          country: current.country,
          languages: current.languages,
          shippingAddress: current.shippingAddress,
          niches: current.niches,
          reviewStats: current.reviewStats,
          subscription: current.subscription,
          analytics: current.analytics,
          isConnectedAccount: current.isConnectedAccount,
          stripeConnectedAccountId: current.stripeConnectedAccountId,
          activeBoost: current.activeBoost,
          portfolio: nextPortfolio,
          reviews: current.reviews,
          creatorReviewStats: current.creatorReviewStats,
          creatorLevelProgress: current.creatorLevelProgress,
        );
      }
      Utils.snackBar('success'.tr, 'removed_from_portfolio'.tr);
    } catch (e) {
      Utils.snackBar('error'.tr, e.toString());
    }
  }

  Map<String, dynamic> _extractProfileJson(Map<String, dynamic> root) {
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final nestedData = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final candidates = <Map<String, dynamic>>[
      nestedData,
      data,
      _asMap(data['profile']),
      _asMap(data['creatorProfile']),
      _asMap(data['creator']),
      _asMap(data['user']),
      _asMap(data['roleData']),
      _asMap(nestedData['profile']),
      _asMap(nestedData['creatorProfile']),
      _asMap(nestedData['creator']),
      _asMap(nestedData['user']),
      _asMap(nestedData['roleData']),
      _asMap(root['profile']),
      _asMap(root['creatorProfile']),
      _asMap(root['creator']),
      _asMap(root['user']),
      _asMap(root['roleData']),
      root,
    ].where((m) => m.isNotEmpty).toList();

    Map<String, dynamic> best = <String, dynamic>{};
    var bestScore = -1;
    var bestStructuralScore = -1;
    var bestKeyCount = -1;

    for (final raw in candidates) {
      final normalized = _normalizeProfileCandidate(raw);
      final structuralScore = _profileStructuralScore(normalized);
      if (structuralScore == 0) continue;
      final score = _profileScore(normalized);
      final keyCount = normalized.keys.length;
      final isBetter =
          score > bestScore ||
          (score == bestScore && structuralScore > bestStructuralScore) ||
          (score == bestScore &&
              structuralScore == bestStructuralScore &&
              keyCount > bestKeyCount);
      if (isBetter) {
        bestScore = score;
        bestStructuralScore = structuralScore;
        bestKeyCount = keyCount;
        best = normalized;
      }
    }

    if (best.isEmpty && data.isNotEmpty) {
      final fallback = _normalizeProfileCandidate(data);
      if (_profileStructuralScore(fallback) > 0) {
        return fallback;
      }
    }
    return best;
  }

  Map<String, dynamic> _normalizeProfileCandidate(Map<String, dynamic> raw) {
    final roleData = _asMap(raw['roleData']);
    final creator = _asMap(raw['creator']);
    final creatorProfile = _asMap(raw['creatorProfile']);
    final profile = _asMap(raw['profile']);
    final user = _asMap(raw['user']);

    final merged = <String, dynamic>{};
    merged.addAll(roleData);
    merged.addAll(creatorProfile);
    merged.addAll(creator);
    merged.addAll(profile);
    merged.addAll(raw);
    merged.addAll(_asMap(merged['data']));

    merged['firstName'] = _coalesceString([
      merged['firstName'],
      merged['first_name'],
      merged['firstname'],
      user['firstName'],
      user['first_name'],
      user['firstname'],
    ]);
    merged['lastName'] = _coalesceString([
      merged['lastName'],
      merged['last_name'],
      merged['lastname'],
      merged['surname'],
      user['lastName'],
      user['last_name'],
      user['lastname'],
      user['surname'],
    ]);
    merged['displayName'] = _coalesceString([
      merged['displayName'],
      merged['fullName'],
      merged['name'],
      merged['username'],
      merged['userName'],
      user['displayName'],
      user['username'],
      user['userName'],
      user['brandCompanyName'],
      user['fullName'],
      user['name'],
    ]);
    merged['imageUrl'] = _coalesceString([
      merged['imageUrl'],
      merged['profileImage'],
      merged['profileImageUrl'],
      merged['avatar'],
      merged['photoUrl'],
      user['imageUrl'],
      user['profileImage'],
      user['profileImageUrl'],
      user['avatar'],
    ]);
    merged['description'] = _coalesceString([
      merged['description'],
      merged['bio'],
      merged['about'],
      merged['creatorDescription'],
      user['description'],
      user['bio'],
      user['about'],
    ]);
    merged['ageGroup'] = _coalesceString([
      merged['ageGroup'],
      merged['age'],
      merged['ageRange'],
      merged['age_range'],
      merged['age_group'],
    ]);
    merged['gender'] = _coalesceString([
      merged['gender'],
      merged['sex'],
      merged['genre'],
    ]);
    merged['country'] = _coalesceString([
      merged['country'],
      merged['location'],
      merged['countryName'],
    ]);

    if (merged['shippingAddress'] is! Map<String, dynamic>) {
      final shipping = _coalesceMap([
        merged['shippingAddress'],
        roleData['shippingAddress'],
        creator['shippingAddress'],
        creatorProfile['shippingAddress'],
        profile['shippingAddress'],
      ]);
      if (shipping.isNotEmpty) merged['shippingAddress'] = shipping;
    }
    if (merged['shippingAddress'] is! Map<String, dynamic>) {
      final city = _coalesceString([
        merged['city'],
        roleData['city'],
        creator['city'],
      ]);
      final country = _coalesceString([
        merged['country'],
        roleData['country'],
        creator['country'],
      ]);
      if (city.isNotEmpty || country.isNotEmpty) {
        merged['shippingAddress'] = <String, dynamic>{
          'street': '',
          'city': city,
          'zipCode': '',
          'country': country,
        };
      }
    }

    final rawLanguages = _coalesceList([
      merged['languages'],
      roleData['languages'],
      creator['languages'],
      creatorProfile['languages'],
      profile['languages'],
      user['languages'],
    ]);
    merged['languages'] = rawLanguages
        .map((e) {
          if (e is Map) {
            final map = _asMap(e);
            final language = _coalesceString([map['language'], map['name']]);
            if (language.isEmpty) return null;
            return <String, dynamic>{
              'language': language,
              'level': _coalesceString([map['level'], 'Beginner']),
            };
          }
          final language = _coalesceString([e]);
          if (language.isEmpty) return null;
          return <String, dynamic>{'language': language, 'level': 'Beginner'};
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    merged['portfolio'] = _coalesceList([
      merged['portfolio'],
      roleData['portfolio'],
      creator['portfolio'],
      creatorProfile['portfolio'],
      profile['portfolio'],
    ]).map((e) => _asMap(e)).where((e) => e.isNotEmpty).toList();

    merged['reviews'] = _coalesceList([
      merged['reviews'],
      roleData['reviews'],
      creator['reviews'],
      creatorProfile['reviews'],
      profile['reviews'],
    ]).map((e) => _asMap(e)).where((e) => e.isNotEmpty).toList();

    merged['niches'] = _coalesceList([
      merged['niches'],
      roleData['niches'],
      creator['niches'],
      creatorProfile['niches'],
      profile['niches'],
      merged['skills'],
      roleData['skills'],
      creator['skills'],
    ]).map((e) => _coalesceString([e])).where((e) => e.isNotEmpty).toList();
    merged['badge'] = _coalesceString([
      merged['badge'],
      roleData['badge'],
      creator['badge'],
      creatorProfile['badge'],
    ]);
    merged['userId'] = _coalesceString([
      merged['userId'],
      merged['user_id'],
      merged['id'],
      merged['_id'],
      user['userId'],
      user['_id'],
      roleData['user'],
      creator['user'],
    ]);
    merged['role'] = _coalesceString([
      merged['role'],
      user['role'],
      roleData['role'],
      'creator',
    ]);
    merged['status'] = _coalesceString([
      merged['status'],
      merged['profileStatus'],
      roleData['profileStatus'],
      'active',
    ]);

    return merged;
  }

  int _profileScore(Map<String, dynamic> json) {
    var score = 0;
    if (_coalesceString([json['displayName']]).isNotEmpty) score += 3;
    if (_coalesceString([json['firstName']]).isNotEmpty) score += 2;
    if (_coalesceString([json['lastName']]).isNotEmpty) score += 2;
    if (_coalesceString([json['description']]).isNotEmpty) score += 2;
    if (_coalesceString([json['imageUrl']]).isNotEmpty) score += 2;
    if (json['shippingAddress'] is Map<String, dynamic>) score += 2;
    if (json['languages'] is List && (json['languages'] as List).isNotEmpty) {
      score += 2;
    }
    if (json['portfolio'] is List && (json['portfolio'] as List).isNotEmpty) {
      score += 3;
    }
    if (json['reviews'] is List && (json['reviews'] as List).isNotEmpty) {
      score += 1;
    }
    if (_coalesceString([json['userId']]).isNotEmpty) score += 1;
    if (_coalesceString([json['badge']]).isNotEmpty) score += 1;
    if (json['creatorLevelProgress'] is Map<String, dynamic>) score += 1;
    if (json['reviewStats'] is Map<String, dynamic>) score += 1;
    return score;
  }

  int _profileStructuralScore(Map<String, dynamic> json) {
    const keys = <String>{
      'role',
      'status',
      'badge',
      'userId',
      'imageUrl',
      'firstName',
      'lastName',
      'displayName',
      'description',
      'ageGroup',
      'gender',
      'country',
      'languages',
      'shippingAddress',
      'niches',
      'reviewStats',
      'portfolio',
      'reviews',
      'creatorReviewStats',
      'creatorLevelProgress',
      'subscription',
      'analytics',
      'isConnectedAccount',
    };
    var score = 0;
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      if (value is List && value.isEmpty) continue;
      if (value is Map && value.isEmpty) continue;
      score++;
    }
    return score;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _coalesceMap(List<dynamic> values) {
    for (final value in values) {
      final map = _asMap(value);
      if (map.isNotEmpty) return map;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _coalesceList(List<dynamic> values) {
    for (final value in values) {
      if (value is List && value.isNotEmpty) return value;
    }
    return const [];
  }

  String _coalesceString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isEmpty) continue;
      if (text == '-' || text.toLowerCase() == 'null') continue;
      return text;
    }
    return '';
  }

  void _patchProfileFromServiceFallback(GigDetailModel detail, MyGigModel gig) {
    final creator = detail.creator;
    final current = profileData.value;

    String fallbackDisplayName() {
      final joined = '${creator.firstName.trim()} ${creator.lastName.trim()}'
          .trim();
      return _coalesceString([
        creator.displayName,
        joined,
        gig.creatorFullName,
        current?.displayName,
        current?.firstName,
      ]);
    }

    final resolvedDisplayName = fallbackDisplayName();
    final resolvedFirstName = _coalesceString([
      current?.firstName,
      creator.firstName,
    ]);
    final resolvedLastName = _coalesceString([
      current?.lastName,
      creator.lastName,
    ]);
    final resolvedImage = _coalesceString([
      current?.imageUrl,
      creator.imageUrl,
      gig.creatorImageUrl,
    ]);
    final resolvedDescription = _coalesceString([
      current?.description,
      creator.description,
      detail.description,
    ]);
    final resolvedCountry = _coalesceString([
      current?.country,
      creator.country,
      _extractCountryFromAddress(gig.creatorAddress),
    ]);
    final resolvedAgeGroup = _coalesceString([
      current?.ageGroup,
      creator.ageGroup,
    ]);
    final resolvedGender = _coalesceString([current?.gender, creator.gender]);

    if (current == null) {
      profileData.value = ProfileModel(
        role: 'creator',
        status: 'active',
        badge: _coalesceString([creator.badge, 'none']),
        userId: _coalesceString([gig.creatorUserId]),
        imageUrl: resolvedImage,
        firstName: resolvedFirstName,
        lastName: resolvedLastName,
        displayName: resolvedDisplayName,
        description: resolvedDescription,
        ageGroup: resolvedAgeGroup,
        gender: resolvedGender,
        country: resolvedCountry,
        languages: const [],
        shippingAddress: ShippingAddress(
          street: '',
          city: _extractCityFromAddress(gig.creatorAddress),
          zipCode: '',
          country: resolvedCountry,
        ),
        niches: creator.niches,
        reviewStats: ReviewStatsModel(
          totalReviews: gig.reviewStats.totalReviews,
          averageRating: gig.reviewStats.averageRating,
        ),
        subscription: null,
        analytics: null,
        isConnectedAccount: false,
        stripeConnectedAccountId: null,
        activeBoost: null,
        portfolio: const [],
        reviews: const [],
        creatorReviewStats: null,
        creatorLevelProgress: null,
      );
      return;
    }

    profileData.value = ProfileModel(
      role: _coalesceString([current.role, 'creator']),
      status: _coalesceString([current.status, 'active']),
      badge: _coalesceString([current.badge, creator.badge, 'none']),
      userId: _coalesceString([current.userId, gig.creatorUserId]),
      imageUrl: resolvedImage,
      firstName: resolvedFirstName,
      lastName: resolvedLastName,
      displayName: _coalesceString([current.displayName, resolvedDisplayName]),
      description: resolvedDescription,
      ageGroup: resolvedAgeGroup,
      gender: resolvedGender,
      country: resolvedCountry,
      languages: current.languages,
      shippingAddress: ShippingAddress(
        street: current.shippingAddress.street,
        city: _coalesceString([
          current.shippingAddress.city,
          _extractCityFromAddress(gig.creatorAddress),
        ]),
        zipCode: current.shippingAddress.zipCode,
        country: _coalesceString([
          current.shippingAddress.country,
          resolvedCountry,
        ]),
      ),
      niches: current.niches.isNotEmpty ? current.niches : creator.niches,
      reviewStats: ReviewStatsModel(
        totalReviews: current.reviewStats.totalReviews > 0
            ? current.reviewStats.totalReviews
            : gig.reviewStats.totalReviews,
        averageRating: current.reviewStats.averageRating > 0
            ? current.reviewStats.averageRating
            : gig.reviewStats.averageRating,
      ),
      subscription: current.subscription,
      analytics: current.analytics,
      isConnectedAccount: current.isConnectedAccount,
      stripeConnectedAccountId: current.stripeConnectedAccountId,
      activeBoost: current.activeBoost,
      portfolio: current.portfolio,
      reviews: current.reviews,
      creatorReviewStats: current.creatorReviewStats,
      creatorLevelProgress: current.creatorLevelProgress,
    );
  }

  String _extractCityFromAddress(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return '';
    final parts = cleaned.split(',');
    return parts.first.trim();
  }

  String _extractCountryFromAddress(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return '';
    final parts = cleaned.split(',');
    if (parts.length < 2) return '';
    return parts.last.trim();
  }

  PortfolioItem _withCanHide(PortfolioItem item, bool canHide) {
    return PortfolioItem(
      galleryItemId: item.galleryItemId,
      gigId: item.gigId,
      gigTitle: item.gigTitle,
      deliveryFile: item.deliveryFile,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      workDescription: item.workDescription,
      deliveryStatus: item.deliveryStatus,
      canHide: canHide,
    );
  }

  Map<String, dynamic>? _extractGigDetailJson(Map<String, dynamic> root) {
    final data = _asMap(root['data']);
    final nestedData = _asMap(data['data']);
    final candidates = <Map<String, dynamic>>[
      nestedData,
      data,
      _asMap(data['gig']),
      _asMap(root['gig']),
      root,
    ].where((m) => m.isNotEmpty).toList();

    for (final candidate in candidates) {
      if (_looksLikeGigDetail(candidate)) return candidate;
    }
    return null;
  }

  bool _looksLikeGigDetail(Map<String, dynamic> json) {
    if (json.isEmpty) return false;
    if (json['gallery'] is List) return true;
    return json.containsKey('_id') || json.containsKey('title');
  }

  // @override
  // void onClose() {
  //   tabController.dispose();
  //   super.onClose();
  // }
}
