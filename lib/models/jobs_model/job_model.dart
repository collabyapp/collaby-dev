// class JobModel {
//   final String id;
//   final String title;
//   final String company;
//   final String? companyLogo;
//   final String? imageUrl;
//   final String? videoStyle;
//   final double budget;
//   final int videoTimeline;
//   final int videoQuantity;
//   final int deliveryTimeline;
//   final String description;
//   final DateTime updatedAt;
//   final DateTime createdAt;
//   final bool isSaved;
//   final JobStatus status;

//   final String? category;
//   final SubmittedInterest? submittedInterest;
//   final BrandProfile? brandProfile;
//   final bool interestSubmitted; // NEW FIELD

//   JobModel({
//     required this.id,
//     required this.title,
//     required this.company,
//     this.companyLogo,
//     this.imageUrl,
//     this.videoStyle,
//     required this.budget,
//     required this.videoTimeline,
//     required this.videoQuantity,
//     required this.deliveryTimeline,
//     required this.description,
//     required this.updatedAt,
//     DateTime? createdAt,
//     this.isSaved = false,
//     this.status = JobStatus.open,
//     this.category,
//     this.submittedInterest,
//     this.brandProfile,
//     this.interestSubmitted = false, // NEW FIELD
//   }) : this.createdAt = createdAt ?? updatedAt;

//   // Factory constructor for API response
//   factory JobModel.fromJson(Map<String, dynamic> json) {
//     return JobModel(
//       id: json['_id'] ?? '',
//       title: json['title'] ?? '',
//       company:
//           json['brandProfile']?['brandCompanyName'] ??
//           json['brandProfile']?['username'] ??
//           'Unknown Company',
//       companyLogo: json['brandProfile']?['imageUrl'],
//       imageUrl: json['imageUrl'],
//       videoStyle: json['videoStyle'],
//       budget: (json['budget'] ?? 0).toDouble(),
//       videoTimeline: json['videoTimeline'],
//       videoQuantity: json['videoQuantity'] ?? 0,
//       deliveryTimeline: json['deliveryTimeline'],
//       description: json['description'] ?? '',
//       updatedAt: json['updatedAt'] != null
//           ? DateTime.parse(json['updatedAt'])
//           : DateTime.now(),
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'])
//           : DateTime.now(),
//       isSaved: json['isFavourite'] ?? false,
//       status: _parseStatus(json['status']),
//       category: json['category'],
//       submittedInterest: json['submittedInterest'] != null
//           ? SubmittedInterest.fromJson(json['submittedInterest'])
//           : null,
//       brandProfile: json['brandProfile'] != null
//           ? BrandProfile.fromJson(json['brandProfile'])
//           : null,
//       interestSubmitted: json['interestSubmitted'] ?? false, // NEW FIELD
//     );
//   }

//   // Helper to parse timeline (handles both int and string)
//   // static String _parseTimeline(dynamic value) {
//   //   if (value == null) return 'N/A';
//   //   if (value is int) return '$value days';
//   //   if (value is String) return value;
//   //   return value.toString();
//   // }

//   // Convert to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'title': title,
//       'description': description,
//       'budget': budget,
//       'videoStyle': videoStyle,
//       'imageUrl': imageUrl,
//       'videoTimeline': videoTimeline,
//       'videoQuantity': videoQuantity,
//       'deliveryTimeline': deliveryTimeline,
//       'status': status.toString().split('.').last,
//       'isFavourite': isSaved,
//       'category': category,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       'interestSubmitted': interestSubmitted, // NEW FIELD
//       if (brandProfile != null) 'brandProfile': brandProfile!.toJson(),
//       if (submittedInterest != null)
//         'submittedInterest': submittedInterest!.toJson(),
//     };
//   }

//   // CopyWith method
//   JobModel copyWith({
//     String? id,
//     String? title,
//     String? company,
//     String? companyLogo,
//     String? imageUrl,
//     String? videoStyle,
//     double? budget,
//     int? videoTimeline,
//     int? videoQuantity,
//     int? deliveryTimeline,
//     String? description,
//     DateTime? updatedAt,
//     DateTime? createdAt,
//     bool? isSaved,
//     JobStatus? status,
//     String? category,
//     SubmittedInterest? submittedInterest,
//     BrandProfile? brandProfile,
//     bool? interestSubmitted, // NEW FIELD
//   }) {
//     return JobModel(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       company: company ?? this.company,
//       companyLogo: companyLogo ?? this.companyLogo,
//       imageUrl: imageUrl ?? this.imageUrl,
//       videoStyle: videoStyle ?? this.videoStyle,
//       budget: budget ?? this.budget,
//       videoTimeline: videoTimeline ?? this.videoTimeline,
//       videoQuantity: videoQuantity ?? this.videoQuantity,
//       deliveryTimeline: deliveryTimeline ?? this.deliveryTimeline,
//       description: description ?? this.description,
//       updatedAt: updatedAt ?? this.updatedAt,
//       createdAt: createdAt ?? this.createdAt,
//       isSaved: isSaved ?? this.isSaved,
//       status: status ?? this.status,
//       category: category ?? this.category,
//       submittedInterest: submittedInterest ?? this.submittedInterest,
//       brandProfile: brandProfile ?? this.brandProfile,
//       interestSubmitted:
//           interestSubmitted ?? this.interestSubmitted, // NEW FIELD
//     );
//   }

//   static JobStatus _parseStatus(String? status) {
//     if (status == null) return JobStatus.open;
//     switch (status.toLowerCase()) {
//       case 'posted':
//       case 'open':
//         return JobStatus.open;
//       case 'Applied':
//         return JobStatus.applied;
//       case 'applied':
//         return JobStatus.applied;
//       case 'Hired':
//         return JobStatus.hired;
//       case 'closed':
//         return JobStatus.closed;
//       case 'Closed':
//         return JobStatus.closed;
//       case 'hired':
//         return JobStatus.hired;
//       default:
//         return JobStatus.open;
//     }
//   }
// }

// // Supporting classes
// class SubmittedInterest {
//   final String status;
//   final DateTime date;

//   SubmittedInterest({required this.status, required this.date});

//   factory SubmittedInterest.fromJson(Map<String, dynamic> json) {
//     return SubmittedInterest(
//       status: json['status'] ?? 'pending',
//       date: json['date'] != null
//           ? DateTime.parse(json['date'])
//           : DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'status': status, 'date': date.toIso8601String()};
//   }
// }

// class BrandProfile {
//   final String username;
//   final String brandCompanyName;
//   final String? logo;
//   final String? imageUrl;
//   final String? industry;
//   final DateTime createdAt;

//   BrandProfile({
//     required this.username,
//     required this.brandCompanyName,
//     this.logo,
//     this.imageUrl,
//     this.industry,
//     DateTime? createdAt,
//   }) : this.createdAt = createdAt ?? DateTime.now();

//   factory BrandProfile.fromJson(Map<String, dynamic> json) {
//     return BrandProfile(
//       username: json['username'] ?? '',
//       brandCompanyName: json['brandCompanyName'] ?? '',
//       logo: json['logo'],
//       imageUrl: json['imageUrl'],
//       industry: json['industry'],
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'])
//           : DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'username': username,
//       'brandCompanyName': brandCompanyName,
//       if (logo != null) 'logo': logo,
//       if (imageUrl != null) 'imageUrl': imageUrl,
//       if (industry != null) 'industry': industry,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }

// // Enums
// enum JobStatus { open, applied, closed, hired }

// enum JobCategory { all, fashion, food, health }

// // Application Model
// class ApplicationModel {
//   final String id;
//   final String jobId;
//   final String title;
//   final DateTime submittedAt;
//   final String status;
//   final String? companyLogo;
//   final String? imageUrl;
//   final double budget;
//   final int videoTimeline;
//   final int videoQuantity;
//   final int deliveryTimeline;
//   final String description;

//   ApplicationModel({
//     required this.id,
//     required this.jobId,
//     required this.title,
//     required this.submittedAt,
//     this.status = 'pending',
//     this.companyLogo,
//     this.imageUrl,
//     required this.budget,
//     required this.videoTimeline,
//     required this.videoQuantity,
//     required this.deliveryTimeline,
//     required this.description,
//   });

//   factory ApplicationModel.fromJson(Map<String, dynamic> json) {
//     return ApplicationModel(
//       id: json['id'] ?? json['_id'] ?? '',
//       jobId: json['jobId'] ?? '',
//       title: json['title'] ?? '',
//       submittedAt: json['submittedAt'] != null
//           ? DateTime.parse(json['submittedAt'])
//           : DateTime.now(),
//       status: json['status'] ?? 'pending',
//       companyLogo: json['brandProfile']?['imageUrl'],
//       imageUrl: json['imageUrl'],
//       budget: (json['budget'] ?? 0).toDouble(),
//       videoTimeline: json['videoTimeline'],
//       videoQuantity: json['videoQuantity'] ?? 0,
//       deliveryTimeline: json['deliveryTimeline'],
//       description: json['description'] ?? '',
//     );
//   }
//   // // Helper to parse timeline (handles both int and string)
//   // static String _parseTimeline(dynamic value) {
//   //   if (value == null) return 'N/A';
//   //   if (value is int) return '$value days';
//   //   if (value is String) return value;
//   //   return value.toString();
//   // }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'jobId': jobId,
//       'title': title,
//       'submittedAt': submittedAt.toIso8601String(),
//       'status': status,
//       'description': description,
//       'budget': budget,
//       'videoTimeline': videoTimeline,
//       'videoQuantity': videoQuantity,
//       'deliveryTimeline': deliveryTimeline,
//     };
//   }
// }



class JobModel {
  final String id;
  final String title;
  final String company;
  final String? companyLogo;
  final String? imageUrl;
  final String? videoStyle;
  final double budget;
  final int videoTimeline;
  final int videoQuantity;
  final int deliveryTimeline;
  final String description;
  final DateTime updatedAt;
  final DateTime createdAt;
  final bool isSaved;
  final JobStatus status;
  final InterestStatus? interestStatus; // UPDATED
  final String? category;
  final SubmittedInterest? submittedInterest;
  final BrandProfile? brandProfile;
  final bool interestSubmitted;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogo,
    this.imageUrl,
    this.videoStyle,
    required this.budget,
    required this.videoTimeline,
    required this.videoQuantity,
    required this.deliveryTimeline,
    required this.description,
    required this.updatedAt,
    DateTime? createdAt,
    this.isSaved = false,
    this.status = JobStatus.open,
    this.interestStatus, // Can be null
    this.category,
    this.submittedInterest,
    this.brandProfile,
    this.interestSubmitted = false,
  }) : this.createdAt = createdAt ?? updatedAt;

  // Factory constructor for API response
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      company:
          json['brandProfile']?['brandCompanyName'] ??
          json['brandProfile']?['username'] ??
          'Unknown Company',
      companyLogo: json['brandProfile']?['imageUrl'],
      imageUrl: json['imageUrl'],
      videoStyle: json['videoStyle'],
      budget: (json['budget'] ?? 0).toDouble(),
      videoTimeline: json['videoTimeline'],
      videoQuantity: json['videoQuantity'] ?? 0,
      deliveryTimeline: json['deliveryTimeline'],
      description: json['description'] ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isSaved: json['isFavourite'] ?? false,
      status: _parseStatus(json['status']),
      category: json['category'],
      submittedInterest: json['submittedInterest'] != null
          ? SubmittedInterest.fromJson(json['submittedInterest'])
          : null,
      brandProfile: json['brandProfile'] != null
          ? BrandProfile.fromJson(json['brandProfile'])
          : null,
      interestSubmitted: json['interestSubmitted'] ?? false,
      interestStatus: _parseInterestStatus(json['interestStatus']), // UPDATED
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'budget': budget,
      'videoStyle': videoStyle,
      'imageUrl': imageUrl,
      'videoTimeline': videoTimeline,
      'videoQuantity': videoQuantity,
      'deliveryTimeline': deliveryTimeline,
      'status': status.toString().split('.').last,
      'isFavourite': isSaved,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'interestSubmitted': interestSubmitted,
      if (brandProfile != null) 'brandProfile': brandProfile!.toJson(),
      if (submittedInterest != null)
        'submittedInterest': submittedInterest!.toJson(),
      if (interestStatus != null)
        'interestStatus': interestStatus.toString().split('.').last, // UPDATED
    };
  }

  // CopyWith method
  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    String? companyLogo,
    String? imageUrl,
    String? videoStyle,
    double? budget,
    int? videoTimeline,
    int? videoQuantity,
    int? deliveryTimeline,
    String? description,
    DateTime? updatedAt,
    DateTime? createdAt,
    bool? isSaved,
    JobStatus? status,
    String? category,
    SubmittedInterest? submittedInterest,
    BrandProfile? brandProfile,
    bool? interestSubmitted,
    InterestStatus? interestStatus, // UPDATED
    bool clearSubmittedInterest = false, // NEW: for setting null
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyLogo: companyLogo ?? this.companyLogo,
      imageUrl: imageUrl ?? this.imageUrl,
      videoStyle: videoStyle ?? this.videoStyle,
      budget: budget ?? this.budget,
      videoTimeline: videoTimeline ?? this.videoTimeline,
      videoQuantity: videoQuantity ?? this.videoQuantity,
      deliveryTimeline: deliveryTimeline ?? this.deliveryTimeline,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
      status: status ?? this.status,
      category: category ?? this.category,
      submittedInterest: clearSubmittedInterest
          ? null
          : (submittedInterest ?? this.submittedInterest),
      brandProfile: brandProfile ?? this.brandProfile,
      interestSubmitted: interestSubmitted ?? this.interestSubmitted,
      interestStatus: interestStatus ?? this.interestStatus, // UPDATED
    );
  }

  static JobStatus _parseStatus(String? status) {
    if (status == null) return JobStatus.open;
    switch (status.toLowerCase()) {
      case 'posted':
      case 'open':
        return JobStatus.open;
      case 'applied':
        return JobStatus.applied;
      case 'hired':
        return JobStatus.hired;
      case 'closed':
        return JobStatus.closed;
      default:
        return JobStatus.open;
    }
  }

  // NEW: Parse interest status
  static InterestStatus? _parseInterestStatus(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'pending':
        return InterestStatus.pending;
      case 'hired':
        return InterestStatus.hired;
      case 'rejected':
        return InterestStatus.rejected;
      default:
        return null;
    }
  }
}

// Supporting classes
class SubmittedInterest {
  final String status;
  final DateTime date;

  SubmittedInterest({required this.status, required this.date});

  factory SubmittedInterest.fromJson(Map<String, dynamic> json) {
    return SubmittedInterest(
      status: json['status'] ?? 'pending',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'date': date.toIso8601String()};
  }
}

class BrandProfile {
  final String username;
  final String brandCompanyName;
  final String? logo;
  final String? imageUrl;
  final String? industry;
  final DateTime createdAt;

  BrandProfile({
    required this.username,
    required this.brandCompanyName,
    this.logo,
    this.imageUrl,
    this.industry,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory BrandProfile.fromJson(Map<String, dynamic> json) {
    return BrandProfile(
      username: json['username'] ?? '',
      brandCompanyName: json['brandCompanyName'] ?? '',
      logo: json['logo'],
      imageUrl: json['imageUrl'],
      industry: json['industry'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'brandCompanyName': brandCompanyName,
      if (logo != null) 'logo': logo,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (industry != null) 'industry': industry,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Enums
enum JobStatus { open, applied, closed, hired }

enum JobCategory { all, fashion, food, health }

// NEW: Interest Status Enum
enum InterestStatus { pending, hired, rejected }

// Application Model
class ApplicationModel {
  final String id;
  final String jobId;
  final String title;
  final DateTime submittedAt;
  final String status;
  final String? companyLogo;
  final String? imageUrl;
  final double budget;
  final int videoTimeline;
  final int videoQuantity;
  final int deliveryTimeline;
  final String description;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.title,
    required this.submittedAt,
    this.status = 'pending',
    this.companyLogo,
    this.imageUrl,
    required this.budget,
    required this.videoTimeline,
    required this.videoQuantity,
    required this.deliveryTimeline,
    required this.description,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] ?? json['_id'] ?? '',
      jobId: json['jobId'] ?? '',
      title: json['title'] ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      companyLogo: json['brandProfile']?['imageUrl'],
      imageUrl: json['imageUrl'],
      budget: (json['budget'] ?? 0).toDouble(),
      videoTimeline: json['videoTimeline'],
      videoQuantity: json['videoQuantity'] ?? 0,
      deliveryTimeline: json['deliveryTimeline'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'title': title,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
      'description': description,
      'budget': budget,
      'videoTimeline': videoTimeline,
      'videoQuantity': videoQuantity,
      'deliveryTimeline': deliveryTimeline,
    };
  }
}
