import 'package:collaby_app/models/orders_model/orders_models.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/order_controller/order_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timelines_plus/timelines_plus.dart';

Widget buildTimelineTab(
  BuildContext context,
  OrderDetailController controller,
) {
  return Obx(() {
    final activityEvents = controller.activityEvents;
    final isLoading = controller.isActivityLoading.value;

    // Defensive reads
    final thumb = (controller.orderThumb ?? '').toString();
    final title = (controller.orderTitle ?? '').toString();
    final orderNumber = (controller.orderNumber ?? '').toString();
    final orderDate = controller.orderDate;

    return Column(
      children: [
        // Order Header Card
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SafeThumb(url: thumb),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isEmpty ? 'Untitled order' : title,
                            style: AppTextStyles.smallMediumText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orderNumber.isEmpty
                                ? 'Order'
                                : 'Order #$orderNumber',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Order Request: ${_safeDate(orderDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        if (!isLoading && (activityEvents.isEmpty))
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timeline, size: 64, color: Color(0xFFD6D6D6)),
                  SizedBox(height: 16),
                  Text(
                    'No activity timeline available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

        if (!isLoading && activityEvents.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 5,
                ),
                child: FixedTimeline.tileBuilder(
                  theme: TimelineTheme.of(context).copyWith(
                    nodePosition: 0.05,
                    connectorTheme: TimelineTheme.of(context).connectorTheme
                        .copyWith(thickness: 2.0, color: Colors.grey[300]),
                    indicatorTheme: TimelineTheme.of(
                      context,
                    ).indicatorTheme.copyWith(size: 16.0, position: 0.5),
                  ),
                  builder: TimelineTileBuilder(
                    itemCount: activityEvents.length,

                    indicatorBuilder: (context, index) {
                      final event = activityEvents[index];
                      return DotIndicator(
                        size: 16.0,
                        color: const Color(0xffD9D9D9),
                        child: Icon(
                          _getActivityIcon(event.activityType),
                          color: Colors.white,
                          size: 10,
                        ),
                      );
                    },

                    startConnectorBuilder: (context, index) => index == 0
                        ? null
                        : SolidLineConnector(
                            color: Colors.grey[300]!,
                            thickness: 2.0,
                          ),

                    endConnectorBuilder: (context, index) =>
                        index == activityEvents.length - 1
                        ? null
                        : SolidLineConnector(
                            color: Colors.grey[300]!,
                            thickness: 2.0,
                          ),

                    contentsBuilder: (context, index) {
                      final e = activityEvents[index];

                      final title = e.title.trim().isNotEmpty == true
                          ? e.title.trim()
                          : 'Activity';
                      final desc = e.description;
                      final createdAt = e.createdAt; // DateTime?
                      final performedByEmail = e.performedBy.email;
                      final meta = e.metadata; // nullable

                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          bottom: 16.0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Date
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: AppTextStyles.smallMediumText,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(createdAt),
                                    style: AppTextStyles.extraSmallMediumText
                                        .copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),

                              if (desc.trim().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  desc,
                                  style: AppTextStyles.extraSmallText.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],

                              if (meta != null) _buildMetadataSectionSafe(meta),

                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    performedByEmail,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),

                              if ((e.activityType).toLowerCase() ==
                                  'order_delivered') ...[
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => controller.changeTab(2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'View Submission',
                                        style: AppTextStyles.smallTextBold
                                            .copyWith(
                                              color: const Color(0xff816CED),
                                            ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  });
}

class _SafeThumb extends StatelessWidget {
  final String url;
  const _SafeThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    final isHttp = url.startsWith('http://') || url.startsWith('https://');
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: isHttp
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const ColoredBox(color: Color(0xFFEFEFEF));
              },
            )
          : const ColoredBox(color: Color(0xFFEFEFEF)),
    );
  }
}

String _safeDate(DateTime? dt) {
  if (dt == null) return '-';
  try {
    return DateFormat('dd MMM, yyyy').format(dt);
  } catch (_) {
    return dt.toIso8601String().split('T').first;
  }
}

Widget _buildMetadataSectionSafe(ActivityMetadata metadata) {
  // Use your existing layout but guard nulls
  final reason = metadata.revisionReason;
  final count = metadata.revisionCount;
  final max = metadata.maxRevisions;
  final amount = metadata.creatorEarnings;
  final currency = metadata.currency ?? "USD";
  final files = metadata.deliveryFilesCount;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      if (reason != null && reason.trim().isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revision Reason:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reason,
                style: TextStyle(fontSize: 12, color: Colors.orange[800]),
              ),
              if (count != null && max != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Revision $count/$max',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
      if (amount != null) ...[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(Icons.payments, size: 16, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(
                '$amount $currency',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
        ),
      ],
      if (files != null) ...[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(Icons.attach_file, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Text(
                '$files file(s) delivered',
                style: TextStyle(fontSize: 12, color: Colors.blue[900]),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

// Helper function to get activity icon
IconData _getActivityIcon(String activityType) {
  switch (activityType.toLowerCase()) {
    case 'order_requested':
    case 'order_created':
      return Icons.add_circle;
    case 'order_accepted':
      return Icons.check_circle;
    case 'order_delivered':
      return Icons.done_all;
    case 'revision_requested':
      return Icons.refresh;
    case 'payment_processed':
      return Icons.payment;
    case 'requirements_submitted':
      return Icons.description;
    case 'creator_review':
      return Icons.rate_review;
    default:
      return Icons.circle;
  }
}

// Helper function to format date
String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      return '${difference.inMinutes}m ago';
    }
    return '${difference.inHours}h ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return DateFormat('dd MMM, yyyy').format(date);
  }
}
