import 'dart:io';

import 'package:collaby_app/models/create_gig_model/video_model.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/gig_creation_controller/create_gig_controller.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_controller.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryStep extends GetView<CreateGigController> {
  const GalleryStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Portfolio & Intro Video', style: AppTextStyles.h6Bold),
          const SizedBox(height: 8),
          Text(
            'Upload 1 intro video (required). This will be your profile cover.\nYou can add up to 3 more portfolio videos.',
            style: AppTextStyles.extraSmallText.copyWith(color: const Color(0xff77787A)),
          ),
          const SizedBox(height: 18),

          // Intro (required)
          Text('Intro video (required)', style: AppTextStyles.smallText.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),

          SizedBox(
            height: 180,
            child: Obx(() {
              final hasIntro = controller.galleryVideos.isNotEmpty;
              if (!hasIntro) {
                return _AddVideoCard(
                  title: 'Add intro video',
                  subtitle: 'This video will appear in search as your cover',
                  onTap: controller.pickVideoFromGallery,
                );
              }

              final intro = controller.galleryVideos.first;
              return _IntroVideoTile(
                key: ValueKey('intro_${intro.id}'),
                item: intro,
              );
            }),
          ),

          const SizedBox(height: 18),

          // Portfolio (optional)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Portfolio videos (optional)', style: AppTextStyles.smallText.copyWith(fontWeight: FontWeight.w700)),
              Obx(() {
                final count = controller.portfolioVideos.length;
                return Text(
                  '$count / 3',
                  style: AppTextStyles.extraSmallText.copyWith(color: const Color(0xff77787A)),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child: Obx(() {
              final portfolio = controller.portfolioVideos;
              final canAdd = controller.galleryVideos.length < controller.maxVideosAllowed;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 12,
                ),
                itemCount: 4, // fixed: 4 slots => 3 portfolio + 1 add slot (or placeholders)
                itemBuilder: (context, index) {
                  // We want exactly 3 portfolio slots + 1 add slot.
                  // index 0..2 => portfolio slots
                  // index 3 => add slot
                  if (index < 3) {
                    if (index < portfolio.length) {
                      return _VideoTile(
                        key: ValueKey(portfolio[index].id),
                        item: portfolio[index],
                        isIntro: false,
                      );
                    }
                    // Empty placeholder tile
                    return _EmptyTile();
                  }

                  // Add slot
                  return _AddVideoTile(
                    isDisabled: !canAdd,
                    onTap: controller.pickVideoFromGallery,
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 18),

          // Declaration
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: controller.toggleDeclaration,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: controller.isDeclarationAccepted.value ? AppColor.primaryColor : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: controller.isDeclarationAccepted.value ? AppColor.primaryColor : Colors.transparent,
                    ),
                    child: controller.isDeclarationAccepted.value
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'I declare that these materials were created by myself or by my team and do not infringe on any 3rd party rights. I understand that the illegal use of digital assets is against UGC Terms of Service and may result in blocking my account.',
                    style: AppTextStyles.extraSmallText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddVideoCard extends StatelessWidget {
  const _AddVideoCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          color: const Color(0xffF4F7FF),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xff4C1CAE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: AppTextStyles.normalTextMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.extraSmallText.copyWith(color: const Color(0xff77787A)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroVideoTile extends StatefulWidget {
  const _IntroVideoTile({required super.key, required this.item});
  final VideoItem item;

  @override
  State<_IntroVideoTile> createState() => _IntroVideoTileState();
}

class _IntroVideoTileState extends State<_IntroVideoTile> {
  late CreateGigController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CreateGigController>();
  }

  @override
  Widget build(BuildContext context) {
    return _VideoTile(
      key: widget.key,
      item: widget.item,
      isIntro: true,
    );
  }
}

class _VideoTile extends StatefulWidget {
  const _VideoTile({required super.key, required this.item, required this.isIntro});
  final VideoItem item;
  final bool isIntro;

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  late CreateGigController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CreateGigController>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openVideoPlayer(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.isIntro ? const Color(0xff4C1CAE) : Colors.grey.shade300, width: widget.isIntro ? 2 : 1),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox.expand(
                child: Obx(() {
                  if (widget.item.isUploading.value) {
                    return _UploadingIndicator(item: widget.item);
                  }

                  final thumbUrl = widget.item.thumbnailUrl.value;
                  if (thumbUrl != null && thumbUrl.isNotEmpty) {
                    return _buildThumbnail(thumbUrl);
                  }

                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.video_library, size: 40, color: Colors.grey),
                    ),
                  );
                }),
              ),
            ),

            // Intro badge
            if (widget.isIntro)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xff4C1CAE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'COVER',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

            // Play overlay
            Obx(() {
              if (widget.item.isUploading.value) return const SizedBox.shrink();

              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      radius: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 35, color: Color(0xff816CED)),
                    ),
                  ),
                ),
              );
            }),

            // Duration badge
            Positioned(
              bottom: 8,
              right: 8,
              child: Obx(() {
                final dur = widget.item.duration.value;
                if (dur == Duration.zero) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    controller.formatDuration(dur),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                );
              }),
            ),

            // Remove button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _safeRemoveVideo(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.black, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String thumbnailUrl) {
    final isUrl = thumbnailUrl.startsWith('http://') || thumbnailUrl.startsWith('https://');

    return isUrl
        ? Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff816CED)),
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _thumbnailErrorWidget(),
          )
        : Image.file(
            File(thumbnailUrl),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _thumbnailErrorWidget(),
          );
  }

  Widget _thumbnailErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam, color: Colors.grey, size: 32),
          const SizedBox(height: 8),
          Text('Video Ready', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
        ],
      ),
    );
  }

  void _openVideoPlayer() {
    try {
      if (widget.item.isUploading.value) {
        Utils.snackBar('Please Wait', 'Video is still uploading...');
        return;
      }

      final videoUrl = widget.item.videoUrl.value ?? widget.item.path;

      Get.to(
        () => const VideoPlayerPage(),
        binding: BindingsBuilder(() {
          Get.put(VideoPlayController(videoUrl));
        }),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      debugPrint('Error opening video player: $e');
      Utils.snackBar('Error', 'Unable to open video player');
    }
  }

  void _safeRemoveVideo() {
    try {
      // Block removing intro if it is uploading? Up to you; we allow removing.
      controller.removeVideo(widget.item.id);
    } catch (e) {
      debugPrint('Error removing video: $e');
    }
  }
}

class _UploadingIndicator extends StatelessWidget {
  const _UploadingIndicator({required this.item});
  final VideoItem item;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pct = (item.uploadProgress.value * 100).toInt();
      final status = item.uploadStatus.value;

      return Container(
        color: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff4C1CAE)),
            ),
            const SizedBox(height: 12),
            Text(
              status,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$pct%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff4C1CAE)),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: item.uploadProgress.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AddVideoTile extends StatelessWidget {
  const _AddVideoTile({this.isDisabled = false, required this.onTap});
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled ? Colors.grey.shade200 : Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
          color: isDisabled ? Colors.grey.shade50 : Colors.transparent,
        ),
        child: Center(
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey : const Color(0xff4C1CAE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: isDisabled ? 16 : 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.grey.shade50,
      ),
      child: const Center(
        child: Icon(Icons.video_library_outlined, size: 28, color: Colors.grey),
      ),
    );
  }
}



