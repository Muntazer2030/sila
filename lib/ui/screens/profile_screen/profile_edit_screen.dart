// lib/ui/screens/home_screen/pages/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/models/profile_model.dart';
import 'package:sila/models/app_data.dart';
import 'package:sila/data/database_helper.dart'; 

class ProfileEditScreen extends StatefulWidget {
  final ProfileModel? initialData;
  final bool isEditMode;

  const ProfileEditScreen({super.key, this.initialData, this.isEditMode = false});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late ProfileModel formData;
  late bool isEditMode;

  List<String> mainCategories = [];
  List<String> subCategories = [];

  final List<String> governorates = [
    "بغداد", "البصرة", "نينوى", "أربيل", "النجف", "كربلاء", "كركوك", 
    "الأنبار", "ذي قار", "ديالى", "بابل", "ميسان", "واسط", "الديوانية", 
    "صلاح الدين", "دهوك", "السليمانية", "حلبجة"
  ];

  @override
  void initState() {
    super.initState();
    isEditMode = widget.isEditMode;
    formData = widget.initialData ?? ProfileModel.empty();

    // جلب الفئات الرئيسية من app_data متجاهلين "الرئيسية"
    var appData = AppData();
    mainCategories = appData.categories
        .skip(1)
        .map((e) => e['name'] as String)
        .toList();

    // التأكد من أن الفئة الرئيسية القادمة من الجدول موجودة بالفعل
    if (!mainCategories.contains(formData.mainCategory)) {
      formData.mainCategory = mainCategories.first;
    }

    _updateSubCategories();
  }

  // تحديث الفئات الفرعية بناءً على الفئة الرئيسية المختارة
  void _updateSubCategories() {
    var appData = AppData();
    try {
      var selectedCat = appData.categories.firstWhere(
        (c) => c['name'] == formData.mainCategory,
      );
      if (selectedCat.containsKey('subcategories')) {
        subCategories = (selectedCat['subcategories'] as List)
            .map((s) => s['name'] as String)
            .toList();
      } else {
        subCategories = ["أخرى"];
      }
    } catch (e) {
      subCategories = ["أخرى"];
    }

    if (subCategories.isNotEmpty && !subCategories.contains(formData.subCategory)) {
      formData.subCategory = subCategories.first;
    }
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (isEditMode) {
        // تحديث البيانات الحالية
        await DatabaseHelper.instance.updateProfile(formData);
      } else {
        // إضافة سجل جديد وإعطاءه ID فريد
        formData.id = const Uuid().v4(); 
        await DatabaseHelper.instance.insertProfile(formData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditMode ? 'تم تحديث البيانات بنجاح!' : 'تمت الإضافة بنجاح!')),
        );
        // إغلاق الشاشة وإرجاع true لتحديث الجدول
        Navigator.pop(context, true); 
      }
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: c2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEditMode ? Icons.edit_document : Icons.person_add_alt_1, 
                        color: Colors.white, 
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditMode ? "تعديل بيانات: ${formData.name}" : "إضافة سجل جديد (${formData.mainCategory})",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEditMode ? "الرئيسية / الأشخاص / تعديل البيانات" : "الرئيسية / الأشخاص / إضافة شخص",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("إلغاء"),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _saveData,
                      icon: const Icon(Icons.save, size: 18),
                      label: Text(isEditMode ? "حفظ التعديلات" : "حفظ وإضافة", style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c2,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. FORM BODY
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ================= RIGHT COLUMN =================
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildBasicInfoSection(),
                                const SizedBox(height: 12),
                                _buildContactInfoSection(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          
                          // ================= LEFT COLUMN =================
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildSocialMediaSection(),
                                const SizedBox(height: 12),
                                _buildAudienceSection(),
                                const SizedBox(height: 12),
                                _buildHistorySection(),
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
      bg: Color.alphaBlend(c2.withValues(alpha: 0.05), Theme.of(context).colorScheme.surface),
      title: "البيانات الأساسية",
      icon: Icons.person_outline,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField("الاسم الكامل", formData.name, (val) => formData.name = val)),
              const SizedBox(width: 15),
              Expanded(child: _buildDropdown("نوع الجهة", formData.entityType, ["شخص", "مؤسسة", "فريق"], (val) => formData.entityType = val!)),
            ],
          ),
          Row(
            children: [
              // الفئة الرئيسية ديناميكية
              Expanded(child: _buildDropdown("الفئة الرئيسية", formData.mainCategory, mainCategories, (val) {
                formData.mainCategory = val!;
                _updateSubCategories(); // تحديث القائمة الفرعية عند تغيير الرئيسية
                setState(() {});
              })),
              const SizedBox(width: 15),
              // الفئة الفرعية ديناميكية
              Expanded(child: _buildDropdown("الفئة الفرعية", formData.subCategory, subCategories, (val) => formData.subCategory = val!)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildDropdown("المحافظة", formData.governorate, governorates, (val) => formData.governorate = val!)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField("المنطقة", formData.region, (val) => formData.region = val)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildDropdown("الحالة", formData.status, ["فعال", "غير فعال", "يحتاج تحديث", "علاقة حساسة"], (val) => formData.status = val!)),
              const SizedBox(width: 15),
              Expanded(child: _buildDropdown("درجة الأهمية", formData.importance, ["عالية", "متوسطة", "منخفضة"], (val) => formData.importance = val!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return _buildCardWrapper(
      bg: Color.alphaBlend(c1.withValues(alpha: 0.05), Theme.of(context).colorScheme.surface),
      title: "بيانات التواصل",
      icon: Icons.contact_phone_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField("رقم الهاتف الأساسي", formData.primaryPhone, (val) => formData.primaryPhone = val, isPhone: true)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField("رقم هاتف بديل", formData.secondaryPhone, (val) => formData.secondaryPhone = val, isPhone: true)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField("البريد الإلكتروني", formData.email, (val) => formData.email = val)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField("الموقع الإلكتروني", formData.website, (val) => formData.website = val)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField("الشخص المسؤول", formData.contactPerson, (val) => formData.contactPerson = val)),
              const SizedBox(width: 15),
              Expanded(child: _buildTimePickerField("أفضل وقت للتواصل", formData.bestContactTime, (val) => formData.bestContactTime = val)),
            ],
          ),
          _buildTextField("ملاحظات التواصل", formData.contactNotes, (val) => formData.contactNotes = val, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildCardWrapper(
      bg: Color.alphaBlend(c1.withValues(alpha: 0.05), Theme.of(context).colorScheme.surface),
      title: "حسابات السوشيال ميديا",
      icon: Icons.language,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField("Instagram", formData.instagramUrl, (val) => formData.instagramUrl = val)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField("Facebook", formData.facebookUrl, (val) => formData.facebookUrl = val)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField("TikTok", formData.tiktokUrl, (val) => formData.tiktokUrl = val)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField("X / Twitter", formData.twitterUrl, (val) => formData.twitterUrl = val)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField("Youtube", formData.youtubeUrl, (val) => formData.youtubeUrl = val)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField("Snapchat", formData.snapchatUrl, (val) => formData.snapchatUrl = val)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField("Telegram", formData.telegramUrl, (val) => formData.telegramUrl = val)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField("Linkedin", formData.linkedinUrl, (val) => formData.linkedinUrl = val)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField("عدد المتابعين", formData.followersCount, (val) => formData.followersCount = val)),
              const SizedBox(width: 15),
              Expanded(
                child: CheckboxListTile(
                  title: const Text("الحساب موثق؟", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  value: formData.isVerified,
                  activeColor: c2,
                  onChanged: (val) => setState(() => formData.isVerified = val ?? false),
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

  Widget _buildAudienceSection() {
    return _buildCardWrapper(
      bg: Color.alphaBlend(c2.withValues(alpha: 0.05), Theme.of(context).colorScheme.surface),
      title: "بيانات الجمهور",
      icon: Icons.groups_outlined,
      child: Row(
        children: [
          Expanded(child: _buildTextField("نوع الجمهور", formData.audienceType, (val) => formData.audienceType = val)),
          const SizedBox(width: 15),
          Expanded(child: _buildDropdown("العمر", formData.ageGroup, ["18-24", "25-39", "40-55", "55+"], (val) => formData.ageGroup = val!)),
          const SizedBox(width: 15),
          Expanded(child: _buildDropdown("التفاعل", formData.interactionLevel, ["عالي", "متوسط", "ضعيف"], (val) => formData.interactionLevel = val!)),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return _buildCardWrapper(
      bg: Color.alphaBlend(c2.withValues(alpha: 0.05), Theme.of(context).colorScheme.surface),
      title: "تاريخ العلاقة والتقييم",
      icon: Icons.history,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown("نوع العلاقة", formData.status, ["شراكة", "تعاون", "دعم إعلامي", "حضور فعاليات", "متبرع", "مستفيد", "جهة رسمية", "مرشح للتعاون"], (val) => formData.status = val!),
              ),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField("عدد مرات التعاون", "4", (val) => print(val))),
            ],
          ),
          _buildRatingField("تقييم العلاقة (من 1 إلى 5)"),
        ],
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _buildCardWrapper({required String title, required IconData icon, required Widget child, Color? bg}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15), 
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: c2, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onSaved, {int maxLines = 1, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 4), 
          TextFormField(
            initialValue: initialValue,
            maxLines: maxLines,
            textDirection: isPhone ? TextDirection.ltr : TextDirection.rtl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: c2, width: 1.5)),
            ),
            onSaved: (val) => onSaved(val ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: options.contains(currentValue) ? currentValue : options.first,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: c2, width: 1.5)),
            ),
            items: options.map((String val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (val) {
              onChanged(val);
            },
            onSaved: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField(String label, String currentValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          InkWell(
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: c2, onPrimary: Colors.white, onSurface: Colors.black)),
                  child: Directionality(textDirection: TextDirection.rtl, child: child!),
                ),
              );
              if (pickedTime != null && mounted) {
                onChanged(pickedTime.format(context));
                setState(() {});
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), 
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(currentValue.isEmpty ? "اختر الوقت..." : currentValue, style: TextStyle(fontSize: 13, color: currentValue.isEmpty ? Colors.grey : Colors.black87)),
                  const Icon(Icons.access_time, color: c2, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, top: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: EditableStarRating(
              initialRating: 4.0,
              onChanged: (newRating) => print("New Rating: $newRating"),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// EDITABLE STAR RATING WIDGET
// =========================================================================

class EditableStarRating extends StatefulWidget {
  final double initialRating;
  final Function(double) onChanged;

  const EditableStarRating({super.key, required this.initialRating, required this.onChanged});

  @override
  State<EditableStarRating> createState() => _EditableStarRatingState();
}

class _EditableStarRatingState extends State<EditableStarRating> {
  late double currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return GestureDetector(
            onTap: () {
              setState(() => currentRating = index + 1.0);
              widget.onChanged(currentRating);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 24, 
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        Text(currentRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}