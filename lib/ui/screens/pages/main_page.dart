import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/ui/widgets/main_page_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

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
  late int _maxValue; // 1. Added this to track the highest number

  @override
  void initState() {
    super.initState();

    _chartData = [
      ChartData("حكومية", 12, c2),
      ChartData("غير حكومية", 8, c1),
      ChartData("مؤثرة", 20, c2),
      ChartData("أكاديمية", 15, c1),
      ChartData("عامة", 14, c2),
      ChartData(
        "الجمهور",
        100,
        c1,
      ), // I set this back to 500 to test the dynamic alpha
      ChartData("الإعلام", 5, c2),
      ChartData("القطاع الخاص", 44, c1),
    ];

    // 2. Automatically find the highest value in your dataset (which is 500 here)
    _maxValue = _chartData.fold(0, (max, e) => e.value > max ? e.value : max);
    if (_maxValue == 0)
      _maxValue = 1; // Safety check to prevent division by zero

    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Top Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "منظومة الصلة",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
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
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
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
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: black,
                              fontSize: 14,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
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
                    // 1. THE FIX: Wrap the Row in an Expanded widget
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // 2. This stretches the Chart to match the Grid perfectly
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 3. Changed Flexible to Expanded for strict constraints
                          Expanded(
                            flex: 2,
                            // 4. Removed shrinkWrap & physics. The Expanded parent handles sizing natively now!
                            child: GridView.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                              childAspectRatio: 1.8,
                              padding: const EdgeInsets.all(10),
                              children: const [
                                MainPageStatisticsCard(
                                  iconColor: c2,
                                  title: "المؤسسات الحكومية",
                                  icon: Icons.account_balance_outlined,
                                  count: 12,
                                ),
                                MainPageStatisticsCard(
                                  iconColor: c1,
                                  title: "المؤسسات غير الحكومية",
                                  icon: Icons.apartment_outlined,
                                  count: 8,
                                ),
                                MainPageStatisticsCard(
                                  iconColor: c2,
                                  title: "الشخصيات المؤثرة",
                                  icon: Icons.group_add_outlined,
                                  count: 20,
                                ),
                                MainPageStatisticsCard(
                                  iconColor: c1,
                                  title: "الشخصيات الأكاديمية",
                                  icon: Icons.school_outlined,
                                  count: 15,
                                ),
                                MainPageStatisticsCard(
                                  iconColor: c2,
                                  title: "الشخصيات العامة والأجتماعية",
                                  icon: Icons.group_add_outlined,
                                  count: 14,
                                ),
                                MainPageStatisticsCard(
                                  iconColor: c1,
                                  title: "الجمهور",
                                  icon: Icons.group_outlined,
                                  count: 100,
                                ),
                                MainPageStatisticsCard(
                                  iconColor: c2,
                                  title: "الأعلام والمنصات",
                                  icon: Icons.campaign_outlined,
                                  count: 5,
                                ),
                                MainPageStatisticsCard(
                                  iconColor: c1,
                                  title: "القطاع الخاص",
                                  icon: Icons.business_outlined,
                                  count: 17,
                                ),
                                MainPageStatisticsCard(
                                  iconColor: c2,
                                  title: "القطاع الخاص",
                                  icon: Icons.business_outlined,
                                  count: 27,
                                ),
                              ],
                            ),
                          ),
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
                                    pointColorMapper: (ChartData data, _) {
                                      // The dynamic alpha calculation remains exactly the same
                                      double ratio = data.value / _maxValue;
                                      double calculatedAlpha =
                                          0.8 + (ratio * 0.5);
                                      return data.color?.withValues(
                                            alpha: calculatedAlpha,
                                          ) ??
                                          Colors.blue;
                                    },
                                    innerRadius: '45%',
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      connectorLineSettings:
                                          ConnectorLineSettings(
                                            type: ConnectorType.curve,
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

                    // The Bottom Action Cards remain constrained to the bottom
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
      ),
    );
  }
}

