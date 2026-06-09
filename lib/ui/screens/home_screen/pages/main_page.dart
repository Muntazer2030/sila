import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/models/app_data.dart';
import 'package:sila/ui/widgets/main_page_widgets.dart';
import 'package:sila/ui/widgets/statistics_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainPage extends StatefulWidget {
  final AppData appData;
  const MainPage({super.key, required this.appData});

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
  late List<ChartData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  late int _maxValue;
  late int _totalValue; // 1. Added this to track the total sum for percentages

  @override
  void initState() {
    super.initState();
    _chartData = [];
    for (int i = 1; i < widget.appData.categories.length - 1; i++) {
      _chartData.add(
        ChartData(
          widget.appData.categories[i]["name"],
          widget.appData.categories[i]["count"],
          i % 2 == 0 ? c2 : c1,
        ),
      );
    }

    // Find the highest value
    _maxValue = _chartData.fold(0, (max, e) => e.value > max ? e.value : max);
    if (_maxValue == 0) _maxValue = 1;

    // 2. Find the total sum of all values to calculate percentages
    _totalValue = _chartData.fold(0, (sum, e) => sum + e.value);
    if (_totalValue == 0) _totalValue = 1;

    _tooltipBehavior = TooltipBehavior(enable: true);
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
                    "منظومة الصلة",
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
                      color: black,
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
                      color: black,
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
              child: Column(
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  childAspectRatio: 1.8,
                                ),
                            itemCount: widget.appData.categories.length - 1,
                            padding: const EdgeInsets.all(10),
                            itemBuilder: (context, index) {
                              return StatisticsCard(
                                iconColor: index % 2 == 0 ? c2 : c1,
                                title: widget
                                    .appData
                                    .categories[index + 1]["name"],
                                icon: widget
                                    .appData
                                    .categories[index + 1]["icon"],
                                count: widget
                                    .appData
                                    .categories[index + 1]["count"],
                              );
                            },
                          ),
                        ),

                        // The Circular Chart
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(
                              right: 10,
                              top: 10,
                              bottom: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: SfCircularChart(
                              title: const ChartTitle(
                                text: 'توزيع فئات المؤسسة',
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
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
                                  xValueMapper: (ChartData data, _) =>
                                      data.category,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value,
                                  dataLabelMapper: (ChartData data, _) {
                                    final percentage =
                                        (data.value / _totalValue) * 100;
                                    if (percentage < 3.0) return '';
                                    return '${percentage.toStringAsFixed(1)}%';
                                  },
                                  pointColorMapper: (ChartData data, _) {
                                    double ratio = data.value / _maxValue;
                                    double calculatedAlpha =
                                        0.8 + (ratio * 0.5);
                                    return data.color?.withValues(
                                          alpha: calculatedAlpha.clamp(
                                            0.0,
                                            1.0,
                                          ),
                                        ) ??
                                        Colors.blue;
                                  },
                                  innerRadius: '45%',
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelPosition:
                                        ChartDataLabelPosition.inside,
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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
                    children: const [
                      MainPageAddingCard(
                        title: "اضافة مؤسسة حكومية",
                        icon: Icons.account_balance_outlined,
                        color: c2,
                      ),
                      MainPageAddingCard(
                        title: "اضافة مؤسسة غير حكومية",
                        icon: Icons.apartment_outlined,
                        color: c1,
                      ),
                      MainPageAddingCard(
                        title: "اضافة شخصية مؤثرة",
                        icon: Icons.group_add_outlined,
                        color: c2,
                      ),
                      MainPageAddingCard(
                        title: "اضافة شخصية أكاديمية",
                        icon: Icons.school_outlined,
                        color: c1,
                      ),
                      MainPageAddingCard(
                        title: "اضافة شخصية عامة أو اجتماعية",
                        icon: Icons.group_add_outlined,
                        color: c2,
                      ),
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
}
