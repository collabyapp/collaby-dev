import 'package:collaby_app/models/jobs_model/job_model.dart';
import 'package:collaby_app/repository/job_repository/job_repository.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:get/get.dart';

class JobController extends GetxController {
  final JobRepository _repository = JobRepository();

  // Observable variables
  final RxList<JobModel> allJobs = <JobModel>[].obs;
  final RxList<JobModel> savedJobs = <JobModel>[].obs;
  final RxList<ApplicationModel> appliedJobs = <ApplicationModel>[].obs;
  final Rx<JobModel?> currentJobDetails = Rx<JobModel?>(null);

  final RxInt currentTabIndex = 0.obs;
  final Rx<JobCategory> selectedCategory = JobCategory.all.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isSubmittingInterest = false.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;
  final int pageLimit = 10;

  // Computed values - Remove local search filtering
  List<JobModel> get newJobs {
    return allJobs
        .where(
          (job) =>
              job.status == JobStatus.open && job.submittedInterest == null,
        )
        .toList();
  }

  List<JobModel> get savedJobsList =>
      allJobs.where((job) => job.isSaved).toList();

  List<ApplicationModel> get appliedJobsList {
    final jobsWithInterest = allJobs
        .where((job) => job.submittedInterest != null)
        .map(
          (job) => ApplicationModel(
            id: job.id,
            jobId: job.id,
            title: job.title,
            submittedAt: job.submittedInterest!.date,
            status: job.submittedInterest!.status,
            companyLogo: job.companyLogo,
            imageUrl: job.imageUrl,
            budget: job.budget,
            videoQuantity: job.videoQuantity,
            videoTimeline: job.videoTimeline,
            deliveryTimeline: job.deliveryTimeline,
            description: job.description,
          ),
        )
        .toList();

    return jobsWithInterest;
  }

  @override
  void onInit() {
    super.onInit();
    fetchJobs(refresh: true);
  }

  // Fetch single job details
  Future<void> fetchJobDetails(String jobId) async {
    try {
      isLoadingDetails.value = true;

      final response = await _repository.fetchJobDetails(jobId);

      if (response['success']) {
        final jobData = response['data'];
        if (jobData != null) {
          currentJobDetails.value = JobModel.fromJson(jobData);

          // Update the job in allJobs list if it exists
          final index = allJobs.indexWhere((j) => j.id == jobId);
          if (index != -1) {
            allJobs[index] = currentJobDetails.value!;
          }
        }
      } else {
        _showError(response['message']);
      }
    } catch (e) {
      _showError('Failed to load job details: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  // Tab management
  void changeTab(int index) {
    currentTabIndex.value = index;

    // Clear search when switching tabs
    searchQuery.value = '';

    // Fetch appropriate data based on tab
    switch (index) {
      case 0: // New Jobs
        if (allJobs.isEmpty) {
          fetchJobs(refresh: true);
        }
        break;
      case 1: // Saved Jobs
        fetchSavedJobs(refresh: true);
        break;
      case 2: // Applied Jobs
        fetchAppliedJobs(refresh: true);
        break;
    }
  }

  // Category filter
  void changeCategory(JobCategory category) {
    selectedCategory.value = category;
  }

  // Search functionality - Calls API instead of local filtering
  void updateSearchQuery(String query) {
    searchQuery.value = query;

    // Debounce search to avoid too many API calls
    // You can add a debounce timer here if needed
    fetchJobs(refresh: true, search: query);
  }

  // Fetch jobs from API
  Future<void> fetchJobs({bool refresh = false, String? search}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    if (!hasMore.value) return;

    try {
      if (refresh) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final response = await _repository.fetchJobs(
        page: currentPage.value,
        limit: pageLimit,
        search: search ?? searchQuery.value,
      );

      if (response['success']) {
        final List<dynamic> jobsData = response['data'];
        final List<JobModel> fetchedJobs = jobsData
            .map((json) => JobModel.fromJson(json))
            .toList();

        if (refresh) {
          allJobs.value = fetchedJobs;
        } else {
          allJobs.addAll(fetchedJobs);
        }

        totalPages.value = response['totalPages'];
        hasMore.value = currentPage.value < totalPages.value;

        if (hasMore.value) {
          currentPage.value++;
        }
      } else {
        _showError(response['message']);
      }
    } catch (e) {
      _showError('Failed to load jobs: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Fetch saved jobs
  Future<void> fetchSavedJobs({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
    }

    try {
      isLoading.value = true;

      final response = await _repository.fetchJobs(
        page: currentPage.value,
        limit: pageLimit,
        showFavs: true,
      );

      if (response['success']) {
        final List<dynamic> jobsData = response['data'];
        final List<JobModel> fetchedJobs = jobsData
            .map((json) => JobModel.fromJson(json))
            .toList();

        if (refresh) {
          // Update allJobs with saved status
          for (var job in fetchedJobs) {
            final index = allJobs.indexWhere((j) => j.id == job.id);
            if (index != -1) {
              allJobs[index] = job;
            } else {
              allJobs.add(job);
            }
          }
        }
      } else {
        _showError(response['message']);
      }
    } catch (e) {
      _showError('Failed to load saved jobs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch applied jobs
  Future<void> fetchAppliedJobs({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
    }

    try {
      isLoading.value = true;

      final response = await _repository.fetchJobs(
        page: currentPage.value,
        limit: pageLimit,
        showSubmittedInterest: true,
      );

      if (response['success']) {
        final List<dynamic> jobsData = response['data'];
        final List<JobModel> fetchedJobs = jobsData
            .map((json) => JobModel.fromJson(json))
            .toList();

        if (refresh) {
          // Update allJobs with application status
          for (var job in fetchedJobs) {
            final index = allJobs.indexWhere((j) => j.id == job.id);
            if (index != -1) {
              allJobs[index] = job;
            } else {
              allJobs.add(job);
            }
          }
        }
      } else {
        _showError(response['message']);
      }
    } catch (e) {
      _showError('Failed to load applied jobs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle save job with API
  final Set<String> _favInFlight = <String>{};
  final Set<String> _interestInFlight = <String>{};

  Future<void> toggleSaveJob(String jobId) async {
    if (_favInFlight.contains(jobId)) return;
    _favInFlight.add(jobId);

    try {
      final index = allJobs.indexWhere((j) => j.id == jobId);
      if (index == -1) {
        // Check if it's the current job details
        if (currentJobDetails.value?.id == jobId) {
          final current = currentJobDetails.value!;
          final wasSaved = current.isSaved;

          currentJobDetails.value = current.copyWith(isSaved: !wasSaved);

          final response = wasSaved
              ? await _repository.removeFromFavorites(jobId)
              : await _repository.addToFavorites(jobId);

          if (!response['success']) {
            currentJobDetails.value = current.copyWith(isSaved: wasSaved);
            _showError(
              response['message'] ?? 'Failed to update favorite status',
            );
          }
        }
        return;
      }

      final current = allJobs[index];
      final wasSaved = current.isSaved;

      allJobs[index] = current.copyWith(isSaved: !wasSaved);

      // Also update currentJobDetails if it's the same job
      if (currentJobDetails.value?.id == jobId) {
        currentJobDetails.value = allJobs[index];
      }

      final response = wasSaved
          ? await _repository.removeFromFavorites(jobId)
          : await _repository.addToFavorites(jobId);

      if (!response['success']) {
        allJobs[index] = current.copyWith(isSaved: wasSaved);
        if (currentJobDetails.value?.id == jobId) {
          currentJobDetails.value = allJobs[index];
        }
        _showError(response['message'] ?? 'Failed to update favorite status');
      }
    } catch (_) {
      final idx = allJobs.indexWhere((j) => j.id == jobId);
      if (idx != -1) {
        final original = allJobs[idx];
        allJobs[idx] = original.copyWith(isSaved: !original.isSaved);
        if (currentJobDetails.value?.id == jobId) {
          currentJobDetails.value = allJobs[idx];
        }
      }
      _showError('Failed to update favorite status');
    } finally {
      _favInFlight.remove(jobId);
    }
  }

  // Apply for job
  Future<void> applyForJob(String jobId) async {
    if (_interestInFlight.contains(jobId)) return;
    _interestInFlight.add(jobId);

    try {
      isSubmittingInterest.value = true;

      final response = await _repository.submitInterest(jobId);

      if (response['success']) {
        // Update job with submitted interest
        final index = allJobs.indexWhere((job) => job.id == jobId);
        if (index != -1) {
          allJobs[index] = allJobs[index].copyWith(
            interestSubmitted: true,
            submittedInterest: SubmittedInterest(
              status: 'pending',
              date: DateTime.now(),
            ),
          );
        }

        // Also update currentJobDetails
        if (currentJobDetails.value?.id == jobId) {
          currentJobDetails.value = currentJobDetails.value!.copyWith(
            interestSubmitted: true,
            submittedInterest: SubmittedInterest(
              status: 'pending',
              date: DateTime.now(),
            ),
          );
        }

        Utils.snackBar('success'.tr, 'job_interest_submitted_success'.tr);
        Get.back();
      } else {
        _showError(response['message']);
      }
    } catch (e) {
      _showError('Failed to submit application: $e');
    } finally {
      isSubmittingInterest.value = false;
      _interestInFlight.remove(jobId);
    }
  }

  // Withdraw interest from job
  Future<void> withdrawInterest(String jobId) async {
    if (_interestInFlight.contains(jobId)) return;
    _interestInFlight.add(jobId);

    try {
      isSubmittingInterest.value = true;

      final response = await _repository.withdrawInterest(jobId);
      // Check for both success field and error field
      if (response['success'] == true ||
          response['statusCode'] == 200 ||
          response['statusCode'] == 201) {
        // Update job - remove submitted interest
        final index = allJobs.indexWhere((job) => job.id == jobId);
        if (index != -1) {
          allJobs[index] = allJobs[index].copyWith(
            interestSubmitted: false,
            submittedInterest: null,
          );
        }

        // Also update currentJobDetails
        if (currentJobDetails.value?.id == jobId) {
          currentJobDetails.value = currentJobDetails.value!.copyWith(
            interestSubmitted: false,
            submittedInterest: null,
          );
        }

        Utils.snackBar('success'.tr, 'job_interest_withdrawn_success'.tr);
        if (Get.key.currentState?.canPop() ?? false) {
          Get.back();
        }
        fetchAppliedJobs(refresh: true);
      } else {
        // Handle error - show the message from API
        _showError('job_interest_withdrawn_failed'.tr);
      }
    } catch (e) {
      _showError('job_interest_withdrawn_failed'.tr);
    } finally {
      isSubmittingInterest.value = false;
      _interestInFlight.remove(jobId);
    }
  }

  // Load more jobs (for pagination)
  Future<void> loadMoreJobs() async {
    if (!isLoadingMore.value && hasMore.value) {
      await fetchJobs();
    }
  }

  // Refresh current tab
  Future<void> refreshCurrentTab() async {
    switch (currentTabIndex.value) {
      case 0:
        await fetchJobs(refresh: true);
        break;
      case 1:
        await fetchSavedJobs(refresh: true);
        break;
      case 2:
        await fetchAppliedJobs(refresh: true);
        break;
    }
  }

  void _showError(String message) {
    Utils.snackBar('error'.tr, message);
  }
}
