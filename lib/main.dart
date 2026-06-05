
import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/ui/screens/home_screen/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eye Clinic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: c2, // Medical Teal
          surface: const Color(0xFFF4F7FA), // Soft Blue-Grey Background
        ),
        fontFamily: 'Segoe UI', // Native Windows Font
      ),
      home: HomeScreen(),
    );
  }
}
