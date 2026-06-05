import 'package:sila/const/colors.dart';
import 'package:sila/ui/screens/pages/main_page.dart';
import 'package:sila/ui/widgets/nav_tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

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
          bool isMediumScreen = constraints.maxWidth > 700;

          bool isTooSmallScreen =
              constraints.maxWidth < 450 || constraints.maxHeight < 300;

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
                                  color: c2
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
                                color: c2
                              ),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 20),

                            // --- MIDDLE SECTION (Scrollable) ---
                            // 1. Expanded takes up all remaining empty space (replacing Spacer)
                            // 2. SingleChildScrollView ensures no overflow if height is small
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    NavTile(
                                      icon: Icons.home,
                                      title: "الرئيسية",
                                      isActive: selectedIndex == 0,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 0;
                                        });
                                      },
                                    ),
                                    NavTile(
                                      icon: Icons.account_balance_outlined,
                                      title: "المؤسسات الحكومية",
                                      isActive: selectedIndex == 1,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 1;
                                        });
                                      },
                                    ),
                                    NavTile(
                                      icon: Icons.apartment_outlined,
                                      title: "المؤسسات غير الحكومية",
                                      isActive: selectedIndex == 2,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 2;
                                        });
                                      },
                                    ),
                                    NavTile(
                                      icon: Icons.group_add_outlined,
                                      title: "الشخصيات المؤثرة",
                                      isActive: selectedIndex == 3,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 3;
                                        });
                                      },
                                    ),
                                    NavTile(
                                      icon: Icons.school_outlined,
                                      title: "الشخصيات الأكاديمية",
                                      isActive: selectedIndex == 4,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 4;
                                        });
                                      },
                                    ),
                                    NavTile(
                                      icon: Icons.group_add_outlined,
                                      title: "الشخصيات العامة والأجتماعية",
                                      isActive: selectedIndex == 5,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 5;
                                        });
                                      },
                                    ),
                                    NavTile(
                                      icon: Icons.group_outlined,
                                      title: "الجمهور",
                                      isActive: selectedIndex == 6,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 6;
                                        });
                                      },
                                    ),
                                    NavTile(
                                      icon: Icons.campaign_outlined,
                                      title: "الأعلام والمنصات",
                                      isActive: selectedIndex == 7,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 7;
                                        });
                                      },
                                    ),
                                    NavTile(
                                      icon: Icons.business_outlined,
                                      title: "القطاع الخاص",
                                      isActive: selectedIndex == 8,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 8;
                                        });
                                      },
                                    ),
                                    NavTile(
                                      icon: Icons.campaign_outlined,
                                      title: "الحملات",
                                      isActive: selectedIndex == 9,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 9;
                                        });
                                      },
                                    ),

                                    NavTile(
                                      icon: Icons.settings_outlined,
                                      title: "الاعدادات",
                                      isActive: selectedIndex == 10,
                                      isCompact: !isWideScreen,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 10;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Builder(
                        builder: (context) {
                          if (selectedIndex == 0) {
                            return MainPage();
                          }

                          // 4. Main Content Area (Flexible for Both Resizes)
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
                        },
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
