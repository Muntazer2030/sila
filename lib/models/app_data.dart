import 'package:flutter/material.dart';

class AppData {
  static String name = "Sila";
  static String version = "1.0.0";

  List<Map<String, dynamic>> categories = [
    {"name": "الرئيسية", "icon": Icons.home},
    {
      "name": "المؤسسات الحكومية",
      "icon": Icons.account_balance_outlined,
      "count": 12,
      "subcategories": [
        {
          "name": "ﻣﻨﻈﻤﺎﺕ ﻣﺠﺘﻤﻊ ﻣﺪﻧﻲ",
          "icon": Icons.account_balance_outlined,
          "count": 2,
        },
        {
          "name": "ﻓﺮﻕ ﺗﻄﻮﻋﻴﺔ",
          "icon": Icons.account_balance_outlined,
          "count": 2,
        },
        {
          "name": "ﻣﺆﺳﺴﺎﺕ ﺧﻴﺮﻳﺔ",
          "icon": Icons.account_balance_outlined,
          "count": 3,
        },
        {"name": "ﺍﺗﺤﺎﺩﺍﺕ", "icon": Icons.account_balance_outlined, "count": 2},
        {"name": "ﻧﻘﺎﺑﺎﺕ", "icon": Icons.account_balance_outlined, "count": 3},
        {"name": "جمعيات", "icon": Icons.account_balance_outlined, "count": 2},
        {
          "name": "ﻣﺮﺍﻛﺰ ﺗﺪﺭﻳﺐ",
          "icon": Icons.account_balance_outlined,
          "count": 4,
        },
        {
          "name": "ﻣﺒﺎﺩﺭﺍﺕ ﺷﺒﺎﺑﻴﺔ",
          "icon": Icons.account_balance_outlined,
          "count": 1,
        },
      ],
    },
    {
      "name": "المؤسسات غير الحكومية",
      "icon": Icons.business,
      "count": 12,
    },
    {"name": "الشخصيات المؤثرة", "icon": Icons.people_alt_outlined, "count": 12},
    {"name": "الشخصيات الأكاديمية", "icon": Icons.school, "count": 12},
    {
      "name": "الشخصيات العامة والأجتماعية",
      "icon": Icons.people_outline,
      "count": 12,
    },
    {"name": "الجمهور", "icon": Icons.group, "count": 12},
    {"name": "الأعلام والمنصات", "icon": Icons.newspaper, "count": 12},
    {"name": "القطاع الخاص", "icon": Icons.business_center, "count": 12},
    {"name": "الحملات", "icon": Icons.campaign, "count": 12},
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
