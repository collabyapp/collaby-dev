import 'package:collaby_app/models/jobs_model/job_model.dart';
import 'package:collaby_app/view/jobs_view/job_details_view.dart';
import 'package:get/get.dart';

void navigateToJobDetails(JobModel job) {
  Get.to(() => JobDetailsView(jobId: job.id), arguments: job);
}

String formatDate(DateTime date) {
  const months = [
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
  return '${date.day} ${months[date.month - 1]}, ${date.year}';
}
