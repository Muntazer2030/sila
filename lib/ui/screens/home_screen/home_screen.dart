import 'package:sila/const/colors.dart';
import 'package:sila/models/app_data.dart';
import 'package:sila/ui/screens/home_screen/pages/campaigns_page.dart';
import 'package:sila/ui/screens/home_screen/pages/main_page.dart';
import 'package:sila/ui/screens/home_screen/pages/sub_page.dart';
import 'package:sila/ui/screens/settings_screen/settings_screen.dart';
import 'package:sila/ui/widgets/nav_tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  AppData appData = AppData();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // 1. LayoutBuilder detects window resize
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Define breakpoints
          bool isWideScreen = constraints.maxWidth > 900;

          bool isTooSmallScreen =
              constraints.maxWidth < 500 || constraints.maxHeight < 500;

          return isTooSmallScreen
              ? Container()
              : Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      // 3. Side Navigation Bar (Fixed for Height Resize)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isWideScreen ? 250 : 70,
                        color: Colors.white,
                        child: Column(
                          children: [
                            // --- HEADER SECTION ---
                            const SizedBox(height: 30),
                            Image.asset(
                              'assets/images/logo.png', // your image path
                              width: isWideScreen ? 140 : 70,
                              height: isWideScreen ? 140 : 70,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 10),
                            if (isWideScreen)
                              const Text(
                                "منظومة صلة",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: c2,
                                ),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                              ),
                            const SizedBox(height: 5),
                            const Text(
                              "لإدارة العلاقات",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 1.2,
                                color: c2,
                              ),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 20),

                            Expanded(
                              child: ListView.builder(
                                itemCount: appData.categories.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return NavTile(
                                    title: appData.categories[index]['name'],
                                    icon: appData.categories[index]['icon'],
                                    isActive: selectedIndex == index,
                                    onTap: () =>
                                        setState(() => selectedIndex = index),
                                    isCompact: !isWideScreen,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20), // Spacer
                            // Add a Divider line to separate settings
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Divider(color: Colors.grey.shade300),
                            ),

                            // Settings Button
                            NavTile(
                              icon: Icons.settings,
                              title: "الإعدادات",
                              isActive:
                                  selectedIndex ==
                                  99, // Unique index for settings
                              isCompact: !isWideScreen,
                              onTap: () {
                                setState(() {
                                  selectedIndex = 99;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Builder(
                          builder: (context) {
                            switch (selectedIndex) {
                              case 0:
                                return MainPage(
                                  appData: appData,
                                  onNavigate: (int index) {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                );
                              case 1:
                                return SubPage(category: appData.categories[1]);
                              case 2:
                                return SubPage(category: appData.categories[2]);
                              case 3:
                                return SubPage(category: appData.categories[3]);
                              case 4:
                                return SubPage(category: appData.categories[4]);
                              case 5:
                                return SubPage(category: appData.categories[5]);
                              case 6:
                                return SubPage(category: appData.categories[6]);
                              case 7:
                                return SubPage(category: appData.categories[7]);
                              case 8:
                                return SubPage(category: appData.categories[8]);

                              case 9:
                                return const CampaignsPage();
                              case 99:
                                return const SettingsScreen();
                              default:
                                return Container(
                                  width: isWideScreen
                                      ? constraints.maxWidth - 250
                                      : constraints.maxWidth - 70,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Text(
                                      "المحتوى الرئيسي لقسم ${selectedIndex + 1}",
                                      style: TextStyle(
                                        fontSize: isWideScreen ? 24 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
