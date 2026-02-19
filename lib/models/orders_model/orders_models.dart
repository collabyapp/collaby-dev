import 'dart:developer';

class OrderModel {
  final String id;
  final String orderNumber;
  final String title;
  final String gigThumbnail;
  final String brandName;
  final String brandLogo;
  final String brandIndustry;
  final DateTime endDate;
  OrderStatus status;
  final String paymentStatus;
  final String pricingName;
  final double totalAmount;
  final double creatorEarnings;
  final String currency;
  final int deliveryTimeDays;
  final int numberOfRevisions;
  final double? daysRemaining;
  final bool hasRequirementsSubmitted;
  final DateTime? requirementsSubmittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? declinedReason;
  final DateTime? declinedAt;
  final bool isNew;

  // Additional fields for detail view
  final String? description;
  final List<String>? includes;
  final String? workDescription;
  List<OrderSubmission>? submissions;
  List<TimelineEvent>? timelineEvents;

  // Activity Timeline fields
  List<ActivityEvent>? activityEvents;
  final OrderInfo? orderInfo;
  final CreatorActions? creatorActions;

  // Other existing fields
  final String? gigId;
  final String? gigDescription;
  final String? gigStatus;
  final String? pricingId;
  final double? basePrice;
  final double? additionalFeaturesTotal;
  final double? serviceFee;
  final List<Map<String, dynamic>>? selectedAdditionalFeatures;
  final List<String>? pricingFeatures;
  final OrderRequirements? orderRequirements;
  final List<OrderQuestionAnswer>? orderSpecificQuestionAnswers;
  final BrandDetails? brandDetails;
  final bool? isReviewed;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.title,
    required this.gigThumbnail,
    required this.brandName,
    required this.brandLogo,
    required this.brandIndustry,
    required this.endDate,
    required this.status,
    required this.paymentStatus,
    required this.pricingName,
    required this.totalAmount,
    required this.creatorEarnings,
    required this.currency,
    required this.deliveryTimeDays,
    required this.numberOfRevisions,
    this.daysRemaining,
    required this.hasRequirementsSubmitted,
    this.requirementsSubmittedAt,
    required this.createdAt,
    required this.updatedAt,
    this.declinedReason,
    this.declinedAt,
    this.isNew = false,
    this.description,
    this.includes,
    this.workDescription,
    this.submissions,
    this.timelineEvents,
    this.activityEvents,
    this.orderInfo,
    this.creatorActions,
    this.gigId,
    this.gigDescription,
    this.gigStatus,
    this.pricingId,
    this.basePrice,
    this.additionalFeaturesTotal,
    this.serviceFee,
    this.selectedAdditionalFeatures,
    this.pricingFeatures,
    this.orderRequirements,
    this.orderSpecificQuestionAnswers,
    this.brandDetails,
    this.isReviewed,
  });

  /// SAFE helper to extract string from dynamic value
  static String _safeString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is Map) return value.toString();
    return value.toString();
  }

  /// SAFE helper to extract int from dynamic value
  static int _safeInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  /// SAFE helper to extract double from dynamic value
  static double _safeDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  /// SAFE helper to extract bool from dynamic value
  static bool _safeBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return fallback;
  }

  /// SAFE helper to parse DateTime
  static DateTime? _safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static DateTime _resolveEndDate(
    Map<String, dynamic> json, {
    required int deliveryTimeDays,
  }) {
    final directEndDate =
        _safeDateTime(json['calculatedDeliveryDate']) ??
        _safeDateTime(json['expectedDeliveryDate']) ??
        _safeDateTime(json['deliveryDate']) ??
        _safeDateTime(json['endDate']);
    if (directEndDate != null) return directEndDate;

    final baseDate =
        _safeDateTime(json['acceptedAt']) ??
        _safeDateTime(json['inProgressAt']) ??
        _safeDateTime(json['requirementsSubmittedAt']) ??
        _safeDateTime(json['updatedAt']) ??
        _safeDateTime(json['createdAt']) ??
        DateTime.now();

    final safeDays = deliveryTimeDays > 0 ? deliveryTimeDays : 0;
    return baseDate.add(Duration(days: safeDays));
  }

  static double? _resolveDaysRemaining(
    Map<String, dynamic> json,
    DateTime endDate,
  ) {
    // Backend sometimes returns 0 right after acceptance; in that case,
    // derive from endDate instead of trusting the stale payload.
    final raw = _safeDouble(json['daysRemaining'], fallback: -1);
    if (raw > 0) return raw;

    final hoursLeft = endDate.difference(DateTime.now()).inMinutes / 60.0;
    final derivedDays = hoursLeft / 24.0;
    return derivedDays > 0 ? derivedDays : 0;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      // Safe extraction with fallbacks
      final brandInfo = json['brandInfo'] as Map<String, dynamic>?;
      final brandProfile = json['brandProfile'] as Map<String, dynamic>?;
      final resolvedDeliveryTimeDays = _safeInt(json['deliveryTimeDays']);
      final resolvedEndDate = _resolveEndDate(
        json,
        deliveryTimeDays: resolvedDeliveryTimeDays,
      );
      final resolvedDaysRemaining = _resolveDaysRemaining(
        json,
        resolvedEndDate,
      );

      return OrderModel(
        id: _safeString(json['_id'] ?? json['id']),
        orderNumber: _safeString(json['orderNumber']),
        title: _safeString(
          json['gigName'] ?? json['title'] ?? (json['gig'] as Map?)?['title'],
        ),
        gigThumbnail: _safeString(
          json['gigThumbnail'] ?? (json['gig'] as Map?)?['gigThumbnail'],
        ),
        brandName: _safeString(
          brandInfo?['name'] ??
              brandProfile?['brandCompanyName'] ??
              brandProfile?['username'],
        ),
        brandLogo: _safeString(brandInfo?['logo'] ?? brandProfile?['imageUrl']),
        brandIndustry: _safeString(
          brandInfo?['industry'] ?? brandProfile?['industry'],
        ),
        endDate: resolvedEndDate,
        status: parseStatus(_safeString(json['status'])),
        paymentStatus: _safeString(json['paymentStatus']),
        pricingName: _safeString(
          json['pricingName'] ?? (json['pricing'] as Map?)?['pricingName'],
        ),
        totalAmount: _safeDouble(json['totalAmount']),
        creatorEarnings: _safeDouble(json['creatorEarnings']),
        currency: _safeString(
          json['currency'] ?? (json['pricing'] as Map?)?['currency'],
          fallback: 'USD',
        ),
        deliveryTimeDays: resolvedDeliveryTimeDays,
        numberOfRevisions: _safeInt(json['numberOfRevisions']),
        daysRemaining: resolvedDaysRemaining,
        hasRequirementsSubmitted: _safeBool(json['hasRequirementsSubmitted']),
        requirementsSubmittedAt: _safeDateTime(json['requirementsSubmittedAt']),
        createdAt: _safeDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: _safeDateTime(json['updatedAt']) ?? DateTime.now(),
        declinedReason: _safeString(json['declinedReason']),
        declinedAt: _safeDateTime(json['declinedAt']),
        isNew: _safeString(json['status']) == 'Requested',
      );
    } catch (e) {
      log('Error parsing OrderModel: $e');
      log('JSON: $json');
      rethrow;
    }
  }

  factory OrderModel.fromDetailJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] ?? json;
      final gigData = data['gig'] as Map<String, dynamic>?;
      final pricingData = data['pricing'] as Map<String, dynamic>?;
      final orderData = data['order'] as Map<String, dynamic>? ?? data;
      final brandData = data['brand'] as Map<String, dynamic>?;
      final brandProfile = data['brandProfile'] as Map<String, dynamic>?;

      // Extract brand info safely
      String brandName = '';
      String brandLogo = '';
      String brandIndustry = '';

      if (brandData != null) {
        final profile = brandData['profile'] as Map<String, dynamic>?;
        brandName = _safeString(
          profile?['brandCompanyName'] ?? profile?['username'],
        );
        brandLogo = _safeString(profile?['imageUrl']);
        brandIndustry = _safeString(profile?['industry']);
      } else if (brandProfile != null) {
        brandName = _safeString(
          brandProfile['brandCompanyName'] ?? brandProfile['username'],
        );
        brandLogo = _safeString(brandProfile['imageUrl']);
        brandIndustry = _safeString(brandProfile['industry']);
      }

      return OrderModel(
        id: _safeString(orderData['_id']),
        orderNumber: _safeString(orderData['orderNumber']),
        title: _safeString(gigData?['title']),
        gigThumbnail: _safeString(gigData?['gigThumbnail']),
        brandName: brandName,
        brandLogo: brandLogo,
        brandIndustry: brandIndustry,
        endDate: DateTime.now().add(
          Duration(days: _safeInt(orderData['deliveryTimeDays'])),
        ),
        status: parseStatus(_safeString(orderData['status'])),
        paymentStatus: _safeString(orderData['paymentStatus']),
        pricingName: _safeString(pricingData?['pricingName']),
        totalAmount: _safeDouble(orderData['totalAmount']),
        creatorEarnings: _safeDouble(orderData['creatorEarnings']),
        currency: _safeString(pricingData?['currency'], fallback: 'USD'),
        deliveryTimeDays: _safeInt(orderData['deliveryTimeDays']),
        numberOfRevisions: _safeInt(orderData['numberOfRevisions']),
        hasRequirementsSubmitted: _safeBool(
          orderData['hasRequirementsSubmitted'],
        ),
        requirementsSubmittedAt: _safeDateTime(
          orderData['requirementsSubmittedAt'],
        ),
        createdAt: _safeDateTime(orderData['createdAt']) ?? DateTime.now(),
        updatedAt: _safeDateTime(orderData['updatedAt']) ?? DateTime.now(),
        isNew: _safeString(orderData['status']) == 'Requested',
        gigId: _safeString(gigData?['_id']),
        gigDescription: _safeString(gigData?['description']),
        gigStatus: _safeString(gigData?['gigStatus']),
        description: _safeString(gigData?['description']),
        pricingId: _safeString(pricingData?['_id']),
        basePrice: _safeDouble(pricingData?['price']),
        additionalFeaturesTotal: _safeDouble(
          orderData['additionalFeaturesTotal'],
        ),
        serviceFee: _safeDouble(orderData['serviceFee']),
        pricingFeatures: _safeStringList(pricingData?['features']),
        includes: _safeStringList(pricingData?['features']),
        selectedAdditionalFeatures: _safeMapList(
          orderData['selectedAdditionalFeatures'],
        ),
        orderRequirements:
            data['orderRequirements'] != null || data['requirements'] != null
            ? OrderRequirements.fromJson(
                data['orderRequirements'] ?? data['requirements'],
              )
            : null,
        workDescription: _safeString(
          (data['orderRequirements'] ??
              data['requirements'])?['workDescription'],
        ),
        orderSpecificQuestionAnswers: _safeQuestionAnswers(
          data['orderSpecificQuestionAnswers'] ?? data['answers'],
        ),
        brandDetails: brandData != null
            ? BrandDetails.fromJson(brandData)
            : null,
        isReviewed: _safeBool(data['isReviewed']),
      );
    } catch (e) {
      log('Error parsing OrderModel from detail: $e');
      log('JSON: $json');
      rethrow;
    }
  }

  /// Safe list extraction helpers
  static List<String>? _safeStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value
          .map((e) => _safeString(e))
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return null;
  }

  static List<Map<String, dynamic>>? _safeMapList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return null;
  }

  static List<OrderQuestionAnswer>? _safeQuestionAnswers(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      try {
        return value
            .whereType<Map<String, dynamic>>()
            .map(OrderQuestionAnswer.fromJson)
            .toList();
      } catch (e) {
        log('Error parsing question answers: $e');
        return null;
      }
    }
    return null;
  }

  factory OrderModel.fromActivityJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final activities = data['activities'] as List<dynamic>?;
    final orderInfo = data['orderInfo'];
    final creatorsActions = data['creatorsActions'];

    return OrderModel(
      id: '',
      orderNumber: '',
      title: '',
      gigThumbnail: '',
      brandName: '',
      brandLogo: '',
      brandIndustry: '',
      endDate: DateTime.now(),
      status: orderInfo != null
          ? parseStatus(_safeString(orderInfo['status']))
          : OrderStatus.newOrder,
      paymentStatus: '',
      pricingName: '',
      totalAmount: 0,
      creatorEarnings: 0,
      currency: 'USD',
      deliveryTimeDays: 0,
      numberOfRevisions: _safeInt(orderInfo?['numberOfRevisions']),
      hasRequirementsSubmitted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      activityEvents: activities
          ?.whereType<Map<String, dynamic>>()
          .map(ActivityEvent.fromJson)
          .toList(),
      orderInfo: orderInfo != null ? OrderInfo.fromJson(orderInfo) : null,
      creatorActions: creatorsActions != null
          ? CreatorActions.fromJson(creatorsActions)
          : null,
    );
  }

  static OrderStatus parseStatus(String? status) {
    if (status == null || status.isEmpty) return OrderStatus.newOrder;

    String normalizedStatus = status.toLowerCase().replaceAll(' ', '');

    switch (normalizedStatus) {
      case 'requested':
        return OrderStatus.newOrder;
      case 'active':
        return OrderStatus.active;
      case 'inprogress':
        return OrderStatus.inProgress;
      case 'inrevision':
        return OrderStatus.inRevision;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'declined':
        return OrderStatus.declined;
      case 'draft':
        return OrderStatus.draft;
      default:
        return OrderStatus.newOrder;
    }
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? title,
    String? gigThumbnail,
    String? brandName,
    String? brandLogo,
    String? brandIndustry,
    DateTime? endDate,
    OrderStatus? status,
    String? paymentStatus,
    String? pricingName,
    double? totalAmount,
    double? creatorEarnings,
    String? currency,
    int? deliveryTimeDays,
    int? numberOfRevisions,
    double? daysRemaining,
    bool? hasRequirementsSubmitted,
    DateTime? requirementsSubmittedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? declinedReason,
    DateTime? declinedAt,
    bool? isNew,
    String? description,
    List<String>? includes,
    String? workDescription,
    List<OrderSubmission>? submissions,
    List<TimelineEvent>? timelineEvents,
    List<ActivityEvent>? activityEvents,
    OrderInfo? orderInfo,
    CreatorActions? creatorActions,
    String? gigId,
    String? gigDescription,
    String? gigStatus,
    String? pricingId,
    double? basePrice,
    double? additionalFeaturesTotal,
    double? serviceFee,
    List<Map<String, dynamic>>? selectedAdditionalFeatures,
    List<String>? pricingFeatures,
    OrderRequirements? orderRequirements,
    List<OrderQuestionAnswer>? orderSpecificQuestionAnswers,
    BrandDetails? brandDetails,
    bool? isReviewed,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      title: title ?? this.title,
      gigThumbnail: gigThumbnail ?? this.gigThumbnail,
      brandName: brandName ?? this.brandName,
      brandLogo: brandLogo ?? this.brandLogo,
      brandIndustry: brandIndustry ?? this.brandIndustry,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pricingName: pricingName ?? this.pricingName,
      totalAmount: totalAmount ?? this.totalAmount,
      creatorEarnings: creatorEarnings ?? this.creatorEarnings,
      currency: currency ?? this.currency,
      deliveryTimeDays: deliveryTimeDays ?? this.deliveryTimeDays,
      numberOfRevisions: numberOfRevisions ?? this.numberOfRevisions,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      hasRequirementsSubmitted:
          hasRequirementsSubmitted ?? this.hasRequirementsSubmitted,
      requirementsSubmittedAt:
          requirementsSubmittedAt ?? this.requirementsSubmittedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      declinedReason: declinedReason ?? this.declinedReason,
      declinedAt: declinedAt ?? this.declinedAt,
      isNew: isNew ?? this.isNew,
      description: description ?? this.description,
      includes: includes ?? this.includes,
      workDescription: workDescription ?? this.workDescription,
      submissions: submissions ?? this.submissions,
      timelineEvents: timelineEvents ?? this.timelineEvents,
      activityEvents: activityEvents ?? this.activityEvents,
      orderInfo: orderInfo ?? this.orderInfo,
      creatorActions: creatorActions ?? this.creatorActions,
      gigId: gigId ?? this.gigId,
      gigDescription: gigDescription ?? this.gigDescription,
      gigStatus: gigStatus ?? this.gigStatus,
      pricingId: pricingId ?? this.pricingId,
      basePrice: basePrice ?? this.basePrice,
      additionalFeaturesTotal:
          additionalFeaturesTotal ?? this.additionalFeaturesTotal,
      serviceFee: serviceFee ?? this.serviceFee,
      selectedAdditionalFeatures:
          selectedAdditionalFeatures ?? this.selectedAdditionalFeatures,
      pricingFeatures: pricingFeatures ?? this.pricingFeatures,
      orderRequirements: orderRequirements ?? this.orderRequirements,
      orderSpecificQuestionAnswers:
          orderSpecificQuestionAnswers ?? this.orderSpecificQuestionAnswers,
      brandDetails: brandDetails ?? this.brandDetails,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }
}

// Keep all other supporting classes (ActivityEvent, OrderRequirements, etc.) the same
// Just update the FileAttachment class:

class FileAttachment {
  final String name;
  final String type;
  final String url;
  final int size;

  FileAttachment({
    required this.name,
    required this.type,
    required this.url,
    required this.size,
  });

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      name: OrderModel._safeString(json['name']),
      type: OrderModel._safeString(json['type']),
      url: OrderModel._safeString(json['url']),
      size: OrderModel._safeInt(json['size']),
    );
  }

  String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);
}

// NEW Activity Timeline Models
class ActivityEvent {
  final String id;
  final String orderId;
  final String activityType;
  final String title;
  final String description;
  final PerformedBy performedBy;
  final ActivityMetadata? metadata;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityEvent({
    required this.id,
    required this.orderId,
    required this.activityType,
    required this.title,
    required this.description,
    required this.performedBy,
    this.metadata,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    return ActivityEvent(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      activityType: json['activityType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      performedBy: PerformedBy.fromJson(json['performedBy'] ?? {}),
      metadata: json['metadata'] != null
          ? ActivityMetadata.fromJson(json['metadata'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class PerformedBy {
  final String id;
  final String email;

  PerformedBy({required this.id, required this.email});

  factory PerformedBy.fromJson(Map<String, dynamic> json) {
    return PerformedBy(id: json['_id'] ?? '', email: json['email'] ?? '');
  }
}

class ActivityMetadata {
  final String? revisionReason;
  final int? revisionCount;
  final int? maxRevisions;
  final double? amount;
  final double? creatorEarnings;
  final String? currency;
  final String? stripePaymentIntentId;
  final String? paymentMethodId;
  final String? orderNumber;
  final String? deliveryId;
  final int? deliveryFilesCount;
  final bool? hasWorkDescription;

  ActivityMetadata({
    this.revisionReason,
    this.revisionCount,
    this.maxRevisions,
    this.amount,
    required this.creatorEarnings,
    this.currency,
    this.stripePaymentIntentId,
    this.paymentMethodId,
    this.orderNumber,
    this.deliveryId,
    this.deliveryFilesCount,
    this.hasWorkDescription,
  });

  factory ActivityMetadata.fromJson(Map<String, dynamic> json) {
    return ActivityMetadata(
      revisionReason: json['revisionReason'],
      revisionCount: json['revisionCount'],
      maxRevisions: json['maxRevisions'],
      amount: json['amount']?.toDouble(),
      creatorEarnings: json['creatorEarnings']?.toDouble(),
      currency: json['currency'],
      stripePaymentIntentId: json['stripePaymentIntentId'],
      paymentMethodId: json['paymentMethodId'],
      orderNumber: json['orderNumber'],
      deliveryId: json['deliveryId'],
      deliveryFilesCount: json['deliveryFilesCount'],
      hasWorkDescription: json['hasWorkDescription'],
    );
  }
}

class OrderInfo {
  final String status;
  final int revisionCount;
  final int numberOfRevisions;
  final String? lastRevisionReason;
  final String? chatId;
  final DateTime? lastRevisionRequestedAt;
  final bool isBuyer;
  final bool isCreator;

  OrderInfo({
    required this.status,
    required this.revisionCount,
    required this.numberOfRevisions,
    this.lastRevisionReason,
    this.chatId,
    this.lastRevisionRequestedAt,
    required this.isBuyer,
    required this.isCreator,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      status: json['status'] ?? '',
      revisionCount: json['revisionCount'] ?? 0,
      numberOfRevisions: json['numberOfRevisions'] ?? 0,
      chatId: json['chatId'] ?? '',
      lastRevisionReason: json['lastRevisionReason'],
      lastRevisionRequestedAt: json['lastRevisionRequestedAt'] != null
          ? DateTime.parse(json['lastRevisionRequestedAt'])
          : null,
      isBuyer: json['isBuyer'] ?? false,
      isCreator: json['isCreator'] ?? false,
    );
  }
}

class CreatorActions {
  final bool deliverNow;
  final bool showActions;

  CreatorActions({required this.deliverNow, required this.showActions});

  factory CreatorActions.fromJson(Map<String, dynamic> json) {
    return CreatorActions(
      deliverNow: json['deliverNow'] ?? false,
      showActions: json['showActions'] ?? false,
    );
  }
}

// Existing supporting classes remain the same...
class OrderRequirements {
  final String? workDescription;
  final List<FileAttachment>? workDescriptionAttachments;
  final String? scriptOption;
  final String? providedScript;
  final List<FileAttachment>? scriptAttachments;

  OrderRequirements({
    this.workDescription,
    this.workDescriptionAttachments,
    this.scriptOption,
    this.providedScript,
    this.scriptAttachments,
  });

  factory OrderRequirements.fromJson(Map<String, dynamic> json) {
    return OrderRequirements(
      workDescription: json['workDescription'],
      workDescriptionAttachments: json['workDescriptionAttachments'] != null
          ? (json['workDescriptionAttachments'] as List)
                .map((a) => FileAttachment.fromJson(a))
                .toList()
          : null,
      scriptOption: json['scriptOption'],
      providedScript: json['providedScript'],
      scriptAttachments: json['scriptAttachments'] != null
          ? (json['scriptAttachments'] as List)
                .map((a) => FileAttachment.fromJson(a))
                .toList()
          : null,
    );
  }
}

// class FileAttachment {
//   final String name;
//   final String type;
//   final String url;
//   final int size;

//   FileAttachment({
//     required this.name,
//     required this.type,
//     required this.url,
//     required this.size,
//   });

//   factory FileAttachment.fromJson(Map<String, dynamic> json) {
//     return FileAttachment(
//       name: json['name'] ?? '',
//       type: json['type'] ?? '',
//       url: json['url'] ?? '',
//       size: json['size'] ?? 0,
//     );
//   }

//   String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);
// }

class OrderQuestionAnswer {
  final Question question;
  final Answer answer;

  OrderQuestionAnswer({required this.question, required this.answer});

  factory OrderQuestionAnswer.fromJson(Map<String, dynamic> json) {
    return OrderQuestionAnswer(
      question: Question.fromJson(json['question']),
      answer: Answer.fromJson(json['answer']),
    );
  }
}

class Question {
  final String id;
  final String questionText;
  final String questionType;
  final List<String> options;
  final bool isRequired;

  Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.isRequired,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'] ?? '',
      questionText: json['questionText'] ?? '',
      questionType: json['questionType'] ?? '',
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],
      isRequired: json['isRequired'] ?? false,
    );
  }
}

class Answer {
  final String? textAnswer;
  final List<String>? multipleChoiceAnswers;
  final List<FileAttachment>? attachmentAnswers;

  Answer({this.textAnswer, this.multipleChoiceAnswers, this.attachmentAnswers});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      textAnswer: json['textAnswer'],
      multipleChoiceAnswers: json['multipleChoiceAnswers'] != null
          ? List<String>.from(json['multipleChoiceAnswers'])
          : null,
      attachmentAnswers: json['attachmentAnswers'] != null
          ? (json['attachmentAnswers'] as List)
                .map((a) => FileAttachment.fromJson(a))
                .toList()
          : null,
    );
  }
}

class BrandDetails {
  final UserInfo user;
  final BrandProfile profile;

  BrandDetails({required this.user, required this.profile});

  factory BrandDetails.fromJson(Map<String, dynamic> json) {
    return BrandDetails(
      user: UserInfo.fromJson(json['user']),
      profile: BrandProfile.fromJson(json['profile']),
    );
  }
}

class UserInfo {
  final String id;
  final String email;

  UserInfo({required this.id, required this.email});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(id: json['_id'] ?? '', email: json['email'] ?? '');
  }
}

class BrandProfile {
  final String? username;
  final String? brandCompanyName;
  final String? industry;
  final String? websiteUrl;
  final String? imageUrl;

  BrandProfile({
    this.username,
    this.brandCompanyName,
    this.industry,
    this.websiteUrl,
    this.imageUrl,
  });

  factory BrandProfile.fromJson(Map<String, dynamic> json) {
    return BrandProfile(
      username: json['username'],
      brandCompanyName: json['brandCompanyName'],
      industry: json['industry'],
      websiteUrl: json['websiteUrl'],
      imageUrl: json['imageUrl'],
    );
  }
}

enum OrderStatus {
  active,
  newOrder,
  completed,
  declined,
  inProgress,
  inRevision,
  delivered,
  draft,
}

class OrderSubmission {
  final String id;
  final DateTime date;
  final String status;
  final List<String> images;
  final String? workDetail;

  OrderSubmission({
    required this.id,
    required this.date,
    required this.status,
    required this.images,
    this.workDetail,
  });
}

class TimelineEvent {
  final String title;
  final String? description;
  final DateTime date;
  final String? earning;
  final bool isCompleted;

  TimelineEvent({
    required this.title,
    this.description,
    required this.date,
    this.earning,
    this.isCompleted = false,
  });
}

enum MessageType { text, image, video, file, project, revision }

enum FileType { image, video, document }

class ChatMessage {
  final String message;
  final bool isSender;
  final DateTime timestamp;
  final String senderName;
  final MessageType messageType;
  final String? imagePath;
  final String? projectDescription;
  final String? projectStatus;
  final String? projectImage;
  final String? postedTime;
  final String? revisionFeature;
  final String? revisionPrice;
  final String? revisionDeliveryDays;

  ChatMessage({
    required this.message,
    required this.isSender,
    required this.timestamp,
    required this.senderName,
    required this.messageType,
    this.imagePath,
    this.projectDescription,
    this.projectStatus,
    this.projectImage,
    this.postedTime,
    this.revisionFeature,
    this.revisionPrice,
    this.revisionDeliveryDays,
  });
}

// Delivery Models for API Integration

class DeliveryResponse {
  final List<Delivery> deliveries;
  final RevisionRequest? revisionRequest;
  final DeliveryOrderInfo orderInfo;

  DeliveryResponse({
    required this.deliveries,
    this.revisionRequest,
    required this.orderInfo,
  });

  factory DeliveryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return DeliveryResponse(
      deliveries: data['deliveries'] != null
          ? (data['deliveries'] as List)
                .map((d) => Delivery.fromJson(d))
                .toList()
          : [],
      revisionRequest: data['revisionRequest'] != null
          ? RevisionRequest.fromJson(data['revisionRequest'])
          : null,
      orderInfo: DeliveryOrderInfo.fromJson(data['orderInfo'] ?? {}),
    );
  }
}

class Delivery {
  final String id;
  final String orderId;
  final DeliveredBy deliveredBy;
  final String workDescription;
  final List<DeliveryFile> deliveryFiles;
  final String deliveryStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BrandsActions? brandsActions;
  final RevisionDetails? revisionDetails;

  Delivery({
    required this.id,
    required this.orderId,
    required this.deliveredBy,
    required this.workDescription,
    required this.deliveryFiles,
    required this.deliveryStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.brandsActions,
    this.revisionDetails,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      deliveredBy: DeliveredBy.fromJson(json['deliveredBy'] ?? {}),
      workDescription: json['workDescription'] ?? '',
      deliveryFiles: json['deliveryFiles'] != null
          ? (json['deliveryFiles'] as List)
                .map((f) => DeliveryFile.fromJson(f))
                .toList()
          : [],
      deliveryStatus: json['deliveryStatus'] ?? 'pending',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      brandsActions: json['brandsActions'] != null
          ? BrandsActions.fromJson(json['brandsActions'])
          : null,
      revisionDetails: json['revisionDetails'] != null
          ? RevisionDetails.fromJson(json['revisionDetails'])
          : null,
    );
  }

  // Helper to get status label
  String get statusLabel {
    switch (deliveryStatus.toLowerCase()) {
      case 'delivered':
      case 'revision_delivered':
        return 'Submitted';
      case 'approved':
        return 'Approved';
      case 'revision_requested':
        return 'Revision Requested';
      default:
        return 'Pending';
    }
  }

  // Helper to get status color
  String get statusColor {
    switch (deliveryStatus.toLowerCase()) {
      case 'delivered':
        return 'purple';
      case 'approved':
        return 'green';
      case 'revision_requested':
        return 'orange';
      case 'revision_delivered':
        return 'orange';
      default:
        return 'grey';
    }
  }
}

class DeliveredBy {
  final String id;
  final String email;

  DeliveredBy({required this.id, required this.email});

  factory DeliveredBy.fromJson(Map<String, dynamic> json) {
    return DeliveredBy(id: json['_id'] ?? '', email: json['email'] ?? '');
  }
}

class DeliveryFile {
  final String name;
  final String type;
  final String url;
  final int size;
  final DateTime uploadedAt;

  DeliveryFile({
    required this.name,
    required this.type,
    required this.url,
    required this.size,
    required this.uploadedAt,
  });

  factory DeliveryFile.fromJson(Map<String, dynamic> json) {
    return DeliveryFile(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      size: json['size'] ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  // Helper to get file size in MB
  String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);

  // Helper to check if it's video
  bool get isVideo => type.toLowerCase().contains('video');

  // Helper to check if it's image
  bool get isImage => type.toLowerCase().contains('image');

  // Helper to get file icon
  String get fileIcon {
    if (isVideo) return 'video';
    if (isImage) return 'image';
    return 'document';
  }
}

class BrandsActions {
  final bool canApprove;
  final bool canRequestRevision;
  final bool showActions;

  BrandsActions({
    required this.canApprove,
    required this.canRequestRevision,
    required this.showActions,
  });

  factory BrandsActions.fromJson(Map<String, dynamic> json) {
    return BrandsActions(
      canApprove: json['canApprove'] ?? false,
      canRequestRevision: json['canRequestRevision'] ?? false,
      showActions: json['showActions'] ?? false,
    );
  }
}

class RevisionDetails {
  final String revisionReason;
  final DateTime revisionRequestedAt;
  final int revisionNumber;
  final String status;
  final String brandName;
  final String brandImageUrl;

  RevisionDetails({
    required this.revisionReason,
    required this.revisionRequestedAt,
    required this.revisionNumber,
    required this.status,
    required this.brandName,
    required this.brandImageUrl,
  });

  factory RevisionDetails.fromJson(Map<String, dynamic> json) {
    return RevisionDetails(
      revisionReason: json['revisionReason'] ?? '',
      revisionRequestedAt: DateTime.parse(json['revisionRequestedAt']),
      revisionNumber: json['revisionNumber'] ?? 0,
      status: json['status'] ?? '',
      brandName: json['brandName'] ?? '',
      brandImageUrl: json['brandImageUrl'] ?? '',
    );
  }
}

class RevisionRequest {
  final String revisionReason;
  final DateTime revisionRequestedAt;
  final int revisionCount;
  final int maxRevisions;
  final String brandName;
  final String brandImageUrl;

  RevisionRequest({
    required this.revisionReason,
    required this.revisionRequestedAt,
    required this.revisionCount,
    required this.maxRevisions,
    required this.brandName,
    required this.brandImageUrl,
  });

  factory RevisionRequest.fromJson(Map<String, dynamic> json) {
    return RevisionRequest(
      revisionReason: json['revisionReason'] ?? '',
      revisionRequestedAt: DateTime.parse(json['revisionRequestedAt']),
      revisionCount: json['revisionCount'] ?? 0,
      maxRevisions: json['maxRevisions'] ?? 0,
      brandName: json['brandName'] ?? '',
      brandImageUrl: json['brandImageUrl'] ?? '',
    );
  }

  // Helper to check if revisions are available
  bool get hasRevisionsLeft => revisionCount < maxRevisions;
}

class DeliveryOrderInfo {
  final String status;
  final int revisionCount;
  final int numberOfRevisions;
  final bool isBuyer;
  final bool isCreator;

  DeliveryOrderInfo({
    required this.status,
    required this.revisionCount,
    required this.numberOfRevisions,
    required this.isBuyer,
    required this.isCreator,
  });

  factory DeliveryOrderInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderInfo(
      status: json['status'] ?? '',
      revisionCount: json['revisionCount'] ?? 0,
      numberOfRevisions: json['numberOfRevisions'] ?? 0,
      isBuyer: json['isBuyer'] ?? false,
      isCreator: json['isCreator'] ?? false,
    );
  }
}

class UploadedFile {
  final String name;
  final String path;
  final String size;
  final double progress;
  final FileType type;

  UploadedFile({
    required this.name,
    required this.path,
    required this.size,
    required this.progress,
    required this.type,
  });
}
