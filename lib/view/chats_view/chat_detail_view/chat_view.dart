import 'dart:io';
import 'package:collaby_app/models/chat_model/chat_model.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/chats_view/chat_detail_view/widget/custom_offer/custom_offer.dart';
import 'package:collaby_app/view_models/controller/chat_controller/chat_controller.dart';
import 'package:collaby_app/view_models/services/downlaod_file_service/downlaod_file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    chatController.messageController.addListener(_onTextChanged);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      if (chatController.hasMoreMessages.value &&
          !chatController.isLoadingMessages.value) {
        chatController.loadMessages(
          chatController.currentChatId.value,
          loadMore: true,
        );
      }
    }
  }

  void _onTextChanged() {
    if (chatController.messageController.text.isNotEmpty) {
      chatController.onTyping();
    } else {
      chatController.stopTyping();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    chatController.messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (chatController.isLoadingMessages.value &&
                  chatController.messages.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                reverse: true,
                itemCount:
                    chatController.messages.length +
                    (chatController.isLoadingMessages.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatController.messages.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final reversedIndex =
                      chatController.messages.length - 1 - index;
                  final message = chatController.messages[reversedIndex];

                  return MessageBubble(
                    message: message,
                    isMe:
                        message.senderId == chatController.currentUserId.value,
                  );
                },
              );
            }),
          ),

          // Typing indicator
          Obx(() {
            final user = chatController.selectedUser.value;
            if (user != null && chatController.isUserTyping(user.id)) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${user.name} is typing...',
                      style: AppTextStyles.extraSmallText.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),

          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Obx(() {
        final user = chatController.selectedUser.value;
        if (user == null) return SizedBox();

        final isOnline = chatController.isUserOnline(user.id);

        return Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                chatController.stopTyping();
                if (chatController.currentChatId.value.isNotEmpty) {
                  chatController.socketService.leaveChat(
                    chatController.currentChatId.value,
                  );
                  chatController.socketService.leaveChatOffers(
                    chatController.currentChatId.value,
                  );
                }
                Get.back();
              },
            ),
            Stack(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(user.avatar),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTextStyles.normalTextBold.copyWith(
                      color: Color(0xff1E1E1E),
                    ),
                  ),
                  Text(
                    isOnline
                        ? 'Online'
                        : 'Last seen ${chatController.formatTime(user.lastSeen)}',
                    style: AppTextStyles.extraSmallText.copyWith(
                      color: Color(0xff1E1E1E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0XFFD9D9D9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Color(0XFF0C0C0C)),
              ),
              onPressed: () => _showBottomSheet(),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: chatController.messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: AppTextStyles.smallText.copyWith(
                    color: Color(0XFF000000),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Image.asset(ImageAssets.sendIcons, width: 24),
              onPressed: () => chatController.sendTextMessage(),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet() {
    Get.bottomSheet(
      BottomSheetOptions(
        onCreateOffer: () {
          Get.back();
          Get.to(() => OfferScreen());
        },
        onUploadPhoto: () {
          Get.back();
          chatController.pickAndSendImage();
        },
        onSendFile: () {
          Get.back();
          chatController.pickAndSendFile();
        },
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

// Bottom Sheet Options
class BottomSheetOptions extends StatelessWidget {
  final VoidCallback onCreateOffer;
  final VoidCallback onUploadPhoto;
  final VoidCallback onSendFile;

  const BottomSheetOptions({
    Key? key,
    required this.onCreateOffer,
    required this.onUploadPhoto,
    required this.onSendFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            _buildOption(title: 'Create an offer', onTap: onCreateOffer),
            SizedBox(height: 10),
            _buildOption(title: 'Upload Photo', onTap: onUploadPhoto),
            SizedBox(height: 10),
            _buildOption(title: 'Send a file', onTap: onSendFile),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Color(0xFFF4F7FF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(title, style: AppTextStyles.normalText),
      ),
    );
  }
}

// Message Bubble
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({Key? key, required this.message, required this.isMe})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIXED: Handle system messages (no senderId or receiverId)
    final isSystemMessage =
        message.senderId == null ||
        message.senderId == 'null' ||
        message.senderId == '';

    // if (isSystemMessage && message.type == MessageType.order_created) {
    //   return _buildSystemMessage();
    // }

    // Check if it's a system message type (order_created or overdue)
    final isSystemMessageType =
        message.type == MessageType.orderCreated ||
        message.type == MessageType.overdue ||
        message.type == MessageType.alert;

    // If it's a system message, display it centered
    if (isSystemMessage && isSystemMessageType) {
      return _buildSystemMessage();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 241.w),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Color(0xff917DE5) : Color(0xffE1D5FA),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(context),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Build centered system message
  // Updated _buildSystemMessage method
  Widget _buildSystemMessage() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getSystemMessageColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getSystemMessageBorderColor()),
          ),
          child: Column(
            children: [
              // Main message content
              Text(
                message.content,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              // Order number (for both order_created and overdue types)
              if (message.metadata?['orderNumber'] != null) ...[
                SizedBox(height: 4),
                Text(
                  'Order #${message.metadata!['orderNumber']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              // Additional info for overdue messages
              if ((message.type == MessageType.overdue ||
                  message.type == MessageType.alert) &&
                  message.metadata != null) ...[
                SizedBox(height: 8),
                _buildOverdueDetails(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build overdue details
  Widget _buildOverdueDetails() {
    final metadata = message.metadata!;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (metadata['daysOverdue'] != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Colors.red[700],
                ),
                SizedBox(width: 4),
                Text(
                  '${metadata['daysOverdue']} days overdue',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

          if (metadata['originalDeadline'] != null) ...[
            SizedBox(height: 4),
            Text(
              'Original deadline: ${_formatDate(metadata['originalDeadline'])}',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to get background color based on message type
  Color _getSystemMessageColor() {
    switch (message.type) {
      case MessageType.overdue:
        return Colors.red[50]!;
      case MessageType.alert:
        return Colors.red[50]!;
      case MessageType.orderCreated:
        return Colors.green[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  // Helper method to get border color based on message type
  Color _getSystemMessageBorderColor() {
    switch (message.type) {
      case MessageType.overdue:
        return Colors.red[200]!;
      case MessageType.orderCreated:
        return Colors.green[200]!;
      default:
        return Colors.grey[300]!;
    }
  }

  // Helper method to format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
  // Widget _buildSystemMessage() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 8),
  //     child: Center(
  //       child: Container(
  //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         decoration: BoxDecoration(
  //           color: Colors.grey[100],
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: Colors.grey[300]!),
  //         ),
  //         child: Column(
  //           children: [
  //             Text(
  //               message.content,
  //               style: TextStyle(
  //                 color: Colors.grey[700],
  //                 fontSize: 13,
  //                 fontStyle: FontStyle.italic,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //             if (message.metadata?['orderNumber'] != null) ...[
  //               SizedBox(height: 4),
  //               Text(
  //                 'Order #${message.metadata!['orderNumber']}',
  //                 style: TextStyle(
  //                   color: Colors.grey[600],
  //                   fontSize: 11,
  //                 ),
  //               ),
  //             ],
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        );

      case MessageType.image:
        return _buildImageMessage();

      case MessageType.file:
        return _buildFileMessage(context);

      case MessageType.offer:
        return _buildOfferCard();

      case MessageType.additionalRevision:
        return _buildAdditionalRevisionCard();

      case MessageType.system:
      case MessageType.orderCreated:
        return Text(
          message.content,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        );

      default:
        return Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        );
    }
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.attachments != null && message.attachments!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message.attachments!.first.url,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          )
        else if (message.filePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(message.filePath!),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        if (message.content.isNotEmpty && message.content != 'Image')
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFileMessage(BuildContext context) {
    final fileName =
        message.fileName ?? message.attachments?.first.name ?? 'Unknown file';
    final fileSize = message.fileSize ?? message.attachments?.first.size;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (fileSize != null)
                Text(
                  _formatFileSize(fileSize),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        if (message.attachments != null && message.attachments!.isNotEmpty)
          IconButton(
            icon: Icon(
              Icons.download,
              color: isMe ? Colors.white : Colors.grey[600],
            ),
            onPressed: () {
              final attachment = message.attachments!.first;
              final fileUrl = attachment.url;

              DownloadService.downloadFileWithDialog(
                url: fileUrl,
                context: context,
              );
            },
          ),
      ],
    );
  }

  Widget _buildOfferCard() {
    final offer = message.offerDetails;
    if (offer == null) return SizedBox();

    final chatController = Get.find<ChatController>();
    final isCreator = chatController.currentUserRole.value == 'creator';
    final isPending = offer.status == 'pending';
    final isAccepted = offer.status == 'accepted';
    final isDeclined = offer.status == 'declined';
    final isWithdrawn = offer.status == 'withdrawn';

    return Container(
      width: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer.gigThumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                offer.gigThumbnail!,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: 12),

          Text(
            offer.gigTitle,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),

          Text(
            offer.gigDescription,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${offer.price.toStringAsFixed(0)} ${offer.currency}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${offer.deliveryDays} days',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 8),

          Text(
            '${offer.revisions} revisions • ${offer.videoLength}s video',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(offer.status ?? 'pending'),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(offer.status ?? 'pending'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 12),

          if (isPending) ...[
            if (!isCreator) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        chatController.declineCustomOffer(offer.offerId ?? '');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                      ),
                      child: Text('Decline'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        chatController.acceptCustomOffer(offer.offerId ?? '');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff917DE5),
                      ),
                      child: Text('Accept'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    chatController.withdrawCustomOffer(offer.offerId ?? '');
                  },
                  child: Text('Withdraw Offer'),
                ),
              ),
            ],
          ],

          if (isAccepted)
            Center(
              child: Text(
                '✓ Offer Accepted',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (isDeclined)
            Center(
              child: Text(
                '✗ Offer Declined',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (isWithdrawn)
            Center(
              child: Text(
                '↶ Offer Withdrawn',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'withdrawn':
        return Colors.grey;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
      case 'withdrawn':
        return 'Withdrawn';
      case 'expired':
        return 'Expired';
      default:
        return 'Pending';
    }
  }

  Widget _buildAdditionalRevisionCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.orange[700], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Additional Revision Request',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final utcTime = DateTime.parse(dateTime.toIso8601String());
    final localTime = utcTime.toLocal();
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
