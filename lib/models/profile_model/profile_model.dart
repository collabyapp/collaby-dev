class ProfileModel {
  final String role;
  final String status;
  final String badge;
  final String userId;
  final String imageUrl;
  final String firstName;
  final String lastName;
  final String displayName;
  final String description;
  final String ageGroup;
  final String gender;
  final String country;
  final List<LanguageModel> languages;
  final ShippingAddress shippingAddress;
  final List<String> niches;
  final ReviewStatsModel reviewStats;
  final SubscriptionModel? subscription;
  final AnalyticsModel? analytics;
  final bool isConnectedAccount;
  final String? stripeConnectedAccountId;
  final ActiveBoostModel? activeBoost;
  final List<PortfolioItem> portfolio;
  final List<GigReviewModel> reviews;
  final CreatorReviewStats? creatorReviewStats;
  final CreatorLevelProgress? creatorLevelProgress;

  ProfileModel({
    required this.role,
    required this.status,
    required this.badge,
    required this.userId,
    required this.imageUrl,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.description,
    required this.ageGroup,
    required this.gender,
    required this.country,
    required this.languages,
    required this.shippingAddress,
    required this.niches,
    required this.reviewStats,
    this.subscription,
    this.analytics,
    required this.isConnectedAccount,
    this.stripeConnectedAccountId,
    this.activeBoost,
    required this.portfolio,
    required this.reviews,
    this.creatorReviewStats,
    this.creatorLevelProgress,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      badge: json['badge'] ?? 'none',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'] ?? '',
      ageGroup: json['ageGroup'] ?? '',
      gender: json['gender'] ?? '',
      country: json['country'] ?? '',
      languages:
          (json['languages'] as List?)
              ?.map((e) => LanguageModel.fromJson(e))
              .toList() ??
          [],
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] ?? {}),
      niches: List<String>.from(json['niches'] ?? []),
      reviewStats: ReviewStatsModel.fromJson(json['reviewStats'] ?? {}),
      subscription: json['subscription'] != null
          ? SubscriptionModel.fromJson(json['subscription'])
          : null,
      analytics: json['analytics'] != null
          ? AnalyticsModel.fromJson(json['analytics'])
          : null,
      isConnectedAccount: json['isConnectedAccount'] ?? false,
      stripeConnectedAccountId: json['stripeConnectedAccountId'],
      activeBoost: json['activeBoost'] != null
          ? ActiveBoostModel.fromJson(json['activeBoost'])
          : null,
      portfolio:
          (json['portfolio'] as List?)
              ?.map((e) => PortfolioItem.fromJson(e))
              .toList() ??
          [],
      reviews:
          (json['reviews'] as List?)
              ?.map((e) => GigReviewModel.fromJson(e))
              .toList() ??
          [],
      creatorReviewStats: json['creatorReviewStats'] != null
          ? CreatorReviewStats.fromJson(json['creatorReviewStats'])
          : null,
      creatorLevelProgress: json['creatorLevelProgress'] != null
          ? CreatorLevelProgress.fromJson(json['creatorLevelProgress'])
          : null,
    );
  }
}

class CreatorLevelProgress {
  final int levelTwoProgressPercent;
  final CreatorLevelRequirements requirements;

  CreatorLevelProgress({
    required this.levelTwoProgressPercent,
    required this.requirements,
  });

  factory CreatorLevelProgress.fromJson(Map<String, dynamic> json) {
    return CreatorLevelProgress(
      levelTwoProgressPercent: (json['levelTwoProgressPercent'] ?? 0) as int,
      requirements: CreatorLevelRequirements.fromJson(
        (json['requirements'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
    );
  }
}

class CreatorLevelRequirements {
  final LevelRequirement gigs;
  final LevelRequirement reviews;
  final LevelRequirement completedOrders;
  final LevelRequirement averageRating;
  final LevelRequirement daysSinceRegistration;

  CreatorLevelRequirements({
    required this.gigs,
    required this.reviews,
    required this.completedOrders,
    required this.averageRating,
    required this.daysSinceRegistration,
  });

  factory CreatorLevelRequirements.fromJson(Map<String, dynamic> json) {
    return CreatorLevelRequirements(
      gigs: LevelRequirement.fromJson(
        (json['gigs'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      reviews: LevelRequirement.fromJson(
        (json['reviews'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      completedOrders: LevelRequirement.fromJson(
        (json['completedOrders'] ?? <String, dynamic>{})
            as Map<String, dynamic>,
      ),
      averageRating: LevelRequirement.fromJson(
        (json['averageRating'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      daysSinceRegistration: LevelRequirement.fromJson(
        (json['daysSinceRegistration'] ?? <String, dynamic>{})
            as Map<String, dynamic>,
      ),
    );
  }
}

class LevelRequirement {
  final num current;
  final num target;
  final bool met;

  LevelRequirement({
    required this.current,
    required this.target,
    required this.met,
  });

  factory LevelRequirement.fromJson(Map<String, dynamic> json) {
    return LevelRequirement(
      current: (json['current'] ?? 0) as num,
      target: (json['target'] ?? 0) as num,
      met: json['met'] == true,
    );
  }
}

class LanguageModel {
  final String language;
  final String level;

  LanguageModel({required this.language, required this.level});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      language: json['language'] ?? '',
      level: json['level'] ?? '',
    );
  }
}

class ShippingAddress {
  final String street;
  final String city;
  final String zipCode;
  final String country;

  ShippingAddress({
    required this.street,
    required this.city,
    required this.zipCode,
    required this.country,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class ReviewStatsModel {
  final int totalReviews;
  final double averageRating;

  ReviewStatsModel({required this.totalReviews, required this.averageRating});

  factory ReviewStatsModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatsModel(
      totalReviews: json['totalReviews'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}

class SubscriptionModel {
  final bool hasActiveSubscription;
  final BoostDetails? boostDetails;

  SubscriptionModel({required this.hasActiveSubscription, this.boostDetails});

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      hasActiveSubscription: json['hasActiveSubscription'] ?? false,
      boostDetails: json['boostDetails'] != null
          ? BoostDetails.fromJson(json['boostDetails'])
          : null,
    );
  }
}

class BoostDetails {
  final String id;
  final String userId;
  final String boostType;
  final int duration;
  final String expiresAt;
  final String subscriptionStartDate;
  final String status;
  final bool isRecurring;
  final bool autoRenewal;

  BoostDetails({
    required this.id,
    required this.userId,
    required this.boostType,
    required this.duration,
    required this.expiresAt,
    required this.subscriptionStartDate,
    required this.status,
    required this.isRecurring,
    required this.autoRenewal,
  });

  factory BoostDetails.fromJson(Map<String, dynamic> json) {
    return BoostDetails(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      boostType: json['boostType'] ?? '',
      duration: json['duration'] ?? 0,
      expiresAt: json['expiresAt'] ?? '',
      subscriptionStartDate: json['subscriptionStartDate'] ?? '',
      status: json['status'] ?? '',
      isRecurring: json['isRecurring'] ?? false,
      autoRenewal: json['autoRenewal'] ?? false,
    );
  }
}

class AnalyticsModel {
  final int profileViews;
  final int responseRate;
  final int newLeads;

  AnalyticsModel({
    required this.profileViews,
    required this.responseRate,
    required this.newLeads,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      profileViews: json['profileViews'] ?? 0,
      responseRate: json['responseRate'] ?? 0,
      newLeads: json['newLeads'] ?? 0,
    );
  }
}

class ActiveBoostModel {
  final String type;
  final String expiresAt;
  final String subscriptionStartDate;
  final bool isRecurring;
  final bool autoRenewal;

  ActiveBoostModel({
    required this.type,
    required this.expiresAt,
    required this.subscriptionStartDate,
    required this.isRecurring,
    required this.autoRenewal,
  });

  factory ActiveBoostModel.fromJson(Map<String, dynamic> json) {
    return ActiveBoostModel(
      type: json['type'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      subscriptionStartDate: json['subscriptionStartDate'] ?? '',
      isRecurring: json['isRecurring'] ?? false,
      autoRenewal: json['autoRenewal'] ?? false,
    );
  }
}

/// -- PORTFOLIO ITEM (new API) --
class PortfolioItem {
  // New fields from API
  final String galleryItemId;
  final String gigId;
  final String gigTitle;
  final DeliveryFile deliveryFile; // maps 'galleryItem'
  final String? createdAt;
  final String? updatedAt;

  // Backward-compat: these existed in the old schema; keep as optional if you still reference them anywhere
  final String? workDescription;
  final String? deliveryStatus;
  final bool canHide;

  PortfolioItem({
    required this.galleryItemId,
    required this.gigId,
    required this.gigTitle,
    required this.deliveryFile,
    this.createdAt,
    this.updatedAt,
    this.workDescription,
    this.deliveryStatus,
    this.canHide = false,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    // New response puts the file under "galleryItem"
    final galleryItemJson = (json['galleryItem'] as Map?) ?? {};
    final resolvedCanHide = json['canHide'] == true;

    return PortfolioItem(
      galleryItemId: json['galleryItemId'] ?? json['deliveryId'] ?? '',
      gigId: json['gigId'] ?? '',
      gigTitle: json['gigTitle'] ?? '',
      deliveryFile: DeliveryFile.fromJson(
        galleryItemJson.isNotEmpty
            ? galleryItemJson
            : (json['deliveryFile'] ?? <String, dynamic>{}), // backward compat
      ),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,

      // backward-compat only (old payloads)
      workDescription: json['workDescription'] as String?,
      deliveryStatus: json['deliveryStatus'] as String?,
      canHide: resolvedCanHide,
    );
  }
}

/// -- DELIVERY FILE (now maps to "galleryItem") --
class DeliveryFile {
  final String name;
  final String type; // e.g., "video/mp4"
  final String url; // video url
  final String thumbnail; // thumbnail url

  // Backward-compat optional fields (old schema sometimes included these)
  final int? size;
  final String? uploadedAt;

  DeliveryFile({
    required this.name,
    required this.type,
    required this.url,
    required this.thumbnail,
    this.size,
    this.uploadedAt,
  });

  factory DeliveryFile.fromJson(Map<String, dynamic> json) {
    return DeliveryFile(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      size: (json['size'] is int) ? json['size'] as int : null,
      uploadedAt: json['uploadedAt'] as String?,
    );
  }
}

class GigReviewModel {
  final String id;
  final String gigId;
  final ReviewedBy reviewedBy;
  final String description;
  final int communication;
  final int timeliness;
  final int satisfaction;
  final String createdAt;
  final double averageRating;
  final GigInfo? gig;

  GigReviewModel({
    required this.id,
    required this.gigId,
    required this.reviewedBy,
    required this.description,
    required this.communication,
    required this.timeliness,
    required this.satisfaction,
    required this.createdAt,
    required this.averageRating,
    this.gig,
  });

  factory GigReviewModel.fromJson(Map<String, dynamic> json) {
    return GigReviewModel(
      id: json['_id'] ?? '',
      gigId: json['gigId'] ?? '',
      reviewedBy: ReviewedBy.fromJson(json['reviewedBy'] ?? {}),
      description: json['description'] ?? '',
      communication: json['communication'] ?? 0,
      timeliness: json['timeliness'] ?? 0,
      satisfaction: json['satisfaction'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      gig: json['gig'] != null ? GigInfo.fromJson(json['gig']) : null,
    );
  }

  // Helper to get time ago string
  String get timeAgo {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}

class ReviewedBy {
  final String userId;
  final String email;
  final String username;
  final String companyName;
  final String imageUrl;

  ReviewedBy({
    required this.userId,
    required this.email,
    required this.username,
    required this.companyName,
    required this.imageUrl,
  });

  factory ReviewedBy.fromJson(Map<String, dynamic> json) {
    return ReviewedBy(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      companyName: json['companyName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class GigInfo {
  final String id;
  final String title;
  final String gigThumbnail;

  GigInfo({required this.id, required this.title, required this.gigThumbnail});

  factory GigInfo.fromJson(Map<String, dynamic> json) {
    return GigInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      gigThumbnail: json['gigThumbnail'] ?? '',
    );
  }
}

class CreatorReviewStats {
  final int totalReviews;
  final double averageRating;
  final StarDistribution starDistribution;

  CreatorReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.starDistribution,
  });

  factory CreatorReviewStats.fromJson(Map<String, dynamic> json) {
    return CreatorReviewStats(
      totalReviews: json['totalReviews'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      starDistribution: StarDistribution.fromJson(
        json['starDistribution'] ?? {},
      ),
    );
  }
}

class StarDistribution {
  final int fiveStarsTotal;
  final int fourStarsTotal;
  final int threeStarsTotal;
  final int twoStarsTotal;
  final int oneStarsTotal;

  StarDistribution({
    required this.fiveStarsTotal,
    required this.fourStarsTotal,
    required this.threeStarsTotal,
    required this.twoStarsTotal,
    required this.oneStarsTotal,
  });

  factory StarDistribution.fromJson(Map<String, dynamic> json) {
    return StarDistribution(
      fiveStarsTotal: json['five_starsTotal'] ?? 0,
      fourStarsTotal: json['four_starsTotal'] ?? 0,
      threeStarsTotal: json['three_starsTotal'] ?? 0,
      twoStarsTotal: json['two_starsTotal'] ?? 0,
      oneStarsTotal: json['one_starsTotal'] ?? 0,
    );
  }
}
