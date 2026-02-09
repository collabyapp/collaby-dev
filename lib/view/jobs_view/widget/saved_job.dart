import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/view/jobs_view/helper/helper_function.dart';
import 'package:collaby_app/view/jobs_view/widget/empty_state.dart';
import 'package:collaby_app/view/jobs_view/widget/job_card.dart';
import 'package:collaby_app/view_models/controller/job_controller/job_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class SavedJobsTab extends StatelessWidget {
  const SavedJobsTab({required this.controller});
  final JobController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchSavedJobs(refresh: true),
      child: Obx(() {
        if (controller.isLoading.value && controller.savedJobsList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final saved = controller.savedJobsList;
        if (saved.isEmpty) {
          return EmptyState(
            image: ImageAssets.noSavedJobImage,
            message: 'jobs_empty_saved'.tr,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: saved.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => JobCard(
            job: saved[i],
            isSaved: true,
            onTap: () => navigateToJobDetails(saved[i]),
            onToggleSave: () => controller.toggleSaveJob(saved[i].id),
          ),
        );
      }),
    );
  }
}
