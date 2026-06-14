// lib/ui/screens/campaigns_screen/campaign_details_screen.dart
import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/models/campaign_model.dart';
import 'package:sila/models/profile_model.dart';
import 'package:sila/data/database_helper.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final CampaignModel campaign;
  const CampaignDetailsScreen({super.key, required this.campaign});

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  late CampaignModel campaign;
  List<ProfileModel> allProfiles = [];
  Set<String> invitedProfileIds = {};

  // Filter States
  String searchQuery = "";
  String selectedMainCategory = "جميع الفئات الرئيسية";
  String selectedSubCategory = "جميع التخصصات";
  String selectedGovernorate = "جميع المحافظات";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    campaign = widget.campaign;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    allProfiles = await DatabaseHelper.instance.getAllProfiles();
    List<String> ids = await DatabaseHelper.instance.getInvitedProfileIds(
      campaign.id,
    );
    setState(() {
      invitedProfileIds = ids.toSet();
      isLoading = false;
    });
  }

  // --- Campaign Details Editing ---
  void _saveCampaignDetails() async {
    await DatabaseHelper.instance.updateCampaign(campaign);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "تم حفظ تفاصيل الفعالية",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // --- Invitation Logic ---
  void _inviteProfile(String profileId) async {
    await DatabaseHelper.instance.addInvite(campaign.id, profileId);
    setState(() => invitedProfileIds.add(profileId));
  }

  void _removeInvite(String profileId) async {
    await DatabaseHelper.instance.removeInvite(campaign.id, profileId);
    setState(() => invitedProfileIds.remove(profileId));
  }

  void _deleteCampaign() async {
    await DatabaseHelper.instance.deleteCampaign(campaign.id);
    if (mounted) Navigator.pop(context);
  }

  // --- Date Picker Logic ---
  Future<void> _pickDate(
    String initialDate,
    Function(String) onDateSelected,
  ) async {
    DateTime? initial = DateTime.tryParse(initialDate);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: c2,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        onDateSelected(picked.toIso8601String().split('T')[0]);
      });
    }
  }

  // --- Profile Info Popup ---
  void _showProfileInfo(ProfileModel p) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.all(25),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: c2.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: c2, size: 40),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        p.name.isEmpty ? "بدون اسم" : p.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SelectableText(
                        "${p.mainCategory} - ${p.subCategory}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black54,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: SizedBox(
              width: 700,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Divider(),
                    _buildFancyInfoRow(
                      Icons.phone,
                      "الهاتف الأساسي",
                      p.primaryPhone,
                      isLtr: true,
                    ),
                    _buildFancyInfoRow(
                      Icons.phone_android,
                      "هاتف بديل",
                      p.secondaryPhone,
                      isLtr: true,
                    ),
                    _buildFancyInfoRow(
                      Icons.location_on,
                      "المحافظة والمنطقة",
                      "${p.governorate} - ${p.region}",
                    ),
                    _buildFancyInfoRow(Icons.badge, "نوع الجهة", p.entityType),
                    _buildFancyInfoRow(
                      Icons.email,
                      "البريد الإلكتروني",
                      p.email,
                      isLtr: true,
                    ),
                    _buildFancyInfoRow(
                      Icons.language,
                      "الموقع الإلكتروني",
                      p.website,
                      isLtr: true,
                    ),
                    _buildFancyInfoRow(
                      Icons.contact_support,
                      "الشخص المسؤول",
                      p.contactPerson,
                    ),
                    _buildFancyInfoRow(
                      Icons.access_time,
                      "أفضل وقت للتواصل",
                      p.bestContactTime,
                    ),
                    const Divider(),
                    _buildFancyInfoRow(
                      Icons.star,
                      "التقييم",
                      p.rating.toStringAsFixed(1),
                    ),
                    _buildFancyInfoRow(
                      Icons.groups,
                      "الجمهور المستهدف",
                      "${p.audienceType} (${p.ageGroup}) - تفاعل: ${p.interactionLevel}",
                    ),
                    _buildFancyInfoRow(
                      Icons.info_outline,
                      "الحالة والأهمية",
                      "${p.status} - أهمية ${p.importance}",
                    ),
                    const Divider(),
                    _buildFancyInfoRow(
                      Icons.facebook,
                      "فيسبوك",
                      p.facebookUrl,
                      isLtr: true,
                    ),
                    _buildFancyInfoRow(
                      Icons.tiktok,
                      "تيك توك",
                      p.tiktokUrl,
                      isLtr: true,
                    ),
                    _buildFancyInfoRow(
                      Icons.camera_alt,
                      "انستغرام",
                      p.instagramUrl,
                      isLtr: true,
                    ),
                    _buildFancyInfoRow(
                      Icons.group,
                      "عدد المتابعين",
                      "${p.followersCount} ${p.isVerified ? '(حساب موثق ✅)' : ''}",
                    ),
                    const Divider(),
                    _buildFancyInfoRow(Icons.notes, "ملاحظات", p.contactNotes),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.all(20),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "إغلاق النافذة",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: c2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFancyInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLtr = false,
  }) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c1.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: c1),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Prepare Filter Options dynamically
    List<String> mainCats = [
      "جميع الفئات الرئيسية",
      ...allProfiles.map((e) => e.mainCategory).toSet(),
    ];
    List<String> govs = [
      "جميع المحافظات",
      ...allProfiles.map((e) => e.governorate).toSet(),
    ];

    List<String> subCats = ["جميع التخصصات"];
    if (selectedMainCategory != "جميع الفئات الرئيسية") {
      subCats.addAll(
        allProfiles
            .where((e) => e.mainCategory == selectedMainCategory)
            .map((e) => e.subCategory)
            .toSet(),
      );
    } else {
      subCats.addAll(allProfiles.map((e) => e.subCategory).toSet());
    }

    if (!mainCats.contains(selectedMainCategory)) {
      selectedMainCategory = "جميع الفئات الرئيسية";
    }
    if (!subCats.contains(selectedSubCategory)) {
      selectedSubCategory = "جميع التخصصات";
    }
    if (!govs.contains(selectedGovernorate)) {
      selectedGovernorate = "جميع المحافظات";
    }

    // 2. Filter Lists
    List<ProfileModel> invitedProfiles = allProfiles
        .where((p) => invitedProfileIds.contains(p.id))
        .toList();

    List<ProfileModel> availableProfiles = allProfiles.where((p) {
      if (invitedProfileIds.contains(p.id)) return false;

      bool matchSearch =
          searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.primaryPhone.contains(searchQuery);

      bool matchMain =
          selectedMainCategory == "جميع الفئات الرئيسية" ||
          p.mainCategory == selectedMainCategory;
      bool matchSub =
          selectedSubCategory == "جميع التخصصات" ||
          p.subCategory == selectedSubCategory;
      bool matchGov =
          selectedGovernorate == "جميع المحافظات" ||
          p.governorate == selectedGovernorate;

      return matchSearch && matchMain && matchSub && matchGov;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isTooSmallScreen =
                constraints.maxWidth < 500 || constraints.maxHeight < 500;

            return isTooSmallScreen
                ? Container()
                : Column(
                    children: [
                      // HEADER
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 15),
                            const Icon(Icons.campaign, color: c2, size: 35),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                "إدارة الحملة: ${campaign.name}",
                                style:  TextStyle(
                                  fontSize: 10 * constraints.maxWidth / 500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            ElevatedButton.icon(
                              onPressed: _saveCampaignDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: c2,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              icon: const Icon(Icons.save, size: 20),
                              label: const Text(
                                "حفظ التعديلات",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            OutlinedButton.icon(
                              onPressed: _deleteCampaign,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              icon: const Icon(Icons.delete, size: 20),
                              label: const Text(
                                "حذف الفعالية",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // RESPONSIVE BODY WITH SMART CONSTRAINTS (THE FIX)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Check if screen is wide and has enough height
                              bool isWide = constraints.maxWidth > 900;
                              bool isTallEnough = constraints.maxHeight > 600;

                              Widget leftPanel = _buildLeftPanel(
                                availableProfiles,
                                mainCats,
                                subCats,
                                govs,
                              );
                              Widget rightPanel = _buildRightPanel(
                                invitedProfiles,
                              );

                              if (isWide && isTallEnough) {
                                // Safe Desktop Layout
                                return Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(flex: 5, child: leftPanel),
                                    const SizedBox(width: 20),
                                    Expanded(flex: 4, child: rightPanel),
                                  ],
                                );
                              } else if (isWide && !isTallEnough) {
                                // Wide but short window -> Make it scrollable vertically
                                return SingleChildScrollView(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: SizedBox(
                                          height: 750,
                                          child: leftPanel,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        flex: 4,
                                        child: SizedBox(
                                          height: 750,
                                          child: rightPanel,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                // Narrow window -> Stack them vertically and make scrollable
                                return SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 800, child: leftPanel),
                                      const SizedBox(height: 20),
                                      SizedBox(height: 600, child: rightPanel),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  // ================= LEFT COLUMN: SETTINGS & SEARCH =================
  Widget _buildLeftPanel(
    List<ProfileModel> availableProfiles,
    List<String> mainCats,
    List<String> subCats,
    List<String> govs,
  ) {
    return Column(
      children: [
        // 1. Campaign Details Form
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "تفاصيل الفعالية",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: c2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "اسم الفعالية",
                      campaign.name,
                      (val) => campaign.name = val,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildDatePickerField(
                      "تاريخ البداية",
                      campaign.startDate,
                      (val) => campaign.startDate = val,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildDatePickerField(
                      "تاريخ النهاية",
                      campaign.endDate,
                      (val) => campaign.endDate = val,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                "وصف الفعالية",
                campaign.description,
                (val) => campaign.description = val,
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Available Profiles Search & Filter
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "البحث وإضافة مدعوين",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 15),

                // Filters Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: "ابحث بالاسم أو الهاتف...",
                          prefixIcon: const Icon(Icons.search, size: 24),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                        selectedGovernorate,
                        govs,
                        (val) => setState(() => selectedGovernorate = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        selectedMainCategory,
                        mainCats,
                        (val) => setState(() {
                          selectedMainCategory = val!;
                          selectedSubCategory = "جميع التخصصات";
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                        selectedSubCategory,
                        subCats,
                        (val) => setState(() => selectedSubCategory = val!),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: availableProfiles.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            var p = availableProfiles[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
                              ),
                              onTap: () => _showProfileInfo(p),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              ),
                              title: Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "🏢 ${p.mainCategory} - ${p.subCategory}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "📍 ${p.governorate}  |  📞 ${p.primaryPhone.isEmpty ? 'لا يوجد هاتف' : p.primaryPhone}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: c2,
                                  size: 35,
                                ),
                                onPressed: () => _inviteProfile(p.id),
                                tooltip: "دعوة",
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= RIGHT COLUMN: INVITED PROFILES =================
  Widget _buildRightPanel(List<ProfileModel> invitedProfiles) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "قائمة المدعوين",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: c1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: c1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${invitedProfiles.length} شخص",
                  style: const TextStyle(
                    color: c1,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: invitedProfiles.isEmpty
                ? const Center(
                    child: Text(
                      "لم يتم دعوة أي شخص بعد.",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    itemCount: invitedProfiles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      var p = invitedProfiles[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 15,
                          ),
                          onTap: () => _showProfileInfo(p),
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 35,
                            ),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "🏢 ${p.subCategory}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "📞 ${p.primaryPhone.isEmpty ? 'لا يوجد هاتف' : p.primaryPhone}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                              size: 30,
                            ),
                            onPressed: () => _removeInvite(p.id),
                            tooltip: "إزالة من القائمة",
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildTextField(
    String label,
    String initialValue,
    Function(String) onChanged, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: initialValue,
            maxLines: maxLines,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(
    String label,
    String currentValue,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _pickDate(currentValue, onChanged),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentValue,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Icon(Icons.calendar_month, color: c2, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String currentValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentValue,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
            size: 24,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
