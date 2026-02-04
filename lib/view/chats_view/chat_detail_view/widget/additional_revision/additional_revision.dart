import 'package:collaby_app/models/chat_model/chat_model.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/chats_view/chat_detail_view/widget/active_order/active_order_details.dart';
import 'package:collaby_app/view_models/controller/chat_controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdditionalRevisionScreen extends StatelessWidget {
  final TextEditingController featureController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final RxInt selectedDeliveryDays = 1.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Additional Revision',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            TextFormField(
              controller: featureController,
              decoration: InputDecoration(
                hintText: 'Additional Feature name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(
                hintText: 'Extra Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {}, // Show delivery time selector
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Additiona Delivery Time in Days',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey[500]),
                  ],
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Send additional revision request
                  final message = ChatMessage(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    senderId: Get.find<ChatController>().currentUserId.value,
                    senderName: 'You',
                    content:
                        'Additional revision requested: ${featureController.text}',
                    type: MessageType.additional_revision,
                    timestamp: DateTime.now(),
                  );
                  Get.find<ChatController>().messages.add(message);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Send Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class OrdersBottomSheet extends StatelessWidget {
  final String userName;

  const OrdersBottomSheet({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Orders with $userName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Order item
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _buildOrderItem(
              title:
                  'Influencer Needed for Beauty Brand User-Generated Content (UGC)',
              date: 'Order Request: 24 Oct, 2024',
              imageUrl:
                  'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=60&h=60&fit=crop&crop=face',
              onTap: () {
                Get.back();
                //  Get.to(() => OrderDetailView(), arguments: {order});
                // Navigate to order detail
                Get.to(() => OrderDetailScreen());
              },
            ),
          ),
          SizedBox(height: 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _buildOrderItem(
              title:
                  'Influencer Needed for Beauty Brand User-Generated Content (UGC)',
              date: 'Order Request: 24 Oct, 2024',
              imageUrl:
                  'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=60&h=60&fit=crop&crop=face',
              onTap: () {
                Get.back();
                // Navigate to order detail
                Get.to(() => OrderDetailScreen());
              },
            ),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required String title,
    required String date,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.smallMediumText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Order Detail button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    Text(
                      'Order Detail',
                      style: AppTextStyles.extraSmallText.copyWith(
                        color: AppColor.primaryColor,
                        fontFamily: AppFonts.OpenSansBold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
