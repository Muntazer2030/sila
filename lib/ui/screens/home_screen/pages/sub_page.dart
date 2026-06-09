// lib/ui/screens/home_screen/pages/sub_page.dart
import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/models/profile_model.dart';
import 'package:sila/data/database_helper.dart';
import 'package:sila/ui/screens/profile_screen/profile_edit_screen.dart'; // Adjust path if needed
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
      selectedIndex.clear(); // Reset filters on category change
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    // Fetch profiles belonging to this specific Main Category
    final data = await DatabaseHelper.instance.getProfilesByCategory(widget.category['name']);
    setState(() {
      allProfiles = data;
      isLoading = false;
    });
  }

  // Calculate dynamic count for the Statistics Cards
  int _getSubcategoryCount(String subCatName) {
    return allProfiles.where((p) => p.subCategory == subCatName).length;
  }

  // Filter profiles based on selected Statistics Cards
  List<ProfileModel> get _gridFilteredProfiles {
    if (selectedIndex.isEmpty) return allProfiles; // If none selected, show all

    // Extract names of the selected subcategories
    List<String> activeSubcategories = selectedIndex.map((idx) {
      return widget.category["subcategories"][idx]["name"] as String;
    }).toList();

    return allProfiles.where((p) => activeSubcategories.contains(p.subCategory)).toList();
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
                child: Icon(widget.category['icon'], color: Colors.white, size: 40),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category['name'],
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "الرئيسية / ${widget.category['name']} / ",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black, fontSize: 14,
                          ),
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
                  // SECTION 1: STATISTICS GRID (Acting as a Filter)
                  if (widget.category["subcategories"] != null)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: widget.category["subcategories"].length,
                      itemBuilder: (context, index) {
                        String subCatName = widget.category["subcategories"][index]["name"];
                        int dynamicCount = _getSubcategoryCount(subCatName); // Fetch actual count from DB

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

                  // SECTION 2: TABLE VIEW
                  isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: c2),
                          ),
                        )
                      : ContactsTableView(
                          profiles: _gridFilteredProfiles, // Pass the Grid-filtered data down
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
// TABLE VIEW COMPONENT (Handles Search, Dropdowns, and Delete Warning)
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
  final Map<String, int> columnFlex = {
    'checkbox': 1,
    'name': 5,
    'category': 3,
    'gov': 2,
    'phone': 3,
    'status': 2,
    'actions': 3,
  };

  // Local Filter States
  String searchQuery = "";
  String selectedSubCategory = "جميع الفئات";
  String selectedGovernorate = "جميع المحافظات";

  // Text Controller for Search Bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Calculate final displayed profiles after local search/dropdowns
  List<ProfileModel> get _finalDisplayedProfiles {
    return widget.profiles.where((p) {
      // 1. Search Query Match
      bool matchesSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.primaryPhone.contains(searchQuery) ||
          p.subCategory.toLowerCase().contains(searchQuery.toLowerCase());

      // 2. Subcategory Match
      bool matchesCat = selectedSubCategory == "جميع الفئات" || p.subCategory == selectedSubCategory;

      // 3. Governorate Match
      bool matchesGov = selectedGovernorate == "جميع المحافظات" || p.governorate == selectedGovernorate;

      return matchesSearch && matchesCat && matchesGov;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<ProfileModel> displayedData = _finalDisplayedProfiles;

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
              final double tableWidth = constraints.maxWidth > 1000 ? constraints.maxWidth : 1000;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTableHeader(),
                      const Divider(height: 1, color: Colors.black12),
                      if (displayedData.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: Text("لا توجد بيانات تطابق الفلتر أو البحث")),
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
    // Dynamically extract unique categories and governorates from available data
    List<String> availableCategories = ["جميع الفئات", ...widget.profiles.map((e) => e.subCategory).toSet()];
    List<String> availableGovs = ["جميع المحافظات", ...widget.profiles.map((e) => e.governorate).toSet()];

    // Safety checks to ensure selected values exist in the dynamic lists
    if (!availableCategories.contains(selectedSubCategory)) selectedSubCategory = "جميع الفئات";
    if (!availableGovs.contains(selectedGovernorate)) selectedGovernorate = "جميع المحافظات";

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Wrap(
        runSpacing: 10,
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Dynamic Search Bar
          SizedBox(
            width: 250,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "بحث بالاسم أو الهاتف...",
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          
          // Actual working Dropdowns
          _buildRealDropdown(selectedSubCategory, availableCategories, (val) {
            setState(() => selectedSubCategory = val!);
          }),
          
          _buildRealDropdown(selectedGovernorate, availableGovs, (val) {
            setState(() => selectedGovernorate = val!);
          }),
          
          ElevatedButton.icon(
            onPressed: () async {
              ProfileModel newProfile = ProfileModel.empty();
              newProfile.mainCategory = widget.categoryName; 
              
              bool? added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen(initialData: newProfile, isEditMode: false)),
              );
              
              if (added == true) widget.onRefresh(); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF912441),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("إضافة سجل جديد", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // A functional dropdown widget
  Widget _buildRealDropdown(String currentValue, List<String> items, Function(String?) onChanged) {
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
          items: items.map((e) => DropdownMenuItem(
            value: e, 
            child: Text(e, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13))
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      child: Row(
        children: [
          Expanded(flex: columnFlex['checkbox']!, child: const Icon(Icons.check_box_outline_blank, color: Colors.grey)),
          Expanded(flex: columnFlex['name']!, child: _headerText("الاسم")),
          Expanded(flex: columnFlex['category']!, child: _headerText("التخصص/الفئة")),
          Expanded(flex: columnFlex['gov']!, child: _headerText("المحافظة")),
          Expanded(flex: columnFlex['phone']!, child: _headerText("رقم الهاتف")),
          Expanded(flex: columnFlex['status']!, child: _headerText("الحالة")),
          Expanded(flex: columnFlex['actions']!, child: _headerText("الإجراءات")),
        ],
      ),
    );
  }

  Widget _buildTableRow(ProfileModel profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
      child: Row(
        children: [
          Expanded(flex: columnFlex['checkbox']!, child: const Icon(Icons.check_box_outline_blank, color: Colors.grey)),
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
                      Text(profile.name.isEmpty ? 'بدون اسم' : profile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(profile.entityType, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
              child: StatusChip(text: profile.subCategory, color: Colors.blueAccent),
            ),
          ),
          Expanded(flex: columnFlex['gov']!, child: Text(profile.governorate, style: const TextStyle(fontSize: 13))),
          Expanded(flex: columnFlex['phone']!, child: Text(profile.primaryPhone.isEmpty ? 'لا يوجد' : profile.primaryPhone, style: const TextStyle(fontSize: 13))),
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
                    MaterialPageRoute(builder: (context) => ProfileEditScreen(initialData: profile, isEditMode: true)),
                  );
                  if (updated == true) widget.onRefresh(); 
                }),
                
                // --- Updated Delete Button with Warning Dialog ---
                _actionIcon(Icons.delete_outline, Colors.redAccent, () {
                  _showDeleteWarning(profile);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- DELETE WARNING DIALOG ---
  void _showDeleteWarning(ProfileModel profile) {
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
                Text("تأكيد الحذف", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text("هل أنت متأكد من حذف السجل '${profile.name}'؟\nلا يمكن التراجع عن هذا الإجراء."),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("إلغاء", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.pop(ctx); // Close dialog
                  await DatabaseHelper.instance.deleteProfile(profile.id); // Delete from DB
                  widget.onRefresh(); // Refresh table and grids
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم الحذف بنجاح"), backgroundColor: Colors.redAccent),
                    );
                  }
                },
                child: const Text("نعم، احذف", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerText(String title) => Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14));
  
  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap, 
    borderRadius: BorderRadius.circular(20), 
    child: Padding(
      padding: const EdgeInsets.all(6.0), 
      child: Icon(icon, size: 18, color: color)
    )
  );
}