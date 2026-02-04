import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
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
          Text('Profile', style: AppTextStyles.normalTextBold),
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
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[300],
                backgroundImage: profile.imageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(profile.imageUrl)
                    : AssetImage(ImageAssets.createProfileIcon),
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
                      color: AppColor.whiteColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: 16,
                    ),
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
                              '${profile.activeBoost?.type ?? 'Pro'} - Level',
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
    return Column(
      children: [
        _buildProfileInfo(),
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
              'Boost Your Profile and get\nmore UGC Deals',
              style: AppTextStyles.extraSmallText.copyWith(color: Colors.white),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to boost screen
              Get.to(() => BoostProfileScreen());
            },
            icon: Image.asset(ImageAssets.boostIcon, width: 20, height: 20),
            label: Text('Boost Now', style: AppTextStyles.extraSmallMediumText),
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
                    'Analytic Overview',
                    style: AppTextStyles.extraSmallText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => BoostDetailsScreen()),
                    child: Text(
                      'View Details',
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
                  'Profile View',
                  ImageAssets.eyeIcon,
                ),
                _buildAnalyticsItem(
                  '${analytics.responseRate} %',
                  'Response Rate',
                  ImageAssets.responseIcon,
                ),
                _buildAnalyticsItem(
                  '${analytics.newLeads}',
                  'New Leads',
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
        tabs: controller.tabs.map((t) => Tab(text: t)).toList(),
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
