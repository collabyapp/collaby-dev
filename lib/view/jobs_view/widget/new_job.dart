import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/view/jobs_view/helper/helper_function.dart';
import 'package:collaby_app/view/jobs_view/widget/empty_state.dart';
import 'package:collaby_app/view/jobs_view/widget/job_card.dart';
import 'package:collaby_app/view_models/controller/job_controller/job_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewJobsTab extends StatelessWidget {
  const NewJobsTab({required this.controller});
  final JobController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchJobs(refresh: true),
      child: Obx(() {
        if (controller.isLoading.value && controller.allJobs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = controller.newJobs;
        if (jobs.isEmpty && !controller.isLoading.value) {
          return const EmptyState(
            image: ImageAssets.noNewJobImage,
            message: 'There are currently no jobs. Please check again later.',
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!controller.isLoadingMore.value &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              controller.loadMoreJobs();
            }
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: jobs.length + (controller.hasMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              if (i == jobs.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return JobCard(
                job: jobs[i],
                isSaved: jobs[i].isSaved,
                onTap: () => navigateToJobDetails(jobs[i]),
                onToggleSave: () => controller.toggleSaveJob(jobs[i].id),
              );
            },
          ),
        );
      }),
    );
  }
}
