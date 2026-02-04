import 'package:collaby_app/view_models/services/vedio_player_service/video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
class VideoPlayerPage extends GetView<VideoPlayController> {
  const VideoPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Obx(() {
          // Error state
          final err = controller.errorText.value;
          if (err != null) {
            return _errorView(
              err,
              onRetry: () {
                Get.back();
                Get.to(
                  () => const VideoPlayerPage(),
                  binding: BindingsBuilder(() {
                    Get.put(VideoPlayController(controller.url));
                  }),
                );
              },
            );
          }

          // Loading state
          if (!controller.initialized || controller.chewieController == null) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading video...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            );
          }

          // Video player with Chewie
          return AspectRatio(
            aspectRatio: controller.videoPlayerController.value.aspectRatio,
            child: Chewie(controller: controller.chewieController!),
          );
        }),
      ),
    );
  }

  Widget _errorView(String msg, {required VoidCallback onRetry}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

