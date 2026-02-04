import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/models/jobs_model/job_model.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/job_controller/job_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class JobDetailsView extends StatefulWidget {
  final String jobId; // Changed to jobId instead of JobModel

  JobDetailsView({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetailsView> createState() => _JobDetailsViewState();
}

class _JobDetailsViewState extends State<JobDetailsView> {
  final JobController controller = Get.find<JobController>();

  @override
  void initState() {
    super.initState();
    // Fetch job details when screen opens
    controller.fetchJobDetails(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
        actions: [
          Obx(() {
            final job = controller.currentJobDetails.value;
            if (job == null) return SizedBox.shrink();

            final isSaved = job.isSaved;

            return IconButton(
              splashColor: Colors.transparent,
              icon: Icon(
                isSaved ? Icons.favorite : Icons.favorite_border,
                color: isSaved ? AppColor.primaryColor : Colors.grey[600],
              ),
              onPressed: () => controller.toggleSaveJob(job.id),
            );
          }),
          SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetails.value) {
          return Center(child: CircularProgressIndicator());
        }

        final job = controller.currentJobDetails.value;
        if (job == null) {
          return Center(child: Text('Job not found'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner (if applicable)
              _buildStatusBanner(job),

              // Job Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // _buildCompanyLogo(job),
                        // SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: AppTextStyles.smallMediumText,
                              ),
                              if (job.status == JobStatus.closed)
                                Text(
                                  'Job is closed',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: AppFonts.OpenSansBold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 115,
                          height: 102,
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
                        SizedBox(width: 16),
                        Column(
                          children: [
                            Row(
                              children: [
                                _buildDetailItem(
                                  'Budget',
                                  '\$ ${job.budget.toInt()}',
                                ),
                                _buildDetailItem(
                                  'Video Quantity',
                                  'QTY ${job.videoQuantity}',
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                _buildDetailItem(
                                  'Video Duration',
                                  '${job.videoTimeline} sec',
                                ),
                                _buildDetailItem(
                                  'Delivery Timeline',
                                  '${job.deliveryTimeline} days',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16),
                    Text(
                      'Updated: ${_formatDate(job.updatedAt)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Objective Section
                    Text('Job Objective', style: AppTextStyles.smallMediumText),
                    SizedBox(height: 12),
                    Text(job.description, style: AppTextStyles.extraSmallText),
                  ],
                ),
              ),

              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About the Brand Section
                    Text(
                      'About the Brand',
                      style: AppTextStyles.smallMediumText,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildCompanyLogo(job, size: 32),
                        SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: Text(
                            job.company,
                            style: AppTextStyles.extraSmallMediumText,
                          ),
                        ),
                        Spacer(),
                        if (job.brandProfile?.createdAt != null)
                          Text(
                            'Member since ${_formatDate(job.brandProfile!.createdAt)}',
                            style: AppTextStyles.extraSmallText,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildStatusBanner(JobModel job) {
    final isApplied = job.interestSubmitted || job.submittedInterest != null;
    final isClosed = job.status == JobStatus.closed;

    if (isApplied && !isClosed) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Color(0xFF6C5CE7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Interest submitted. Waiting for the client\'s response to decide if they\'d like to hire you.',
          style: TextStyle(color: Color(0xFF6C5CE7), fontSize: 14),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildCompanyLogo(JobModel job, {double size = 48}) {
    if (job.brandProfile?.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          job.brandProfile!.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultLogo(job, size);
          },
        ),
      );
    }
    return _buildDefaultLogo(job, size);
  }

  Widget _buildDefaultLogo(JobModel job, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(0xFF0057B3),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          job.company.isNotEmpty
              ? job.company.substring(0, 1).toUpperCase()
              : 'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: size / 3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return SizedBox(
      width: 90.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.extraSmallText.copyWith(
              color: Color(0xff848194),
              fontSize: 10,
            ),
          ),
          SizedBox(height: 4),
          Text(value, style: AppTextStyles.extraSmallMediumText),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final job = controller.currentJobDetails.value;
        if (job == null) return SizedBox.shrink();

        final isApplied =
            job.interestSubmitted || job.submittedInterest != null;
        final isClosed = job.status == JobStatus.closed;
        final isHired = job.interestStatus == InterestStatus.hired;

        // Determine button state
        String buttonTitle;
        Color buttonColor;
        Color textColor;
        VoidCallback? onPressed;

        if (isClosed) {
          buttonTitle = 'Job Closed';
          buttonColor = Colors.grey[300] ?? Colors.grey;
          textColor = Colors.grey[600] ?? Colors.grey;
          onPressed = null;
        } else if (isHired) {
          buttonTitle = 'Hired';
          buttonColor = Colors.green[50] ?? Colors.green.shade50;
          textColor = Colors.green[700] ?? Colors.green;
          onPressed = null;
        } else if (isApplied) {
          buttonTitle = 'Withdraw Interest';
          buttonColor = Colors.red[50] ?? Colors.red.shade50;
          textColor = Colors.red[700] ?? Colors.red;
          onPressed = () {
            controller.withdrawInterest(job.id);
          };
        } else {
          buttonTitle = 'I\'m Interested';
          buttonColor = Colors.black;
          textColor = Colors.white;
          onPressed = () {
            controller.applyForJob(job.id);
          };
        }

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomButton(
            isLoading: controller.isSubmittingInterest.value,
            title: buttonTitle,
            buttonColor: buttonColor,
            textColor: textColor,
            onPressed: onPressed,
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
