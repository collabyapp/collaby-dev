import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/jobs_view/helper/helper_function.dart';
import 'package:collaby_app/view/jobs_view/job_details_view.dart';
import 'package:collaby_app/view/jobs_view/widget/empty_state.dart';
import 'package:collaby_app/view_models/controller/job_controller/job_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppliedJobsTab extends StatelessWidget {
  const AppliedJobsTab({required this.controller});
  final JobController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchAppliedJobs(refresh: true),
      child: Obx(() {
        if (controller.isLoading.value && controller.appliedJobsList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final applied = controller.appliedJobsList;
        if (applied.isEmpty) {
          return EmptyState(
            image: ImageAssets.noAppliedImage,
            message: 'jobs_empty_applied'.tr,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: applied.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final a = applied[i];
            return InkWell(
              onTap: () {
                Get.to(() => JobDetailsView(jobId: a.id), arguments: a);
              },
              borderRadius: BorderRadius.circular(12),

              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            a.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.smallMediumText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C5CE7).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            a.status,
                            style: const TextStyle(
                              color: Color(0xFF2F80ED),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 115,
                          height: 102,
                          padding: EdgeInsets.only(left: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: a.imageUrl ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Row(
                              // runSpacing: 8,
                              // spacing: 24,
                              children: [
                                _metaRow1(
                                  'job_budget'.tr,
                                  '\$${a.budget.toStringAsFixed(0)}',
                                ),

                                _meta(
                                  'job_video_quantity'.tr,
                                  '${a.videoQuantity.toString()}',
                                ),
                                // _meta('Video Quantity', job.videoQuantity.toString()),
                                // _meta('Delivery Timeline', job.deliveryTimeline),
                              ],
                            ),
                            Row(
                              // runSpacing: 8,
                              // spacing: 24,
                              children: [
                                // _meta('Budget', job.budget.toStringAsFixed(0)),
                                // _meta('Video Timeline', job.videoTimeline),
                                _metaRow1(
                                  'job_video_duration'.tr,
                                  '${a.videoTimeline} ${'job_unit_seconds'.tr}',
                                ),

                                _meta(
                                  'job_delivery_timeline'.tr,
                                  '${a.deliveryTimeline} ${'job_unit_days'.tr}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    // const SizedBox(height: 12),
                    // if (job.description.isNotEmpty)
                    //   Text(
                    //     job.description,
                    //     maxLines: 3,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: AppTextStyles.extraSmallText.copyWith(fontSize: 10),
                    //   ),
                    const SizedBox(height: 12),
                    Text(
                      'job_submitted_on'.trParams(
                        {'date': formatDate(a.submittedAt)},
                      ),

                      style: AppTextStyles.extraSmallText.copyWith(
                        fontSize: 10,
                        color: Color(0xff848194),
                      ),
                    ),
                  ],
                ),
              ),
            );
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(12),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(0.05),
            //         blurRadius: 8,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(a.title, style: AppTextStyles.smallMediumText),
            //             const SizedBox(height: 6),
            //             Text(
            //               'Submitted: ${formatDate(a.submittedAt)}',
            //               style: AppTextStyles.extraSmallText.copyWith(
            //                 fontSize: 10,
            //                 color: Color(0xff848194),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 10,
            //           vertical: 6,
            //         ),
            //         decoration: BoxDecoration(
            //           color: const Color(0xFF6C5CE7).withOpacity(0.12),
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         child: Text(
            //           a.status,
            //           style: const TextStyle(
            //             color: Color(0xFF2F80ED),
            //             fontSize: 12,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // );
          },
        );
      }),
    );
  }

  Widget _metaRow1(String label, String value) {
    return SizedBox(
      width: 80.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            // overflow: TextOverflow.ellipsis,
            style: AppTextStyles.extraSmallText.copyWith(
              fontSize: 10,
              color: Color(0xff848194),
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.extraSmallMediumText),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 90.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              // overflow: TextOverflow.ellipsis,
              style: AppTextStyles.extraSmallText.copyWith(
                fontSize: 10,
                color: Color(0xff848194),
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.extraSmallMediumText),
          ],
        ),
      ),
    );
  }
}
