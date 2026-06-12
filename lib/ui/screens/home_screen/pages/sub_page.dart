// lib/ui/screens/home_screen/pages/sub_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:uuid/uuid.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/models/profile_model.dart';
import 'package:sila/data/database_helper.dart';
import 'package:sila/ui/screens/profile_screen/profile_edit_screen.dart';
import 'package:sila/ui/widgets/cool_widgets.dart';
import 'package:sila/ui/widgets/statistics_widgets.dart';

class SubPage extends StatefulWidget {
  final Map<String, dynamic> category;

  const SubPage({super.key, required this.category});

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  List<int> selectedIndex = [];
  List<ProfileModel> allProfiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant SubPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category['name'] != widget.category['name']) {
      selectedIndex.clear();
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getProfilesByCategory(
      widget.category['name'],
    );
    setState(() {
      allProfiles = data;
      isLoading = false;
    });
  }

  int _getSubcategoryCount(String subCatName) {
    return allProfiles.where((p) => p.subCategory == subCatName).length;
  }

  List<ProfileModel> get _gridFilteredProfiles {
    if (selectedIndex.isEmpty) return allProfiles;
    List<String> activeSubcategories = selectedIndex.map((idx) {
      return widget.category["subcategories"][idx]["name"] as String;
    }).toList();
    return allProfiles
        .where((p) => activeSubcategories.contains(p.subCategory))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. FIXED HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: c2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.category['icon'],
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category['name'],
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "الرئيسية / ${widget.category['name']} / ",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. SCROLLING DASHBOARD
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  if (widget.category["subcategories"] != null)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                      itemCount: widget.category["subcategories"].length,
                      itemBuilder: (context, index) {
                        String subCatName =
                            widget.category["subcategories"][index]["name"];
                        int dynamicCount = _getSubcategoryCount(subCatName);

                        return StatisticsCard(
                          iconColor: index % 2 == 0 ? c2 : c1,
                          title: subCatName,
                          icon: widget.category["subcategories"][index]["icon"],
                          count: dynamicCount,
                          isSelected: selectedIndex.contains(index),
                          action: () {
                            setState(() {
                              if (selectedIndex.contains(index)) {
                                selectedIndex.remove(index);
                              } else {
                                selectedIndex.add(index);
                              }
                            });
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 10),

                  // 3. TABLE VIEW
                  isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: c2),
                          ),
                        )
                      : ContactsTableView(
                          profiles: _gridFilteredProfiles,
                          categoryName: widget.category['name'],
                          onRefresh: _loadData,
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// TABLE VIEW COMPONENT (Handles Checkboxes, Export, Import, Bulk Delete)
// =========================================================================

class ContactsTableView extends StatefulWidget {
  final List<ProfileModel> profiles;
  final String categoryName;
  final VoidCallback onRefresh;

  const ContactsTableView({
    super.key,
    required this.profiles,
    required this.categoryName,
    required this.onRefresh,
  });

  @override
  State<ContactsTableView> createState() => _ContactsTableViewState();
}

class _ContactsTableViewState extends State<ContactsTableView> {
  // Flex layout for table columns
  final Map<String, int> columnFlex = {
    'checkbox': 1,
    'name': 4,
    'category': 2,
    'gov': 2,
    'rating': 2,
    'updated': 2,
    'status': 2,
    'actions': 2,
  };

  String searchQuery = "";
  String selectedSubCategory = "جميع الفئات";
  String selectedGovernorate = "جميع المحافظات";
  final TextEditingController _searchController = TextEditingController();

  // Tracks selected rows for export/bulk actions
  Set<String> selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Deep Search logic
  List<ProfileModel> get _finalDisplayedProfiles {
    return widget.profiles.where((p) {
      bool matchesSearch =
          searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.primaryPhone.contains(searchQuery) ||
          p.subCategory.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.entityType.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.governorate.toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesCat =
          selectedSubCategory == "جميع الفئات" ||
          p.subCategory == selectedSubCategory;
      bool matchesGov =
          selectedGovernorate == "جميع المحافظات" ||
          p.governorate == selectedGovernorate;

      return matchesSearch && matchesCat && matchesGov;
    }).toList();
  }

  // --- EXPORT TO EXCEL ---
  Future<void> _exportToExcel() async {
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى تحديد سجل واحد على الأقل للتصدير"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'حفظ ملف Excel',
      fileName: 'Sila_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (outputFile != null) {
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Add Headers
      sheet.appendRow([
        TextCellValue("الاسم"),
        TextCellValue("النوع"),
        TextCellValue("الفئة الرئيسية"),
        TextCellValue("الفئة الفرعية"),
        TextCellValue("المحافظة"),
        TextCellValue("المنطقة"),
        TextCellValue("رقم الهاتف"),
        TextCellValue("البريد الالكتروني"),
        TextCellValue("التقييم"),
        TextCellValue("الحالة"),
        TextCellValue("تاريخ التحديث"),
      ]);

      // Add Data Rows
      for (var p in widget.profiles.where(
        (element) => selectedIds.contains(element.id),
      )) {
        sheet.appendRow([
          TextCellValue(p.name),
          TextCellValue(p.entityType),
          TextCellValue(p.mainCategory),
          TextCellValue(p.subCategory),
          TextCellValue(p.governorate),
          TextCellValue(p.region),
          TextCellValue(p.primaryPhone),
          TextCellValue(p.email),
          TextCellValue(p.rating.toString()),
          TextCellValue(p.status),
          TextCellValue(p.updatedAt),
        ]);
      }

      File(outputFile)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم تصدير البيانات بنجاح!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // --- IMPORT FROM EXCEL ---
  Future<void> _importFromExcel() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      int importedCount = 0;
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table]!;
        // Skip header row
        for (int i = 1; i < sheet.maxRows; i++) {
          var row = sheet.rows[i];
          if (row.isEmpty || row[0]?.value == null) continue; // Skip empty rows

          ProfileModel newProfile = ProfileModel.empty();
          newProfile.id = const Uuid().v4();
          newProfile.mainCategory =
              widget.categoryName; // Force to current category

          newProfile.name = row[0]?.value?.toString() ?? "بدون اسم";
          newProfile.entityType = row.length > 1
              ? (row[1]?.value?.toString() ?? "شخص")
              : "شخص";
          newProfile.subCategory = row.length > 3
              ? (row[3]?.value?.toString() ?? "أخرى")
              : "أخرى";
          newProfile.governorate = row.length > 4
              ? (row[4]?.value?.toString() ?? "بغداد")
              : "بغداد";
          newProfile.region = row.length > 5
              ? (row[5]?.value?.toString() ?? "")
              : "";
          newProfile.primaryPhone = row.length > 6
              ? (row[6]?.value?.toString() ?? "")
              : "";
          newProfile.email = row.length > 7
              ? (row[7]?.value?.toString() ?? "")
              : "";
          newProfile.status = row.length > 9
              ? (row[9]?.value?.toString() ?? "فعال")
              : "فعال";

          await DatabaseHelper.instance.insertProfile(newProfile);
          importedCount++;
        }
      }
      widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم استيراد $importedCount سجل بنجاح!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // --- BULK DELETE ---
  void _deleteSelectedWarning() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 10),
                Text(
                  "تأكيد الحذف الجماعي",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              "هل أنت متأكد من حذف ${selectedIds.length} سجلات؟\nلا يمكن التراجع عن هذا الإجراء.",
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "إلغاء",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);

                  for (String id in selectedIds) {
                    await DatabaseHelper.instance.deleteProfile(id);
                  }

                  setState(() => selectedIds.clear());
                  widget.onRefresh();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم الحذف بنجاح"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text(
                  "نعم، احذف",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ProfileModel> displayedData = _finalDisplayedProfiles;

    // Determine Select All state
    bool isAllSelected =
        displayedData.isNotEmpty &&
        displayedData.every((p) => selectedIds.contains(p.id));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolbar(),
          const Divider(height: 1, color: Colors.black12),
          LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth = constraints.maxWidth > 1200
                  ? constraints.maxWidth
                  : 1200;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTableHeader(isAllSelected, displayedData),
                      const Divider(height: 1, color: Colors.black12),
                      if (displayedData.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(
                            child: Text("لا توجد بيانات تطابق الفلتر أو البحث"),
                          ),
                        ),
                      ...displayedData.map(
                        (profile) => Column(
                          children: [
                            _buildTableRow(profile),
                            const Divider(height: 1, color: Colors.black12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    List<String> availableCategories = [
      "جميع الفئات",
      ...widget.profiles.map((e) => e.subCategory).toSet(),
    ];
    List<String> availableGovs = [
      "جميع المحافظات",
      ...widget.profiles.map((e) => e.governorate).toSet(),
    ];

    if (!availableCategories.contains(selectedSubCategory))
      selectedSubCategory = "جميع الفئات";
    if (!availableGovs.contains(selectedGovernorate))
      selectedGovernorate = "جميع المحافظات";

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Wrap(
        runSpacing: 10,
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 250,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "بحث شامل...",
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          _buildRealDropdown(
            selectedSubCategory,
            availableCategories,
            (val) => setState(() => selectedSubCategory = val!),
          ),
          _buildRealDropdown(
            selectedGovernorate,
            availableGovs,
            (val) => setState(() => selectedGovernorate = val!),
          ),

          // Action Buttons
          OutlinedButton.icon(
            onPressed: _importFromExcel,
            icon: const Icon(Icons.upload_file, size: 18, color: Colors.green),
            label: Padding(
              padding: const EdgeInsets.all(6.0),
              child: const Text(
                "استيراد XLSX",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          OutlinedButton.icon(
            onPressed: _exportToExcel,
            icon: const Icon(Icons.download, size: 18, color: c2),
            label: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                selectedIds.isEmpty
                    ? "تصدير للكل"
                    : "تصدير المحدد (${selectedIds.length})",
                style: const TextStyle(fontWeight: FontWeight.bold, color: c2),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: c2),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // --- DYNAMIC DELETE SELECTED BUTTON ---
          if (selectedIds.isNotEmpty)
            OutlinedButton.icon(
              onPressed: _deleteSelectedWarning,
              icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
              label: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  "حذف المحدد (${selectedIds.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

          ElevatedButton.icon(
            onPressed: () async {
              ProfileModel newProfile = ProfileModel.empty();
              newProfile.mainCategory = widget.categoryName;

              bool? added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileEditScreen(
                    initialData: newProfile,
                    isEditMode: false,
                  ),
                ),
              );
              if (added == true) widget.onRefresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF912441),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Padding(
              padding: const EdgeInsets.all(6.0),
              child: const Text(
                "إضافة سجل جديد",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),

              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealDropdown(
    String currentValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTableHeader(
    bool isAllSelected,
    List<ProfileModel> displayedData,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: columnFlex['checkbox']!,
            child: Checkbox(
              value: isAllSelected,
              activeColor: c2,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedIds.addAll(displayedData.map((e) => e.id));
                  } else {
                    selectedIds.removeAll(displayedData.map((e) => e.id));
                  }
                });
              },
            ),
          ),
          Expanded(flex: columnFlex['name']!, child: _headerText("الاسم")),
          Expanded(
            flex: columnFlex['category']!,
            child: _headerText("الفئة / التخصص"),
          ),
          Expanded(flex: columnFlex['gov']!, child: _headerText("المحافظة")),
          Expanded(flex: columnFlex['rating']!, child: _headerText("التقييم")),
          Expanded(
            flex: columnFlex['updated']!,
            child: _headerText("آخر تحديث"),
          ),
          Expanded(flex: columnFlex['status']!, child: _headerText("الحالة")),
          Expanded(
            flex: columnFlex['actions']!,
            child: _headerText("الإجراءات"),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(ProfileModel profile) {
    bool isSelected = selectedIds.contains(profile.id);

    return Container(
      color: isSelected ? c2.withValues(alpha: 0.05) : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: columnFlex['checkbox']!,
            child: Checkbox(
              value: isSelected,
              activeColor: c2,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedIds.add(profile.id);
                  } else {
                    selectedIds.remove(profile.id);
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: columnFlex['name']!,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: c2.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: c2, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.isEmpty ? 'بدون اسم' : profile.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        profile.entityType,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: columnFlex['category']!,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusChip(
                text: profile.subCategory,
                color: Colors.blueAccent,
              ),
            ),
          ),
          Expanded(
            flex: columnFlex['gov']!,
            child: Text(
              profile.governorate,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          Expanded(
            flex: columnFlex['rating']!,
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  profile.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            flex: columnFlex['updated']!,
            child: Text(
              profile.updatedAt,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),

          Expanded(
            flex: columnFlex['status']!,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusChip(
                text: profile.status,
                color: profile.status == 'فعال' ? Colors.green : Colors.orange,
              ),
            ),
          ),
          Expanded(
            flex: columnFlex['actions']!,
            child: Row(
              children: [
                _actionIcon(Icons.edit_outlined, Colors.blueGrey, () async {
                  bool? updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileEditScreen(
                        initialData: profile,
                        isEditMode: true,
                      ),
                    ),
                  );
                  if (updated == true) widget.onRefresh();
                }),
                _actionIcon(
                  Icons.delete_outline,
                  Colors.redAccent,
                  () => _showSingleDeleteWarning(profile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSingleDeleteWarning(ProfileModel profile) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 10),
                Text(
                  "تأكيد الحذف",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              "هل أنت متأكد من حذف السجل '${profile.name}'؟\nلا يمكن التراجع عن هذا الإجراء.",
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "إلغاء",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await DatabaseHelper.instance.deleteProfile(profile.id);
                  setState(() => selectedIds.remove(profile.id));
                  widget.onRefresh();
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم الحذف بنجاح"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                },
                child: const Text(
                  "نعم، احذف",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerText(String title) => Text(
    title,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      fontSize: 16,
    ),
  );

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Padding(
      padding: const EdgeInsets.all(6.0),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}
