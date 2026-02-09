import 'package:collaby_app/models/orders_model/orders_models.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/order_controller/order_details_controller.dart';
import 'package:collaby_app/view_models/services/downlaod_file_service/downlaod_file_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderRequestView extends StatelessWidget {
  final OrderDetailController controller = Get.put(OrderDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text('order_request_title'.tr),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'order_request_new_badge'.tr,
              style: TextStyle(
                fontFamily: AppFonts.OpenSansBold,
                fontSize: 10,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Show loading state
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // Show error state
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'order_request_error_title'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.onInit(),
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        // Show empty state if no order
        final order = controller.currentOrder.value;
        if (order == null) {
          return Center(child: Text('order_request_empty'.tr));
        }

        // Main content
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              order.gigThumbnail,
                              width: 70,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 70,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image_not_supported),
                                  ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              order.title,
                              style: AppTextStyles.smallMediumText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${'order_request_order_label'.tr} ${order.orderNumber}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${'order_request_requested_label'.tr} ${_formatDate(order.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Order Details (Pricing & Delivery)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            order.pricingName,
                            style: AppTextStyles.normalTextMedium,
                          ),
                          Spacer(),
                          Image.asset(ImageAssets.dollarIcon, width: 12),
                          SizedBox(width: 4),
                          Text(
                            '\$ ${order.creatorEarnings.toStringAsFixed(0)}',
                            style: AppTextStyles.normalText,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Pricing Features with null safety
                      if (order.pricingFeatures != null &&
                          order.pricingFeatures!.isNotEmpty)
                        ...order.pricingFeatures!.map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: AppTextStyles.extraSmallText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 16),

                      // Delivery & Revisions
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${order.deliveryTimeDays} ${'order_request_days'.tr}',
                                  style: AppTextStyles.extraSmallMediumText,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  ImageAssets.revisionIcon,
                                  width: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${order.numberOfRevisions} ${'order_request_revisions'.tr}',
                                  style: AppTextStyles.extraSmallMediumText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Work Description with null safety
                if (order.orderRequirements?.workDescription != null &&
                    order.orderRequirements!.workDescription!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'order_request_work_description'.tr,
                          style: AppTextStyles.smallMediumText,
                        ),
                        SizedBox(height: 8),
                        Text(
                          order.orderRequirements!.workDescription!,
                          style: AppTextStyles.extraSmallText,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),

                // Work Description Attachments with null safety
                if (order.orderRequirements?.workDescriptionAttachments !=
                        null &&
                    order
                        .orderRequirements!
                        .workDescriptionAttachments!
                        .isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'order_request_work_attachments'.tr,
                          style: AppTextStyles.extraSmallText.copyWith(
                            fontSize: 10,
                            color: Color(0XFF848194),
                          ),
                        ),
                        SizedBox(height: 8),
                        ...order.orderRequirements!.workDescriptionAttachments!
                            .map(
                              (attachment) => _buildAttachmentItem(
                                attachment.name,
                                attachment.sizeInMB,
                                attachment.url,
                                context,
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                SizedBox(height: 16),

                // Script Section with null safety
                if (order.orderRequirements?.providedScript != null &&
                    order.orderRequirements!.providedScript!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'order_request_script'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          order.orderRequirements!.providedScript!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (order.orderRequirements?.scriptAttachments !=
                                null &&
                            order
                                .orderRequirements!
                                .scriptAttachments!
                                .isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              Text(
                                'order_request_script_attachments'.tr,
                                style: AppTextStyles.extraSmallText.copyWith(
                                  fontSize: 10,
                                  color: Color(0xff848194),
                                ),
                              ),
                              SizedBox(height: 8),
                              ...order.orderRequirements!.scriptAttachments!
                                  .map(
                                    (attachment) => _buildAttachmentItem(
                                      attachment.name,
                                      attachment.sizeInMB,
                                      attachment.url,
                                      context,
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),

                // Order Specific Questions with null safety
                if (order.orderSpecificQuestionAnswers != null &&
                    order.orderSpecificQuestionAnswers!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'order_request_specific_questions'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        ...order.orderSpecificQuestionAnswers!
                            .map((qa) => _buildQuestionAnswerItem(qa))
                            .toList(),
                      ],
                    ),
                  ),
                SizedBox(height: 16),

                // Brand/Client Info with null safety
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'order_request_about_client'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Column(
                          //   children: [
                          //     Row(
                          //       children: [
                          //         ...List.generate(
                          //           4,
                          //           (index) => Icon(
                          //             Icons.star,
                          //             color: Colors.amber,
                          //             size: 16,
                          //           ),
                          //         ),
                          //         Icon(
                          //           Icons.star_border,
                          //           color: Colors.grey,
                          //           size: 16,
                          //         ),
                          //         SizedBox(width: 4),
                          //         Text('4.5', style: TextStyle(fontSize: 12)),
                          //       ],
                          //     ),
                          //     Text(
                          //       '156 Reviews',
                          //       style: TextStyle(
                          //         fontSize: 10,
                          //         color: Colors.grey,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                order.brandDetails?.profile.imageUrl != null
                                ? NetworkImage(
                                    order.brandDetails!.profile.imageUrl!,
                                  )
                                : null,
                            backgroundColor: const Color(0xFFEFF0FF),
                            child: order.brandDetails?.profile.imageUrl == null
                                ? Text(
                                    (order
                                            .brandDetails
                                            ?.profile
                                            .brandCompanyName
                                            ?.characters
                                            .first ??
                                        'B'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order
                                          .brandDetails
                                          ?.profile
                                          .brandCompanyName ??
                                      order.brandName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (order.brandDetails?.profile.industry !=
                                    null)
                                  Text(
                                    order.brandDetails!.profile.industry!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Row(
                      //   children: [
                      //     Icon(
                      //       Icons.verified,
                      //       color: Color(0XFF26B999),
                      //       size: 16,
                      //     ),
                      //     SizedBox(width: 4),
                      //     Text(
                      //       'Payment Verified',
                      //       style: AppTextStyles.extraSmallText,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   icon: Image.asset(ImageAssets.brandJob, width: 24),
      //   label: Padding(
      //     padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      //     child: Text('Chat', style: AppTextStyles.extraSmallText),
      //   ),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(44)),
      //   elevation: 6,
      // ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Obx(() {
      //   final order = controller.currentOrder.value;
      //   if (order == null || controller.isOrderProcessed.value) {
      //     return SizedBox.shrink();
      //   }
      //   return _buildBottomBar(order, context);
      // }),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          // Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 5, // softness
              spreadRadius: 0,
              offset: const Offset(0, -2), // <— cast shadow upward
            ),
          ],
        ),
        child: Obx(() {
          final order = controller.currentOrder.value;
          if (order == null) return SizedBox.shrink();
          return _buildBottomBar(order, context);
        }),
      ),
    );
  }

  Widget _buildAttachmentItem(
    String filename,
    String size,
    String url,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xffF4F7FF),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: Image.asset(
              ImageAssets.pdfIcons,
              width: 20,
              color: Color(0xff4F4F4F),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(filename, style: AppTextStyles.extraSmallText),
                Text(
                  '${size} ${'order_request_mb'.tr}',
                  style: AppTextStyles.extraSmallText.copyWith(
                    color: Color(0xff8B8B8B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              DownloadService.downloadFileWithDialog(
                url: url,
                context: context,
              );
            },
            icon: Icon(Icons.file_download_outlined, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnswerItem(OrderQuestionAnswer qa) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            qa.question.questionText,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (qa.answer.textAnswer != null &&
                    qa.answer.textAnswer!.isNotEmpty)
                  Text(
                    qa.answer.textAnswer!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                if (qa.answer.multipleChoiceAnswers != null &&
                    qa.answer.multipleChoiceAnswers!.isNotEmpty)
                  Text(
                    qa.answer.multipleChoiceAnswers!.join(', '),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                if (qa.answer.attachmentAnswers != null &&
                    qa.answer.attachmentAnswers!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: qa.answer.attachmentAnswers!
                        .map(
                          (att) => Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              '${'order_request_attachment'.tr} ${att.name}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(OrderModel order, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 5,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'order_request_auto_approve_note'.tr,
            style: AppTextStyles.extraSmallText,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDeclineDialog(order, context),
                  child: Text('decline'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.acceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isSubmitting.value
                          ? Colors.grey
                          : Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: controller.isSubmitting.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : Text('order_request_accept'.tr),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(OrderModel order, BuildContext context) {
    controller.selectedDeclineReason.value = '';

    Get.bottomSheet(
      SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.65,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'order_request_decline_title'.tr,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...controller.declineReasons.map(
                          (reason) => _buildDeclineOption(reason, context),
                        ),
                        Obx(() {
                          if (controller.selectedDeclineReason.value ==
                              'decline_reason_other') {
                            return Column(
                              children: [
                                SizedBox(height: 16),
                                TextField(
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'order_request_reason_hint'.tr,
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (v) =>
                                      controller.customDeclineReason.value = v,
                                ),
                              ],
                            );
                          }
                          return SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.fromHeight(48),
                        ),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () => controller.declineOrder(order),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(48),
                            backgroundColor: controller.isSubmitting.value
                                ? Colors.grey
                                : Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: controller.isSubmitting.value
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('order_request_decline'.tr),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDeclineOption(String reason, BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffF4F7FF),
          ),
          child: RadioListTile<String>(
            title: Text(reason.tr),
            value: reason,
            controlAffinity: ListTileControlAffinity.trailing,
            groupValue: controller.selectedDeclineReason.value,
            onChanged: (value) {
              controller.selectedDeclineReason.value = value!;
            },
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return Theme.of(context).disabledColor;
              }
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary;
              }
              return const Color(0xFF4C1CAE);
            }),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)}, ${date.year}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
