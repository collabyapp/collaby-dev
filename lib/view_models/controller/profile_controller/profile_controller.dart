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

  // Gigs data
  final myGigs = <MyGigModel>[].obs;
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
    });

    // Fetch profile data on init
    fetchProfileData();
    // Preload gigs so the services CTA doesn't flicker
    fetchMyGigs();
  }

  /// Fetch profile data from API
  Future<void> fetchProfileData({bool refresh = false}) async {
    if (isLoadingProfile.value && !refresh) return;

    isLoadingProfile.value = true;

    try {
      final response = await _profileRepository.getCreatorProfileApi();

      final statusCode = response is Map<String, dynamic>
          ? response['statusCode'] as int?
          : null;
      final success = response is Map<String, dynamic>
          ? response['success'] == true
          : false;

      if (statusCode == 200 || success) {
        final responseData = response is Map<String, dynamic>
            ? (response['data'] as Map<String, dynamic>? ?? {})
            : <String, dynamic>{};
        final profileJson = (responseData['profile'] is Map<String, dynamic>)
            ? responseData['profile'] as Map<String, dynamic>
            : responseData;

        profileData.value = ProfileModel.fromJson(profileJson);

        final phone = responseData['phoneNumber'] ?? profileJson['phoneNumber'];
        if (phone != null) {
          await _userPref.saveUser(phoneNumber: phone.toString());
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
    return profileData.value?.portfolio ?? [];
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
    } catch (e) {
      Utils.snackBar('error'.tr, e.toString());
    } finally {
      isLoadingGigs.value = false;
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
      final data = response is Map<String, dynamic> ? response['data'] : null;
      if (data == null) {
        Utils.snackBar('error'.tr, 'error_no_service'.tr);
        return;
      }
      Get.toNamed(
        RouteName.createGigView,
        arguments: {
          'isEditMode': true,
          'gigId': gig.gigId.toString(),
          'gigData': data,
        },
      );
    } catch (e) {
      Utils.snackBar('error'.tr, e.toString());
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      fetchProfileData(refresh: true),
      if (currentIndex.value == 1) fetchMyGigs(refresh: true),
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

  // @override
  // void onClose() {
  //   tabController.dispose();
  //   super.onClose();
  // }
}
