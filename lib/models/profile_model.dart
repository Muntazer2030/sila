// profile_model.dart

class ProfileModel {
  String id;
  String name;
  String entityType; // شخص / مؤسسة / الخ
  String mainCategory;
  String subCategory;
  String governorate;
  String region;
  String status;
  String importance;
  String dataSource;
  
  // Contact
  String primaryPhone;
  String secondaryPhone;
  String email;
  String website;
  String contactPerson;
  String bestContactTime;
  String preferredContactMethod;
  String contactNotes;

  // Social
  String facebookUrl;
  String tiktokUrl;
  String instagramUrl;
  String twitterUrl;
  String linkedinUrl;
  String youtubeUrl;
  String telegramUrl;
  String snapchatUrl;

  bool isVerified;
  String followersCount;

  // Audience
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
    required this.isVerified,
    required this.followersCount,
    required this.audienceType,
    required this.ageGroup,
    required this.interactionLevel,
  });

  // Mock Data for testing
  static ProfileModel getMockData() {
    return ProfileModel(
      id: "101",
      name: "محمد مهدي",
      entityType: "شخص",
      mainCategory: "حكومي",
      subCategory: "مقدم أخبار",
      governorate: "بغداد",
      region: "الجادرية",
      status: "فعال",
      importance: "عالية",
      dataSource: "محمد",
      primaryPhone: "0772925169",
      secondaryPhone: "07729251691",
      email: "mohammadmahdi@gmail.com",
      website: "www.mohammed.iq",
      contactPerson: "مريم",
      bestContactTime: "4:00 PM",
      preferredContactMethod: "اتصال هاتفي",
      contactNotes: "يمشي بلغة الفلوس واحجي وياه بالفلوس اول شي",
      facebookUrl: "facebook.com/mohammed",
      tiktokUrl: "tiktok.com/@mohammed",
      instagramUrl: "instagram.com/mohammed",
      isVerified: true,
      followersCount: "1.2M",
      audienceType: "بنات",
      ageGroup: "18-24",
      interactionLevel: "عالي",
    );
  }
}