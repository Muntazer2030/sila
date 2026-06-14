// lib/ui/screens/settings_screen/settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sila/const/colors.dart';
import 'package:sila/data/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String backupDir = "لم يتم تحديد مسار النسخ الاحتياطي";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      backupDir =
          prefs.getString('backup_dir') ?? "لم يتم تحديد مسار النسخ الاحتياطي";
      isLoading = false;
    });
  }

  // --- 1. SET BACKUP DIRECTORY ---
  Future<void> _selectBackupDir() async {
    String? selectedDirectory = await FilePicker.getDirectoryPath(
      dialogTitle: 'اختر مجلد لحفظ النسخ الاحتياطية',
    );

    if (selectedDirectory != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backup_dir', selectedDirectory);
      setState(() {
        backupDir = selectedDirectory;
      });

      // Trigger an immediate initial backup to the new location
      await DatabaseHelper.instance.backupDatabase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حفظ مسار النسخ وتم أخذ نسخة احتياطية بنجاح!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // --- 2. IMPORT DATABASE (.db file) ---
  Future<void> _importDatabase() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
      dialogTitle: 'اختر ملف قاعدة البيانات (sila_database.db)',
    );

    if (result != null && result.files.single.path != null) {
      bool success = await DatabaseHelper.instance.importDatabase(
        result.files.single.path!,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "تم استيراد قاعدة البيانات بنجاح! يرجى إعادة تشغيل التطبيق.",
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("فشل في استيراد قاعدة البيانات."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  // --- 3. WIPE DATABASE ---
  Future<void> _wipeDatabase() async {
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
                  "حذف جميع البيانات",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              "هل أنت متأكد من حذف جميع البيانات؟\nسيتم مسح قاعدة البيانات بالكامل ولا يمكن التراجع!",
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
                  await DatabaseHelper.instance.wipeDatabase();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم تهيئة قاعدة البيانات بنجاح!"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text(
                  "نعم، احذف الكل",
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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        alignment: Alignment.topCenter,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              "الإعدادات والنظام",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
        
            _buildSettingsCard(
              title: "مسار النسخ الاحتياطي التلقائي",
              description:
                  "اختر مجلد ليتم حفظ نسخة مطابقة لقاعدة البيانات فيه مع كل تغيير.",
              icon: Icons.folder_special_outlined,
              color: c2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "المسار الحالي: $backupDir",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _selectBackupDir,
                    icon: const Icon(Icons.drive_folder_upload, size: 18),
                    label: const Text("تغيير المسار"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c2,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        
            const SizedBox(height: 20),
        
            _buildSettingsCard(
              title: "استيراد قاعدة بيانات",
              description:
                  "هل لديك ملف قاعدة بيانات (sila_database.db) سابق؟ يمكنك استعادته من هنا.",
              icon: Icons.restore,
              color: c1,
              child: OutlinedButton.icon(
                onPressed: _importDatabase,
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: const Text("استيراد ملف .db"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c1,
                  side: const BorderSide(color: c1),
                ),
              ),
            ),
        
            const SizedBox(height: 20),
        
            _buildSettingsCard(
              title: "تهيئة النظام",
              description: "مسح جميع البيانات والعودة لضبط المصنع.",
              icon: Icons.delete_forever,
              color: Colors.redAccent,
              child: OutlinedButton.icon(
                onPressed: _wipeDatabase,
                icon: const Icon(
                  Icons.warning,
                  size: 18,
                  color: Colors.redAccent,
                ),
                label: const Text(
                  "حذف جميع البيانات",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
