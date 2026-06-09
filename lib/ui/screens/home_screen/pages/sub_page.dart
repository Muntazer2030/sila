import 'package:sila/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:sila/models/app_data.dart';
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // 1. FIXED HEADER (Remains at the top while the rest scrolls)
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
                  child: Icon(widget.category['icon'], color: white, size: 40),
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
                              color: black,
                              fontSize: 24,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "الرئيسية / ${widget.category['name']} / ",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: black, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. THE SCROLLING DASHBOARD AREA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                // THE MASTER SCROLLER: This ListView controls the whole page
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    // --- SECTION 1: YOUR GRID ---
                    GridView.builder(
                      shrinkWrap:
                          true, // CRITICAL: Forces grid to calculate its height
                      physics:
                          const NeverScrollableScrollPhysics(), // CRITICAL: Passes scrolling to parent
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: widget.category["subcategories"].length,
                      itemBuilder: (context, index) {
                        return StatisticsCard(
                          iconColor: index % 2 == 0 ? c2 : c1,
                          title:
                              widget.category["subcategories"][index]["name"],
                          icon: widget.category["subcategories"][index]["icon"],
                          count:
                              widget.category["subcategories"][index]["count"],
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

                    // --- SECTION 2: YOUR NEW LIST VIEW ---
                    ContactsTableView(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactsTableView extends StatefulWidget {
  const ContactsTableView({super.key});

  @override
  State<ContactsTableView> createState() => _ContactsTableViewState();
}

class _ContactsTableViewState extends State<ContactsTableView> {
  // Flex values determine column widths. They MUST be identical for Header and Data rows.
  final Map<String, int> columnFlex = {
    'checkbox': 1,
    'name': 6,
    'category': 4,
    'gov': 3,
    'phone': 4,
    'rating': 4,
    'date': 3,
    'status': 3,
    'actions': 4,
  };

  // Dummy data based on your screenshot
  final List<ContactModel> mockData = [
    ContactModel(
      name: "أ. أحمد الزبيدي",
      role: "إعلامي",
      category: "إعلاميون",
      categoryColor: Colors.blueAccent,
      governorate: "بغداد",
      phone: "0770 123 4567",
      rating: 4.8,
      lastContactDate: "2024-05-26",
      status: "نشط",
      statusColor: Colors.green,
    ),
    ContactModel(
      name: "مؤسسة الإبداع الخيرية",
      role: "مؤسسة خيرية",
      category: "مؤسسات خيرية",
      categoryColor: Colors.redAccent,
      governorate: "البصرة",
      phone: "0780 987 6543",
      rating: 4.6,
      lastContactDate: "2024-05-25",
      status: "نشط",
      statusColor: Colors.green,
      fallbackIcon: Icons.people,
    ),
    ContactModel(
      name: "قناة الرؤيا الفضائية",
      role: "وسيلة إعلامية",
      category: "وسائل إعلامية",
      categoryColor: Colors.redAccent,
      governorate: "بغداد",
      phone: "0773 888 9999",
      rating: 4.4,
      lastContactDate: "2024-05-21",
      status: "يحتاج متابعة",
      statusColor: Colors.orange,
      fallbackIcon: Icons.tv,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          // 1. TOOLBAR / ACTION BAR
          _buildToolbar(),

          const Divider(height: 1, color: Colors.black12),

          // 2. THE TABLE AREA
          // THE FIX: LayoutBuilder checks the available screen space.
          LayoutBuilder(
            builder: (context, constraints) {
              // If the screen is wider than 1200, take the full screen width.
              // If it's smaller, lock the width to 1200 so it can scroll horizontally without crashing.
              final double tableWidth = constraints.maxWidth > 1200
                  ? constraints.maxWidth
                  : 1200;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // THE FIX: SizedBox provides the bounded width required for Expanded widgets to work!
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Table Header
                      _buildTableHeader(),
                      const Divider(height: 1, color: Colors.black12),

                      // Table Rows
                      ...mockData.map(
                        (contact) => Column(
                          children: [
                            _buildTableRow(contact),
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

  // --- WIDGET BUILDERS ---

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Wrap(
        runSpacing: 10,
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,

        children: [
          // Search Bar
          SizedBox(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: "بحث بالاسم او الهاتف او اي كلمة...",
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
          _buildDropdownButton("جميع الفئات"),
          _buildDropdownButton("جميع المحافظات"),

          _buildOutlinedButton("استيراد من إكسل", Icons.download_outlined),
          _buildOutlinedButton("تصدير الى إكسل", Icons.upload_outlined),

          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF912441), // The dark maroon color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Padding(
              padding: const EdgeInsets.all(6.0),
              child: const Text(
                "إضافة شخص جديد",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: columnFlex['checkbox']!,
            child: const Icon(
              Icons.check_box_outline_blank,
              color: Colors.grey,
            ),
          ),
          Expanded(flex: columnFlex['name']!, child: _headerText("الاسم")),
          Expanded(flex: columnFlex['category']!, child: _headerText("الفئة")),
          Expanded(flex: columnFlex['gov']!, child: _headerText("المحافظة")),
          Expanded(
            flex: columnFlex['phone']!,
            child: _headerText("رقم الهاتف"),
          ),
          Expanded(
            flex: columnFlex['rating']!,
            child: _headerText("التقييم العام"),
          ),
          Expanded(flex: columnFlex['date']!, child: _headerText("آخر تواصل")),
          Expanded(flex: columnFlex['status']!, child: _headerText("الحالة")),
          Expanded(
            flex: columnFlex['actions']!,
            child: _headerText("الإجراءات"),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(ContactModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
      child: Row(
        children: [
          // 1. Checkbox
          Expanded(
            flex: columnFlex['checkbox']!,
            child: const Icon(
              Icons.check_box_outline_blank,
              color: Colors.grey,
            ),
          ),

          // 2. Avatar & Name
          Expanded(
            flex: columnFlex['name']!,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blueGrey.shade800,
                  child: data.fallbackIcon != null
                      ? Icon(data.fallbackIcon, color: Colors.white, size: 20)
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                        ), // Use NetworkImage(data.avatarUrl) in real app
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        data.role,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Category
          Expanded(
            flex: columnFlex['category']!,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusChip(text: data.category, color: data.categoryColor),
            ),
          ),

          // 4. Governorate
          Expanded(
            flex: columnFlex['gov']!,
            child: Text(data.governorate, style: const TextStyle(fontSize: 13)),
          ),

          // 5. Phone
          Expanded(
            flex: columnFlex['phone']!,
            child: Text(
              data.phone,
              style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
            ),
          ),

          // 6. Rating
          Expanded(
            flex: columnFlex['rating']!,
            child: StarRating(rating: data.rating),
          ),

          // 7. Last Contact Date
          Expanded(
            flex: columnFlex['date']!,
            child: Text(
              data.lastContactDate,
              style: const TextStyle(fontSize: 13),
            ),
          ),

          // 8. Status
          Expanded(
            flex: columnFlex['status']!,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusChip(text: data.status, color: data.statusColor),
            ),
          ),

          // 9. Actions
          Expanded(
            flex: columnFlex['actions']!,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _actionIcon(Icons.visibility_outlined, Colors.blueGrey),
                _actionIcon(Icons.phone_outlined, Colors.blueGrey),
                _actionIcon(Icons.edit_outlined, Colors.blueGrey),
                _actionIcon(Icons.more_vert, Colors.blueGrey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UTILITY WIDGETS ---

  Widget _headerText(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontSize: 14,
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildOutlinedButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18),
      label: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDropdownButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}
