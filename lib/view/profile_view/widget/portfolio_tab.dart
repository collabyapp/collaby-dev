import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/models/profile_model/profile_model.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/profile_controller/profile_controller.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_controller.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PortfolioTab extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.portfolioItems;

      if (controller.isLoadingProfile.value && items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('no_portfolio_items'.tr, style: AppTextStyles.normalText),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ugc_portfolio'.tr, style: AppTextStyles.normalTextBold),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _PortfolioTile(
                    item: items[i],
                    onHide: () => controller.hidePortfolioItem(items[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({required this.item, required this.onHide});
  final PortfolioItem item;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final isVideo = item.deliveryFile.type.toLowerCase().startsWith('video/');
    final thumbUrl = item.deliveryFile.thumbnail; // from API
    final videoUrl = item.deliveryFile.url;

    return GestureDetector(
      onTap: () {
        if (!isVideo) return;
        if (Get.isRegistered<VideoPlayController>()) {
          Get.delete<VideoPlayController>();
        }
        Get.to(
          () => const VideoPlayerPage(),
          binding: BindingsBuilder(() {
            Get.put(VideoPlayController(videoUrl));
          }),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _NetworkThumb(url: thumbUrl),
            ),
            if (isVideo)
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onHide,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkThumb extends StatelessWidget {
  const _NetworkThumb({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();

    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => _skeleton(),
      errorWidget: (_, __, ___) => _placeholder(),
      fadeInDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.movie, size: 32, color: Colors.black45),
    );
  }

  Widget _skeleton() => Container(color: Colors.grey[300]);
}
