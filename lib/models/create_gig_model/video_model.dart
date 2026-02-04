import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoItem {
  final String id;
  String path; // Can be local path or S3 URL
  
  // Video player controller (only used for local preview, can be null)
  final Rx<VideoPlayerController?> controller = Rx<VideoPlayerController?>(null);
  
  // S3 URLs
  final RxnString videoUrl = RxnString(); // Video URL from S3
  final RxnString thumbnailUrl = RxnString(); // Thumbnail URL from S3
  
  // Upload state
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxString uploadStatus = 'Preparing...'.obs;
  
  // Playback state
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  VideoItem({
    required this.id,
    required this.path,
  });

  // Check if video is ready to use
  bool get isReady => 
      !isUploading.value && 
      videoUrl.value != null && 
      videoUrl.value!.isNotEmpty;
}