import 'package:collaby_app/models/chat_model/chat_model.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileScreen extends StatelessWidget {
  final ChatUser user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Get.back(),
        // ),
        title: Text(
          'brand_profile_title'.trParams({'name': user.name}),
          style: AppTextStyles.h6,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color(0xffFBBB00),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'brand_profile_location'.tr,
                        style: AppTextStyles.extraSmallMediumText,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Stats Container
                  _buildAnalyticsCard(),
                ],
              ),
            ),

            // About Section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('about_title'.tr, style: AppTextStyles.normalTextBold),
                  SizedBox(height: 12),
                  Text(
                    'brand_profile_about'.tr,
                    style: AppTextStyles.extraSmallText,
                  ),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'brand_profile_timezone'.tr,
                        style: AppTextStyles.extraSmallMediumText,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'brand_profile_timezone_value'.tr,
                        style: AppTextStyles.smallMediumText.copyWith(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'brand_profile_last_conversation'.tr,
                        style: AppTextStyles.extraSmallMediumText,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'brand_profile_last_conversation_value'.tr,
                        style: AppTextStyles.smallMediumText.copyWith(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Active Gig Section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'brand_profile_active_gig'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=80&h=80&fit=crop&crop=face',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'brand_profile_active_gig_title'.tr,
                                    style: AppTextStyles.smallMediumText,
                                  ),
                                  Text(
                                    'brand_profile_visibility_public'.tr,
                                    style: TextStyle(
                                      color: Color(0xff5DA160),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 4),
                              Text(
                                'brand_profile_active_gig_desc'.tr,
                                style: AppTextStyles.extraSmallText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: Color(0xff676767),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'brand_profile_posted_2_days_ago'.tr,
                                    style: AppTextStyles.extraSmallText
                                        .copyWith(color: Color(0xff676767)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('package_preview'.tr, style: AppTextStyles.h6),
            ),
            // Package Preview Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(ImageAssets.dollarIcon, width: 16),

                        Text(' \$ 50', style: AppTextStyles.normalTextMedium),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildPackageFeature('package_feature_raw_files'.tr),
                    _buildPackageFeature('package_feature_commercial_use'.tr),
                    _buildPackageFeature('package_feature_background_music'.tr),
                    _buildPackageFeature('package_feature_voice_over'.tr),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                color: Colors.orange,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'brand_profile_delivery_days'.trParams(
                                  {'days': '3'},
                                ),
                                style: AppTextStyles.extraSmallMediumText,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(ImageAssets.revisionIcon, width: 12),

                              SizedBox(width: 4),
                              Text(
                                'reviews_count'.trParams({'count': '2'}),
                                style: AppTextStyles.extraSmallMediumText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text('additional_revision'.tr, style: AppTextStyles.h6),
            ),

            // Additional Revision Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(ImageAssets.dollarIcon, width: 12),
                        Text(
                          " \$ 30",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 20),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            // color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                color: Colors.orange,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'brand_profile_delivery_days'.trParams(
                                  {'days': '1'},
                                ),
                                style: AppTextStyles.extraSmallMediumText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'brand_profile_revision_desc'.tr,
                      style: AppTextStyles.extraSmallText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          // color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            title: 'brand_profile_view_files'.tr,
            onPressed: () => Get.to(() => MediaFilesScreen()),
          ),

          // child: SizedBox(
          //   width: double.infinity,
          //   height: 50,
          //   child: ElevatedButton(
          //     onPressed: () => Get.to(() => MediaFilesScreen()),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.black,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(25),
          //       ),
          //     ),
          //     child: Text(
          //       'View Files',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 16,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xff4C1CAE),

        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnalyticsItem('95%', 'brand_profile_response_rate'.tr, 20),
              _buildAnalyticsItem('4.9', 'brand_profile_rating'.tr, 30),
              _buildAnalyticsItem('2024', 'brand_profile_member_since'.tr, 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(
    String value,
    String label,
    double horizontalPadding,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 10,
      ),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),

          Text(
            label,
            style: AppTextStyles.extraSmallText.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageFeature(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.black, size: 16),
          SizedBox(width: 8),
          Text(feature, style: AppTextStyles.extraSmallText),
        ],
      ),
    );
  }
}

// Media Files Screen
class MediaFilesScreen extends StatefulWidget {
  @override
  _MediaFilesScreenState createState() => _MediaFilesScreenState();
}

class _MediaFilesScreenState extends State<MediaFilesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('media_files'.tr),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'media_tab_videos'.tr),
            Tab(text: 'media_tab_photos'.tr),
            Tab(text: 'media_tab_files'.tr),
          ],
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: AppTextStyles.smallMediumText,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildVideosTab(), _buildPhotosTab(), _buildFilesTab()],
      ),
    );
  }

  Widget _buildVideosTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildVideoItem(
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=250&fit=crop',
          '2:45',
          '02:59 PM',
          true,
        ),
        SizedBox(height: 16),
        _buildVideoItem(
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=250&fit=crop',
          '2:45',
          '02:59 PM',
          false,
        ),
      ],
    );
  }

  Widget _buildPhotosTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildPhotoItem(
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=250&fit=crop',
          '02:59 PM',
          true,
        ),
        SizedBox(height: 16),
        _buildPhotoItem(
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=250&fit=crop',
          '02:59 PM',
          false,
        ),
      ],
    );
  }

  Widget _buildFilesTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildFileItem('Project_Overview_2025.pdf', '2.4 MB', '02:59 PM', true),
        SizedBox(height: 16),
        _buildFileItem(
          'Project_Overview_2025.pdf',
          '2.4 MB',
          '02:59 PM',
          false,
        ),
      ],
    );
  }

  Widget _buildVideoItem(
    String imageUrl,
    String duration,
    String time,
    bool isSent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 8, left: 4, right: 4, top: 4),
          decoration: BoxDecoration(
            color: isSent ? Color(0xff816CED) : Color(0xffDFD5FA),
            borderRadius: isSent
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  )
                : BorderRadius.only(
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Dark overlay for video effect
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
              // Play button
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              // Duration badge
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: isSent
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                isSent
                    ? 'media_sent'.trParams({'time': time})
                    : 'media_received'.trParams({'time': time}),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoItem(String imageUrl, String time, bool isSent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            padding: EdgeInsets.only(bottom: 8, left: 4, right: 4, top: 4),
            decoration: BoxDecoration(
              color: isSent ? Color(0xff816CED) : Color(0xffDFD5FA),
              borderRadius: isSent
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    )
                  : BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: isSent
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                isSent
                    ? 'media_sent'.trParams({'time': time})
                    : 'media_received'.trParams({'time': time}),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(
    String fileName,
    String fileSize,
    String time,
    bool isSent,
  ) {
    return Container(
      // padding: EdgeInsets.all(16),
      // decoration: BoxDecoration(
      //   color: isSent ? AppColor.primaryColor : Colors.grey[200],
      //   borderRadius: BorderRadius.circular(16),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSent ? Color(0xff816CED) : Color(0xffDFD5FA),
              borderRadius: isSent
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    )
                  : BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon(
                    //   Icons.picture_as_pdf,
                    //   color: isSent ? Colors.white : Colors.grey[700],
                    //   size: 24,
                    // ),
                    Image.asset(
                      ImageAssets.pdfIcons,
                      color: isSent ? Colors.white : Colors.grey[700],
                      width: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              color: isSent ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            fileSize,
                            style: TextStyle(
                              color: isSent ? Colors.white70 : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.file_download_outlined,
                      color: isSent ? Colors.white : Colors.grey[700],
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: isSent
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                isSent
                    ? 'media_sent'.trParams({'time': time})
                    : 'media_received'.trParams({'time': time}),
                style: TextStyle(
                  color: isSent ? Colors.grey[600] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
