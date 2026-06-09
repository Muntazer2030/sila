// profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/models/profile_model.dart';

class ProfileEditScreen extends StatefulWidget {
  final ProfileModel? initialData;

  const ProfileEditScreen({super.key, this.initialData});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late ProfileModel formData;

  @override
  void initState() {
    super.initState();
    formData = widget.initialData ?? ProfileModel.getMockData();
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // هنا يمكنك إرسال formData إلى الـ API
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ البيانات بنجاح!')));
      print("Saved Name: ${formData.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. TOP APP BAR / HEADER
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: c2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.edit_document,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "تعديل بيانات: ${formData.name}",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 22,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "الرئيسية / الأشخاص / تعديل البيانات",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons (Save & Cancel)
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("إلغاء"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _saveData,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text(
                        "حفظ التعديلات",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c2,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. FORM BODY (SCROLLABLE)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWide = constraints.maxWidth > 900;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Right Column (Main Info)
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildBasicInfoSection(),
                                const SizedBox(height: 10),
                                _buildAudienceSection(),
                                const SizedBox(height: 10),
                                _buildHistorySection(),
                              ],
                            ),
                          ),
                          if (isWide) const SizedBox(width: 20),
                          // Left Column (Secondary Info)
                          if (isWide)
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildContactInfoSection(),
                                  const SizedBox(height: 10),
                                  _buildSocialMediaSection(),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // SECTIONS
  // =========================================================================

  Widget _buildBasicInfoSection() {
    return _buildCardWrapper(
      bg: Color.alphaBlend(
        c2.withValues(alpha: 0.05),
        Theme.of(context).colorScheme.surface,
      ),
      title: "البيانات الأساسية",
      icon: Icons.person_outline,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "الاسم الكامل",
                  formData.name,
                  (val) => formData.name = val,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDropdown(
                  "نوع الجهة",
                  formData.entityType,
                  ["شخص", "مؤسسة", "فريق"],
                  (val) => formData.entityType = val!,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "الفئة الرئيسية",
                  formData.mainCategory,
                  ["حكومي", "إعلامي", "مؤثر", "أكاديمي"],
                  (val) => formData.mainCategory = val!,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDropdown(
                  "الفئة الفرعية",
                  formData.subCategory,
                  ["مدونين"],
                  (val) => formData.subCategory = val!,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "المحافظة",
                  formData.governorate,
                  ["بغداد", "البصرة", "أربيل", "النجف"],
                  (val) => formData.governorate = val!,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "المنطقة",
                  formData.region,
                  (val) => formData.region = val,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildDropdown("الحالة", formData.status, [
                  "فعال",
                  "غير فعال",
                  "يحتاج تحديث",
                  "علاقة حساسة",
                ], (val) => formData.status = val!),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDropdown(
                  "درجة الأهمية",
                  formData.importance,
                  ["عالية", "متوسطة", "منخفضة"],
                  (val) => formData.importance = val!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return _buildCardWrapper(
      bg: Color.alphaBlend(
        c1.withValues(alpha: 0.05),
        Theme.of(context).colorScheme.surface,
      ),
      title: "بيانات التواصل",
      icon: Icons.contact_phone_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "رقم الهاتف الأساسي",
                  formData.primaryPhone,
                  (val) => formData.primaryPhone = val,
                  isPhone: true,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "رقم هاتف بديل",
                  formData.secondaryPhone,
                  (val) => formData.secondaryPhone = val,
                  isPhone: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "البريد الإلكتروني",
                  formData.email,
                  (val) => formData.email = val,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "الموقع الإلكتروني",
                  formData.website,
                  (val) => formData.website = val,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "الشخص المسؤول",
                  formData.contactPerson,
                  (val) => formData.contactPerson = val,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "أفضل وقت للتواصل",
                  formData.bestContactTime,
                  (val) => formData.bestContactTime = val,
                ),
              ),
            ],
          ),
          _buildTextField(
            "ملاحظات التواصل",
            formData.contactNotes,
            (val) => formData.contactNotes = val,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceSection() {
    return _buildCardWrapper(
      bg: Color.alphaBlend(
        c2.withValues(alpha: 0.05),
        Theme.of(context).colorScheme.surface,
      ),
      title: "بيانات الجمهور",
      icon: Icons.groups_outlined,
      child: Column(
        children: [
          _buildTextField(
            "نوع الجمهور",
            formData.audienceType,
            (val) => formData.audienceType = val,
          ),
          _buildDropdown("الفئة العمرية", formData.ageGroup, [
            "18-24",
            "25-39",
            "40-55",
            "55+",
          ], (val) => formData.ageGroup = val!),
          _buildDropdown(
            "مستوى التفاعل",
            formData.interactionLevel,
            ["عالي", "متوسط", "ضعيف"],
            (val) => formData.interactionLevel = val!,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return _buildCardWrapper(
      bg: Color.alphaBlend(
        c2.withValues(alpha: 0.05),
        Theme.of(context).colorScheme.surface,
      ),
      title: "تاريخ العلاقة مع المؤسسة",
      icon: Icons.history,
      child: Column(
        children: [
          _buildDropdown("نوع العلاقة", formData.ageGroup, [
            "شراكة",
            "تعاون",
            "دعم إعلامي",
            "حضور فعاليات",
            "متبرع",
            "مستفيد",
            "جهة رسمية",
            "مرشح للتعاون",
          ], (val) => formData.ageGroup = val!),
          _buildTextField(
            "عدد مرات التعاون",
            formData.audienceType,
            (val) => formData.audienceType = val,
          ),
          _buildDropdown(
            "مستوى التفاعل",
            formData.interactionLevel,
            ["عالي", "متوسط", "ضعيف"],
            (val) => formData.interactionLevel = val!,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildCardWrapper(
      bg: Color.alphaBlend(
        c1.withValues(alpha: 0.05),
        Theme.of(context).colorScheme.surface,
      ),
      title: "حسابات السوشيال ميديا",
      icon: Icons.language,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "رابط Instagram",
                  formData.instagramUrl,
                  (val) => formData.instagramUrl = val,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "رابط Facebook",
                  formData.facebookUrl,
                  (val) => formData.facebookUrl = val,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "رابط TikTok",
                  formData.tiktokUrl,
                  (val) => formData.tiktokUrl = val,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "رابط X/Twitter",
                  formData.instagramUrl,
                  (val) => formData.instagramUrl = val,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "رابط Youtube",
                  formData.instagramUrl,
                  (val) => formData.instagramUrl = val,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "رابط Snapchat",
                  formData.instagramUrl,
                  (val) => formData.instagramUrl = val,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "رابط Telegram channel",
                  formData.instagramUrl,
                  (val) => formData.instagramUrl = val,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "رابط Linkedin",
                  formData.instagramUrl,
                  (val) => formData.instagramUrl = val,
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "عدد المتابعين",
                  formData.followersCount,
                  (val) => formData.followersCount = val,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: CheckboxListTile(
                  title: const Text(
                    "الحساب موثق؟",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  value: formData.isVerified,
                  activeColor: c2,
                  onChanged: (val) =>
                      setState(() => formData.isVerified = val ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Widget child,
    Color? bg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg ?? Colors.white,

        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: c2, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    Function(String) onSaved, {
    int maxLines = 1,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: initialValue,
            maxLines: maxLines,
            textDirection: isPhone
                ? TextDirection.ltr
                : TextDirection.rtl, // الأرقام دائماً LTR
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: c2, width: 1.5),
              ),
            ),
            onSaved: (val) => onSaved(val ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String currentValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: options.contains(currentValue)
                ? currentValue
                : options.first,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: c2, width: 1.5),
              ),
            ),
            items: options.map((String val) {
              return DropdownMenuItem(
                value: val,
                child: Text(val, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (val) {
              onChanged(val);
              setState(() {});
            },
            onSaved: onChanged,
          ),
        ],
      ),
    );
  }
}
