import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/jobs_view/helper/helper_function.dart';
import 'package:collaby_app/view/jobs_view/widget/company_avatar.dart';
import 'package:flutter/material.dart';
import 'package:collaby_app/models/jobs_model/job_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    required this.job,
    required this.onTap,
    required this.onToggleSave,
    required this.isSaved,
  });

  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
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
                // CompanyAvatar(name: job.company, logo: job.companyLogo),
                // const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    job.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.smallMediumText,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onToggleSave,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xffEFF5FC).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isSaved
                          ? const Color(0xFF6C5CE7)
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 120,
                  height: 102,
                  padding: EdgeInsets.only(left: 2),

                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: job.imageUrl ?? '',
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
                          'Budget',
                          '\$ ${job.budget.toStringAsFixed(0)}',
                        ),

                        _meta('Video Quantity', job.videoQuantity.toString()),
                        // _meta('Video Timeline', job.videoTimeline),
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
                        _metaRow1('Video Duration', '${job.videoTimeline} sec'),

                        _meta(
                          'Delivery Timeline',
                          '${job.deliveryTimeline} days',
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
              'Updated: ${formatDate(job.updatedAt)}',
              style: AppTextStyles.extraSmallText.copyWith(
                fontSize: 10,
                color: Color(0xff848194),
              ),
            ),
          ],
        ),
      ),
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
        width: 98.w,
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
