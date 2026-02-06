import 'dart:developer';
import 'dart:io';
import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/models/orders_model/vedio_model.dart';
import 'package:collaby_app/repository/order_repository/order_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_controller.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class DeliverWorkController extends GetxController {
  final String orderId;
  final workDetailController = TextEditingController();
  final uploadedVideos = <VideoUpload>[].obs;
  final isUploading = false.obs;
  final isDelivering = false.obs;
  final _repository = OrdersRepository();

  DeliverWorkController({required this.orderId});

  // @override
  // void onClose() {
  //   workDetailController.dispose();
  //   super.onClose();
  // }

  Future<void> pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        final file = File(video.path);
        final fileSize = await file.length();
        final fileName = video.path.split('/').last;

        final videoUpload = VideoUpload(
          file: file,
          progress: 0.0,
          fileName: fileName,
          fileSize: fileSize,
          fileType: 'video/mp4',
        );

        uploadedVideos.add(videoUpload);

        // Upload video without awaiting - allows multiple uploads
        _uploadVideo(videoUpload);
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to pick video: $e');
    }
  }

  Future<void> _uploadVideo(VideoUpload videoUpload) async {
    isUploading.value = true;

    try {
      // Generate thumbnail first
      final thumbnailPath = await _generateThumbnail(videoUpload.file.path);

      // Update the specific video with thumbnail
      final index1 = uploadedVideos.indexWhere(
        (v) => v.file.path == videoUpload.file.path,
      );
      if (index1 != -1) {
        uploadedVideos[index1] = uploadedVideos[index1].copyWith(
          thumbnailPath: thumbnailPath,
          progress: 0.2,
        );
        uploadedVideos.refresh();
      }

      // Upload the video file
      final uploadResult = await NetworkApiServices().uploadAnyFile(
        filePath: videoUpload.file.path,
      );

      // Update with uploaded URL
      final index2 = uploadedVideos.indexWhere(
        (v) => v.file.path == videoUpload.file.path,
      );
      if (index2 != -1 && uploadResult.isNotEmpty) {
        uploadedVideos[index2] = uploadedVideos[index2].copyWith(
          uploadedUrl: uploadResult,
          progress: 1.0,
        );
        uploadedVideos.refresh();

        Utils.snackBar('Success', 'Video uploaded successfully!');
      }
    } catch (e) {
      // Remove failed upload
      final indexToRemove = uploadedVideos.indexWhere(
        (v) => v.file.path == videoUpload.file.path,
      );
      if (indexToRemove != -1) {
        uploadedVideos.removeAt(indexToRemove);
      }
      Utils.snackBar('Upload Failed', 'Failed to upload video: $e');
    } finally {
      // Check if there are any videos still uploading
      final hasUploadingVideos = uploadedVideos.any((v) => v.progress < 1.0);
      if (!hasUploadingVideos) {
        isUploading.value = false;
      }
    }
  }

  Future<String?> _generateThumbnail(String videoPath) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.PNG,
        maxWidth: 400,
        quality: 75,
      );

      if (uint8list != null) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'thumb_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(uint8list);
        return file.path;
      }
      return null;
    } catch (e) {
      log('Error generating thumbnail: $e');
      return null;
    }
  }

  void removeVideo(VideoUpload video) {
    uploadedVideos.remove(video);
  }

  void playVideo(VideoUpload video) {
    final url = video.uploadedUrl;
    if (url == null || url.isEmpty) {
      Utils.snackBar('Error', 'Video is still uploading');
      return;
    }

    if (Get.isRegistered<VideoPlayController>()) {
      Get.delete<VideoPlayController>();
    }

    Get.to(
      () => const VideoPlayerPage(),
      binding: BindingsBuilder(() {
        Get.put(VideoPlayController(url));
      }),
    );
  }

  // void playVideo(VideoUpload video) {
  //   if (video.uploadedUrl != null) {
  //     openVideoPlayerGetX(video.uploadedUrl!);
  //   } else {
  //     Utils.snackBar(
  //       'Error',
  //       'Video is still uploading',

  //     );
  //   }
  // }

  Future<void> deliverWork() async {
    // Validation
    if (workDetailController.text.trim().isEmpty && uploadedVideos.isEmpty) {
      Utils.snackBar(
        'Error',
        'Please add work details or upload at least one video',
      );
      return;
    }

    // Check if any video is still uploading
    final hasUploadingVideos = uploadedVideos.any((v) => v.progress < 1.0);
    if (hasUploadingVideos) {
      Utils.snackBar('Error', 'Please wait for all videos to finish uploading');
      return;
    }

    // Check if all videos have URLs
    final hasInvalidVideos = uploadedVideos.any((v) => v.uploadedUrl == null);
    if (hasInvalidVideos) {
      Utils.snackBar(
        'Error',
        'Some videos failed to upload. Please remove and try again.',
      );
      return;
    }

    isDelivering.value = true;

    try {
      // Prepare delivery files
      final deliveryFiles = uploadedVideos
          .map(
            (video) => {
              'name': video.fileName,
              'type': video.fileType,
              'url': video.uploadedUrl!,
              'size': video.fileSize,
            },
          )
          .toList();

      // Call delivery API
      final response = await _repository.deliverOrder(
        orderId,
        workDescription: workDetailController.text.trim(),
        deliveryFiles: deliveryFiles,
      );

      if (response != null) {
        Get.back(); // Close bottom sheet
        Get.offAllNamed(
          RouteName.bottomNavigationView,
          arguments: {'index': 1},
        );
        Utils.snackBar('Success', 'Work delivered successfully!');
      } else {
        Utils.snackBar('Error', 'Failed to deliver work. Please try again.');
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to deliver work: $e');
    } finally {
      isDelivering.value = false;
    }
  }
}

