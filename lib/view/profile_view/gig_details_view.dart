import 'package:cached_network_image/cached_network_image.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view_models/controller/profile_controller/gig_details_controller.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_controller.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GigDetailView extends StatelessWidget {
  const GigDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(GigDetailController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gig Detail'),
        actions: [
          Obx(
            () => GestureDetector(
              onTap: c.showStatusBottomSheet,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: c.gigStatus.value == 'Active'
                      ? Color(0xff5DA160).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      c.gigStatus.value,
                      style: TextStyle(
                        color: c.gigStatus.value == 'Active'
                            ? Color(0xff5DA160)
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: AppFonts.OpenSansSemiBold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: c.gigStatus.value == 'Active'
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (c.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // No data state
        if (c.gigDetail.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Failed to load gig details'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              _gigThumbnail(c),

              const SizedBox(height: 16),

              // Header card (title)
              _headerCard(c),

              const SizedBox(height: 12),

              // Top tags (categories)
              if (c.categories.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: c.categories.map((t) => _chip(t)).toList(),
                ),

              const SizedBox(height: 16),

              // Duration tabs
              if (c.durations.isNotEmpty) _durationTabs(c),

              const SizedBox(height: 12),

              // Pricing & inclusions
              _pricingCard(c),

              const SizedBox(height: 20),

              // Description
              _sectionTitle('Description'),
              const SizedBox(height: 8),
              Text(c.description, style: AppTextStyles.extraSmallText),

              const SizedBox(height: 20),

              // Video Style
              if (c.videoStyles.isNotEmpty) ...[
                _sectionTitle('Video Style'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: c.videoStyles.map((t) => _chip(t)).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Requirements
              if (c.requirements.isNotEmpty) ...[
                _sectionTitle('Requirements'),
                const SizedBox(height: 8),
                ...c.requirements.asMap().entries.map((e) {
                  final idx = e.key + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '$idx. ${e.value}',
                      style: AppTextStyles.extraSmallText,
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],

              // Gallery
              if (c.gallery.isNotEmpty) ...[
                _sectionTitle('Gallery'),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: c.gallery.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (_, i) => _galleryTile(c.gallery[i]),
                ),
                const SizedBox(height: 24),
              ],

              // Edit Button
              // CustomButton(
              //   title: 'Edit Gig',
              //   onPressed: () {
              //     c.editGig();
              //   },
              // ),

              // Add this at the bottom of your build method in GigDetailView, after the Gallery section

              // Edit Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomButton(
                    title: 'Edit Gig',
                    onPressed: () {
                      Get.toNamed(
                        RouteName.createGigView,
                        arguments: {
                          'isEditMode': true,
                          'gigId': c.gigId,
                          'gigData': c.gigDetail.value,
                        },
                      );
                    },
                  ),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Navigate to edit gig
                  //     Get.toNamed(
                  //       RouteName.createGigView,
                  //       arguments: {
                  //         'isEditMode': true,
                  //         'gigId': c.gigId,
                  //         'gigData': c.gigDetail.value,
                  //       },
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color(0xff4C1CAE),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  //   child: Text(
                  //     'Edit Gig',
                  //     style: AppTextStyles.normalTextBold.copyWith(
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ====== Widget pieces ======

  Widget _gigThumbnail(GigDetailController c) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: c.gigThumbnail,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _headerCard(GigDetailController c) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(c.title, style: AppTextStyles.h6)],
      ),
    );
  }

  Widget _durationTabs(GigDetailController c) {
    final items = c.durations;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
      child: Row(
        children: items.map((label) {
          final selected = c.selectedDuration.value == label;
          return Expanded(
            child: GestureDetector(
              onTap: () => c.selectDuration(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _pricingCard(GigDetailController c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(ImageAssets.dollarIcon, width: 16),
              const SizedBox(width: 8),
              Text(
                '\$ ${c.selectedPrice}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...c.inclusions.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 18, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t, style: AppTextStyles.extraSmallText)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _tinyInfo(icon: Icons.access_time, text: c.deliveryText),
              const SizedBox(width: 12),
              Row(
                children: [
                  Image.asset(ImageAssets.revisionIcon, width: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${c.numberOfRevisions} Revision',
                    style: AppTextStyles.extraSmallMediumText,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tinyInfo({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xffFBBB00)),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.extraSmallMediumText),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(t, style: AppTextStyles.normalTextBold),
  );

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xff816CED),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: AppTextStyles.extraSmallText.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _galleryTile(dynamic galleryItem) {
    final bool isVideo = galleryItem.isVideo == true;
    final String url = (galleryItem.url ?? '') as String; // video or image url
    final String thumbUrl =
        (galleryItem.thumbnail ?? '') as String; // API-provided thumbnail

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Use thumbnail if available; otherwise fall back to main url
          CachedNetworkImage(
            imageUrl: (thumbUrl.isNotEmpty ? thumbUrl : url),
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: Icon(
                isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                color: Colors.grey,
              ),
            ),
            fadeInDuration: const Duration(milliseconds: 200),
          ),

          // Video overlay (dim + play icon)
          if (isVideo) ...[
            Container(color: Colors.black.withOpacity(0.10)),
            Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 30),
              ),
            ),
          ],

          // Tap action
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isVideo) {
                  // Open the video player with the video URL
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
