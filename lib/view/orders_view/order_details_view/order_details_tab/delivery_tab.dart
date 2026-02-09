import 'dart:io';
import 'package:collaby_app/models/orders_model/orders_models.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/order_controller/order_details_controller.dart';
import 'package:collaby_app/view_models/services/downlaod_file_service/downlaod_file_service.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_controller.dart';
import 'package:collaby_app/view_models/services/vedio_player_service/video_player_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget buildDeliveryTab(OrderDetailController controller) {
  return Obx(() {
    final isLoading = controller.isDeliveriesLoading.value;
    final deliveries = controller.deliveries;
    final revisionRequest = controller.revisionRequest.value;

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (deliveries.isEmpty && revisionRequest == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImageAssets.noOrderImage, width: 58),
            SizedBox(height: 16),

            SizedBox(height: 8),
            Text(
              'All deliveries you’ve submitted will\n appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.extraSmallText,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: deliveries.length + (revisionRequest != null ? 1 : 0),
      itemBuilder: (context, index) {
        // Show revision request at the end
        if (index == deliveries.length && revisionRequest != null) {
          return _buildRevisionRequestCard(revisionRequest);
        }

        final delivery = deliveries[index];

        //controller.getSubmissionNumber(index);
        return _buildSubmissionCard(delivery, context);
      },
    );
  });
}

Widget _buildSubmissionCard(Delivery delivery, BuildContext context) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with submission number and status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('order_delivery_submission'.tr, style: AppTextStyles.smallMediumText),
            _buildStatusBadge(delivery),
          ],
        ),

        SizedBox(height: 8),

        // Date
        Text(
          DateFormat('dd MMM, yyyy').format(delivery.createdAt),
          style: AppTextStyles.extraSmallText,
        ),

        SizedBox(height: 16),

        // Delivery Files Grid
        if (delivery.deliveryFiles.isNotEmpty)
          _buildFilesGrid(delivery.deliveryFiles),

        // Revision Details (if exists)
        if (delivery.revisionDetails != null) ...[
          SizedBox(height: 16),
          _buildRevisionDetailsSection(delivery.revisionDetails!),
        ],

        SizedBox(height: 16),

        // Work Description
        Text(
          'Work Detail',
          style: AppTextStyles.extraSmallText.copyWith(
            fontSize: 10,

            color: Color(0xff848194),
          ),
        ),
        SizedBox(height: 8),
        Text(
          delivery.workDescription,
          style: AppTextStyles.extraSmallText,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),

        // View Detail Button
        TextButton(
          onPressed: () => _showDeliveryDetails(delivery, context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'View Detail',
            style: AppTextStyles.extraSmallText.copyWith(
              fontFamily: AppFonts.OpenSansBold,
              color: Color(0xff816CED),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatusBadge(Delivery delivery) {
  Color backgroundColor;
  Color textColor;

  switch (delivery.deliveryStatus.toLowerCase()) {
    case 'delivered':
      backgroundColor = Color(0xff8281E6).withOpacity(0.13);
      textColor = Color(0xff4C1CAE);
      break;
    case 'approved':
      backgroundColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
      break;
    case 'revision_requested':
      backgroundColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
      break;
    case 'revision_delivered':
      backgroundColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
      break;
    default:
      backgroundColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey;
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      delivery.statusLabel,
      style: TextStyle(
        fontSize: 12,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _buildFilesGrid(List<DeliveryFile> files) {
  final thumbs = Get.put(VideoThumbsController());

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1,
    ),
    itemCount: files.length > 6 ? 6 : files.length,
    itemBuilder: (context, index) {
      final file = files[index];

      return GestureDetector(
        onTap: () {
          if (file.isVideo) {
            if (Get.isRegistered<VideoPlayController>()) {
              Get.delete<VideoPlayController>();
            }

            Get.to(
              () => const VideoPlayerPage(),
              binding: BindingsBuilder(() {
                Get.put(VideoPlayController(file.url));
              }),
            );
            // openVideoPlayerGetX(file.url);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- Preview ---
              if (file.isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: file.url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.image, color: Colors.grey),
                  ),
                )
              else if (file.isVideo)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Obx(() {
                    final path = thumbs.pathFor(
                      file.url,
                    ); // triggers generation if missing
                    if (path == null) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    final f = File(path);
                    if (!f.existsSync()) {
                      return const Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.grey,
                          size: 32,
                        ),
                      );
                    }
                    return Image.file(f, fit: BoxFit.cover);
                  }),
                )
              else
                const Center(
                  child: Icon(
                    Icons.insert_drive_file,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),

              // --- Play overlay for videos ---
              if (file.isVideo)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

              // --- "+N" counter on the last visible tile ---
              if (index == 5 && files.length > 6)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+${files.length - 6}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildRevisionDetailsSection(RevisionDetails revisionDetails) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.orange[50],
      borderRadius: BorderRadius.circular(8),
      // border: Border.all(color: Colors.orange[200]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Icon(Icons.refresh, color: Colors.orange[700], size: 18),
            // SizedBox(width: 8),
            Text(
              'Revision ${revisionDetails.revisionNumber} Requested',
              style: AppTextStyles.smallMediumText,
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          revisionDetails.revisionReason,
          style: AppTextStyles.extraSmallText,
        ),
        SizedBox(height: 8),
        Text(
          DateFormat(
            'dd MMM, yyyy at HH:mm',
          ).format(revisionDetails.revisionRequestedAt),
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}

Widget _buildRevisionRequestCard(RevisionRequest revisionRequest) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      // border: Border.all(color: Colors.orange[200]!, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            // Icon(
            //   Icons.warning_amber_rounded,
            //   color: Colors.orange[700],
            //   size: 24,
            // ),
            // SizedBox(width: 8),
            Expanded(
              child: Text(
                'Revision Request',
                style: AppTextStyles.smallMediumText,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xffECECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${revisionRequest.revisionCount}/${revisionRequest.maxRevisions}',
                style: AppTextStyles.extraSmallMediumText,
              ),
            ),
          ],
        ),

        SizedBox(height: 8),

        // Date
        Text(
          DateFormat(
            'dd MMM, yyyy',
          ).format(revisionRequest.revisionRequestedAt),
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),

        SizedBox(height: 12),

        // Brand Info
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
              child: revisionRequest.brandImageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: revisionRequest.brandImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            revisionRequest.brandName.isNotEmpty
                                ? revisionRequest.brandName[0].toUpperCase()
                                : 'B',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        revisionRequest.brandName.isNotEmpty
                            ? revisionRequest.brandName[0].toUpperCase()
                            : 'B',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 8),
            Text(
              revisionRequest.brandName,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),

        SizedBox(height: 12),

        // Revision Reason
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            revisionRequest.revisionReason,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),

        SizedBox(height: 12),

        // Action message
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  revisionRequest.hasRevisionsLeft
                      ? 'Your order has been sent back for revision. Please review the feedback and resubmit.'
                      : 'This is your final revision. Please ensure all requirements are met.',
                  style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper function to show delivery details
void _showDeliveryDetails(Delivery delivery, BuildContext context) {
  Get.bottomSheet(
    Container(
      height: Get.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Delivery Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      _buildStatusBadge(delivery),
                    ],
                  ),

                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),

                  // Date
                  Text(
                    'Submitted On',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'EEEE, dd MMM yyyy at HH:mm',
                    ).format(delivery.createdAt),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),

                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),

                  // Work Description
                  Text(
                    'Work Description',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    delivery.workDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),

                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),

                  // Delivery Files
                  Text(
                    'Delivery Files (${delivery.deliveryFiles.length})',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  ...delivery.deliveryFiles
                      .map((file) => _buildFileItem(file, context))
                      .toList(),

                  // Revision Details
                  if (delivery.revisionDetails != null) ...[
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 16),
                    Text(
                      'Revision Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildRevisionDetailsSection(delivery.revisionDetails!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

// Helper function to build file item
Widget _buildFileItem(DeliveryFile file, BuildContext context) {
  return Container(
    margin: EdgeInsets.only(bottom: 8),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Row(
      children: [
        // File Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            file.isVideo
                ? Icons.videocam
                : file.isImage
                ? Icons.image
                : Icons.insert_drive_file,
            color: Colors.purple,
            size: 20,
          ),
        ),

        SizedBox(width: 12),

        // File Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '${file.sizeInMB} MB',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Download Button
        IconButton(
          icon: Icon(Icons.download, color: Colors.purple),
          onPressed: () {
            DownloadService.downloadFileWithDialog(
              url: file.url,
              context: context,
            );
          },
        ),
      ],
    ),
  );
}
