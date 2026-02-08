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
  final tabs = ['Portfolio', 'Services', 'About', 'Reviews'];

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
  }

  /// Fetch profile data from API
  Future<void> fetchProfileData({bool refresh = false}) async {
    if (isLoadingProfile.value && !refresh) return;

    isLoadingProfile.value = true;

    try {
      final response = await _profileRepository.getCreatorProfileApi();

      if (response['statusCode'] == 200) {
        profileData.value = ProfileModel.fromJson(response['data']);
        if (response['data']['phoneNumber'] != null) {
          await _userPref.saveUser(
            phoneNumber: response['data']['phoneNumber'].toString(),
          );
        }
      }
    } catch (e) {
      Utils.snackBar('Error', e.toString());
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
      Utils.snackBar('Error', e.toString());
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
    if (gig.gigId == null || gig.gigId.toString().isEmpty) {
      Utils.snackBar('Error', 'error_no_service'.tr);
      return;
    }
    Get.toNamed(
      RouteName.gigDetailView,
      arguments: {'gigId': gig.gigId, 'gigIndex': index},
    );
  }

  /// Edit service (open create gig flow prefilled)
  Future<void> editService(MyGigModel gig) async {
    if (gig.gigId == null || gig.gigId.toString().isEmpty) {
      Utils.snackBar('Error', 'error_no_service'.tr);
      return;
    }
    try {
      final response = await _gigRepository.getGigDetailApi(gig.gigId.toString());
      final data = response is Map<String, dynamic> ? response['data'] : null;
      if (data == null) {
        Utils.snackBar('Error', 'error_no_service'.tr);
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
      Utils.snackBar('Error', e.toString());
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      fetchProfileData(refresh: true),
      if (currentIndex.value == 1) fetchMyGigs(refresh: true),
    ]);
  }

  // @override
  // void onClose() {
  //   tabController.dispose();
  //   super.onClose();
  // }
}
