class UserModel {
  final String name;
  final String location;
  final String profileImage;
  final List<String> portfolioImages;
  final List<MyGigModel>? gigs;
  final String bio;
  final String ageGroup;
  final String gender;
  final List<String> skills;
  final List<String> languages;
  final List<ReviewModel> reviews;
  final bool isBoosted;

  UserModel({
    required this.name,
    required this.location,
    required this.profileImage,
    required this.portfolioImages,
    this.gigs,
    required this.bio,
    required this.ageGroup,
    required this.gender,
    required this.skills,
    required this.languages,
    required this.reviews,
    this.isBoosted = false,
  });

  UserModel copyWith({
    String? name,
    String? location,
    String? profileImage,
    List<String>? portfolioImages,
    List<MyGigModel>? gigs,
    String? bio,
    String? ageGroup,
    String? gender,
    List<String>? skills,
    List<String>? languages,
    List<ReviewModel>? reviews,
    bool? isBoosted,
  }) {
    return UserModel(
      name: name ?? this.name,
      location: location ?? this.location,
      profileImage: profileImage ?? this.profileImage,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      gigs: gigs ?? this.gigs,
      bio: bio ?? this.bio,
      ageGroup: ageGroup ?? this.ageGroup,
      gender: gender ?? this.gender,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      reviews: reviews ?? this.reviews,
      isBoosted: isBoosted ?? this.isBoosted,
    );
  }
}

// models/gig/my_gigs_response_model.dart

class MyGigsResponseModel {
  final int totalPages;
  final int totalData;
  final int pageNumber;
  final List<MyGigModel> data;
  final int statusCode;
  final String message;
  final String timestamp;

  MyGigsResponseModel({
    required this.totalPages,
    required this.totalData,
    required this.pageNumber,
    required this.data,
    required this.statusCode,
    required this.message,
    required this.timestamp,
  });

  factory MyGigsResponseModel.fromJson(Map<String, dynamic> json) {
    return MyGigsResponseModel(
      totalPages: json['totalPages'] ?? 0,
      totalData: json['totalData'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      data:
          (json['data'] as List?)
              ?.map((e) => MyGigModel.fromJson(e))
              .toList() ??
          [],
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class MyGigModel {
  final String gigId;
  final String gigTitle;
  final String gigThumbnail;
  final String gigStatus;
  final String createdAt;
  final int startingPrice;
  final String creatorUserId;
  final String creatorFullName;
  final String creatorAddress;
  final String creatorImageUrl;
  final ReviewStats reviewStats;
  final bool isFavourited;

  MyGigModel({
    required this.gigId,
    required this.gigTitle,
    required this.gigThumbnail,
    required this.gigStatus,
    required this.createdAt,
    required this.startingPrice,
    required this.creatorUserId,
    required this.creatorFullName,
    required this.creatorAddress,
    required this.creatorImageUrl,
    required this.reviewStats,
    required this.isFavourited,
  });

  factory MyGigModel.fromJson(Map<String, dynamic> json) {
    return MyGigModel(
      gigId: json['gigId'] ?? '',
      gigTitle: json['gigTitle'] ?? '',
      gigThumbnail: json['gigThumbnail'] ?? '',
      gigStatus: json['gigStatus'] ?? 'Active',
      createdAt: json['createdAt'] ?? '',
      startingPrice: json['startingPrice'] ?? 0,
      creatorUserId: json['creatorUserId'] ?? '',
      creatorFullName: json['creatorFullName'] ?? '',
      creatorAddress: json['creatorAddress'] ?? '',
      creatorImageUrl: json['creatorImageUrl'] ?? '',
      reviewStats: json['reviewStats'] != null
          ? ReviewStats.fromJson(json['reviewStats'])
          : ReviewStats(totalReviews: 0, averageRating: 0),
      isFavourited: json['isFavourited'] ?? false,
    );
  }

  // Helper to get formatted time ago
  String get postedTimeAgo {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return 'Posted ${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
      } else if (difference.inHours > 0) {
        return 'Posted ${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"} ago';
      } else {
        return 'Posted ${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"} ago';
      }
    } catch (e) {
      return 'Posted recently';
    }
  }
}

// models/gig/gig_detail_model.dart

class GigDetailResponseModel {
  final GigDetailModel data;
  final int statusCode;
  final String message;
  final String timestamp;

  GigDetailResponseModel({
    required this.data,
    required this.statusCode,
    required this.message,
    required this.timestamp,
  });

  factory GigDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return GigDetailResponseModel(
      data: GigDetailModel.fromJson(json['data'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class GigDetailModel {
  final String id;
  final String title;
  final String description;
  final String gigStatus;
  final String createdBy;
  final String gigThumbnail;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final List<PricingModel> pricings;
  final List<TagModel> tags;
  final List<VideoStyleModel> videoStyles;
  final List<QuestionModel> questions;
  final List<GalleryModel> gallery;
  final CreatorModel creator;
  final String creatorFullName;
  final String creatorAddress;
  final String creatorImageUrl;
  final ReviewStats reviewStats;
  final bool isFavourited;

  GigDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.gigStatus,
    required this.createdBy,
    required this.gigThumbnail,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.pricings,
    required this.tags,
    required this.videoStyles,
    required this.questions,
    required this.gallery,
    required this.creator,
    required this.creatorFullName,
    required this.creatorAddress,
    required this.creatorImageUrl,
    required this.reviewStats,
    required this.isFavourited,
  });

  factory GigDetailModel.fromJson(Map<String, dynamic> json) {
    return GigDetailModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      gigStatus: json['gigStatus'] ?? 'Active',
      createdBy: json['createdBy'] ?? '',
      gigThumbnail: json['gigThumbnail'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      pricings:
          (json['pricings'] as List?)
              ?.map((e) => PricingModel.fromJson(e))
              .toList() ??
          [],
      tags:
          (json['tags'] as List?)?.map((e) => TagModel.fromJson(e)).toList() ??
          [],
      videoStyles:
          (json['videoStyles'] as List?)
              ?.map((e) => VideoStyleModel.fromJson(e))
              .toList() ??
          [],
      questions:
          (json['questions'] as List?)
              ?.map((e) => QuestionModel.fromJson(e))
              .toList() ??
          [],
      gallery:
          (json['gallery'] as List?)
              ?.map((e) => GalleryModel.fromJson(e))
              .toList() ??
          [],
      creator: json['creator'] != null
          ? CreatorModel.fromJson(json['creator'])
          : CreatorModel.empty(),
      creatorFullName: json['creatorFullName'] ?? '',
      creatorAddress: json['creatorAddress'] ?? '',
      creatorImageUrl: json['creatorImageUrl'] ?? '',
      reviewStats: json['reviewStats'] != null
          ? ReviewStats.fromJson(json['reviewStats'])
          : ReviewStats(totalReviews: 0, averageRating: 0),
      isFavourited: json['isFavourited'] ?? false,
    );
  }
}

class PricingModel {
  final String id;
  final String pricingName;
  final String currency;
  final int price;
  final int deliveryTimeDays;
  final int numberOfRevisions;
  final List<String> features;
  final List<AdditionalFeatureModel> additionalFeatures;

  PricingModel({
    required this.id,
    required this.pricingName,
    required this.currency,
    required this.price,
    required this.deliveryTimeDays,
    required this.numberOfRevisions,
    required this.features,
    required this.additionalFeatures,
  });

  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return PricingModel(
      id: json['_id'] ?? '',
      pricingName: json['pricingName'] ?? '',
      currency: json['currency'] ?? 'USD',
      price: json['price'] ?? 0,
      deliveryTimeDays: json['deliveryTimeDays'] ?? 0,
      numberOfRevisions: json['numberOfRevisions'] ?? 0,
      features: (json['features'] as List?)?.cast<String>() ?? [],
      additionalFeatures:
          (json['additionalFeatures'] as List?)
              ?.map((e) => AdditionalFeatureModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  String get deliveryText =>
      '$deliveryTimeDays ${deliveryTimeDays == 1 ? "Day" : "Days"} Delivery';
}

class AdditionalFeatureModel {
  final String id;
  final String featureType;
  final int price;
  final int? deliveryTimesIndays;

  AdditionalFeatureModel({
    required this.id,
    required this.featureType,
    required this.price,
    this.deliveryTimesIndays,
  });

  factory AdditionalFeatureModel.fromJson(Map<String, dynamic> json) {
    return AdditionalFeatureModel(
      id: json['_id'] ?? '',
      featureType: json['featureType'] ?? '',
      price: json['price'] ?? 0,
      deliveryTimesIndays: json['deliveryTimesIndays'],
    );
  }
}

class TagModel {
  final String id;
  final String name;

  TagModel({required this.id, required this.name});

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}

class VideoStyleModel {
  final String id;
  final String name;

  VideoStyleModel({required this.id, required this.name});

  factory VideoStyleModel.fromJson(Map<String, dynamic> json) {
    return VideoStyleModel(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}

class QuestionModel {
  final String id;
  final String questionText;
  final String questionType;
  final List<String> options;
  final bool isRequired;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.isRequired,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'] ?? '',
      questionText: json['questionText'] ?? '',
      questionType: json['questionType'] ?? '',
      options: (json['options'] as List?)?.cast<String>() ?? [],
      isRequired: json['isRequired'] ?? false,
    );
  }
}

class GalleryModel {
  final String id;
  final String name;
  final String type;
  final String url;
  final String thumbnail;
  final int size;

  GalleryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.thumbnail,
    required this.size,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      size: json['size'] ?? 0,
    );
  }

  bool get isVideo => type.contains('video');
  bool get isImage => type.contains('image');
}

class CreatorModel {
  final String imageUrl;
  final String firstName;
  final String lastName;
  final String displayName;
  final String gender;
  final List<String> niches;
  final String profileStatus;
  final bool isGigCreated;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final double walletBalance;
  final String badge;
  final ActiveBoostModel? activeBoost;
  final List<LanguageModel> languages;
  final String ageGroup;
  final String country;
  final String description;
  final ShippingAddressModel? shippingAddress;

  CreatorModel({
    required this.imageUrl,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.gender,
    required this.niches,
    required this.profileStatus,
    required this.isGigCreated,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.walletBalance,
    required this.badge,
    this.activeBoost,
    required this.languages,
    required this.ageGroup,
    required this.country,
    required this.description,
    this.shippingAddress,
  });

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
      imageUrl: json['imageUrl'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      displayName: json['displayName'] ?? '',
      gender: json['gender'] ?? '',
      niches: (json['niches'] as List?)?.cast<String>() ?? [],
      profileStatus: json['profileStatus'] ?? '',
      isGigCreated: json['isGigCreated'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      badge: json['badge'] ?? '',
      activeBoost: json['activeBoost'] != null
          ? ActiveBoostModel.fromJson(json['activeBoost'])
          : null,
      languages:
          (json['languages'] as List?)
              ?.map((e) => LanguageModel.fromJson(e))
              .toList() ??
          [],
      ageGroup: json['ageGroup'] ?? '',
      country: json['country'] ?? '',
      description: json['description'] ?? '',
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddressModel.fromJson(json['shippingAddress'])
          : null,
    );
  }

  factory CreatorModel.empty() {
    return CreatorModel(
      imageUrl: '',
      firstName: '',
      lastName: '',
      displayName: '',
      gender: '',
      niches: [],
      profileStatus: '',
      isGigCreated: false,
      isEmailVerified: false,
      isPhoneVerified: false,
      walletBalance: 0,
      badge: '',
      languages: [],
      ageGroup: '',
      country: '',
      description: '',
    );
  }
}

class ActiveBoostModel {
  final String type;
  final String expiresAt;
  final String subscriptionStartDate;
  final String? nextSubscriptionStartDate;
  final bool isRecurring;
  final bool autoRenewal;
  final String? subscriptionId;
  final String paymentIntentId;
  final String appliedAt;

  ActiveBoostModel({
    required this.type,
    required this.expiresAt,
    required this.subscriptionStartDate,
    this.nextSubscriptionStartDate,
    required this.isRecurring,
    required this.autoRenewal,
    this.subscriptionId,
    required this.paymentIntentId,
    required this.appliedAt,
  });

  factory ActiveBoostModel.fromJson(Map<String, dynamic> json) {
    return ActiveBoostModel(
      type: json['type'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      subscriptionStartDate: json['subscriptionStartDate'] ?? '',
      nextSubscriptionStartDate: json['nextSubscriptionStartDate'],
      isRecurring: json['isRecurring'] ?? false,
      autoRenewal: json['autoRenewal'] ?? false,
      subscriptionId: json['subscriptionId'],
      paymentIntentId: json['paymentIntentId'] ?? '',
      appliedAt: json['appliedAt'] ?? '',
    );
  }
}

class LanguageModel {
  final String id;
  final String language;
  final String level;

  LanguageModel({
    required this.id,
    required this.language,
    required this.level,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['_id'] ?? '',
      language: json['language'] ?? '',
      level: json['level'] ?? '',
    );
  }
}

class ShippingAddressModel {
  final String id;
  final String street;
  final String city;
  final String zipCode;
  final String country;

  ShippingAddressModel({
    required this.id,
    required this.street,
    required this.city,
    required this.zipCode,
    required this.country,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      id: json['_id'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class ReviewStats {
  final int totalReviews;
  final double averageRating;

  ReviewStats({required this.totalReviews, required this.averageRating});

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      totalReviews: json['totalReviews'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}

class ReviewModel {
  final String reviewerName;
  final String reviewerImage;
  final double rating;
  final String comment;
  final String timeAgo;

  ReviewModel({
    required this.reviewerName,
    required this.reviewerImage,
    required this.rating,
    required this.comment,
    required this.timeAgo,
  });
}
