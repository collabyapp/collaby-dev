import 'dart:io';
import 'package:collaby_app/models/orders_model/vedio_model.dart';
import 'package:collaby_app/view_models/controller/order_controller/deliver_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliverWorkBottomSheet extends StatelessWidget {
  final String orderId;

  const DeliverWorkBottomSheet({Key? key, required this.orderId})
    : super(key: key);

  static void show(String orderId) {
    Get.bottomSheet(
      DeliverWorkBottomSheet(orderId: orderId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeliverWorkController(orderId: orderId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text(
                  'Deliver your work',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Work Detail Label
                  const Text(
                    'Work Detail',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Text Field
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: controller.workDetailController,
                      maxLines: null,
                      expands: true,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: 'Please describe your work in detail',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Video Upload Grid
                  Obx(() {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: controller.uploadedVideos.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Upload Button
                          return _UploadButton(
                            onTap: controller.isUploading.value
                                ? null
                                : controller.pickVideo,
                            isDisabled: controller.isUploading.value,
                          );
                        }

                        // Video Item
                        final video = controller.uploadedVideos[index - 1];
                        return _VideoUploadItem(
                          video: video,
                          onRemove: () => controller.removeVideo(video),
                          onPlay: () => controller.playVideo(video),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Deliver Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              final isLoading = controller.isDelivering.value;
              final isDisabled = controller.isUploading.value || isLoading;

              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isDisabled ? null : controller.deliverWork,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDisabled ? Colors.grey : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Deliver Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ==================== UPLOAD BUTTON WIDGET ====================
class _UploadButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isDisabled;

  const _UploadButton({required this.onTap, this.isDisabled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled ? Colors.grey.shade300 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDisabled ? Colors.grey.shade100 : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey : const Color(0xFF6C3CE3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your work',
              style: TextStyle(
                fontSize: 12,
                color: isDisabled ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== VIDEO UPLOAD ITEM WIDGET ====================
class _VideoUploadItem extends StatelessWidget {
  final VideoUpload video;
  final VoidCallback onRemove;
  final VoidCallback onPlay;

  const _VideoUploadItem({
    required this.video,
    required this.onRemove,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final isUploading = video.progress < 1.0;
    final isUploaded = video.uploadedUrl != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
        image: video.thumbnailPath != null
            ? DecorationImage(
                image: FileImage(File(video.thumbnailPath!)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(isUploading ? 0.5 : 0.3),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          // Uploading Progress
          if (isUploading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Uploading',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(video.progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: video.progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C3CE3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Play Button (when uploaded)
          if (isUploaded && !isUploading)
            Center(
              child: GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),

          // Remove Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
