// lib/models/profile_model.dart

class ProfileModel {
  String id;
  String name;
  String entityType;
  String mainCategory;
  String subCategory;
  String governorate;
  String region;
  String status;
  String importance;
  String dataSource;
  
  String primaryPhone;
  String secondaryPhone;
  String email;
  String website;
  String contactPerson;
  String bestContactTime;
  String preferredContactMethod;
  String contactNotes;

  String facebookUrl;
  String tiktokUrl;
  String instagramUrl;
  String twitterUrl;
  String youtubeUrl;
  String snapchatUrl;
  String telegramUrl;
  String linkedinUrl;
  bool isVerified;
  String followersCount;

  String audienceType;
  String ageGroup;
  String interactionLevel;

  ProfileModel({
    required this.id,
    required this.name,
    required this.entityType,
    required this.mainCategory,
    required this.subCategory,
    required this.governorate,
    required this.region,
    required this.status,
    required this.importance,
    required this.dataSource,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.email,
    required this.website,
    required this.contactPerson,
    required this.bestContactTime,
    required this.preferredContactMethod,
    required this.contactNotes,
    required this.facebookUrl,
    required this.tiktokUrl,
    required this.instagramUrl,
    required this.twitterUrl,
    required this.youtubeUrl,
    required this.snapchatUrl,
    required this.telegramUrl,
    required this.linkedinUrl,
    required this.isVerified,
    required this.followersCount,
    required this.audienceType,
    required this.ageGroup,
    required this.interactionLevel,
  });

  // Convert ProfileModel to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'entityType': entityType,
      'mainCategory': mainCategory,
      'subCategory': subCategory,
      'governorate': governorate,
      'region': region,
      'status': status,
      'importance': importance,
      'dataSource': dataSource,
      'primaryPhone': primaryPhone,
      'secondaryPhone': secondaryPhone,
      'email': email,
      'website': website,
      'contactPerson': contactPerson,
      'bestContactTime': bestContactTime,
      'preferredContactMethod': preferredContactMethod,
      'contactNotes': contactNotes,
      'facebookUrl': facebookUrl,
      'tiktokUrl': tiktokUrl,
      'instagramUrl': instagramUrl,
      'twitterUrl': twitterUrl,
      'youtubeUrl': youtubeUrl,
      'snapchatUrl': snapchatUrl,
      'telegramUrl': telegramUrl,
      'linkedinUrl': linkedinUrl,
      'isVerified': isVerified ? 1 : 0, // SQLite stores bools as 0 or 1
      'followersCount': followersCount,
      'audienceType': audienceType,
      'ageGroup': ageGroup,
      'interactionLevel': interactionLevel,
    };
  }

  // Create a ProfileModel from SQLite Map
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      name: map['name'],
      entityType: map['entityType'],
      mainCategory: map['mainCategory'],
      subCategory: map['subCategory'],
      governorate: map['governorate'],
      region: map['region'],
      status: map['status'],
      importance: map['importance'],
      dataSource: map['dataSource'],
      primaryPhone: map['primaryPhone'],
      secondaryPhone: map['secondaryPhone'],
      email: map['email'],
      website: map['website'],
      contactPerson: map['contactPerson'],
      bestContactTime: map['bestContactTime'],
      preferredContactMethod: map['preferredContactMethod'],
      contactNotes: map['contactNotes'],
      facebookUrl: map['facebookUrl'],
      tiktokUrl: map['tiktokUrl'],
      instagramUrl: map['instagramUrl'],
      twitterUrl: map['twitterUrl'],
      youtubeUrl: map['youtubeUrl'],
      snapchatUrl: map['snapchatUrl'],
      telegramUrl: map['telegramUrl'],
      linkedinUrl: map['linkedinUrl'],
      isVerified: map['isVerified'] == 1,
      followersCount: map['followersCount'],
      audienceType: map['audienceType'],
      ageGroup: map['ageGroup'],
      interactionLevel: map['interactionLevel'],
    );
  }

  static ProfileModel empty() {
    return ProfileModel(
      id: "", name: "", entityType: "شخص", mainCategory: "حكومي", subCategory: "أخرى",
      governorate: "بغداد", region: "", status: "فعال", importance: "عالية", dataSource: "",
      primaryPhone: "", secondaryPhone: "", email: "", website: "", contactPerson: "",
      bestContactTime: "", preferredContactMethod: "اتصال هاتفي", contactNotes: "",
      facebookUrl: "", tiktokUrl: "", instagramUrl: "", twitterUrl: "", youtubeUrl: "",
      snapchatUrl: "", telegramUrl: "", linkedinUrl: "", isVerified: false, followersCount: "",
      audienceType: "", ageGroup: "18-24", interactionLevel: "متوسط",
    );
  }
}