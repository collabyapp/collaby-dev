import 'dart:io';
import 'dart:async';
import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/models/chat_model/chat_model.dart';
import 'package:collaby_app/repository/chat_repository/chat_repository.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/chat_controller/websocket_controller.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view/chats_view/chat_detail_view/widget/custom_offer/custom_offer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderChatController extends GetxController {
  // Services
  final SocketService socketService = Get.find<SocketService>();
  final ChatRepository apiService = ChatRepository();
  final userPref = UserPreference();

  // Chat ID for this specific order chat
  final String chatId;
  final String orderId;

  // Observable lists
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxMap<String, bool> typingUsers = <String, bool>{}.obs;

  // Current state
  final RxString currentUserId = ''.obs;
  final RxString currentUserRole = ''.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxBool isSaving = false.obs;

  // UI controllers
  final TextEditingController messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  // Typing debounce
  Timer? _typingTimer;
  bool _isTyping = false;

  OrderChatController({required this.chatId, required this.orderId});

  @override
  void onInit() {
    super.onInit();
    _initializeOrderChat();
    _setupSocketListeners();
  }

  Future<void> _initializeOrderChat() async {
    try {
      final token = await userPref.getToken();

      // Get user data from token
      final userData = await apiService.verifyToken(token.toString());
      final user = userData['data'];

      currentUserId.value = user['_id'];
      currentUserRole.value = user['role'];

      // Set token for API
      apiService.setToken(token.toString());

      // Join chat room
      socketService.joinChat(chatId);
      socketService.joinChatOffers(chatId);

      // Load messages
      await loadMessages();
    } catch (e) {
      print('Error initializing order chat: $e');
      Utils.snackBar(
        'Error',
        'Failed to initialize chat: $e',
        // backgroundColor: Colors.red,
        // colorText: Colors.white,
      );
    }
  }

  void _setupSocketListeners() {
    // Message received
    socketService.onMessageReceived = (data) {
      _handleMessageReceived(data);
    };

    // Message sent confirmation
    socketService.onMessageSent = (data) {
      _handleMessageSent(data);
    };

    // Message error
    socketService.onMessageError = (data) {
      Utils.snackBar(
        'Error',
        data['message'] ?? 'Failed to send message',
        // backgroundColor: Colors.red,
        // colorText: Colors.white,
      );
    };

    // User typing
    socketService.onUserTyping = (data) {
      final userId = data['userId'];
      final isTyping = data['isTyping'] ?? false;
      typingUsers[userId] = isTyping;
    };

    // Custom offer received
    socketService.onCustomOfferReceived = (data) {
      _handleCustomOfferReceived(data);
    };

    // Custom offer status update
    socketService.onCustomOfferStatusUpdate = (data) {
      _handleCustomOfferStatusUpdate(data);
    };
  }

  // Load messages for this chat
  Future<void> loadMessages({bool loadMore = false}) async {
    if (isLoadingMessages.value) return;

    try {
      isLoadingMessages.value = true;

      if (!loadMore) {
        messages.clear();
      }

      final messagesData = await apiService.getChatMessages(chatId);

      print('Loaded ${messagesData.length} messages for chat $chatId');

      final newMessages = messagesData
          .map((msg) {
            try {
              return ChatMessage.fromJson(msg);
            } catch (e) {
              print('Error parsing message: $e');
              return null;
            }
          })
          .whereType<ChatMessage>()
          .toList();

      if (loadMore) {
        messages.insertAll(0, newMessages);
      } else {
        messages.value = newMessages;
      }

      hasMoreMessages.value = false;

      // Mark chat as read
      _markChatAsRead();
    } catch (e) {
      print('Error loading messages: $e');
      Utils.snackBar(
        'Error',
        'Failed to load messages: $e',
        // backgroundColor: Colors.red,
        // colorText: Colors.white,
      );
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // Send text message
  void sendTextMessage() {
    if (messageController.text.trim().isEmpty) return;
    if (chatId.isEmpty) return;

    final content = messageController.text.trim();
    messageController.clear();

    // Stop typing indicator
    stopTyping();

    // Send via socket
    socketService.sendMessage(chatId: chatId, content: content, type: 'text');

    // Add optimistic message
    _addOptimisticMessage(content: content, type: MessageType.text);
  }

  // Send image
  Future<void> pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadAndSendFile(File(image.path), 'image');
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to pick image: $e');
    }
  }

  // Send file
  Future<void> pickAndSendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        await _uploadAndSendFile(File(result.files.single.path!), 'file');
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to pick file: $e');
    }
  }

  // Upload and send file
  Future<void> _uploadAndSendFile(File file, String messageType) async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Upload file
      final uploadResult = await NetworkApiServices().uploadAnyFile(
        filePath: file.path,
      );

      Get.back(); // Close loading dialog

      final fileUrl = uploadResult;

      // Send message with attachment
      socketService.sendMessage(
        chatId: chatId,
        content: messageType == 'image' ? 'Image' : 'File',
        type: messageType,
        attachments: [
          {
            'url': fileUrl,
            'type': messageType,
            'name': file.path.split('/').last,
            'size': await file.length(),
          },
        ],
      );

      // Add optimistic message
      _addOptimisticMessage(
        content: messageType == 'image' ? 'Image' : 'File',
        type: messageType == 'image' ? MessageType.image : MessageType.file,
        filePath: file.path,
        fileName: file.path.split('/').last,
      );
    } catch (e) {
      Get.back(); // Close loading dialog if open
      Utils.snackBar('Error', 'Failed to upload file: $e');
    }
  }

  // Send custom offer
  Future<void> sendCustomOffer(OfferDetails offerDetails, String gigId) async {
    try {
      if (chatId.isEmpty) {
        throw Exception('No active chat');
      }

      isSaving.value = true;

      final offerData = {
        'chatId': chatId,
        'gigId': gigId,
        'title': offerDetails.gigTitle,
        'description': offerDetails.gigDescription,
        'customPrice': offerDetails.price,
        'currency': offerDetails.currency ?? 'USD',
        'deliveryTimeDays': offerDetails.deliveryDays,
        'numberOfRevisions': offerDetails.revisions,
        'features': offerDetails.features ?? [],
        'videoTimeline': offerDetails.videoLength,
      };

      print('📤 Sending custom offer: $offerData');

      // Create offer via API
      await apiService.createCustomOffer(offerData);

      // Send via socket
      socketService.sendCustomOffer(offerData);

      // Add optimistic message
      _addOptimisticMessage(
        content: 'Custom Offer: ${offerDetails.gigTitle}',
        type: MessageType.offer,
        offerDetails: offerDetails,
      );

      Get.back();

      Utils.snackBar(
        'Success',
        'Offer sent successfully',
        // backgroundColor: Colors.green[100],
        // colorText: Colors.green[900],
        // duration: Duration(seconds: 3),
        // icon: Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      print('❌ Error sending offer: $e');
      Utils.snackBar(
        'Error',
        'Failed to send offer: ${e.toString()}',
        // backgroundColor: Colors.red[100],
        // colorText: Colors.red[900],
        // duration: Duration(seconds: 4),
        // icon: Icon(Icons.error, color: Colors.red),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Accept custom offer
  Future<void> acceptCustomOffer(String offerId) async {
    try {
      await apiService.acceptCustomOffer(offerId, message: 'Offer accepted');
      socketService.acceptCustomOffer(offerId, message: 'Offer accepted');

      Utils.snackBar(
        'Success',
        'Offer accepted successfully',
        // backgroundColor: Colors.green,
        // colorText: Colors.white,
      );
    } catch (e) {
      Utils.snackBar('Error', 'Failed to accept offer: $e');
    }
  }

  // Decline custom offer
  Future<void> declineCustomOffer(String offerId) async {
    try {
      await apiService.declineCustomOffer(offerId, reason: 'Offer declined');
      socketService.declineCustomOffer(offerId, reason: 'Offer declined');

      Utils.snackBar('Info', 'Offer declined');
    } catch (e) {
      Utils.snackBar('Error', 'Failed to decline offer: $e');
    }
  }

  // Withdraw custom offer
  Future<void> withdrawCustomOffer(String offerId) async {
    try {
      await apiService.withdrawCustomOffer(offerId, reason: 'Offer withdrawn');
      socketService.withdrawCustomOffer(offerId, reason: 'Offer withdrawn');
    } catch (e) {
      Utils.snackBar('Error', 'Failed to withdraw offer: $e');
    }
  }

  // Typing indicators
  void onTyping() {
    if (!_isTyping) {
      _isTyping = true;
      socketService.startTyping(chatId);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(seconds: 3), () {
      stopTyping();
    });
  }

  void stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      socketService.stopTyping(chatId);
    }
    _typingTimer?.cancel();
  }

  // Mark chat as read
  void _markChatAsRead() {
    try {
      socketService.markChatAsRead(chatId);
      apiService.markChatAsRead(chatId);
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  // Handle message received
  void _handleMessageReceived(Map<String, dynamic> data) {
    try {
      final message = ChatMessage.fromJson(data['message'] ?? data);

      // Only add message if it's for this chat
      if (message.chatId != chatId) return;

      // Prevent duplicates
      final index = messages.indexWhere((m) => m.id == message.id);
      if (index == -1) {
        messages.add(message);

        // Mark as read
        socketService.markMessageAsRead(message.id, chatId);
        apiService.markMessageAsRead(message.id);
      }
    } catch (e) {
      print('Error handling message received: $e');
    }
  }

  // Handle message sent
  void _handleMessageSent(Map<String, dynamic> data) {
    try {
      final message = ChatMessage.fromJson(data['message'] ?? data);

      // Only update if it's for this chat
      if (message.chatId != chatId) return;

      // Find and update the optimistic message
      final index = messages.indexWhere(
        (m) =>
            m.content == message.content &&
            m.senderId == currentUserId.value &&
            m.timestamp.difference(message.timestamp).inSeconds.abs() < 5,
      );

      if (index != -1) {
        messages[index] = message;
      } else {
        messages.add(message);
      }
    } catch (e) {
      print('Error handling message sent: $e');
    }
  }

  // Handle custom offer received
  void _handleCustomOfferReceived(Map<String, dynamic> data) {
    try {
      final offerData = data['offer'];

      // Only handle if it's for this chat
      if (offerData['chatId'] != chatId) return;

      final message = ChatMessage(
        id: _generateId(),
        senderId: offerData['creatorId'],
        senderName: offerData['creatorName'] ?? 'Creator',
        content: 'Custom Offer',
        type: MessageType.offer,
        timestamp: DateTime.now(),
        offerDetails: OfferDetails.fromJson(offerData),
        chatId: chatId,
      );

      messages.add(message);

      Utils.snackBar(
        'New Offer',
        'You received a custom offer',
        // backgroundColor: Colors.blue,
        // colorText: Colors.white,
      );
    } catch (e) {
      print('Error handling custom offer: $e');
    }
  }

  // Handle custom offer status update
  void _handleCustomOfferStatusUpdate(Map<String, dynamic> data) {
    try {
      final offerId = data['offerId'];
      final status = data['status'];

      // Update offer message in list
      final index = messages.indexWhere(
        (m) =>
            m.type == MessageType.offer && m.offerDetails?.offerId == offerId,
      );

      if (index != -1) {
        final message = messages[index];
        messages[index] = message.copyWith(
          offerDetails: message.offerDetails?.copyWith(status: status),
        );
      }

      // String statusText = status == 'accepted'
      //     ? 'accepted'
      //     : status == 'declined'
      //     ? 'declined'
      //     : 'withdrawn';
      // String statusText = status == 'accepted'
      //     ? 'accepted'
      //     : status == 'declined'
      //     ? 'declined'
      //     : status == 'pending'
      //     ? 'pending'
      //     : 'withdrawn';

      // Utils.snackBar(
      //   'Offer Update',
      //   'Offer has been $statusText',
      //   backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
      //   colorText: Colors.white,
      // );
    } catch (e) {
      print('Error handling offer status update: $e');
    }
  }

  // Add optimistic message
  void _addOptimisticMessage({
    required String content,
    required MessageType type,
    String? filePath,
    String? fileName,
    int? fileSize,
    OfferDetails? offerDetails,
  }) {
    final message = ChatMessage(
      id: _generateId(),
      senderId: currentUserId.value,
      senderName: 'You',
      content: content,
      type: type,
      timestamp: DateTime.now(),
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      offerDetails: offerDetails,
      chatId: chatId,
    );

    messages.add(message);
  }

  // Generate unique ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${currentUserId.value}';
  }

  // Check if user is typing
  bool isUserTyping(String userId) {
    return typingUsers[userId] ?? false;
  }

  @override
  void onClose() {
    messageController.dispose();
    _typingTimer?.cancel();

    // Leave chat room
    socketService.leaveChat(chatId);
    socketService.leaveChatOffers(chatId);

    super.onClose();
  }
}

// Extension for ChatMessage copyWith
extension ChatMessageExtension on ChatMessage {
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    String? filePath,
    String? fileName,
    int? fileSize,
    OfferDetails? offerDetails,
    AdditionalRevisionDetails? revisionDetails,
    String? chatId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      offerDetails: offerDetails ?? this.offerDetails,
      revisionDetails: revisionDetails ?? this.revisionDetails,
      chatId: chatId ?? this.chatId,
    );
  }
}

// Extension for OfferDetails copyWith
extension OfferDetailsExtension on OfferDetails {
  OfferDetails copyWith({
    String? offerId,
    String? gigTitle,
    String? gigDescription,
    int? videoLength,
    double? price,
    int? deliveryDays,
    int? revisions,
    String? status,
  }) {
    return OfferDetails(
      offerId: offerId ?? this.offerId,
      gigTitle: gigTitle ?? this.gigTitle,
      gigDescription: gigDescription ?? this.gigDescription,
      videoLength: videoLength ?? this.videoLength,
      price: price ?? this.price,
      deliveryDays: deliveryDays ?? this.deliveryDays,
      revisions: revisions ?? this.revisions,
      status: status ?? this.status,
    );
  }
}

Widget buildChatTab(
  String chatId,
  String orderId, {
  String? otherUserId,
  String? otherUserName,
}) {
  // Initialize OrderChatController with chatId
  final OrderChatController chatController = Get.put(
    OrderChatController(chatId: chatId, orderId: orderId),
    tag: chatId, // Use tag to allow multiple instances
  );

  final ScrollController scrollController = ScrollController();

  // Add scroll listener for pagination
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.minScrollExtent) {
      if (chatController.hasMoreMessages.value &&
          !chatController.isLoadingMessages.value) {
        chatController.loadMessages(loadMore: true);
      }
    }
  });

  // Add text change listener for typing indicator
  chatController.messageController.addListener(() {
    if (chatController.messageController.text.isNotEmpty) {
      chatController.onTyping();
    } else {
      chatController.stopTyping();
    }
  });

  return Column(
    children: [
      // Typing indicator
      // Obx(() {
      //   if (otherUserId != null && chatController.isUserTyping(otherUserId)) {
      //     return
      // Container(
      //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //   child: Row(
      //     children: [
      //       Text(
      //         '${otherUserName ?? "User"} is typing...',
      //         style: AppTextStyles.extraSmallText.copyWith(
      //           fontStyle: FontStyle.italic,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),

      //   }
      //   return SizedBox.shrink();
      // }),
      Expanded(
        child: Obx(() {
          // Show loading indicator
          if (chatController.isLoadingMessages.value &&
              chatController.messages.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          // Show empty state
          if (chatController.messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: AppTextStyles.normalText.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start the conversation',
                    style: AppTextStyles.smallText.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Show messages
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(16),
            reverse: true,
            itemCount:
                chatController.messages.length +
                (chatController.isLoadingMessages.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at top
              if (index == chatController.messages.length) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final reversedIndex = chatController.messages.length - 1 - index;
              final message = chatController.messages[reversedIndex];

              return MessageBubble(
                message: message,
                isMe: message.senderId == chatController.currentUserId.value,
              );
            },
          );
        }),
      ),

      // Message input
      _buildMessageInput(chatController),
    ],
  );
}

Widget _buildMessageInput(OrderChatController chatController) {
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
            onPressed: () => _showBottomSheet(chatController),
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

void _showBottomSheet(OrderChatController chatController) {
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

// Bottom Sheet Options Widget
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

// Message Bubble Widget
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({Key? key, required this.message, required this.isMe})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          // if (!isMe) ...[
          //   CircleAvatar(
          //     radius: 16,
          //     backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          //   ),
          //   SizedBox(width: 8),
          // ],
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
                  _buildMessageContent(),
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

  Widget _buildMessageContent() {
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
        return _buildFileMessage();
      case MessageType.offer:
        return _buildOfferCard();
      case MessageType.additional_revision:
        return _buildAdditionalRevisionCard();
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.error),
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

  Widget _buildFileMessage() {
    final fileName =
        message.fileName ?? message.attachments?.first.name ?? 'Unknown file';
    final fileSize = message.fileSize ?? message.attachments?.first.size;

    return Row(
      children: [
        Icon(
          Icons.attach_file,
          color: isMe ? Colors.white : Colors.grey[600],
          size: 20,
        ),
        SizedBox(width: 8),
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
      ],
    );
  }

  Widget _buildOfferCard() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Offer',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          if (message.offerDetails != null) ...[
            SizedBox(height: 8),
            Text(
              message.offerDetails!.gigTitle,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '\$${message.offerDetails!.price}',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalRevisionCard() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Additional Revision Request',
        style: TextStyle(
          color: Colors.orange[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final utcTime = DateTime.parse(dateTime.toIso8601String()); // this is UTC
    final localTime = utcTime.toLocal();
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
