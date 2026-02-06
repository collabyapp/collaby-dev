import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:chewie/chewie.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPlayController extends GetxController {
  VideoPlayController(this.url);
  final String url;

  late final vp.VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  // Reactive state
  final initializedRx = false.obs;
  final errorText = RxnString();

  @override
  bool get initialized => initializedRx.value;

  @override
  void onInit() {
    super.onInit();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      // Initialize video player
      videoPlayerController = vp.VideoPlayerController.networkUrl(
        Uri.parse(url),
      );

      await videoPlayerController.initialize();
      // Initialize Chewie controller
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
        aspectRatio: videoPlayerController.value.aspectRatio,
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        // Customization options
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.purple,
          handleColor: Colors.purple,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.purpleAccent,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
        ),
        showControlsOnInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
      );

      initializedRx.value = true;
    } on TimeoutException {
      errorText.value = 'Video took too long to load. Please try again.';
      initializedRx.value = false;
    } catch (e) {
      errorText.value = 'Failed to load video: $e';
      initializedRx.value = false;
    }
  }

  @override
  void onClose() {
    chewieController?.dispose();
    videoPlayerController.dispose();
    super.onClose();
  }
}
class VideoThumbsController extends GetxController {
  final _thumbs = <String, String?>{}.obs; // url -> local image path

  String? pathFor(String url) {
    if (!_thumbs.containsKey(url)) _generate(url);
    return _thumbs[url];
  }

  Future<void> _generate(String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final path = await VideoThumbnail.thumbnailFile(
        video: url,
        thumbnailPath: dir.path, // directory; library creates the file
        imageFormat: ImageFormat.JPEG,
        maxHeight: 160,
        quality: 50,
      );
      _thumbs[url] = path;
    } catch (_) {
      _thumbs[url] = null; // mark as failed → fallback icon
    }
    _thumbs.refresh();
  }
}
