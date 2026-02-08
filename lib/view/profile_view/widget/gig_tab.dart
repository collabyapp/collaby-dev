import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
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
              Text('services'.tr, style: AppTextStyles.normalTextBold),
              Obx(() {
                final hasService = controller.myGigs.isNotEmpty;
                return GestureDetector(
                  onTap: () async {
                    if (controller.isLoadingGigs.value) return;
                    if (controller.myGigs.isEmpty) {
                      await controller.fetchMyGigs(refresh: true);
                    }
                    if (controller.myGigs.isEmpty) {
                      Utils.snackBar('No services yet', 'Create your first service to get started.');
                      Get.toNamed(RouteName.createGigView);
                      return;
                    }
                    if (hasService) {
                      await controller.editService(controller.myGigs.first);
                      return;
                    }
                    Get.toNamed(RouteName.createGigView);
                  },
                  child: Text(
                    hasService ? 'edit_service_cta'.tr : 'create_new_service'.tr,
                    style: AppTextStyles.smallMediumText.copyWith(
                      color: AppColor.primaryColor,
                    ),
                  ),
                );
              }),
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
                      Text('no_services_yet'.tr, style: AppTextStyles.normalTextBold),
                      SizedBox(height: 8),
                      Text(
                        'create_first_service'.tr,
                        style: AppTextStyles.smallText,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchMyGigs(refresh: true),
                child: GridView.builder(
                  padding: EdgeInsets.only(bottom: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 120,
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
                            SizedBox(height: 10),
                            Text(
                              gig.gigTitle,
                              style: AppTextStyles.smallMediumText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: gig.gigStatus == 'Active'
                                        ? Color(0xff5DA160).withOpacity(0.12)
                                        : Colors.grey.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    gig.gigStatus,
                                    style: AppTextStyles.extraSmallMediumText
                                        .copyWith(
                                          color: gig.gigStatus == 'Active'
                                              ? Color(0xff5DA160)
                                              : Colors.grey,
                                        ),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '\$${gig.startingPrice}',
                                  style: AppTextStyles.extraSmallText.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ],
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
                                Expanded(
                                  child: Text(
                                    gig.postedTimeAgo,
                                    style: AppTextStyles.extraSmallText
                                        .copyWith(color: Color(0xff676767)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (gig.reviewStats.totalReviews > 0) ...[
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${gig.reviewStats.averageRating.toStringAsFixed(1)} (${gig.reviewStats.totalReviews})',
                                    style: AppTextStyles.extraSmallText
                                        .copyWith(color: Color(0xff676767)),
                                  ),
                                ],
                              ],
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
