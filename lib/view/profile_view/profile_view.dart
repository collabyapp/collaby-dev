import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/profile_view/boost_profile_view/boost_detials.dart';
import 'package:collaby_app/view/profile_view/boost_profile_view/boost_profile_view.dart';
import 'package:collaby_app/view/profile_view/widget/about_tab.dart';
import 'package:collaby_app/view/profile_view/widget/gig_tab.dart';
import 'package:collaby_app/view/profile_view/widget/portfolio_tab.dart';
import 'package:collaby_app/view/profile_view/widget/review_tab.dart';
import 'package:collaby_app/view_models/controller/profile_controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  String _normalizeBadge(String raw) {
    final v = raw.trim().toLowerCase();
    if (v == 'level_two' || v == 'level2' || v == 'pro') return 'level_two';
    if (v == 'level_one' || v == 'level1') return 'level_one';
    return 'none';
  }

  String _levelLabel(String badge) {
    switch (badge) {
      case 'level_two':
        return 'creator_level_two'.tr;
      case 'level_one':
        return 'creator_level_one'.tr;
      default:
        return 'creator_level_new'.tr;
    }
  }

  Widget _requirementRow({
    required String label,
    required num current,
    required num target,
    required bool met,
  }) {
    final color = met ? const Color(0xff1D9C62) : const Color(0xff7A7A7A);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label (${current.toString()}/${target.toString()})',
              style: AppTextStyles.extraSmallText.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(RouteName.bottomNavigationView);
        return true; // prevent default behavior (app close)
      },
      child: Scaffold(
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoadingProfile.value &&
                controller.profileData.value == null) {
              return Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: controller.refreshAll,
              child: Column(
                children: [
                  _buildHeader(),
                  Obx(() => _buildBoostOrAnalyticsCard()),
                  _buildTabBar(),
                  _buildTabBarView(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text('profile_title'.tr, style: AppTextStyles.normalTextBold),
          Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Color(0xff917DE5).withOpacity(0.26)),
            ),
            child: IconButton(
              icon: Image.asset(ImageAssets.editIcon, width: 18),
              onPressed: () {
                Get.toNamed(
                  RouteName.profileSetUpView,
                  arguments: {'isEdit': true},
                );
              },
            ),
          ),
          SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Color(0xff917DE5).withOpacity(0.26)),
            ),
            child: IconButton(
              icon: Image.asset(ImageAssets.settingIcon, width: 18),
              onPressed: () {
                Get.toNamed(RouteName.settingsView);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    final profile = controller.profileData.value;
    if (profile == null) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CircleAvatar(
          //   radius: 40,
          //   backgroundColor: Colors.grey[300],
          //   backgroundImage: profile.imageUrl.isNotEmpty
          //       ? CachedNetworkImageProvider(profile.imageUrl)
          //       : AssetImage(ImageAssets.createProfileIcon),
          // ),
          Stack(
            children: [
              Builder(
                builder: (_) {
                  ImageProvider? provider;
                  if (profile.imageUrl.isNotEmpty) {
                    provider = CachedNetworkImageProvider(profile.imageUrl);
                  }
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: provider,
                    child: provider == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[400],
                          )
                        : null,
                  );
                },
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      RouteName.profileSetUpView,
                      arguments: {'isEdit': true},
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Image.asset(ImageAssets.cameraIcon, width: 16),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(profile.displayName, style: AppTextStyles.h6Bold),
                        SizedBox(width: 8),
                        if (controller.hasActiveSubscription)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xff917DE5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${profile.activeBoost?.type ?? 'boost_pro'.tr} - ${'boost_level'.tr}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontFamily: AppFonts.OpenSansSemiBold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xff4B5563),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${profile.shippingAddress.city}, ${profile.shippingAddress.country}',
                          style: AppTextStyles.extraSmallText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoostOrAnalyticsCard() {
    final profile = controller.profileData.value;
    final normalizedBadge = _normalizeBadge(profile?.badge ?? 'none');
    final progress = profile?.creatorLevelProgress;
    final progressPct = (progress?.levelTwoProgressPercent ?? 0).clamp(0, 100);

    return Column(
      children: [
        _buildProfileInfo(),
        if (progress != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF7F5FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffE2DBFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('creator_level_title'.tr, style: AppTextStyles.smallTextBold),
                const SizedBox(height: 4),
                Text(
                  'creator_level_current'.trParams({'level': _levelLabel(normalizedBadge)}),
                  style: AppTextStyles.extraSmallText.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'creator_level_progress'.trParams({'percent': '$progressPct'}),
                  style: AppTextStyles.extraSmallText.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: progressPct / 100,
                    backgroundColor: const Color(0xffE9E3FF),
                    valueColor: const AlwaysStoppedAnimation(Color(0xff816CED)),
                  ),
                ),
                _requirementRow(
                  label: 'level_up_requirement_first_gig'.tr,
                  current: progress.requirements.gigs.current,
                  target: progress.requirements.gigs.target,
                  met: progress.requirements.gigs.met,
                ),
                _requirementRow(
                  label: 'level_up_requirement_reviews'.tr,
                  current: progress.requirements.reviews.current,
                  target: progress.requirements.reviews.target,
                  met: progress.requirements.reviews.met,
                ),
                _requirementRow(
                  label: 'level_up_requirement_completed_orders'.tr,
                  current: progress.requirements.completedOrders.current,
                  target: progress.requirements.completedOrders.target,
                  met: progress.requirements.completedOrders.met,
                ),
                _requirementRow(
                  label: 'level_up_requirement_rating'.tr,
                  current: progress.requirements.averageRating.current,
                  target: progress.requirements.averageRating.target,
                  met: progress.requirements.averageRating.met,
                ),
                _requirementRow(
                  label: 'level_up_requirement_days_active'.tr,
                  current: progress.requirements.daysSinceRegistration.current,
                  target: progress.requirements.daysSinceRegistration.target,
                  met: progress.requirements.daysSinceRegistration.met,
                ),
              ],
            ),
          ),
        SizedBox(height: 10),
        Container(
          child: controller.hasActiveSubscription
              ? _buildAnalyticsCard()
              : _buildBoostCard(),
        ),
      ],
    );
  }

  Widget _buildBoostCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF816CED), Color(0xFF33196A), Color(0xFF432C73)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'boost_card_title'.tr,
              style: AppTextStyles.extraSmallText.copyWith(color: Colors.white),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to boost screen
              Get.to(() => BoostProfileScreen());
            },
            icon: Image.asset(ImageAssets.boostIcon, width: 20, height: 20),
            label: Text('boost_now'.tr, style: AppTextStyles.extraSmallMediumText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    final analytics = controller.analytics;
    if (analytics == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xff4C1CAE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'analytics_overview'.tr,
                    style: AppTextStyles.extraSmallText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => BoostDetailsScreen()),
                    child: Text(
                      'view_details'.tr,
                      style: AppTextStyles.extraSmallMediumText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnalyticsItem(
                  '${analytics.profileViews}',
                  'profile_view_label'.tr,
                  ImageAssets.eyeIcon,
                ),
                _buildAnalyticsItem(
                  '${analytics.responseRate} %',
                  'response_rate'.tr,
                  ImageAssets.responseIcon,
                ),
                _buildAnalyticsItem(
                  '${analytics.newLeads}',
                  'new_leads'.tr,
                  ImageAssets.leadIcon,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String value, String label, String icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xff8281E6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(icon, width: 13),
              SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.extraSmallText.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 50,
      child: TabBar(
        controller: controller.tabController,
        tabs: controller.tabs.map((t) => Tab(text: t.tr)).toList(),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2, color: Colors.black),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: AppTextStyles.smallMediumText,
        unselectedLabelStyle: AppTextStyles.smallText,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: controller.tabController,
        physics: const BouncingScrollPhysics(),
        children: [PortfolioTab(), GigsTab(), AboutTab(), ReviewsTab()],
      ),
    );
  }
}
