class BoostProfileResponse {
  final BoostData data;
  final int statusCode;
  final String message;
  final String timestamp;

  BoostProfileResponse({
    required this.data,
    required this.statusCode,
    required this.message,
    required this.timestamp,
  });

  factory BoostProfileResponse.fromJson(Map<String, dynamic> json) {
    return BoostProfileResponse(
      data: BoostData.fromJson(json['data']),
      statusCode: json['statusCode'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}

class BoostData {
  final Subscription subscription;
  final Analytics analytics;
  final PerformanceGraph performanceGraph;

  BoostData({
    required this.subscription,
    required this.analytics,
    required this.performanceGraph,
  });

  factory BoostData.fromJson(Map<String, dynamic> json) {
    return BoostData(
      subscription: Subscription.fromJson(json['subscription']),
      analytics: Analytics.fromJson(json['analytics']),
      performanceGraph: PerformanceGraph.fromJson(json['performanceGraph']),
    );
  }
}

class Subscription {
  final String id;
  final String userId;
  final String boostType;
  final int duration;
  final String expiresAt;
  final String subscriptionStartDate;
  final String status;
  final bool isRecurring;
  final bool autoRenewal;
  final int renewalCount;
  final String createdAt;
  final String updatedAt;
  final PlanDetails planDetails;
  final int daysRemaining;
  final bool isActive;

  Subscription({
    required this.id,
    required this.userId,
    required this.boostType,
    required this.duration,
    required this.expiresAt,
    required this.subscriptionStartDate,
    required this.status,
    required this.isRecurring,
    required this.autoRenewal,
    required this.renewalCount,
    required this.createdAt,
    required this.updatedAt,
    required this.planDetails,
    required this.daysRemaining,
    required this.isActive,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      boostType: json['boostType'],
      duration: json['duration'],
      expiresAt: json['expiresAt'],
      subscriptionStartDate: json['subscriptionStartDate'],
      status: json['status'],
      isRecurring: json['isRecurring'],
      autoRenewal: json['autoRenewal'],
      renewalCount: json['renewalCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      planDetails: PlanDetails.fromJson(json['planDetails']),
      daysRemaining: json['daysRemaining'],
      isActive: json['isActive'],
    );
  }

  Subscription copyWith({bool? autoRenewal}) {
    return Subscription(
      id: id,
      userId: userId,
      boostType: boostType,
      duration: duration,
      expiresAt: expiresAt,
      subscriptionStartDate: subscriptionStartDate,
      status: status,
      isRecurring: isRecurring,
      autoRenewal: autoRenewal ?? this.autoRenewal,
      renewalCount: renewalCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      planDetails: planDetails,
      daysRemaining: daysRemaining,
      isActive: isActive,
    );
  }
}

class PlanDetails {
  final String name;
  final int duration;
  final double multiplier;
  final List<String> features;
  final String description;
  final int price;
  final String currency;
  final String badge;

  PlanDetails({
    required this.name,
    required this.duration,
    required this.multiplier,
    required this.features,
    required this.description,
    required this.price,
    required this.currency,
    required this.badge,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) {
    return PlanDetails(
      name: json['name'],
      duration: json['duration'],
      multiplier: _parseMultiplier(json['multiplier']),
      features: List<String>.from(json['features']),
      description: json['description'],
      price: json['price'],
      currency: json['currency'],
      badge: json['badge'],
    );
  }
}

double _parseMultiplier(dynamic value) {
  if (value == null) {
    return 0.0; // Default value if it's null
  }
  if (value is double) {
    return value;
  } else if (value is int) {
    return value.toDouble(); // Convert int to double
  } else if (value is String) {
    return double.tryParse(value) ?? 1.0; // Try to parse String to double
  }
  return 1.0; // Fallback to default value if all else fails
}

class Analytics {
  final Period period;
  final int profileViews;
  final int responseRate;
  final int newLeads;
  final int totalEngagement;

  Analytics({
    required this.period,
    required this.profileViews,
    required this.responseRate,
    required this.newLeads,
    required this.totalEngagement,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      period: Period.fromJson(json['period']),
      profileViews: json['profileViews'],
      responseRate: json['responseRate'],
      newLeads: json['newLeads'],
      totalEngagement: json['totalEngagement'],
    );
  }
}

class Period {
  final String startDate;
  final String endDate;
  final int days;

  Period({required this.startDate, required this.endDate, required this.days});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      startDate: json['startDate'],
      endDate: json['endDate'],
      days: json['days'],
    );
  }
}

class PerformanceGraph {
  final List<DailyData> dailyData;
  final Summary summary;

  PerformanceGraph({required this.dailyData, required this.summary});

  factory PerformanceGraph.fromJson(Map<String, dynamic> json) {
    return PerformanceGraph(
      dailyData: (json['dailyData'] as List)
          .map((e) => DailyData.fromJson(e))
          .toList(),
      summary: Summary.fromJson(json['summary']),
    );
  }
}

class DailyData {
  final String date;
  final int profileViews;
  final int responseRate;
  final int newLeads;

  DailyData({
    required this.date,
    required this.profileViews,
    required this.responseRate,
    required this.newLeads,
  });

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
      date: json['date'],
      profileViews: json['profileViews'],
      responseRate: json['responseRate'],
      newLeads: json['newLeads'],
    );
  }
}

class Summary {
  final int totalProfileViews;
  final int averageResponseRate;
  final int totalNewLeads;

  Summary({
    required this.totalProfileViews,
    required this.averageResponseRate,
    required this.totalNewLeads,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalProfileViews: json['totalProfileViews'],
      averageResponseRate: json['averageResponseRate'],
      totalNewLeads: json['totalNewLeads'],
    );
  }
}
