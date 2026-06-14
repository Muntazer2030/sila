// lib/models/app_data.dart
import 'package:flutter/material.dart';

class AppData {
  static String name = "Sila";
  static String version = "1.0.0";

  List<Map<String, dynamic>> categories = [
    {"name": "الرئيسية", "icon": Icons.home},
    {
      "name": "الجهات الحكومية",
      "icon": Icons.account_balance_outlined,
      "count": 0,
      "subcategories": [
        {"name": "وزارات", "icon": Icons.account_balance, "count": 0},
        {"name": "هيئات", "icon": Icons.business, "count": 0},
        {"name": "محافظات", "icon": Icons.map, "count": 0},
        {"name": "دوائر", "icon": Icons.apartment, "count": 0},
        {"name": "جامعات حكومية", "icon": Icons.school, "count": 0},
        {"name": "مستشفيات حكومية", "icon": Icons.local_hospital, "count": 0},
        {"name": "مؤسسات أمنية", "icon": Icons.security, "count": 0},
        {"name": "بلديات", "icon": Icons.location_city, "count": 0},
        {"name": "مدارس", "icon": Icons.menu_book, "count": 0},
      ],
    },
    {
      "name": "المؤسسات غير الحكومية",
      "icon": Icons.business,
      "count": 0,
      "subcategories": [
        {"name": "منظمات مجتمع مدني", "icon": Icons.group_work, "count": 0},
        {"name": "فرق تطوعية", "icon": Icons.volunteer_activism, "count": 0},
        {"name": "مؤسسات خيرية", "icon": Icons.favorite, "count": 0},
        {"name": "اتحادات", "icon": Icons.handshake, "count": 0},
        {"name": "نقابات", "icon": Icons.work, "count": 0},
        {"name": "جمعيات", "icon": Icons.people, "count": 0},
        {"name": "مراكز تدريب", "icon": Icons.model_training, "count": 0},
        {"name": "مبادرات شبابية", "icon": Icons.emoji_events, "count": 0},
      ],
    },
    {
      "name": "الشخصيات المؤثرة",
      "icon": Icons.people_alt_outlined,
      "count": 0,
      "subcategories": [
        {"name": "مؤثرين", "icon": Icons.star, "count": 0},
        {"name": "مشاهير سوشيال ميديا", "icon": Icons.camera_alt, "count": 0},
        {"name": "إعلاميين", "icon": Icons.mic, "count": 0},
        {"name": "فنانين", "icon": Icons.palette, "count": 0},
        {"name": "شعراء", "icon": Icons.create, "count": 0},
        {"name": "رياضيين", "icon": Icons.sports_soccer, "count": 0},
        {"name": "صناع محتوى", "icon": Icons.video_camera_front, "count": 0},
        {"name": "ناشطين", "icon": Icons.campaign, "count": 0},
        {"name": "مدونين", "icon": Icons.article, "count": 0},
      ],
    },
    {
      "name": "الشخصيات الأكاديمية",
      "icon": Icons.school,
      "count": 0,
      "subcategories": [
        {"name": "رؤساء جامعات", "icon": Icons.account_balance, "count": 0},
        {"name": "عمداء", "icon": Icons.person, "count": 0},
        {"name": "تدريسيين", "icon": Icons.co_present, "count": 0},
        {"name": "باحثين", "icon": Icons.science, "count": 0},
        {"name": "طلبة مؤثرين", "icon": Icons.school, "count": 0},
        {"name": "شخصيات علمية", "icon": Icons.biotech, "count": 0},
      ],
    },
    {
      "name": "الشخصيات العامة والاجتماعية",
      "icon": Icons.people_outline,
      "count": 0,
      "subcategories": [
        {"name": "وجهاء", "icon": Icons.person_pin, "count": 0},
        {"name": "شيوخ عشائر", "icon": Icons.groups, "count": 0},
        {"name": "رجال دين", "icon": Icons.mosque, "count": 0},
        {"name": "شخصيات مجتمعية", "icon": Icons.public, "count": 0},
        {"name": "قادة رأي", "icon": Icons.lightbulb, "count": 0},
        {"name": "أصحاب مبادرات", "icon": Icons.handshake, "count": 0},
        {"name": "رجال أعمال", "icon": Icons.business_center, "count": 0},
      ],
    },
    {
      "name": "الجمهور",
      "icon": Icons.group,
      "count": 0,
      "subcategories": [
        {"name": "جمهور الفعاليات", "icon": Icons.event_seat, "count": 0},
        {"name": "متطوعين", "icon": Icons.volunteer_activism, "count": 0},
        {"name": "مستفيدين", "icon": Icons.redeem, "count": 0},
        {"name": "متبرعين", "icon": Icons.monetization_on, "count": 0},
        {"name": "مشاركين", "icon": Icons.how_to_reg, "count": 0},
        {"name": "جمهور المنصات الرقمية", "icon": Icons.devices, "count": 0},
      ],
    },
    {
      "name": "الإعلام والمنصات",
      "icon": Icons.newspaper,
      "count": 0,
      "subcategories": [
        {"name": "قنوات تلفزيونية", "icon": Icons.tv, "count": 0},
        {"name": "إذاعات", "icon": Icons.radio, "count": 0},
        {"name": "صحف", "icon": Icons.menu_book, "count": 0},
        {"name": "وكالات", "icon": Icons.public, "count": 0},
        {"name": "صفحات محلية", "icon": Icons.pages, "count": 0},
        {"name": "صفحات جامعية", "icon": Icons.school, "count": 0},
        {"name": "صفحات خدمية", "icon": Icons.room_service, "count": 0},
        {"name": "مجموعات واتساب وتليكرام", "icon": Icons.chat, "count": 0},
      ],
    },
    {
      "name": "القطاع الخاص",
      "icon": Icons.business_center,
      "count": 0,
      "subcategories": [
        {"name": "شركات", "icon": Icons.business, "count": 0},
        {"name": "مطاعم", "icon": Icons.restaurant, "count": 0},
        {"name": "كافيهات", "icon": Icons.local_cafe, "count": 0},
        {"name": "مراكز طبية", "icon": Icons.medical_services, "count": 0},
        {"name": "مطابع", "icon": Icons.print, "count": 0},
        {"name": "شركات تقنية", "icon": Icons.computer, "count": 0},
        {"name": "وكالات إعلان", "icon": Icons.campaign, "count": 0},
        {"name": "شركات إنتاج", "icon": Icons.movie, "count": 0},
        {"name": "رعاة محتملين", "icon": Icons.attach_money, "count": 0},
      ],
    },
    {"name": "الحملات", "icon": Icons.event, "count": 0},
  ];
}

class ContactModel {
  final String name;
  final String category;
  final String role;
  final Color categoryColor;
  final String governorate;
  final String phone;
  final double rating;
  final String lastContactDate;
  final String status;
  final Color statusColor;
  final String? avatarUrl;
  final IconData? fallbackIcon;

  ContactModel({
    required this.name,
    required this.role,
    required this.category,
    required this.categoryColor,
    required this.governorate,
    required this.phone,
    required this.rating,
    required this.lastContactDate,
    required this.status,
    required this.statusColor,
    this.avatarUrl,
    this.fallbackIcon,
  });
}
