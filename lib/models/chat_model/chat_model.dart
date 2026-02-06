import 'dart:developer';

// class ChatUser {
//   final String id;
//   final String name;
//   final String avatar;
//   final bool isOnline;
//   final DateTime lastSeen;
//   final String lastMessage;
//   final int unreadCount;
//   final String? chatId;
//   final String? role;
//   final String? brandCompanyName;
//   final String? displayName;
//   final String? firstName;
//   final String? lastName;

//   ChatUser({
//     required this.id,
//     required this.name,
//     required this.avatar,
//     required this.isOnline,
//     required this.lastSeen,
//     required this.lastMessage,
//     required this.unreadCount,
//     this.chatId,
//     this.role,
//     this.brandCompanyName,
//     this.displayName,
//     this.firstName,
//     this.lastName,
//   });

//   factory ChatUser.fromJson(Map<String, dynamic> json) {
//     // Determine if this is creator or brand based on current user role
//     final isCreatorView = json['creator'] != null;
//     final userData = isCreatorView ? json['brand'] : json['creator'];

//     String getName() {
//       if (isCreatorView) {
//         return userData?['brandCompanyName'] ??
//             userData?['username'] ??
//             'Unknown Brand';
//       } else {
//         return userData?['displayName'] ??
//             '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}'
//                 .trim() ??
//             'Unknown Creator';
//       }
//     }

//     return ChatUser(
//       id: isCreatorView ? json['brandId'] : json['creatorId'],
//       name: getName(),
//       avatar: userData?['imageUrl'] ?? 'https://via.placeholder.com/150',
//       isOnline: false, // Will be updated via socket
//       lastSeen: json['lastMessageAt'] != null
//           ? DateTime.parse(json['lastMessageAt'])
//           : DateTime.now(),
//       lastMessage: json['lastMessage'] ?? 'No messages yet',
//       unreadCount: isCreatorView
//           ? (json['creatorUnreadCount'] ?? 0)
//           : (json['brandUnreadCount'] ?? 0),
//       chatId: json['_id'],
//       role: userData?['role'],
//       brandCompanyName: userData?['brandCompanyName'],
//       displayName: userData?['displayName'],
//       firstName: userData?['firstName'],
//       lastName: userData?['lastName'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'avatar': avatar,
//       'isOnline': isOnline,
//       'lastSeen': lastSeen.toIso8601String(),
//       'lastMessage': lastMessage,
//       'unreadCount': unreadCount,
//       'chatId': chatId,
//       'role': role,
//     };
//   }
// }

// enum MessageType {
//   text,
//   image,
//   video,
//   audio,
//   file,
//   offer,
//   additional_revision,
//   system,
//   order_created,
// }

// class ChatMessage {
//   final String id;
//   final String senderId;
//   final String senderName;
//   final String content;
//   final MessageType type;
//   final DateTime timestamp;
//   final String? filePath;
//   final String? fileName;
//   final int? fileSize;
//   final OfferDetails? offerDetails;
//   final AdditionalRevisionDetails? revisionDetails;
//   final String? chatId;
//   final List<Attachment>? attachments;
//   final Map<String, dynamic>? metadata;
//   final bool? isRead;

//   ChatMessage({
//     required this.id,
//     required this.senderId,
//     required this.senderName,
//     required this.content,
//     required this.type,
//     required this.timestamp,
//     this.filePath,
//     this.fileName,
//     this.fileSize,
//     this.offerDetails,
//     this.revisionDetails,
//     this.chatId,
//     this.attachments,
//     this.metadata,
//     this.isRead,
//   });

//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     MessageType getType(String? typeStr) {
//       switch (typeStr?.toLowerCase()) {
//         case 'image':
//           return MessageType.image;
//         case 'video':
//           return MessageType.video;
//         case 'audio':
//           return MessageType.audio;
//         case 'file':
//           return MessageType.file;
//         case 'custom_offer':
//           return MessageType.offer;
//         case 'additional_revision':
//           return MessageType.additional_revision;
//         case 'system':
//           return MessageType.system;
//         case 'order_created':
//           return MessageType.order_created;
//         default:
//           return MessageType.text;
//       }
//     }

//     OfferDetails? parseOfferDetails(Map<String, dynamic>? json) {
//       if (json == null) return null;
//       try {
//         return OfferDetails.fromJson(json);
//       } catch (e) {
//         log('Error parsing offer details: $e');
//         return null;
//       }
//     }

//     List<Attachment>? parseAttachments(dynamic attachments) {
//       if (attachments == null) return null;
//       if (attachments is! List) return null;

//       try {
//         return attachments
//             .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
//             .toList();
//       } catch (e) {
//         log('Error parsing attachments: $e');
//         return null;
//       }
//     }

//     return ChatMessage(
//       id: json['_id'] ?? json['id'],
//       senderId: json['senderId'] ?? json['sender']?['_id'],
//       senderName:
//           json['senderName'] ??
//           json['sender']?['displayName'] ??
//           json['sender']?['username'] ??
//           'Unknown',
//       content: json['content'] ?? '',
//       type: getType(json['type']),
//       timestamp: json['timestamp'] != null || json['createdAt'] != null
//           ? DateTime.parse(json['timestamp'] ?? json['createdAt'])
//           : DateTime.now(),
//       filePath: json['filePath'],
//       fileName: json['fileName'],
//       fileSize: json['fileSize'],
//       offerDetails: parseOfferDetails(
//         json['metadata']?['offerData'] ?? json['offerDetails'],
//       ),
//       chatId: json['chatId'] ?? json['chat'],
//       attachments: parseAttachments(json['attachments']),
//       metadata: json['metadata'],
//       isRead: json['isRead'] ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     String getTypeString() {
//       switch (type) {
//         case MessageType.image:
//           return 'image';
//         case MessageType.video:
//           return 'video';
//         case MessageType.audio:
//           return 'audio';
//         case MessageType.file:
//           return 'file';
//         case MessageType.offer:
//           return 'custom_offer';
//         case MessageType.additional_revision:
//           return 'additional_revision';
//         case MessageType.system:
//           return 'system';
//         case MessageType.order_created:
//           return 'order_created';
//         default:
//           return 'text';
//       }
//     }

//     return {
//       'id': id,
//       'senderId': senderId,
//       'senderName': senderName,
//       'content': content,
//       'type': getTypeString(),
//       'timestamp': timestamp.toIso8601String(),
//       if (filePath != null) 'filePath': filePath,
//       if (fileName != null) 'fileName': fileName,
//       if (fileSize != null) 'fileSize': fileSize,
//       if (offerDetails != null) 'offerDetails': offerDetails!.toJson(),
//       if (chatId != null) 'chatId': chatId,
//       if (attachments != null)
//         'attachments': attachments!.map((a) => a.toJson()).toList(),
//       if (metadata != null) 'metadata': metadata,
//       if (isRead != null) 'isRead': isRead,
//     };
//   }
// }

// class Attachment {
//   final String url;
//   final String type;
//   final String? name;
//   final int? size;
//   final String? thumbnailUrl;

//   Attachment({
//     required this.url,
//     required this.type,
//     this.name,
//     this.size,
//     this.thumbnailUrl,
//   });

//   factory Attachment.fromJson(Map<String, dynamic> json) {
//     return Attachment(
//       url: json['url'],
//       type: json['type'],
//       name: json['name'],
//       size: json['size'],
//       thumbnailUrl: json['thumbnailUrl'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'url': url,
//       'type': type,
//       if (name != null) 'name': name,
//       if (size != null) 'size': size,
//       if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
//     };
//   }
// }

// class OfferDetails {
//   final String? offerId;
//   final String gigTitle;
//   final String gigDescription;
//   final int videoLength;
//   final double price;
//   final int deliveryDays;
//   final int revisions;
//   final String? status;
//   final String? gigThumbnail;
//   final List<String>? features;
//   final String? currency;

//   OfferDetails({
//     this.offerId,
//     required this.gigTitle,
//     required this.gigDescription,
//     required this.videoLength,
//     required this.price,
//     required this.deliveryDays,
//     required this.revisions,
//     this.status,
//     this.gigThumbnail,
//     this.features,
//     this.currency = 'USD',
//   });

//   factory OfferDetails.fromJson(Map<String, dynamic> json) {
//     return OfferDetails(
//       offerId: json['_id'] ?? json['offerId'],
//       gigTitle:
//           json['title'] ?? json['gigTitle'] ?? json['gig']?['title'] ?? '',
//       gigDescription: json['description'] ?? json['gigDescription'] ?? '',
//       videoLength: json['videoLength'] ?? 15,
//       price: (json['customPrice'] ?? json['price'] ?? 0).toDouble(),
//       deliveryDays: json['deliveryTimeDays'] ?? json['deliveryDays'] ?? 1,
//       revisions: json['numberOfRevisions'] ?? json['revisions'] ?? 3,
//       status: json['status'] ?? 'pending',
//       gigThumbnail: json['gig']?['gigThumbnail'] ?? json['gigThumbnail'],
//       features: json['features'] != null
//           ? List<String>.from(json['features'])
//           : null,
//       currency: json['currency'] ?? 'USD',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       if (offerId != null) 'offerId': offerId,
//       'gigTitle': gigTitle,
//       'gigDescription': gigDescription,
//       'videoLength': videoLength,
//       'price': price,
//       'deliveryDays': deliveryDays,
//       'revisions': revisions,
//       if (status != null) 'status': status,
//       if (gigThumbnail != null) 'gigThumbnail': gigThumbnail,
//       if (features != null) 'features': features,
//       'currency': currency,
//     };
//   }
// }

// class AdditionalRevisionDetails {
//   final String featureName;
//   final double extraPrice;
//   final int additionalDays;

//   AdditionalRevisionDetails({
//     required this.featureName,
//     required this.extraPrice,
//     required this.additionalDays,
//   });

//   factory AdditionalRevisionDetails.fromJson(Map<String, dynamic> json) {
//     return AdditionalRevisionDetails(
//       featureName: json['featureName'] ?? '',
//       extraPrice: (json['extraPrice'] ?? 0).toDouble(),
//       additionalDays: json['additionalDays'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'featureName': featureName,
//       'extraPrice': extraPrice,
//       'additionalDays': additionalDays,
//     };
//   }
// }

// class GigOption {
//   final String id;
//   final String title;
//   final String description;
//   final String imageUrl;
//   final double? price;
//   final int? deliveryDays;

//   GigOption({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.imageUrl,
//     this.price,
//     this.deliveryDays,
//   });

//   factory GigOption.fromJson(Map<String, dynamic> json) {
//     return GigOption(
//       id: json['_id'] ?? json['id'],
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       imageUrl: json['gigThumbnail'] ?? json['imageUrl'] ?? '',
//       price: json['price']?.toDouble(),
//       deliveryDays: json['deliveryDays'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'imageUrl': imageUrl,
//       if (price != null) 'price': price,
//       if (deliveryDays != null) 'deliveryDays': deliveryDays,
//     };
//   }
// }

// // Order Models (for reference)
// enum OrderStatus {
//   pending,
//   active,
//   inProgress,
//   delivered,
//   completed,
//   cancelled,
// }

// class OrderModel {
//   final String id;
//   final String gigId;
//   final String gigTitle;
//   final String gigImage;
//   final String clientId;
//   final String freelancerId;
//   final DateTime orderDate;
//   final OrderStatus status;
//   final double amount;
//   final DateTime? deliveryDate;

//   OrderModel({
//     required this.id,
//     required this.gigId,
//     required this.gigTitle,
//     required this.gigImage,
//     required this.clientId,
//     required this.freelancerId,
//     required this.orderDate,
//     required this.status,
//     required this.amount,
//     this.deliveryDate,
//   });

//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     OrderStatus parseStatus(String? status) {
//       switch (status?.toLowerCase()) {
//         case 'active':
//           return OrderStatus.active;
//         case 'in_progress':
//         case 'inprogress':
//           return OrderStatus.inProgress;
//         case 'delivered':
//           return OrderStatus.delivered;
//         case 'completed':
//           return OrderStatus.completed;
//         case 'cancelled':
//           return OrderStatus.cancelled;
//         default:
//           return OrderStatus.pending;
//       }
//     }

//     return OrderModel(
//       id: json['_id'] ?? json['id'],
//       gigId: json['gigId'] ?? json['gig']?['_id'],
//       gigTitle: json['gigTitle'] ?? json['gig']?['title'] ?? '',
//       gigImage: json['gigImage'] ?? json['gig']?['gigThumbnail'] ?? '',
//       clientId: json['clientId'] ?? json['client']?['_id'],
//       freelancerId: json['freelancerId'] ?? json['freelancer']?['_id'],
//       orderDate: json['orderDate'] != null || json['createdAt'] != null
//           ? DateTime.parse(json['orderDate'] ?? json['createdAt'])
//           : DateTime.now(),
//       status: parseStatus(json['status']),
//       amount: (json['amount'] ?? 0).toDouble(),
//       deliveryDate: json['deliveryDate'] != null
//           ? DateTime.parse(json['deliveryDate'])
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'gigId': gigId,
//       'gigTitle': gigTitle,
//       'gigImage': gigImage,
//       'clientId': clientId,
//       'freelancerId': freelancerId,
//       'orderDate': orderDate.toIso8601String(),
//       'status': status.toString().split('.').last,
//       'amount': amount,
//       if (deliveryDate != null) 'deliveryDate': deliveryDate!.toIso8601String(),
//     };
//   }
// }

// // Media File Models
// enum MediaFileType { image, video, audio, document, other }

// class MediaFile {
//   final String id;
//   final String fileName;
//   final String filePath;
//   final String fileUrl;
//   final MediaFileType type;
//   final int fileSize;
//   final DateTime uploadTime;
//   final bool isSent;
//   final String? duration;
//   final String? thumbnailUrl;

//   MediaFile({
//     required this.id,
//     required this.fileName,
//     required this.filePath,
//     required this.fileUrl,
//     required this.type,
//     required this.fileSize,
//     required this.uploadTime,
//     required this.isSent,
//     this.duration,
//     this.thumbnailUrl,
//   });

//   factory MediaFile.fromJson(Map<String, dynamic> json) {
//     MediaFileType parseType(String? type) {
//       switch (type?.toLowerCase()) {
//         case 'image':
//           return MediaFileType.image;
//         case 'video':
//           return MediaFileType.video;
//         case 'audio':
//           return MediaFileType.audio;
//         case 'document':
//           return MediaFileType.document;
//         default:
//           return MediaFileType.other;
//       }
//     }

//     return MediaFile(
//       id: json['_id'] ?? json['id'],
//       fileName: json['fileName'] ?? '',
//       filePath: json['filePath'] ?? '',
//       fileUrl: json['fileUrl'] ?? json['url'] ?? '',
//       type: parseType(json['type']),
//       fileSize: json['fileSize'] ?? 0,
//       uploadTime: json['uploadTime'] != null
//           ? DateTime.parse(json['uploadTime'])
//           : DateTime.now(),
//       isSent: json['isSent'] ?? false,
//       duration: json['duration'],
//       thumbnailUrl: json['thumbnailUrl'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'fileName': fileName,
//       'filePath': filePath,
//       'fileUrl': fileUrl,
//       'type': type.toString().split('.').last,
//       'fileSize': fileSize,
//       'uploadTime': uploadTime.toIso8601String(),
//       'isSent': isSent,
//       if (duration != null) 'duration': duration,
//       if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
//     };
//   }
// }

class ChatUser {
  final String id;
  final String name;
  final String avatar;
  final bool isOnline;
  final DateTime lastSeen;
  final String lastMessage;
  final int unreadCount;
  final String? chatId;
  final String? role;
  final String? brandCompanyName;
  final String? displayName;
  final String? firstName;
  final String? lastName;

  ChatUser({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isOnline,
    required this.lastSeen,
    required this.lastMessage,
    required this.unreadCount,
    this.chatId,
    this.role,
    this.brandCompanyName,
    this.displayName,
    this.firstName,
    this.lastName,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    final isCreatorView = json['creator'] != null;
    final userData = isCreatorView ? json['brand'] : json['creator'];

    String getName() {
      if (isCreatorView) {
        return userData?['brandCompanyName'] ??
            userData?['username'] ??
            'Unknown Brand';
      } else {
        return userData?['displayName'] ??
            '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}'
                .trim() ??
            'Unknown Creator';
      }
    }

    return ChatUser(
      id: isCreatorView ? json['brandId'] : json['creatorId'],
      name: getName(),
      avatar: userData?['imageUrl'] ?? 'https://via.placeholder.com/150',
      isOnline: false,
      lastSeen: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : DateTime.now(),
      lastMessage: json['lastMessage'] ?? 'No messages yet',
      unreadCount: isCreatorView
          ? (json['creatorUnreadCount'] ?? 0)
          : (json['brandUnreadCount'] ?? 0),
      chatId: json['_id'],
      role: userData?['role'],
      brandCompanyName: userData?['brandCompanyName'],
      displayName: userData?['displayName'],
      firstName: userData?['firstName'],
      lastName: userData?['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'chatId': chatId,
      'role': role,
    };
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  offer,
  overdue,
  alert,
  additionalRevision,
  system,
  orderCreated,
}

class ChatMessage {
  final String id;
  final String? senderId; // FIXED: Made nullable for system messages
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final OfferDetails? offerDetails;
  final AdditionalRevisionDetails? revisionDetails;
  final String? chatId;
  final List<Attachment>? attachments;
  final Map<String, dynamic>? metadata;
  final bool? isRead;

  ChatMessage({
    required this.id,
    this.senderId, // FIXED: Made optional
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.offerDetails,
    this.revisionDetails,
    this.chatId,
    this.attachments,
    this.metadata,
    this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    MessageType getType(String? typeStr) {
      switch (typeStr?.toLowerCase()) {
        case 'image':
          return MessageType.image;
        case 'video':
          return MessageType.video;
        case 'audio':
          return MessageType.audio;
        case 'file':
          return MessageType.file;
        case 'overdue':
          return MessageType.overdue;
        case 'alert':
          return MessageType.alert;
        case 'custom_offer':
          return MessageType.offer;
        case 'additional_revision':
          return MessageType.additionalRevision;
        case 'system':
          return MessageType.system;
        case 'order_created':
          return MessageType.orderCreated;
        default:
          return MessageType.text;
      }
    }

    OfferDetails? parseOfferDetails(Map<String, dynamic>? json) {
      if (json == null) return null;
      try {
        return OfferDetails.fromJson(json);
      } catch (e) {
        log('Error parsing offer details: $e');
        return null;
      }
    }

    List<Attachment>? parseAttachments(dynamic attachments) {
      if (attachments == null) return null;
      if (attachments is! List) return null;

      try {
        return attachments
            .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
            .toList();
      } catch (e) {
        log('Error parsing attachments: $e');
        return null;
      }
    }

    // FIXED: Handle null senderId safely
    final senderId =
        json['senderId'] ??
        json['sender']?['_id'] ??
        (json['senderId'] == null &&
                (json['type'] == 'system' || json['type'] == 'order_created')
            ? null
            : 'unknown');

    return ChatMessage(
      id: json['_id'] ?? json['id'],
      senderId: senderId == 'unknown' ? null : senderId,
      senderName:
          json['senderName'] ??
          json['sender']?['displayName'] ??
          json['sender']?['username'] ??
          'System',
      content: json['content'] ?? '',
      type: getType(json['type']),
      timestamp: json['timestamp'] != null || json['createdAt'] != null
          ? DateTime.parse(json['timestamp'] ?? json['createdAt'])
          : DateTime.now(),
      filePath: json['filePath'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      offerDetails: parseOfferDetails(
        json['metadata']?['offerData'] ?? json['offerDetails'],
      ),
      chatId: json['chatId'] ?? json['chat'],
      attachments: parseAttachments(json['attachments']),
      metadata: json['metadata'],
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    String getTypeString() {
      switch (type) {
        case MessageType.image:
          return 'image';
        case MessageType.video:
          return 'video';
        case MessageType.audio:
          return 'audio';
        case MessageType.overdue:
          return 'overdue';
        case MessageType.alert:
          return 'alert';
        case MessageType.file:
          return 'file';
        case MessageType.offer:
          return 'custom_offer';
        case MessageType.additionalRevision:
          return 'additional_revision';
        case MessageType.system:
          return 'system';
        case MessageType.orderCreated:
          return 'order_created';
        default:
          return 'text';
      }
    }

    return {
      'id': id,
      if (senderId != null) 'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': getTypeString(),
      'timestamp': timestamp.toIso8601String(),
      if (filePath != null) 'filePath': filePath,
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
      if (offerDetails != null) 'offerDetails': offerDetails!.toJson(),
      if (chatId != null) 'chatId': chatId,
      if (attachments != null)
        'attachments': attachments!.map((a) => a.toJson()).toList(),
      if (metadata != null) 'metadata': metadata,
      if (isRead != null) 'isRead': isRead,
    };
  }
}

class Attachment {
  final String url;
  final String type;
  final String? name;
  final int? size;
  final String? thumbnailUrl;

  Attachment({
    required this.url,
    required this.type,
    this.name,
    this.size,
    this.thumbnailUrl,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      url: json['url'],
      type: json['type'],
      name: json['name'],
      size: json['size'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
      if (name != null) 'name': name,
      if (size != null) 'size': size,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }
}

class OfferDetails {
  final String? offerId;
  final String gigTitle;
  final String gigDescription;
  final int videoLength;
  final double price;
  final int deliveryDays;
  final int revisions;
  final String? status;
  final String? gigThumbnail;
  final List<String>? features;
  final String? currency;

  OfferDetails({
    this.offerId,
    required this.gigTitle,
    required this.gigDescription,
    required this.videoLength,
    required this.price,
    required this.deliveryDays,
    required this.revisions,
    this.status,
    this.gigThumbnail,
    this.features,
    this.currency = 'USD',
  });

  // factory OfferDetails.fromJson(Map<String, dynamic> json) {
  //   return OfferDetails(
  //     offerId: json['_id'] ?? json['offerId'],
  //     gigTitle:
  //         json['title'] ?? json['gigTitle'] ?? json['gig']?['title'] ?? '',
  //     gigDescription: json['description'] ?? json['gigDescription'] ?? '',
  //     videoLength: json['videoTimeline'] ?? json['videoLength'] ?? 15,
  //     price: (json['customPrice'] ?? json['price'] ?? 0).toDouble(),
  //     deliveryDays: json['deliveryTimeDays'] ?? json['deliveryDays'] ?? 1,
  //     revisions: json['numberOfRevisions'] ?? json['revisions'] ?? 3,
  //     status: json['status'] ?? 'pending',
  //     gigThumbnail: json['gig']?['gigThumbnail'] ?? json['gigThumbnail'],
  //     features: json['features'] != null
  //         ? List<String>.from(json['features'])
  //         : null,
  //     currency: json['currency'] ?? 'USD',
  //   );
  // }

  factory OfferDetails.fromJson(Map<String, dynamic> json) {
    return OfferDetails(
      offerId: json['_id'] ?? json['offerId'],
      gigTitle:
          json['title'] ?? json['gigTitle'] ?? json['gig']?['title'] ?? '',
      gigDescription: json['description'] ?? json['gigDescription'] ?? '',
      videoLength:
          _parseInt(json['videoTimeline']) ??
          _parseInt(json['videoLength']) ??
          15,
      price: (json['customPrice'] ?? json['price'] ?? 0).toDouble(),
      deliveryDays:
          _parseInt(json['deliveryTimeDays']) ??
          _parseInt(json['deliveryDays']) ??
          1,
      revisions:
          _parseInt(json['numberOfRevisions']) ??
          _parseInt(json['revisions']) ??
          3,
      status: json['status'] ?? 'pending',
      gigThumbnail: json['gig']?['gigThumbnail'] ?? json['gigThumbnail'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : null,
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (offerId != null) 'offerId': offerId,
      'gigTitle': gigTitle,
      'gigDescription': gigDescription,
      'videoLength': videoLength,
      'price': price,
      'deliveryDays': deliveryDays,
      'revisions': revisions,
      if (status != null) 'status': status,
      if (gigThumbnail != null) 'gigThumbnail': gigThumbnail,
      if (features != null) 'features': features,
      'currency': currency,
    };
  }
}

// Helper function to safely parse an int from a dynamic value (either String or int)
int? _parseInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(
      value,
    ); // Will return null if the string cannot be parsed to int
  }
  return null;
}

class AdditionalRevisionDetails {
  final String featureName;
  final double extraPrice;
  final int additionalDays;

  AdditionalRevisionDetails({
    required this.featureName,
    required this.extraPrice,
    required this.additionalDays,
  });

  factory AdditionalRevisionDetails.fromJson(Map<String, dynamic> json) {
    return AdditionalRevisionDetails(
      featureName: json['featureName'] ?? '',
      extraPrice: (json['extraPrice'] ?? 0).toDouble(),
      additionalDays: json['additionalDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'featureName': featureName,
      'extraPrice': extraPrice,
      'additionalDays': additionalDays,
    };
  }
}

class GigOption {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double? price;
  final int? deliveryDays;

  GigOption({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.price,
    this.deliveryDays,
  });

  factory GigOption.fromJson(Map<String, dynamic> json) {
    return GigOption(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['gigThumbnail'] ?? json['imageUrl'] ?? '',
      price: json['price']?.toDouble(),
      deliveryDays: json['deliveryDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      if (price != null) 'price': price,
      if (deliveryDays != null) 'deliveryDays': deliveryDays,
    };
  }
}

enum OrderStatus {
  pending,
  active,
  inProgress,
  delivered,
  completed,
  cancelled,
}

class OrderModel {
  final String id;
  final String gigId;
  final String gigTitle;
  final String gigImage;
  final String clientId;
  final String freelancerId;
  final DateTime orderDate;
  final OrderStatus status;
  final double amount;
  final DateTime? deliveryDate;

  OrderModel({
    required this.id,
    required this.gigId,
    required this.gigTitle,
    required this.gigImage,
    required this.clientId,
    required this.freelancerId,
    required this.orderDate,
    required this.status,
    required this.amount,
    this.deliveryDate,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    OrderStatus parseStatus(String? status) {
      switch (status?.toLowerCase()) {
        case 'active':
          return OrderStatus.active;
        case 'in_progress':
        case 'inprogress':
          return OrderStatus.inProgress;
        case 'delivered':
          return OrderStatus.delivered;
        case 'completed':
          return OrderStatus.completed;
        case 'cancelled':
          return OrderStatus.cancelled;
        default:
          return OrderStatus.pending;
      }
    }

    return OrderModel(
      id: json['_id'] ?? json['id'],
      gigId: json['gigId'] ?? json['gig']?['_id'],
      gigTitle: json['gigTitle'] ?? json['gig']?['title'] ?? '',
      gigImage: json['gigImage'] ?? json['gig']?['gigThumbnail'] ?? '',
      clientId: json['clientId'] ?? json['client']?['_id'],
      freelancerId: json['freelancerId'] ?? json['freelancer']?['_id'],
      orderDate: json['orderDate'] != null || json['createdAt'] != null
          ? DateTime.parse(json['orderDate'] ?? json['createdAt'])
          : DateTime.now(),
      status: parseStatus(json['status']),
      amount: (json['amount'] ?? 0).toDouble(),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gigId': gigId,
      'gigTitle': gigTitle,
      'gigImage': gigImage,
      'clientId': clientId,
      'freelancerId': freelancerId,
      'orderDate': orderDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'amount': amount,
      if (deliveryDate != null) 'deliveryDate': deliveryDate!.toIso8601String(),
    };
  }
}

enum MediaFileType { image, video, audio, document, other }

class MediaFile {
  final String id;
  final String fileName;
  final String filePath;
  final String fileUrl;
  final MediaFileType type;
  final int fileSize;
  final DateTime uploadTime;
  final bool isSent;
  final String? duration;
  final String? thumbnailUrl;

  MediaFile({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileUrl,
    required this.type,
    required this.fileSize,
    required this.uploadTime,
    required this.isSent,
    this.duration,
    this.thumbnailUrl,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    MediaFileType parseType(String? type) {
      switch (type?.toLowerCase()) {
        case 'image':
          return MediaFileType.image;
        case 'video':
          return MediaFileType.video;
        case 'audio':
          return MediaFileType.audio;
        case 'document':
          return MediaFileType.document;
        default:
          return MediaFileType.other;
      }
    }

    return MediaFile(
      id: json['_id'] ?? json['id'],
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      fileUrl: json['fileUrl'] ?? json['url'] ?? '',
      type: parseType(json['type']),
      fileSize: json['fileSize'] ?? 0,
      uploadTime: json['uploadTime'] != null
          ? DateTime.parse(json['uploadTime'])
          : DateTime.now(),
      isSent: json['isSent'] ?? false,
      duration: json['duration'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileUrl': fileUrl,
      'type': type.toString().split('.').last,
      'fileSize': fileSize,
      'uploadTime': uploadTime.toIso8601String(),
      'isSent': isSent,
      if (duration != null) 'duration': duration,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }
}


