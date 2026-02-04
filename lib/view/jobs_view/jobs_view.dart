import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/jobs_view/widget/applied_job.dart';
import 'package:collaby_app/view/jobs_view/widget/new_job.dart';
import 'package:collaby_app/view/jobs_view/widget/saved_job.dart';
import 'package:collaby_app/view/jobs_view/widget/search_field.dart';
import 'package:collaby_app/view_models/controller/job_controller/job_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobsView extends StatelessWidget {
  JobsView({Key? key}) : super(key: key);

  final JobController controller = Get.put(JobController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: controller.currentTabIndex.value,
      child: Builder(
        builder: (context) {
          final tabCtrl = DefaultTabController.of(context);
          tabCtrl.addListener(() {
            if (!tabCtrl.indexIsChanging) {
              controller.changeTab(tabCtrl.index);
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: Text('Jobs', style: AppTextStyles.normalTextBold),
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
                        Expanded(child: Obx(() => _buildTab('New Jobs', 0))),
                        Expanded(child: Obx(() => _buildTab('Saved Jobs', 1))),
                        Expanded(child: Obx(() => _buildTab('Applied', 2))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tab content
                  Expanded(
                    child: Obx(() {
                      switch (controller.currentTabIndex.value) {
                        case 0:
                          return NewJobsTab(controller: controller);
                        case 1:
                          return SavedJobsTab(controller: controller);
                        case 2:
                          return AppliedJobsTab(controller: controller);
                        default:
                          return Container();
                      }
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        controller.changeTab(index);
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




