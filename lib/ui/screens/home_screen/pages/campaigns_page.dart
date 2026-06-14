// lib/ui/screens/campaigns_screen/campaigns_page.dart
import 'package:flutter/material.dart';
import 'package:sila/ui/screens/campaign/campaign_details_screen.dart';

import 'package:uuid/uuid.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/models/campaign_model.dart';
import 'package:sila/data/database_helper.dart';


class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  List<CampaignModel> campaigns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    final data = await DatabaseHelper.instance.getAllCampaigns();
    setState(() {
      campaigns = data;
      isLoading = false;
    });
  }

  Future<void> _createNewCampaign() async {
    CampaignModel newCampaign = CampaignModel.empty();
    newCampaign.id = const Uuid().v4();
    newCampaign.name = "حملة جديدة";
    
    await DatabaseHelper.instance.insertCampaign(newCampaign);
    _openCampaign(newCampaign);
  }

  void _openCampaign(CampaignModel campaign) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CampaignDetailsScreen(campaign: campaign)),
    );
    _loadCampaigns(); // Refresh when returning
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIXED HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: c2, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.campaign, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("الحملات والفعاليات", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24)),
                    const SizedBox(height: 2),
                    Text("الرئيسية / الحملات", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _createNewCampaign,
                style: ElevatedButton.styleFrom(backgroundColor: c2, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                icon: const Icon(Icons.add),
                label: const Text("إنشاء حملة جديدة", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // BODY
        Expanded(
          child: isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : GridView.builder(
                padding: const EdgeInsets.all(20),
                // الحل الجذري للمشكلة: استخدام MaxCrossAxisExtent لتحديد عدد الأعمدة تلقائياً
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 450, // أقصى عرض للبطاقة قبل أن تنزل لسطر جديد
                  mainAxisExtent: 170, // ارتفاع ثابت للبطاقة يحميها من الـ Overflow تماماً
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  var camp = campaigns[index];
                  return InkWell(
                    onTap: () => _openCampaign(camp),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event, color: c2),
                              const SizedBox(width: 10),
                              Expanded(child: Text(camp.name.isEmpty ? "بدون اسم" : camp.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Text(camp.description.isEmpty ? "لا يوجد وصف" : camp.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(height: 10),
                          // استخدام Wrap بدلاً من Row لضمان عدم حدوث تصادم في النصوص عند تصغير الشاشة جداً
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 10,
                            runSpacing: 5,
                            children: [
                              Text("البداية: ${camp.startDate}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text("النهاية: ${camp.endDate}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c1)),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}