import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/jobs_view/widget/applied_job.dart';
import 'package:collaby_app/view/jobs_view/widget/new_job.dart';
import 'package:collaby_app/view/jobs_view/widget/saved_job.dart';
import 'package:collaby_app/view/jobs_view/widget/search_field.dart';
import 'package:collaby_app/view_models/controller/job_controller/job_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobsView extends StatefulWidget {
  const JobsView({Key? key}) : super(key: key);

  @override
  State<JobsView> createState() => _JobsViewState();
}

class _JobsViewState extends State<JobsView> {
  final JobController controller = Get.put(JobController());
  late final PageController _pageController;
  Worker? _tabWorker;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: controller.currentTabIndex.value);
    _tabWorker = ever<int>(controller.currentTabIndex, (index) {
      if (!_pageController.hasClients) return;
      final current = _pageController.page?.round() ?? 0;
      if (current == index) return;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _tabWorker?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('jobs_title'.tr, style: AppTextStyles.normalTextBold),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: SearchField(
                onChanged: controller.updateSearchQuery,
              ),
            ),

            // Custom tabs
            Container(
              decoration: BoxDecoration(
                color: Color(0xffF4F7FF),
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  Expanded(child: Obx(() => _buildTab('jobs_tab_new'.tr, 0))),
                  Expanded(child: Obx(() => _buildTab('jobs_tab_saved'.tr, 1))),
                  Expanded(child: Obx(() => _buildTab('jobs_tab_applied'.tr, 2))),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Swipe content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if (controller.currentTabIndex.value != index) {
                    controller.changeTab(index);
                  }
                },
                children: [
                  NewJobsTab(controller: controller),
                  SavedJobsTab(controller: controller),
                  AppliedJobsTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        controller.changeTab(index);
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: controller.currentTabIndex.value == index
                  ? Colors.black
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.OpenSansRegular,
              fontWeight: controller.currentTabIndex.value == index
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: controller.currentTabIndex.value == index
                  ? Colors.black
                  : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}


