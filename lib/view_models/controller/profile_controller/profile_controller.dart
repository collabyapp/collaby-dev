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

      if (profileJson.isNotEmpty) {
        profileData.value = ProfileModel.fromJson(profileJson);

        final phone =
            responseData['phoneNumber'] ??
            root['phoneNumber'] ??
            profileJson['phoneNumber'];
        final email =
            responseData['email'] ?? root['email'] ?? profileJson['email'];
        if (phone != null) {
          await _userPref.saveUser(phoneNumber: phone.toString());
        }
        if (email != null) {
          await _userPref.saveUser(email: email.toString());
          fallbackEmail.value = email.toString().trim();
        }
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
    if (fromProfile.isNotEmpty) {
      final cleaned = <PortfolioItem>[];
      final seenUrls = <String>{};
      for (final item in fromProfile) {
        final key = item.deliveryFile.url.trim();
        if (seenUrls.contains(key)) continue;
        seenUrls.add(key);
        cleaned.add(item);
      }
      return cleaned;
    }

    if (servicePortfolioItems.isEmpty) return const <PortfolioItem>[];

    final fallback = <PortfolioItem>[];
    final seenUrls = <String>{};
    for (final item in servicePortfolioItems) {
      final key = item.deliveryFile.url.trim();
      if (key.isNotEmpty && seenUrls.contains(key)) continue;
      if (key.isNotEmpty) seenUrls.add(key);
      fallback.add(item);
    }
    return fallback;
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

    for (final gig in myGigs) {
      if (gig.gigId.trim().isEmpty) continue;
      try {
        final response = await _gigRepository.getGigDetailApi(gig.gigId);
        final data = response is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>?
            : null;
        if (data == null) continue;

        final detail = GigDetailModel.fromJson(data);
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
      final data = response is Map<String, dynamic> ? response['data'] : null;
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
      root,
      data,
      nestedData,
      _asMap(root['profile']),
      _asMap(root['creatorProfile']),
      _asMap(root['creator']),
      _asMap(root['user']),
      _asMap(root['roleData']),
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
    ].where((m) => m.isNotEmpty).toList();

    Map<String, dynamic> best = <String, dynamic>{};
    var bestScore = -1;

    for (final raw in candidates) {
      final normalized = _normalizeProfileCandidate(raw);
      final score = _profileScore(normalized);
      if (score > bestScore) {
        bestScore = score;
        best = normalized;
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

    merged['firstName'] = _coalesceString([
      merged['firstName'],
      user['firstName'],
    ]);
    merged['lastName'] = _coalesceString([
      merged['lastName'],
      user['lastName'],
    ]);
    merged['displayName'] = _coalesceString([
      merged['displayName'],
      user['displayName'],
      user['username'],
      user['brandCompanyName'],
    ]);
    merged['imageUrl'] = _coalesceString([
      merged['imageUrl'],
      user['imageUrl'],
    ]);
    merged['description'] = _coalesceString([
      merged['description'],
      user['description'],
    ]);

    if (merged['shippingAddress'] is! Map<String, dynamic>) {
      final shipping = _asMap(roleData['shippingAddress']);
      if (shipping.isNotEmpty) merged['shippingAddress'] = shipping;
    }

    if (merged['languages'] is! List && roleData['languages'] is List) {
      merged['languages'] = roleData['languages'];
    }
    if (merged['portfolio'] is! List && roleData['portfolio'] is List) {
      merged['portfolio'] = roleData['portfolio'];
    }
    if (merged['reviews'] is! List && roleData['reviews'] is List) {
      merged['reviews'] = roleData['reviews'];
    }

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
    if (json['creatorLevelProgress'] is Map<String, dynamic>) score += 1;
    if (json['reviewStats'] is Map<String, dynamic>) score += 1;
    return score;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  String _coalesceString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  // @override
  // void onClose() {
  //   tabController.dispose();
  //   super.onClose();
  // }
}
