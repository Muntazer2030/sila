// main.dart
import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/data/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sila/ui/screens/home_screen/home_screen.dart'; // Adjust path

void main() async{
  // Initialize SQLite for Windows/Desktop
  WidgetsFlutterBinding.ensureInitialized();
  
 
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
 
  await DatabaseHelper.instance.database;

 
  await DatabaseHelper.instance.backupDatabase();

  // 5. Run the App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sila',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: c2, // Medical Teal
          surface: const Color(0xFFF4F7FA), // Soft Blue-Grey Background
        ),
        useMaterial3: true,
        fontFamily: 'Cairo', // Assuming you use an Arabic font
      ),
      home: const HomeScreen(),
    );
  }
}
