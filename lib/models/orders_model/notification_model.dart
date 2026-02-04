enum NotificationType { order, jobApplication, message, payment, other }

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  // ---------- API mapping ----------
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final String rawType = (json['type'] ?? '').toString();

    return NotificationModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      // Prefer "body"; if your design needs a shorter text, you can parse from data.
      description: (json['body'] ?? '').toString(),
      type: _mapType(rawType),
      timestamp: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isRead: json['isDeleted'] == true
          ? true
          : false, // or use a separate isRead if backend adds it later
    );
  }

  static NotificationType _mapType(String raw) {
    switch (raw) {
      case 'order_requested':
        return NotificationType.order;
      case 'revision_requested':
        return NotificationType.message;
      case 'delivery_approved':
        return NotificationType.payment;
      // add more back-end types here
      default:
        return NotificationType.other;
    }
  }
}
