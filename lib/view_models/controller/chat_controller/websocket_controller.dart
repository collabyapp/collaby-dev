import 'dart:developer';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class SocketService extends GetxService {
  IO.Socket? socket;
  final RxBool isConnected = false.obs;
  final RxString socketId = ''.obs;

  // Callbacks
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(Map<String, dynamic>)? onMessageSent;
  Function(Map<String, dynamic>)? onMessageError;
  Function(Map<String, dynamic>)? onMessageRead;
  Function(Map<String, dynamic>)? onChatListUpdate;
  Function(Map<String, dynamic>)? onUserStatus;
  Function(Map<String, dynamic>)? onUserTyping;
  Function(Map<String, dynamic>)? onOnlineUsers;
  Function(Map<String, dynamic>)? onCustomOfferReceived;
  Function(Map<String, dynamic>)? onCustomOfferStatusUpdate;

  static const String BASE_URL = '${AppUrl.baseUrl}';
  static const String NAMESPACE = '/chat';
  Future<SocketService> init(String token) async {
    try {
      if (kDebugMode) {
        log('Initializing Socket connection...');
      }
      socket = IO.io(
        '${AppUrl.baseUrl}/chat',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
            .setExtraHeaders({'auth': token})
            .build(),
      );

      _setupEventHandlers();
      return this;
    } catch (e) {
      if (kDebugMode) {
        log('Socket initialization error: $e');
      }
      rethrow;
    }
  }

  void _setupEventHandlers() {
    if (socket == null) return;

    // Connection events
    socket!.onConnect((_) {
      if (kDebugMode) {
        log('Socket connected: ${socket!.id}');
      }
      isConnected.value = true;
      socketId.value = socket!.id ?? '';

      // Request all chats online status on connect
      emit('get_all_chats_online_status', {});
    });

    socket!.onDisconnect((_) {
      if (kDebugMode) {
        log('Socket disconnected');
      }
      isConnected.value = false;
      socketId.value = '';
    });

    socket!.onConnectError((error) {
      if (kDebugMode) {
        log('Socket connection error: $error');
      }
      isConnected.value = false;
    });

    socket!.onError((error) {
      if (kDebugMode) {
        log('Socket error: $error');
      }
    });

    // Chat events
    socket!.on('message_received', (data) {
      if (kDebugMode) {
        log('Message received: $data');
      }
      if (onMessageReceived != null) {
        onMessageReceived!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('message_sent', (data) {
      if (kDebugMode) {
        log('Message sent: $data');
      }
      if (onMessageSent != null) {
        onMessageSent!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('message_error', (data) {
      if (kDebugMode) {
        log('Message error: $data');
      }
      if (onMessageError != null) {
        onMessageError!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('message_read', (data) {
      if (kDebugMode) {
        log('Message read: $data');
      }
      if (onMessageRead != null) {
        onMessageRead!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('chat_list_update', (data) {
      if (kDebugMode) {
        log('Chat list update: $data');
      }
      if (onChatListUpdate != null) {
        onChatListUpdate!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('chat_read', (data) {
      if (kDebugMode) {
        log('Chat read: $data');
      }
      if (onChatListUpdate != null) {
        onChatListUpdate!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('chat_unread_count_update', (data) {
      if (kDebugMode) {
        log('Chat unread count update: $data');
      }
      if (onChatListUpdate != null) {
        onChatListUpdate!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('user_status', (data) {
      if (kDebugMode) {
        log('User status update: $data');
      }
      if (onUserStatus != null) {
        onUserStatus!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('user_typing', (data) {
      if (kDebugMode) {
        log('User typing: $data');
      }
      if (onUserTyping != null) {
        onUserTyping!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('online_users', (data) {
      if (kDebugMode) {
        log('Online users: $data');
      }
      if (onOnlineUsers != null) {
        onOnlineUsers!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('all_chats_online_status', (data) {
      if (kDebugMode) {
        log('All chats online status: $data');
      }
      if (onOnlineUsers != null) {
        onOnlineUsers!(Map<String, dynamic>.from(data));
      }
    });

    // Custom offer events
    socket!.on('custom_offer_received', (data) {
      if (kDebugMode) {
        log('Custom offer received: $data');
      }
      if (onCustomOfferReceived != null) {
        onCustomOfferReceived!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('custom_offer_created', (data) {
      if (kDebugMode) {
        log('Custom offer created: $data');
      }
      if (onCustomOfferStatusUpdate != null) {
        onCustomOfferStatusUpdate!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('custom_offer_accepted', (data) {
      if (kDebugMode) {
        log('Custom offer accepted: $data');
      }
      if (onCustomOfferStatusUpdate != null) {
        onCustomOfferStatusUpdate!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('custom_offer_declined', (data) {
      if (kDebugMode) {
        log('Custom offer declined: $data');
      }
      if (onCustomOfferStatusUpdate != null) {
        onCustomOfferStatusUpdate!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('custom_offer_withdrawn', (data) {
      if (kDebugMode) {
        log('Custom offer withdrawn: $data');
      }
      if (onCustomOfferStatusUpdate != null) {
        onCustomOfferStatusUpdate!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('system_message', (data) {
      if (kDebugMode) {
        log('System message: $data');
      }
      if (onMessageReceived != null) {
        onMessageReceived!(Map<String, dynamic>.from(data));
      }
    });

    socket!.on('joined_chat', (data) {
      if (kDebugMode) {
        log('Joined chat: $data');
      }
    });

    socket!.on('left_chat', (data) {
      if (kDebugMode) {
        log('Left chat: $data');
      }
    });
  }

  // Emit events
  void emit(String event, Map<String, dynamic> data) {
    if (socket != null && isConnected.value) {
      if (kDebugMode) {
        log('Emitting $event: $data');
      }
      socket!.emit(event, data);
    } else {
      if (kDebugMode) {
        log('Socket not connected, cannot emit $event');
      }
    }
  }

  // Join chat room
  void joinChat(String chatId) {
    emit('join_chat', {'chatId': chatId});
  }

  // Leave chat room
  void leaveChat(String chatId) {
    emit('leave_chat', {'chatId': chatId});
  }

  // Send message
  void sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
    List<Map<String, dynamic>>? attachments,
  }) {
    final data = {
      'chatId': chatId,
      'content': content,
      'type': type,
      if (attachments != null) 'attachments': attachments,
    };
    emit('send_message', data);
  }

  // Mark message as read
  void markMessageAsRead(String messageId, String chatId) {
    emit('mark_read', {'messageId': messageId, 'chatId': chatId});
  }

  // Mark chat as read
  void markChatAsRead(String chatId) {
    emit('mark_chat_read', {'chatId': chatId});
  }

  // Typing indicators
  void startTyping(String chatId) {
    emit('typing_start', {'chatId': chatId});
  }

  void stopTyping(String chatId) {
    emit('typing_stop', {'chatId': chatId});
  }

  // Get online users
  void getOnlineUsers(String chatId) {
    emit('get_online_users', {'chatId': chatId});
  }

  void getAllChatsOnlineStatus() {
    emit('get_all_chats_online_status', {});
  }

  // Custom offer events
  void sendCustomOffer(Map<String, dynamic> offerData) {
    emit('create_custom_offer', offerData);
  }

  void acceptCustomOffer(String offerId, {String message = ''}) {
    emit('accept_custom_offer', {'offerId': offerId, 'message': message});
  }

  void declineCustomOffer(String offerId, {String reason = ''}) {
    emit('decline_custom_offer', {'offerId': offerId, 'reason': reason});
  }

  void withdrawCustomOffer(String offerId, {String reason = ''}) {
    emit('withdraw_custom_offer', {'offerId': offerId, 'reason': reason});
  }

  void joinChatOffers(String chatId) {
    emit('join_chat_offers', {'chatId': chatId});
  }

  void leaveChatOffers(String chatId) {
    emit('leave_chat_offers', {'chatId': chatId});
  }

  // Disconnect
  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      isConnected.value = false;
      socketId.value = '';
    }
  }

  // @override
  // void onClose() {
  //   disconnect();
  //   super.onClose();
  // }
}

