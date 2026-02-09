import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/profile_controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewsTab extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reviews = controller.reviews;
      final reviewStats = controller.reviewStats;

      if (controller.isLoadingProfile.value && reviews.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('reviews_title'.tr, style: AppTextStyles.normalTextBold),
                  if (reviewStats != null)
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              color: index < reviewStats.averageRating.round()
                                  ? Colors.amber
                                  : Colors.grey[300],
                              size: 18,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '(${reviewStats.averageRating.toStringAsFixed(1)})',
                          style: AppTextStyles.smallText,
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 20),
              if (reviews.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('no_reviews_yet'.tr, style: AppTextStyles.normalText),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        margin: EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: CachedNetworkImageProvider(
                                review.reviewedBy.imageUrl,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.reviewedBy.username,
                                        style: AppTextStyles.smallMediumText,
                                      ),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (starIndex) => Icon(
                                            Icons.star,
                                            size: 14,
                                            color:
                                                starIndex <
                                                    review.averageRating.round()
                                                ? Colors.amber
                                                : Colors.grey[300],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    review.description,
                                    style: AppTextStyles.extraSmallText
                                        .copyWith(fontSize: 11),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    review.timeAgo,
                                    style: AppTextStyles.extraSmallText
                                        .copyWith(color: Color(0xff676767)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
