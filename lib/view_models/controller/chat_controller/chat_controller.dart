import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/models/chat_model/chat_model.dart';
import 'package:collaby_app/repository/auth_repository/verify_token_repository/verify_token_repository.dart';
import 'package:collaby_app/repository/chat_repository/chat_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/chat_controller/websocket_controller.dart';
import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  // Services
  SocketService socketService = Get.put(SocketService());
  ChatRepository apiService = ChatRepository();
  VerifyTokenRepository verifyTokenRepo = VerifyTokenRepository();
  final userPref = UserPreference();

  // Observable lists
  final RxList<ChatUser> users = <ChatUser>[].obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxMap<String, bool> onlineUsers = <String, bool>{}.obs;
  final RxMap<String, bool> typingUsers = <String, bool>{}.obs;

  // Current state
  final RxString currentUserId = ''.obs;
  final RxString currentUserRole = ''.obs;
  final Rx<ChatUser?> selectedUser = Rx<ChatUser?>(null);
  final RxString currentChatId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool hasMoreMessages = true.obs;

  // UI controllers
  final TextEditingController messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  // Typing debounce
  Timer? _typingTimer;
  bool _isTyping = false;

  // Tracking pending offers
  final RxMap<String, String> pendingOffers = <String, String>{}.obs;

  // NEW: Track optimistic message IDs
  final Set<String> _optimisticMessageIds = <String>{};

  List<ChatUser> _parseChatsSafely(List<dynamic> chatsData) {
    return chatsData
        .map((chat) {
          try {
            if (chat is Map<String, dynamic>) {
              return ChatUser.fromJson(chat);
            }
            if (chat is Map) {
              return ChatUser.fromJson(Map<String, dynamic>.from(chat));
            }
            return null;
          } catch (e) {
            if (kDebugMode) {
              log('Skipping malformed chat item: $e');
            }
            return null;
          }
        })
        .whereType<ChatUser>()
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    initializeChat();
  }

  Future<void> initializeChat() async {
    try {
      isLoading.value = true;
      final token = await userPref.getToken();

      final userData = await verifyTokenRepo.verifyToken(token.toString());
      final user = userData['data'];

      currentUserId.value = user['_id'];
      currentUserRole.value = user['role'];

      apiService.setToken(token.toString());

      await socketService.init(token.toString());

      _setupSocketListeners();

      // Avoid blocking app entry with noisy startup errors.
      await loadChats(showErrors: false);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      _showSafeError(e);
    }
  }

  void _setupSocketListeners() {
    socketService.onMessageReceived = (data) {
      _handleMessageReceived(data);
    };

    socketService.onMessageSent = (data) {
      _handleMessageSent(data);
    };

    socketService.onMessageError = (data) {
      // FIXED: Remove optimistic message on error
      _handleMessageError(data);
    };

    socketService.onChatListUpdate = (data) {
      _handleChatListUpdate(data);
    };

    socketService.onUserStatus = (data) {
      final userId = data['userId'];
      final status = data['status'];
      onlineUsers[userId] = status == 'online';

      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = users[index].copyWith(isOnline: status == 'online');
      }
    };

    socketService.onUserTyping = (data) {
      final userId = data['userId'];
      final isTyping = data['isTyping'] ?? false;
      typingUsers[userId] = isTyping;
    };

    socketService.onOnlineUsers = (data) {
      if (data['onlineUsers'] != null) {
        for (var user in data['onlineUsers']) {
          onlineUsers[user['userId']] = true;
        }
      }
      if (data['onlineStatusMap'] != null) {
        final Map<String, dynamic> statusMap = data['onlineStatusMap'];
        statusMap.forEach((userId, isOnline) {
          onlineUsers[userId] = isOnline;
        });
      }
    };

    socketService.onCustomOfferReceived = (data) {
      _handleCustomOfferReceived(data);
    };

    socketService.onCustomOfferStatusUpdate = (data) {
      _handleCustomOfferStatusUpdate(data);
    };
  }

  String extractSocketError(dynamic data) {
    if (data == null) return 'Something went wrong';

    if (data is List && data.isNotEmpty) {
      return extractSocketError(data.first);
    }

    if (data is String) return data;

    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      return (m['message'] ??
              m['error'] ??
              m['reason'] ??
              m['detail'] ??
              m['msg'] ??
              'Something went wrong')
          .toString();
    }

    return data.toString();
  }

  String _mapToSafeErrorMessage(dynamic error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('socketexception') || raw.contains('no internet')) {
      return 'error_no_internet'.tr;
    }
    if (raw.contains('timeoutexception') || raw.contains('timed out')) {
      return 'error_timeout'.tr;
    }
    return 'error_generic'.tr;
  }

  void _showSafeError(dynamic error) {
    Utils.snackBar('error'.tr, _mapToSafeErrorMessage(error));
  }

  // NEW: Handle message error by removing optimistic message
  void _handleMessageError(dynamic data) {
    final errorMsg = extractSocketError(data);

    // Remove the last optimistic message that was just sent
    if (_optimisticMessageIds.isNotEmpty) {
      final lastOptimisticId = _optimisticMessageIds.last;
      messages.removeWhere((m) => m.id == lastOptimisticId);
      _optimisticMessageIds.remove(lastOptimisticId);

      if (kDebugMode) {
        log('âŒ Removed failed optimistic message: $lastOptimisticId');
      }
    }

    _showSafeError(errorMsg);
  }

  Future<void> loadMessages(String chatId, {bool loadMore = false}) async {
    if (isLoadingMessages.value) return;

    try {
      isLoadingMessages.value = true;

      if (!loadMore) {
        messages.clear();
        _optimisticMessageIds.clear(); // Clear optimistic IDs on fresh load
      }

      final messagesData = await apiService.getChatMessages(chatId);

      if (kDebugMode) {
        log('Loaded ${messagesData.length} messages');
      }

      final newMessages = messagesData
          .map((msg) {
            try {
              return ChatMessage.fromJson(msg);
            } catch (e) {
              if (kDebugMode) {
                log('Error parsing message: $e');
                log('Message data: $msg');
              }
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
    } catch (e) {
      if (kDebugMode) {
        log('Error loading messages: $e');
      }
      _showSafeError(e);
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> loadChats({bool showErrors = true}) async {
    try {
      final chatsData = await apiService.getUserChats(currentUserId.value);
      users.value = _parseChatsSafely(chatsData);

      users.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

      socketService.getAllChatsOnlineStatus();

      if (kDebugMode) {
        log('âœ… Loaded ${users.length} chats');
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error loading chats: $e');
      }
      if (showErrors) {
        _showSafeError(e);
      }
    }
  }

  Future<void> selectUser(ChatUser user) async {
    try {
      selectedUser.value = user;
      currentChatId.value = user.chatId ?? '';

      if (currentChatId.value.isNotEmpty) {
        socketService.leaveChat(currentChatId.value);
      }

      socketService.joinChat(user.chatId ?? '');
      socketService.joinChatOffers(user.chatId ?? '');

      await loadMessages(user.chatId ?? '');

      markChatAsRead(user.chatId ?? '');

      final userIndex = users.indexWhere((u) => u.id == user.id);
      if (userIndex != -1) {
        users[userIndex] = users[userIndex].copyWith(unreadCount: 0);
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error selecting user: $e');
      }
    }
  }

  void sendTextMessage() {
    if (messageController.text.trim().isEmpty) return;
    if (currentChatId.value.isEmpty) return;

    final content = messageController.text.trim();
    messageController.clear();

    stopTyping();

    // Generate ID for this message
    final messageId = _generateId();

    socketService.sendMessage(
      chatId: currentChatId.value,
      content: content,
      type: 'text',
    );

    _addOptimisticMessage(
      id: messageId,
      content: content,
      type: MessageType.text,
    );
  }

  void _handleMessageSent(Map<String, dynamic> data) {
    try {
      final message = ChatMessage.fromJson(data['message'] ?? data);

      // Remove optimistic message and add real message
      final optimisticIndex = messages.indexWhere(
        (m) =>
            _optimisticMessageIds.contains(m.id) &&
            m.content == message.content &&
            m.senderId == currentUserId.value &&
            m.timestamp.difference(message.timestamp).inSeconds.abs() < 10,
      );

      if (optimisticIndex != -1) {
        final optimisticId = messages[optimisticIndex].id;
        _optimisticMessageIds.remove(optimisticId);
        messages[optimisticIndex] = message;

        if (kDebugMode) {
          log('âœ… Replaced optimistic message with real message');
        }
      } else {
        messages.add(message);
      }

      _updateChatInList(message);
    } catch (e) {
      if (kDebugMode) {
        log('Error handling message sent: $e');
      }
    }
  }

  void _handleMessageReceived(Map<String, dynamic> data) {
    try {
      final message = ChatMessage.fromJson(data['message'] ?? data);

      if (message.chatId == currentChatId.value) {
        final index = messages.indexWhere((m) => m.id == message.id);
        if (index == -1) {
          messages.add(message);
          if (kDebugMode) {
            log('âœ… Added new message to current chat');
          }
        }
      }

      _updateChatInList(message);

      if (message.chatId == currentChatId.value) {
        markMessageAsRead(message.id, message.chatId ?? '');
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error handling message received: $e');
      }
    }
  }

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
      _showSafeError(e);
    }
  }

  Future<void> pickAndSendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        await _uploadAndSendFile(File(result.files.single.path!), 'file');
      }
    } catch (e) {
      _showSafeError(e);
    }
  }

  Future<void> _uploadAndSendFile(File file, String messageType) async {
    String? optimisticMessageId;

    try {
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final uploadResult = await NetworkApiServices().uploadAnyFile(
        filePath: file.path,
      );

      Get.back();

      final fileUrl = uploadResult;

      if (fileUrl.isEmpty) {
        throw Exception('Upload failed: Empty URL returned');
      }

      optimisticMessageId = _generateId();

      socketService.sendMessage(
        chatId: currentChatId.value,
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

      _addOptimisticMessage(
        id: optimisticMessageId,
        content: messageType == 'image' ? 'Image' : 'File',
        type: messageType == 'image' ? MessageType.image : MessageType.file,
        filePath: file.path,
        fileName: file.path.split('/').last,
      );
    } catch (e) {
      Get.back();

      // Remove optimistic message if upload failed
      if (optimisticMessageId != null &&
          _optimisticMessageIds.contains(optimisticMessageId)) {
        messages.removeWhere((m) => m.id == optimisticMessageId);
        _optimisticMessageIds.remove(optimisticMessageId);
      }

      _showSafeError(e);
    }
  }

  RxBool isSaving = false.obs;

  Future<void> sendCustomOffer(OfferDetails offerDetails, String gigId) async {
    String? optimisticMessageId;

    try {
      if (currentChatId.value.isEmpty) {
        throw Exception('No active chat');
      }

      isSaving.value = true;

      final offerData = {
        'chatId': currentChatId.value,
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

      if (kDebugMode) {
        log('ðŸ“¤ Sending custom offer: $offerData');
      }

      final apiResponse = await apiService.createCustomOffer(offerData);

      if (kDebugMode) {
        log('âœ… API Response: $apiResponse');
      }

      final offerId = apiResponse['data']?['_id'] ?? apiResponse['_id'];

      if (offerId == null) {
        throw Exception('No offer ID returned from API');
      }

      socketService.sendCustomOffer(offerData);

      optimisticMessageId = _generateId();

      _addOptimisticMessage(
        id: optimisticMessageId,
        content: 'Custom Offer: ${offerDetails.gigTitle}',
        type: MessageType.offer,
        offerDetails: offerDetails.copyWith(offerId: offerId),
      );

      Get.back();

      Get.snackbar('Success', 'Offer sent successfully');
    } catch (e) {
      if (kDebugMode) {
        log('âŒ Error sending offer: $e');
      }

      // Remove optimistic message if offer failed
      if (optimisticMessageId != null &&
          _optimisticMessageIds.contains(optimisticMessageId)) {
        messages.removeWhere((m) => m.id == optimisticMessageId);
        _optimisticMessageIds.remove(optimisticMessageId);
      }

      _showSafeError(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> acceptCustomOffer(String offerId) async {
    try {
      await apiService.acceptCustomOffer(offerId, message: 'Offer accepted');
      socketService.acceptCustomOffer(offerId, message: 'Offer accepted');

      _updateOfferStatus(offerId, 'accepted');

      Get.snackbar('Success', 'Offer accepted successfully');
    } catch (e) {
      _showSafeError(e);
    }
  }

  Future<void> declineCustomOffer(String offerId) async {
    try {
      await apiService.declineCustomOffer(offerId, reason: 'Offer declined');
      socketService.declineCustomOffer(offerId, reason: 'Offer declined');

      _updateOfferStatus(offerId, 'declined');

      Get.offAllNamed(RouteName.bottomNavigationView, arguments: {'index': 2});

      Get.snackbar('Info', 'Offer declined');
    } catch (e) {
      _showSafeError(e);
    }
  }

  Future<void> withdrawCustomOffer(String offerId) async {
    try {
      await apiService.withdrawCustomOffer(offerId, reason: 'Offer withdrawn');
      socketService.withdrawCustomOffer(offerId, reason: 'Offer withdrawn');

      _updateOfferStatus(offerId, 'withdrawn');
    } catch (e) {
      _showSafeError(e);
    }
  }

  void _updateOfferStatus(String offerId, String newStatus) {
    final index = messages.indexWhere(
      (m) => m.type == MessageType.offer && m.offerDetails?.offerId == offerId,
    );

    if (index != -1) {
      final message = messages[index];
      messages[index] = message.copyWith(
        offerDetails: message.offerDetails?.copyWith(status: newStatus),
      );
    }
  }

  void sendAdditionalRevision(AdditionalRevisionDetails revisionDetails) {
    if (currentChatId.value.isEmpty) return;

    final messageId = _generateId();

    final message = ChatMessage(
      id: messageId,
      senderId: currentUserId.value,
      senderName: 'You',
      content: 'Additional revision requested: ${revisionDetails.featureName}',
      type: MessageType.additionalRevision,
      timestamp: DateTime.now(),
      revisionDetails: revisionDetails,
    );

    messages.add(message);
    _optimisticMessageIds.add(messageId);

    socketService.sendMessage(
      chatId: currentChatId.value,
      content: 'Additional revision requested',
      type: 'text',
    );

    Get.back();
  }

  void onTyping() {
    if (!_isTyping) {
      _isTyping = true;
      socketService.startTyping(currentChatId.value);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(seconds: 3), () {
      stopTyping();
    });
  }

  void stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      socketService.stopTyping(currentChatId.value);
    }
    _typingTimer?.cancel();
  }

  void markChatAsRead(String chatId) {
    if (chatId.isEmpty) return;

    try {
      socketService.markChatAsRead(chatId);
      apiService.markChatAsRead(chatId);
    } catch (e) {
      if (kDebugMode) {
        log('Error marking chat as read: $e');
      }
    }
  }

  void markMessageAsRead(String messageId, String chatId) {
    try {
      socketService.markMessageAsRead(messageId, chatId);
      apiService.markMessageAsRead(messageId);
    } catch (e) {
      if (kDebugMode) {
        log('Error marking message as read: $e');
      }
    }
  }

  void _handleChatListUpdate(Map<String, dynamic> data) {
    try {
      final chatId = data['chatId'];
      final index = users.indexWhere((u) => u.chatId == chatId);

      if (index != -1) {
        final user = users[index];
        users[index] = user.copyWith(
          lastMessage: data['lastMessage'] ?? user.lastMessage,
          lastSeen: data['lastMessageAt'] != null
              ? DateTime.parse(data['lastMessageAt'])
              : user.lastSeen,
          unreadCount: currentUserRole.value == 'creator'
              ? (data['creatorUnreadCount'] ?? user.unreadCount)
              : (data['brandUnreadCount'] ?? user.unreadCount),
        );

        users.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

        if (kDebugMode) {
          log('âœ… Updated existing chat: $chatId');
        }
      } else {
        if (kDebugMode) {
          log(
            'âš ï¸ Chat not found in list: $chatId - Reloading all chats from API',
          );
        }
        _reloadChatsFromAPI();
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error handling chat list update: $e');
      }
    }
  }

  Future<void> _reloadChatsFromAPI() async {
    try {
      if (kDebugMode) {
        log('ðŸ“¥ Fetching latest chats from API...');
      }

      final chatsData = await apiService.getUserChats(currentUserId.value);
      users.value = _parseChatsSafely(chatsData);

      users.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

      if (kDebugMode) {
        log('âœ… Chat list refreshed! Total chats: ${users.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        log('âŒ Error reloading chats: $e');
      }
    }
  }

  void _handleCustomOfferReceived(Map<String, dynamic> data) {
    try {
      final offerData = data['offer'];
      final message = ChatMessage(
        id: _generateId(),
        senderId: offerData['creatorId'],
        senderName: offerData['creatorName'] ?? 'Creator',
        content: 'Custom Offer',
        type: MessageType.offer,
        timestamp: DateTime.now(),
        offerDetails: OfferDetails.fromJson(offerData),
      );

      if (currentChatId.value == offerData['chatId']) {
        messages.add(message);
      }

      _updateChatInList(message);

      Get.snackbar('New Offer', 'You received a custom offer');
    } catch (e) {
      if (kDebugMode) {
        log('Error handling custom offer: $e');
      }
    }
  }

  void _handleCustomOfferStatusUpdate(Map<String, dynamic> data) {
    try {
      final offerId = data['offerId'];
      final status = data['status'];

      _updateOfferStatus(offerId, status);
    } catch (e) {
      if (kDebugMode) {
        log('Error handling offer status update: $e');
      }
    }
  }

  void _addOptimisticMessage({
    required String id,
    required String content,
    required MessageType type,
    String? filePath,
    String? fileName,
    int? fileSize,
    OfferDetails? offerDetails,
  }) {
    final message = ChatMessage(
      id: id,
      senderId: currentUserId.value,
      senderName: 'You',
      content: content,
      type: type,
      timestamp: DateTime.now(),
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      offerDetails: offerDetails,
    );

    messages.add(message);
    _optimisticMessageIds.add(id);

    if (kDebugMode) {
      log('âž• Added optimistic message: $id');
    }
  }

  void _updateChatInList(ChatMessage message) {
    final index = users.indexWhere((u) => u.chatId == message.chatId);

    if (index != -1) {
      final user = users[index];
      final isCurrentChat = message.chatId == currentChatId.value;

      users[index] = user.copyWith(
        lastMessage: message.content,
        lastSeen: message.timestamp,
        unreadCount: isCurrentChat ? 0 : (user.unreadCount + 1),
      );

      users.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

      if (kDebugMode) {
        log(
          'âœ… Chat list updated and sorted. New last message: ${message.content}',
        );
      }
    } else {
      if (kDebugMode) {
        log(
          'âš ï¸ Chat not found in list for message. chatId: ${message.chatId}',
        );
      }
    }
  }

  Future<List<dynamic>> searchUsers(String query) async {
    try {
      return await apiService.searchUsers(query);
    } catch (e) {
      if (kDebugMode) {
        log('Error searching users: $e');
      }
      return [];
    }
  }

  Future<void> createChat(String targetUserId) async {
    try {
      final chatData = await apiService.createChat(targetUserId);
      final newChat = ChatUser.fromJson(chatData);

      final existingIndex = users.indexWhere((u) => u.chatId == newChat.chatId);

      if (existingIndex == -1) {
        users.insert(0, newChat);
      }

      await selectUser(newChat);
    } catch (e) {
      _showSafeError(e);
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${currentUserId.value}';
  }

  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final utcTime = DateTime.parse(dateTime.toIso8601String());
    final localTime = utcTime.toLocal();
    final difference = now.difference(localTime);

    if (difference.inDays == 0) {
      return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${localTime.day}/${localTime.month}';
    }
  }

  bool isUserOnline(String userId) {
    return onlineUsers[userId] ?? false;
  }

  bool isUserTyping(String userId) {
    return typingUsers[userId] ?? false;
  }

  @override
  void dispose() {
    messageController.dispose();
    _typingTimer?.cancel();

    if (currentChatId.value.isNotEmpty) {
      socketService.leaveChat(currentChatId.value);
      socketService.leaveChatOffers(currentChatId.value);
    }

    super.dispose();
  }
}

// Extensions
extension ChatUserExtension on ChatUser {
  ChatUser copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isOnline,
    DateTime? lastSeen,
    String? lastMessage,
    int? unreadCount,
    String? chatId,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      chatId: chatId ?? this.chatId,
    );
  }
}

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
    String? gigThumbnail,
    List<String>? features,
    String? currency,
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
      gigThumbnail: gigThumbnail ?? this.gigThumbnail,
      features: features ?? this.features,
      currency: currency ?? this.currency,
    );
  }
}

// import 'dart:io';
// import 'dart:async';
// import 'package:collaby_app/data/network/network_api_services.dart';
// import 'package:collaby_app/models/chat_model/chat_model.dart';
// import 'package:collaby_app/repository/auth_repository/verify_token_repository/verify_token_repository.dart';
// import 'package:collaby_app/repository/chat_repository/chat_repository.dart';
// import 'package:collaby_app/res/routes/routes_name.dart';
// import 'package:collaby_app/utils/utils.dart';
// import 'package:collaby_app/view_models/controller/chat_controller/websocket_controller.dart';
// import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';

// class ChatController extends GetxController {
//   // Services
//   SocketService socketService = Get.put(SocketService());
//   ChatRepository apiService = ChatRepository();
//   VerifyTokenRepository verifyTokenRepo = VerifyTokenRepository();
//   final userPref = UserPreference();

//   // Observable lists
//   final RxList<ChatUser> users = <ChatUser>[].obs;
//   final RxList<ChatMessage> messages = <ChatMessage>[].obs;
//   final RxMap<String, bool> onlineUsers = <String, bool>{}.obs;
//   final RxMap<String, bool> typingUsers = <String, bool>{}.obs;

//   // Current state
//   final RxString currentUserId = ''.obs;
//   final RxString currentUserRole = ''.obs;
//   final Rx<ChatUser?> selectedUser = Rx<ChatUser?>(null);
//   final RxString currentChatId = ''.obs;
//   final RxBool isLoading = false.obs;
//   final RxBool isLoadingMessages = false.obs;
//   final RxBool hasMoreMessages = true.obs;

//   // UI controllers
//   final TextEditingController messageController = TextEditingController();
//   final ImagePicker _imagePicker = ImagePicker();

//   // Typing debounce
//   Timer? _typingTimer;
//   bool _isTyping = false;

//   // Tracking pending offers
//   final RxMap<String, String> pendingOffers = <String, String>{}.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     initializeChat();
//   }

//   Future<void> initializeChat() async {
//     try {
//       isLoading.value = true;
//       final token = await userPref.getToken();

//       final userData = await verifyTokenRepo.verifyToken(token.toString());
//       final user = userData['data'];

//       currentUserId.value = user['_id'];
//       currentUserRole.value = user['role'];

//       apiService.setToken(token.toString());

//       await socketService.init(token.toString());

//       // Setup socket listeners BEFORE loading chats
//       _setupSocketListeners();

//       await loadChats();

//       isLoading.value = false;
//     } catch (e) {
//       isLoading.value = false;
//       Utils.snackBar('Error', 'Failed to initialize chat: $e');
//     }
//   }

//   void _setupSocketListeners() {
//     socketService.onMessageReceived = (data) {
//       _handleMessageReceived(data);
//     };

//     socketService.onMessageSent = (data) {
//       _handleMessageSent(data);
//     };

//     socketService.onMessageError = (data) {
//       final msg = extractSocketError(data);
//       Utils.snackBar('Error', msg);
//     };

//     socketService.onChatListUpdate = (data) {
//       _handleChatListUpdate(data);
//     };

//     socketService.onUserStatus = (data) {
//       final userId = data['userId'];
//       final status = data['status'];
//       onlineUsers[userId] = status == 'online';

//       final index = users.indexWhere((u) => u.id == userId);
//       if (index != -1) {
//         users[index] = users[index].copyWith(isOnline: status == 'online');
//       }
//     };

//     socketService.onUserTyping = (data) {
//       final userId = data['userId'];
//       final isTyping = data['isTyping'] ?? false;
//       typingUsers[userId] = isTyping;
//     };

//     socketService.onOnlineUsers = (data) {
//       if (data['onlineUsers'] != null) {
//         for (var user in data['onlineUsers']) {
//           onlineUsers[user['userId']] = true;
//         }
//       }
//       if (data['onlineStatusMap'] != null) {
//         final Map<String, dynamic> statusMap = data['onlineStatusMap'];
//         statusMap.forEach((userId, isOnline) {
//           onlineUsers[userId] = isOnline;
//         });
//       }
//     };

//     socketService.onCustomOfferReceived = (data) {
//       _handleCustomOfferReceived(data);
//     };

//     socketService.onCustomOfferStatusUpdate = (data) {
//       _handleCustomOfferStatusUpdate(data);
//     };
//   }

//   String extractSocketError(dynamic data) {
//     if (data == null) return 'Something went wrong';

//     // Sometimes socket.io sends a list like: [ {error: "..."} ]
//     if (data is List && data.isNotEmpty) {
//       return extractSocketError(data.first);
//     }

//     if (data is String) return data;

//     if (data is Map) {
//       final m = Map<String, dynamic>.from(data);
//       return (m['message'] ??
//               m['error'] ??
//               m['reason'] ??
//               m['detail'] ??
//               m['msg'] ??
//               'Something went wrong')
//           .toString();
//     }

//     return data.toString();
//   }

//   Future<void> loadMessages(String chatId, {bool loadMore = false}) async {
//     if (isLoadingMessages.value) return;

//     try {
//       isLoadingMessages.value = true;

//       if (!loadMore) {
//         messages.clear();
//       }

//       final messagesData = await apiService.getChatMessages(chatId);

//       if (kDebugMode) {
//         log('Loaded ${messagesData.length} messages');
//       }

//       final newMessages = messagesData
//           .map((msg) {
//             try {
//               return ChatMessage.fromJson(msg);
//             } catch (e) {
//               if (kDebugMode) {
//                 log('Error parsing message: $e');
//                 log('Message data: $msg');
//               }
//               return null;
//             }
//           })
//           .whereType<ChatMessage>()
//           .toList();

//       if (loadMore) {
//         messages.insertAll(0, newMessages);
//       } else {
//         messages.value = newMessages;
//       }

//       hasMoreMessages.value = false;
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error loading messages: $e');
//       }
//       Get.snackbar('Error', 'Failed to load messages: $e');
//     } finally {
//       isLoadingMessages.value = false;
//     }
//   }

//   Future<void> loadChats() async {
//     try {
//       final chatsData = await apiService.getUserChats(currentUserId.value);

//       users.value = chatsData.map((chat) => ChatUser.fromJson(chat)).toList();

//       // Sort by last seen
//       users.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

//       socketService.getAllChatsOnlineStatus();

//       if (kDebugMode) {
//         log('âœ… Loaded ${users.length} chats');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error loading chats: $e');
//       }
//       Get.snackbar('Error', 'Failed to load chats: $e');
//     }
//   }

//   Future<void> selectUser(ChatUser user) async {
//     try {
//       selectedUser.value = user;
//       currentChatId.value = user.chatId ?? '';

//       if (currentChatId.value.isNotEmpty) {
//         socketService.leaveChat(currentChatId.value);
//       }

//       socketService.joinChat(user.chatId ?? '');
//       socketService.joinChatOffers(user.chatId ?? '');

//       await loadMessages(user.chatId ?? '');

//       markChatAsRead(user.chatId ?? '');

//       final userIndex = users.indexWhere((u) => u.id == user.id);
//       if (userIndex != -1) {
//         users[userIndex] = users[userIndex].copyWith(unreadCount: 0);
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error selecting user: $e');
//       }
//     }
//   }

//   void sendTextMessage() {
//     if (messageController.text.trim().isEmpty) return;
//     if (currentChatId.value.isEmpty) return;

//     final content = messageController.text.trim();
//     messageController.clear();

//     stopTyping();

//     socketService.sendMessage(
//       chatId: currentChatId.value,
//       content: content,
//       type: 'text',
//     );

//     _addOptimisticMessage(content: content, type: MessageType.text);
//   }

//   void _handleMessageSent(Map<String, dynamic> data) {
//     try {
//       final message = ChatMessage.fromJson(data['message'] ?? data);

//       final index = messages.indexWhere(
//         (m) =>
//             m.content == message.content &&
//             m.senderId == currentUserId.value &&
//             m.timestamp.difference(message.timestamp).inSeconds.abs() < 5,
//       );

//       if (index != -1) {
//         messages[index] = message;
//       } else {
//         messages.add(message);
//       }

//       _updateChatInList(message);
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error handling message sent: $e');
//       }
//     }
//   }

//   void _handleMessageReceived(Map<String, dynamic> data) {
//     try {
//       final message = ChatMessage.fromJson(data['message'] ?? data);

//       // Check if message is from current chat
//       if (message.chatId == currentChatId.value) {
//         final index = messages.indexWhere((m) => m.id == message.id);
//         if (index == -1) {
//           messages.add(message);
//           if (kDebugMode) {
//             log('âœ… Added new message to current chat');
//           }
//         }
//       }

//       // IMPORTANT: Always update chat list, even if not in current chat
//       _updateChatInList(message);

//       // Mark as read if in current chat
//       if (message.chatId == currentChatId.value) {
//         markMessageAsRead(message.id, message.chatId ?? '');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error handling message received: $e');
//       }
//     }
//   }

//   Future<void> pickAndSendImage() async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );

//       if (image != null) {
//         await _uploadAndSendFile(File(image.path), 'image');
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to pick image: $e');
//     }
//   }

//   Future<void> pickAndSendFile() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.any,
//       );

//       if (result != null && result.files.single.path != null) {
//         await _uploadAndSendFile(File(result.files.single.path!), 'file');
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to pick file: $e');
//     }
//   }

//   Future<void> _uploadAndSendFile(File file, String messageType) async {
//     try {
//       Get.dialog(
//         Center(child: CircularProgressIndicator()),
//         barrierDismissible: false,
//       );

//       final uploadResult = await NetworkApiServices().uploadAnyFile(
//         filePath: file.path,
//       );

//       Get.back();

//       final fileUrl = uploadResult;

//       if (fileUrl == null) {
//         throw Exception('Upload failed: No URL returned');
//       }

//       socketService.sendMessage(
//         chatId: currentChatId.value,
//         content: messageType == 'image' ? 'Image' : 'File',
//         type: messageType,
//         attachments: [
//           {
//             'url': fileUrl,
//             'type': messageType,
//             'name': file.path.split('/').last,
//             'size': await file.length(),
//           },
//         ],
//       );

//       _addOptimisticMessage(
//         content: messageType == 'image' ? 'Image' : 'File',
//         type: messageType == 'image' ? MessageType.image : MessageType.file,
//         filePath: file.path,
//         fileName: file.path.split('/').last,
//       );
//     } catch (e) {
//       Get.back();
//       Get.snackbar('Error', 'Failed to upload file: $e');
//     }
//   }

//   RxBool isSaving = false.obs;

//   Future<void> sendCustomOffer(OfferDetails offerDetails, String gigId) async {
//     try {
//       if (currentChatId.value.isEmpty) {
//         throw Exception('No active chat');
//       }

//       isSaving.value = true;

//       final offerData = {
//         'chatId': currentChatId.value,
//         'gigId': gigId,
//         'title': offerDetails.gigTitle,
//         'description': offerDetails.gigDescription,
//         'customPrice': offerDetails.price,
//         'currency': offerDetails.currency ?? 'USD',
//         'deliveryTimeDays': offerDetails.deliveryDays,
//         'numberOfRevisions': offerDetails.revisions,
//         'features': offerDetails.features ?? [],
//         'videoTimeline': offerDetails.videoLength,
//       };

//       if (kDebugMode) {
//         log('ðŸ“¤ Sending custom offer: $offerData');
//       }

//       final apiResponse = await apiService.createCustomOffer(offerData);

//       if (kDebugMode) {
//         log('âœ… API Response: $apiResponse');
//       }

//       final offerId = apiResponse['data']?['_id'] ?? apiResponse['_id'];

//       if (offerId == null) {
//         throw Exception('No offer ID returned from API');
//       }

//       socketService.sendCustomOffer(offerData);

//       _addOptimisticMessage(
//         content: 'Custom Offer: ${offerDetails.gigTitle}',
//         type: MessageType.offer,
//         offerDetails: offerDetails.copyWith(offerId: offerId),
//       );

//       Get.back();

//       Get.snackbar('Success', 'Offer sent successfully');
//     } catch (e) {
//       if (kDebugMode) {
//         log('âŒ Error sending offer: $e');
//       }
//       Get.snackbar('Error', 'Failed to send offer: ${e.toString()}');
//     } finally {
//       isSaving.value = false;
//     }
//   }

//   Future<void> acceptCustomOffer(String offerId) async {
//     try {
//       await apiService.acceptCustomOffer(offerId, message: 'Offer accepted');
//       socketService.acceptCustomOffer(offerId, message: 'Offer accepted');

//       _updateOfferStatus(offerId, 'accepted');

//       Get.snackbar('Success', 'Offer accepted successfully');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to accept offer: $e');
//     }
//   }

//   Future<void> declineCustomOffer(String offerId) async {
//     try {
//       await apiService.declineCustomOffer(offerId, reason: 'Offer declined');
//       socketService.declineCustomOffer(offerId, reason: 'Offer declined');

//       _updateOfferStatus(offerId, 'declined');

//       Get.offAllNamed(RouteName.bottomNavigationView, arguments: {'index': 2});

//       Get.snackbar('Info', 'Offer declined');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to decline offer: $e');
//     }
//   }

//   Future<void> withdrawCustomOffer(String offerId) async {
//     try {
//       await apiService.withdrawCustomOffer(offerId, reason: 'Offer withdrawn');
//       socketService.withdrawCustomOffer(offerId, reason: 'Offer withdrawn');

//       _updateOfferStatus(offerId, 'withdrawn');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to withdraw offer: $e');
//     }
//   }

//   void _updateOfferStatus(String offerId, String newStatus) {
//     final index = messages.indexWhere(
//       (m) => m.type == MessageType.offer && m.offerDetails?.offerId == offerId,
//     );

//     if (index != -1) {
//       final message = messages[index];
//       messages[index] = message.copyWith(
//         offerDetails: message.offerDetails?.copyWith(status: newStatus),
//       );
//     }
//   }

//   void sendAdditionalRevision(AdditionalRevisionDetails revisionDetails) {
//     if (currentChatId.value.isEmpty) return;

//     final message = ChatMessage(
//       id: _generateId(),
//       senderId: currentUserId.value,
//       senderName: 'You',
//       content: 'Additional revision requested: ${revisionDetails.featureName}',
//       type: MessageType.additional_revision,
//       timestamp: DateTime.now(),
//       revisionDetails: revisionDetails,
//     );

//     messages.add(message);

//     socketService.sendMessage(
//       chatId: currentChatId.value,
//       content: 'Additional revision requested',
//       type: 'text',
//     );

//     Get.back();
//   }

//   void onTyping() {
//     if (!_isTyping) {
//       _isTyping = true;
//       socketService.startTyping(currentChatId.value);
//     }

//     _typingTimer?.cancel();
//     _typingTimer = Timer(Duration(seconds: 3), () {
//       stopTyping();
//     });
//   }

//   void stopTyping() {
//     if (_isTyping) {
//       _isTyping = false;
//       socketService.stopTyping(currentChatId.value);
//     }
//     _typingTimer?.cancel();
//   }

//   void markChatAsRead(String chatId) {
//     if (chatId.isEmpty) return;

//     try {
//       socketService.markChatAsRead(chatId);
//       apiService.markChatAsRead(chatId);
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error marking chat as read: $e');
//       }
//     }
//   }

//   void markMessageAsRead(String messageId, String chatId) {
//     try {
//       socketService.markMessageAsRead(messageId, chatId);
//       apiService.markMessageAsRead(messageId);
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error marking message as read: $e');
//       }
//     }
//   }

//   void _handleChatListUpdate(Map<String, dynamic> data) {
//     try {
//       final chatId = data['chatId'];
//       final index = users.indexWhere((u) => u.chatId == chatId);

//       if (index != -1) {
//         // âœ… CHAT EXISTS - Update it
//         final user = users[index];
//         users[index] = user.copyWith(
//           lastMessage: data['lastMessage'] ?? user.lastMessage,
//           lastSeen: data['lastMessageAt'] != null
//               ? DateTime.parse(data['lastMessageAt'])
//               : user.lastSeen,
//           unreadCount: currentUserRole.value == 'creator'
//               ? (data['creatorUnreadCount'] ?? user.unreadCount)
//               : (data['brandUnreadCount'] ?? user.unreadCount),
//         );

//         users.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

//         if (kDebugMode) {
//           log('âœ… Updated existing chat: $chatId');
//         }
//       } else {
//         // âŒ CHAT DOESN'T EXIST - Fetch all chats from API
//         if (kDebugMode) {
//           log(
//             'âš ï¸ Chat not found in list: $chatId - Reloading all chats from API',
//           );
//         }
//         _reloadChatsFromAPI();
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error handling chat list update: $e');
//       }
//     }
//   }

//   /// Reload chats from API when a new chat is created
//   Future<void> _reloadChatsFromAPI() async {
//     try {
//       if (kDebugMode) {
//         log('ðŸ“¥ Fetching latest chats from API...');
//       }

//       final chatsData = await apiService.getUserChats(currentUserId.value);
//       users.value = chatsData.map((chat) => ChatUser.fromJson(chat)).toList();

//       // Sort by last seen
//       users.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

//       if (kDebugMode) {
//         log('âœ… Chat list refreshed! Total chats: ${users.length}');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         log('âŒ Error reloading chats: $e');
//       }
//     }
//   }

//   void _handleCustomOfferReceived(Map<String, dynamic> data) {
//     try {
//       final offerData = data['offer'];
//       final message = ChatMessage(
//         id: _generateId(),
//         senderId: offerData['creatorId'],
//         senderName: offerData['creatorName'] ?? 'Creator',
//         content: 'Custom Offer',
//         type: MessageType.offer,
//         timestamp: DateTime.now(),
//         offerDetails: OfferDetails.fromJson(offerData),
//       );

//       if (currentChatId.value == offerData['chatId']) {
//         messages.add(message);
//       }

//       // Always update chat list
//       _updateChatInList(message);

//       Get.snackbar('New Offer', 'You received a custom offer');
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error handling custom offer: $e');
//       }
//     }
//   }

//   void _handleCustomOfferStatusUpdate(Map<String, dynamic> data) {
//     try {
//       final offerId = data['offerId'];
//       final status = data['status'];

//       _updateOfferStatus(offerId, status);
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error handling offer status update: $e');
//       }
//     }
//   }

//   void _addOptimisticMessage({
//     required String content,
//     required MessageType type,
//     String? filePath,
//     String? fileName,
//     int? fileSize,
//     OfferDetails? offerDetails,
//   }) {
//     final message = ChatMessage(
//       id: _generateId(),
//       senderId: currentUserId.value,
//       senderName: 'You',
//       content: content,
//       type: type,
//       timestamp: DateTime.now(),
//       filePath: filePath,
//       fileName: fileName,
//       fileSize: fileSize,
//       offerDetails: offerDetails,
//     );

//     messages.add(message);
//   }

//   void _updateChatInList(ChatMessage message) {
//     final index = users.indexWhere((u) => u.chatId == message.chatId);

//     if (index != -1) {
//       final user = users[index];
//       final isCurrentChat = message.chatId == currentChatId.value;

//       users[index] = user.copyWith(
//         lastMessage: message.content,
//         lastSeen: message.timestamp,
//         unreadCount: isCurrentChat ? 0 : (user.unreadCount + 1),
//       );

//       // Re-sort to move updated chat to top
//       users.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

//       if (kDebugMode) {
//         log(
//           'âœ… Chat list updated and sorted. New last message: ${message.content}',
//         );
//       }
//     } else {
//       if (kDebugMode) {
//         log(
//           'âš ï¸ Chat not found in list for message. chatId: ${message.chatId}',
//         );
//       }
//     }
//   }

//   Future<List<dynamic>> searchUsers(String query) async {
//     try {
//       return await apiService.searchUsers(query);
//     } catch (e) {
//       if (kDebugMode) {
//         log('Error searching users: $e');
//       }
//       return [];
//     }
//   }

//   Future<void> createChat(String targetUserId) async {
//     try {
//       final chatData = await apiService.createChat(targetUserId);
//       final newChat = ChatUser.fromJson(chatData);

//       final existingIndex = users.indexWhere((u) => u.chatId == newChat.chatId);

//       if (existingIndex == -1) {
//         users.insert(0, newChat);
//       }

//       await selectUser(newChat);
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to create chat: $e');
//     }
//   }

//   String _generateId() {
//     return '${DateTime.now().millisecondsSinceEpoch}_${currentUserId.value}';
//   }

//   String formatTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final utcTime = DateTime.parse(dateTime.toIso8601String());
//     final localTime = utcTime.toLocal();
//     final difference = now.difference(localTime);

//     if (difference.inDays == 0) {
//       return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return '${localTime.day}/${localTime.month}';
//     }
//   }

//   bool isUserOnline(String userId) {
//     return onlineUsers[userId] ?? false;
//   }

//   bool isUserTyping(String userId) {
//     return typingUsers[userId] ?? false;
//   }

//   @override
//   void dispose() {
//     messageController.dispose();
//     _typingTimer?.cancel();

//     if (currentChatId.value.isNotEmpty) {
//       socketService.leaveChat(currentChatId.value);
//       socketService.leaveChatOffers(currentChatId.value);
//     }

//     super.dispose();
//   }
// }

// // Extensions
// extension ChatUserExtension on ChatUser {
//   ChatUser copyWith({
//     String? id,
//     String? name,
//     String? avatar,
//     bool? isOnline,
//     DateTime? lastSeen,
//     String? lastMessage,
//     int? unreadCount,
//     String? chatId,
//   }) {
//     return ChatUser(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       avatar: avatar ?? this.avatar,
//       isOnline: isOnline ?? this.isOnline,
//       lastSeen: lastSeen ?? this.lastSeen,
//       lastMessage: lastMessage ?? this.lastMessage,
//       unreadCount: unreadCount ?? this.unreadCount,
//       chatId: chatId ?? this.chatId,
//     );
//   }
// }

// extension ChatMessageExtension on ChatMessage {
//   ChatMessage copyWith({
//     String? id,
//     String? senderId,
//     String? senderName,
//     String? content,
//     MessageType? type,
//     DateTime? timestamp,
//     String? filePath,
//     String? fileName,
//     int? fileSize,
//     OfferDetails? offerDetails,
//     AdditionalRevisionDetails? revisionDetails,
//     String? chatId,
//   }) {
//     return ChatMessage(
//       id: id ?? this.id,
//       senderId: senderId ?? this.senderId,
//       senderName: senderName ?? this.senderName,
//       content: content ?? this.content,
//       type: type ?? this.type,
//       timestamp: timestamp ?? this.timestamp,
//       filePath: filePath ?? this.filePath,
//       fileName: fileName ?? this.fileName,
//       fileSize: fileSize ?? this.fileSize,
//       offerDetails: offerDetails ?? this.offerDetails,
//       revisionDetails: revisionDetails ?? this.revisionDetails,
//       chatId: chatId ?? this.chatId,
//     );
//   }
// }

// extension OfferDetailsExtension on OfferDetails {
//   OfferDetails copyWith({
//     String? offerId,
//     String? gigTitle,
//     String? gigDescription,
//     int? videoLength,
//     double? price,
//     int? deliveryDays,
//     int? revisions,
//     String? status,
//     String? gigThumbnail,
//     List<String>? features,
//     String? currency,
//   }) {
//     return OfferDetails(
//       offerId: offerId ?? this.offerId,
//       gigTitle: gigTitle ?? this.gigTitle,
//       gigDescription: gigDescription ?? this.gigDescription,
//       videoLength: videoLength ?? this.videoLength,
//       price: price ?? this.price,
//       deliveryDays: deliveryDays ?? this.deliveryDays,
//       revisions: revisions ?? this.revisions,
//       status: status ?? this.status,
//       gigThumbnail: gigThumbnail ?? this.gigThumbnail,
//       features: features ?? this.features,
//       currency: currency ?? this.currency,
//     );
//   }
// }
