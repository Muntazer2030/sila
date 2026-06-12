// lib/ui/screens/home_screen/pages/main_page.dart

import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/models/app_data.dart';
import 'package:sila/models/profile_model.dart';
import 'package:sila/data/database_helper.dart';
import 'package:sila/ui/screens/profile_screen/profile_edit_screen.dart'; // Ensure correct path
import 'package:sila/ui/widgets/main_page_widgets.dart';
import 'package:sila/ui/widgets/statistics_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainPage extends StatefulWidget {
  final AppData appData;
  final Function(int) onNavigate; // Callback to switch tabs in HomeScreen

  const MainPage({super.key, required this.appData, required this.onNavigate});

  @override
  State<MainPage> createState() => _MainPageState();
}

class ChartData {
  ChartData(this.category, this.value, [this.color]);
  final String category;
  final int value;
  final Color? color;
}

class _MainPageState extends State<MainPage> {
  List<ChartData> _chartData = [];
  late TooltipBehavior _tooltipBehavior;
  int _maxValue = 1;
  int _totalValue = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _loadData();
  }

  // Fetch real data from SQLite and calculate statistics
  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    // Get all profiles from the database
    final allProfiles = await DatabaseHelper.instance.getAllProfiles();
    
    List<ChartData> tempChartData = [];
    int total = 0;
    int maxVal = 1;

    // Start from index 1 to skip the "Home" (الرئيسية) category
    for (int i = 1; i < widget.appData.categories.length - 1; i++) {
      String catName = widget.appData.categories[i]["name"];
      
      // Count how many profiles belong to this category
      int count = allProfiles.where((p) => p.mainCategory == catName).length;
      
      // Update the local AppData so the UI gets the correct number
      widget.appData.categories[i]["count"] = count;

      tempChartData.add(ChartData(catName, count, i % 2 == 0 ? c2 : c1));
      
      total += count;
      if (count > maxVal) maxVal = count;
    }

    setState(() {
      _chartData = tempChartData;
      _maxValue = maxVal;
      _totalValue = total == 0 ? 1 : total; // Prevent division by zero
      isLoading = false;
    });
  }

  // Helper method to open the Edit Screen for a specific category
  Future<void> _openAddScreen(String categoryName) async {
    ProfileModel newProfile = ProfileModel.empty();
    newProfile.mainCategory = categoryName;

    bool? added = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(initialData: newProfile, isEditMode: false),
      ),
    );

    // If a new profile was successfully added, refresh the dashboard data
    if (added == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          color: Colors.white,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "منظومة صلة",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: c2,
                          fontSize: 24,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "مرحبا بك, مسؤول العلاقات",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 22,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "ادارة علاقات المؤسسة",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: isLoading 
                ? const Center(child: CircularProgressIndicator(color: c2))
                : Column(
                  children: [
                    // Top Row (Grid + Chart)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // The Statistics Grid
                          Expanded(
                            flex: 2,
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                childAspectRatio: 1.8,
                              ),
                              itemCount: widget.appData.categories.length - 2, // -1 for Home, -1 for the last hidden category
                              padding: const EdgeInsets.all(10),
                              itemBuilder: (context, index) {
                                int catIndex = index + 1; // +1 to skip Home
                                return StatisticsCard(
                                  iconColor: index % 2 == 0 ? c2 : c1,
                                  title: widget.appData.categories[catIndex]["name"],
                                  icon: widget.appData.categories[catIndex]["icon"],
                                  count: widget.appData.categories[catIndex]["count"],
                                  // Navigate to SubPage when clicked!
                                  action: () => widget.onNavigate(catIndex), 
                                );
                              },
                            ),
                          ),

                          // The Circular Chart
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade300, width: 1),
                              ),
                              child: _totalValue <= 1 && _chartData.every((e) => e.value == 0)
                                ? const Center(child: Text("لا توجد بيانات كافية للرسم", style: TextStyle(color: Colors.grey)))
                                : SfCircularChart(
                                    title: const ChartTitle(
                                      text: 'توزيع فئات المؤسسة',
                                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    legend: const Legend(
                                      isVisible: true,
                                      overflowMode: LegendItemOverflowMode.wrap,
                                      position: LegendPosition.bottom,
                                    ),
                                    tooltipBehavior: _tooltipBehavior,
                                    series: <CircularSeries>[
                                      DoughnutSeries<ChartData, String>(
                                        dataSource: _chartData,
                                        xValueMapper: (ChartData data, _) => data.category,
                                        yValueMapper: (ChartData data, _) => data.value,
                                        dataLabelMapper: (ChartData data, _) {
                                          final percentage = (data.value / _totalValue) * 100;
                                          if (percentage < 3.0) return '';
                                          return '${percentage.toStringAsFixed(1)}%';
                                        },
                                        pointColorMapper: (ChartData data, _) {
                                          double ratio = data.value / _maxValue;
                                          double calculatedAlpha = 0.8 + (ratio * 0.5);
                                          return data.color?.withValues(
                                                alpha: calculatedAlpha.clamp(0.0, 1.0),
                                              ) ??
                                              Colors.blue;
                                        },
                                        innerRadius: '45%',
                                        dataLabelSettings: const DataLabelSettings(
                                          isVisible: true,
                                          labelPosition: ChartDataLabelPosition.inside,
                                          textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Action Buttons
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 5,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 1.8,
                      padding: const EdgeInsets.all(10),
                      children: [
                        _buildActionCard("اضافة مؤسسة حكومية", Icons.account_balance_outlined, c2, "الجهات الحكومية"),
                        _buildActionCard("اضافة مؤسسة غير حكومية", Icons.apartment_outlined, c1, "المؤسسات غير الحكومية"),
                        _buildActionCard("اضافة شخصية مؤثرة", Icons.group_add_outlined, c2, "الشخصيات المؤثرة"),
                        _buildActionCard("اضافة شخصية أكاديمية", Icons.school_outlined, c1, "الشخصيات الأكاديمية"),
                        _buildActionCard("اضافة شخصية عامة أو اجتماعية", Icons.person_add_alt_1, c2, "الشخصيات العامة والاجتماعية"),
                      ],
                    ),
                  ],
                ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget to make adding cards clickable
  Widget _buildActionCard(String title, IconData icon, Color color, String targetCategory) {
    return GestureDetector(
      onTap: () => _openAddScreen(targetCategory),
      child: MainPageAddingCard(
        title: title,
        icon: icon,
        color: color,
      ),
    );
  }
}