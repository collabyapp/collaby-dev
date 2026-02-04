import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view_models/controller/profile_controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GigsTab extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gigs', style: AppTextStyles.normalTextBold),
              GestureDetector(
                onTap: () {
                  Get.toNamed(RouteName.createGigView);
                },
                child: Text(
                  'Create New Gig',
                  style: AppTextStyles.smallMediumText.copyWith(
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingGigs.value && controller.myGigs.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.myGigs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No gigs yet', style: AppTextStyles.normalTextBold),
                      SizedBox(height: 8),
                      Text(
                        'Create your first gig to get started',
                        style: AppTextStyles.smallText,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchMyGigs(refresh: true),
                child: ListView.builder(
                  itemCount:
                      controller.myGigs.length +
                      (controller.hasMoreGigs.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.myGigs.length) {
                      controller.loadMoreGigs();
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final gig = controller.myGigs[index];
                    return GestureDetector(
                      onTap: () {
                        controller.navigateToGigDetail(gig, index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 88,
                              height: 102,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: gig.gigThumbnail,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                ),
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
                                      Expanded(
                                        child: Text(
                                          gig.gigTitle,
                                          style: AppTextStyles.smallMediumText,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: gig.gigStatus == 'Active'
                                              ? Color(
                                                  0xff5DA160,
                                                ).withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          gig.gigStatus,
                                          style: AppTextStyles
                                              .extraSmallMediumText
                                              .copyWith(
                                                color: gig.gigStatus == 'Active'
                                                    ? Color(0xff5DA160)
                                                    : Colors.grey,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Starting at \$${gig.startingPrice}',
                                    style: AppTextStyles.extraSmallText
                                        .copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.primaryColor,
                                        ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Color(0xff676767),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        gig.postedTimeAgo,
                                        style: AppTextStyles.extraSmallText
                                            .copyWith(color: Color(0xff676767)),
                                      ),
                                      if (gig.reviewStats.totalReviews > 0) ...[
                                        SizedBox(width: 12),
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${gig.reviewStats.averageRating.toStringAsFixed(1)} (${gig.reviewStats.totalReviews})',
                                          style: AppTextStyles.extraSmallText
                                              .copyWith(
                                                color: Color(0xff676767),
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
