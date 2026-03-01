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

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  return <String, dynamic>{};
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

String _str(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    final map = _map(value);
    final nested = map['_id'] ?? map['id'] ?? map['\$oid'];
    if (nested != null) return nested.toString();
  }
  return value.toString();
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _double(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  final raw = value?.toString().toLowerCase().trim() ?? '';
  return raw == 'true' || raw == '1' || raw == 'yes';
}

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
      totalPages: _int(json['totalPages']),
      totalData: _int(json['totalData']),
      pageNumber: _int(json['pageNumber']) == 0 ? 1 : _int(json['pageNumber']),
      data: _list(
        json['data'],
      ).map((e) => MyGigModel.fromJson(_map(e))).toList(),
      statusCode: _int(json['statusCode']),
      message: _str(json['message']),
      timestamp: _str(json['timestamp']),
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
      gigId: _str(json['gigId'] ?? json['_id']),
      gigTitle: _str(json['gigTitle'] ?? json['title']),
      gigThumbnail: _str(json['gigThumbnail'] ?? json['thumbnail']),
      gigStatus: _str(json['gigStatus'] ?? json['status']).isEmpty
          ? 'Active'
          : _str(json['gigStatus'] ?? json['status']),
      createdAt: _str(json['createdAt']),
      startingPrice: _int(json['startingPrice'] ?? json['price']),
      creatorUserId: _str(json['creatorUserId'] ?? json['createdBy']),
      creatorFullName: _str(json['creatorFullName'] ?? json['creatorName']),
      creatorAddress: _str(json['creatorAddress']),
      creatorImageUrl: _str(json['creatorImageUrl']),
      reviewStats: _map(json['reviewStats']).isNotEmpty
          ? ReviewStats.fromJson(_map(json['reviewStats']))
          : ReviewStats(totalReviews: 0, averageRating: 0),
      isFavourited: _bool(json['isFavourited']),
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
      data: GigDetailModel.fromJson(_map(json['data'])),
      statusCode: _int(json['statusCode']),
      message: _str(json['message']),
      timestamp: _str(json['timestamp']),
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
    final pricingsRaw = _list(json['pricings']).isNotEmpty
        ? _list(json['pricings'])
        : _list(json['pricing']);
    final stylesRaw = _list(json['videoStyles']).isNotEmpty
        ? _list(json['videoStyles'])
        : _list(json['videoStyle']);

    return GigDetailModel(
      id: _str(json['_id'] ?? json['gigId'] ?? json['id']),
      title: _str(json['title']),
      description: _str(json['description']),
      gigStatus: _str(json['gigStatus']).isEmpty
          ? 'Active'
          : _str(json['gigStatus']),
      createdBy: _str(json['createdBy']),
      gigThumbnail: _str(json['gigThumbnail']),
      isDeleted: _bool(json['isDeleted']),
      createdAt: _str(json['createdAt']),
      updatedAt: _str(json['updatedAt']),
      pricings: pricingsRaw.map((e) => PricingModel.fromJson(_map(e))).toList(),
      tags: _list(json['tags']).map((e) => TagModel.fromJson(_map(e))).toList(),
      videoStyles: stylesRaw
          .map((e) => VideoStyleModel.fromJson(_map(e)))
          .toList(),
      questions: _list(
        json['questions'],
      ).map((e) => QuestionModel.fromJson(_map(e))).toList(),
      gallery: _list(
        json['gallery'],
      ).map((e) => GalleryModel.fromJson(_map(e))).toList(),
      creator: _map(json['creator']).isNotEmpty
          ? CreatorModel.fromJson(_map(json['creator']))
          : CreatorModel.empty(),
      creatorFullName: _str(json['creatorFullName']),
      creatorAddress: _str(json['creatorAddress']),
      creatorImageUrl: _str(json['creatorImageUrl']),
      reviewStats: _map(json['reviewStats']).isNotEmpty
          ? ReviewStats.fromJson(_map(json['reviewStats']))
          : ReviewStats(totalReviews: 0, averageRating: 0),
      isFavourited: _bool(json['isFavourited']),
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
      id: _str(json['_id']),
      pricingName: _str(json['pricingName']),
      currency: _str(json['currency']).isEmpty ? 'USD' : _str(json['currency']),
      price: _int(json['price']),
      deliveryTimeDays: _int(json['deliveryTimeDays']),
      numberOfRevisions: _int(json['numberOfRevisions']),
      features: _list(json['features']).map((e) => _str(e)).toList(),
      additionalFeatures: _list(
        json['additionalFeatures'],
      ).map((e) => AdditionalFeatureModel.fromJson(_map(e))).toList(),
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
      id: _str(json['_id']),
      featureType: _str(json['featureType']),
      price: _int(json['price']),
      deliveryTimesIndays: json['deliveryTimesIndays'] == null
          ? null
          : _int(json['deliveryTimesIndays']),
    );
  }
}

class TagModel {
  final String id;
  final String name;

  TagModel({required this.id, required this.name});

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(id: _str(json['_id']), name: _str(json['name']));
  }
}

class VideoStyleModel {
  final String id;
  final String name;

  VideoStyleModel({required this.id, required this.name});

  factory VideoStyleModel.fromJson(Map<String, dynamic> json) {
    return VideoStyleModel(id: _str(json['_id']), name: _str(json['name']));
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
      id: _str(json['_id']),
      questionText: _str(json['questionText']),
      questionType: _str(json['questionType']),
      options: _list(json['options']).map((e) => _str(e)).toList(),
      isRequired: _bool(json['isRequired']),
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
      id: _str(json['_id'] ?? json['id']),
      name: _str(json['name']),
      type: _str(json['type']),
      url: _str(json['url']),
      thumbnail: _str(json['thumbnail']),
      size: _int(json['size']),
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
      imageUrl: _str(json['imageUrl']),
      firstName: _str(json['firstName']),
      lastName: _str(json['lastName']),
      displayName: _str(json['displayName']),
      gender: _str(json['gender']),
      niches: _list(json['niches']).map((e) => _str(e)).toList(),
      profileStatus: _str(json['profileStatus']),
      isGigCreated: _bool(json['isGigCreated']),
      isEmailVerified: _bool(json['isEmailVerified']),
      isPhoneVerified: _bool(json['isPhoneVerified']),
      walletBalance: _double(json['walletBalance']),
      badge: _str(json['badge']),
      activeBoost: _map(json['activeBoost']).isNotEmpty
          ? ActiveBoostModel.fromJson(_map(json['activeBoost']))
          : null,
      languages: _list(
        json['languages'],
      ).map((e) => LanguageModel.fromJson(_map(e))).toList(),
      ageGroup: _str(json['ageGroup']),
      country: _str(json['country']),
      description: _str(json['description']),
      shippingAddress: _map(json['shippingAddress']).isNotEmpty
          ? ShippingAddressModel.fromJson(_map(json['shippingAddress']))
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
      type: _str(json['type']),
      expiresAt: _str(json['expiresAt']),
      subscriptionStartDate: _str(json['subscriptionStartDate']),
      nextSubscriptionStartDate: json['nextSubscriptionStartDate']?.toString(),
      isRecurring: _bool(json['isRecurring']),
      autoRenewal: _bool(json['autoRenewal']),
      subscriptionId: json['subscriptionId']?.toString(),
      paymentIntentId: _str(json['paymentIntentId']),
      appliedAt: _str(json['appliedAt']),
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
      id: _str(json['_id']),
      language: _str(json['language']),
      level: _str(json['level']),
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
      id: _str(json['_id']),
      street: _str(json['street']),
      city: _str(json['city']),
      zipCode: _str(json['zipCode']),
      country: _str(json['country']),
    );
  }
}

class ReviewStats {
  final int totalReviews;
  final double averageRating;

  ReviewStats({required this.totalReviews, required this.averageRating});

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      totalReviews: _int(json['totalReviews']),
      averageRating: _double(json['averageRating']),
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
