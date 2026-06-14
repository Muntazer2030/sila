// lib/models/campaign_model.dart

class CampaignModel {
  String id;
  String name;
  String description;
  String startDate;
  String endDate;

  CampaignModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  factory CampaignModel.fromMap(Map<String, dynamic> map) {
    return CampaignModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
    );
  }

  static CampaignModel empty() {
    String today = DateTime.now().toIso8601String().split('T')[0];
    return CampaignModel(
      id: '',
      name: '',
      description: '',
      startDate: today,
      endDate: today,
    );
  }
}