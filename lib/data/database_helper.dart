// lib/data/database_helper.dart
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sila/models/profile_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const String _dbName = 'sila_database.db';

  // --- NEW: Session Tracker ---
  // This remembers the filename generated when the app opened.
  String? _sessionBackupFileName; 

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 4, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        name TEXT, entityType TEXT, mainCategory TEXT, subCategory TEXT,
        governorate TEXT, region TEXT, status TEXT, importance TEXT, dataSource TEXT,
        primaryPhone TEXT, secondaryPhone TEXT, email TEXT, website TEXT,
        contactPerson TEXT, bestContactTime TEXT, preferredContactMethod TEXT, contactNotes TEXT,
        facebookUrl TEXT, tiktokUrl TEXT, instagramUrl TEXT, twitterUrl TEXT,
        youtubeUrl TEXT, snapchatUrl TEXT, telegramUrl TEXT, linkedinUrl TEXT,
        isVerified INTEGER, followersCount TEXT, audienceType TEXT, ageGroup TEXT,
        interactionLevel TEXT, rating REAL, createdAt TEXT, updatedAt TEXT,
        cooperationCount TEXT, infoSource TEXT, gender TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try { await db.execute("ALTER TABLE profiles ADD COLUMN rating REAL DEFAULT 4.0;"); } catch (_) {}
      try { await db.execute("ALTER TABLE profiles ADD COLUMN createdAt TEXT DEFAULT '';"); } catch (_) {}
      try { await db.execute("ALTER TABLE profiles ADD COLUMN updatedAt TEXT DEFAULT '';"); } catch (_) {}
    }
    if (oldVersion < 4) {
      try { await db.execute("ALTER TABLE profiles ADD COLUMN cooperationCount TEXT DEFAULT '';"); } catch (_) {}
      try { await db.execute("ALTER TABLE profiles ADD COLUMN infoSource TEXT DEFAULT '';"); } catch (_) {}
      try { await db.execute("ALTER TABLE profiles ADD COLUMN gender TEXT DEFAULT '';"); } catch (_) {}
    }
  }

  // --- CRUD OPERATIONS ---

  Future<int> insertProfile(ProfileModel profile) async {
    final db = await instance.database;
    int res = await db.insert('profiles', profile.toMap());
    await backupDatabase(); // Updates the current session's backup
    return res;
  }

  Future<List<ProfileModel>> getAllProfiles() async {
    final db = await instance.database;
    final result = await db.query('profiles');
    return result.map((json) => ProfileModel.fromMap(json)).toList();
  }

  Future<List<ProfileModel>> getProfilesByCategory(String mainCategory) async {
    final db = await instance.database;
    final result = await db.query(
      'profiles',
      where: 'mainCategory = ?',
      whereArgs: [mainCategory],
    );
    return result.map((json) => ProfileModel.fromMap(json)).toList();
  }

  Future<int> updateProfile(ProfileModel profile) async {
    final db = await instance.database;
    profile.updatedAt = DateTime.now().toIso8601String().split('T')[0];
    int res = await db.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
    await backupDatabase(); // Updates the current session's backup
    return res;
  }

  Future<int> deleteProfile(String id) async {
    final db = await instance.database;
    int res = await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
    await backupDatabase(); // Updates the current session's backup
    return res;
  }

  // ==========================================================
  // SYSTEM MANAGEMENT: BACKUP, IMPORT, AND WIPE
  // ==========================================================

  // 1. SILENT BACKUP (Creates 1 file per session, updates it on changes)
  Future<void> backupDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? backupDir = prefs.getString('backup_dir');

      if (backupDir != null && backupDir.isNotEmpty) {
        final dbPath = await getDatabasesPath();
        final currentDbPath = join(dbPath, _dbName);
        
        File currentDb = File(currentDbPath);
        if (await currentDb.exists()) {
          
          // If this is the first backup of the session, generate the filename
          if (_sessionBackupFileName == null) {
            String timestamp = DateTime.now().toString().replaceAll(RegExp(r'[:. ]'), '-');
            _sessionBackupFileName = 'Sila_Backup_$timestamp.db';
          }
          
          String destinationPath = join(backupDir, _sessionBackupFileName!);
          
          // Copy overwrites the existing file if it shares the same name
          await currentDb.copy(destinationPath);
          print("Session Auto-Backup synced to: $_sessionBackupFileName");
        }
      }
    } catch (e) {
      print("Backup Failed: $e");
    }
  }

  // 2. IMPORT (RESTORE) DATABASE
  Future<bool> importDatabase(String importedFilePath) async {
    try {
      File importedFile = File(importedFilePath);
      if (await importedFile.exists()) {
        final dbPath = await getDatabasesPath();
        final currentDbPath = join(dbPath, _dbName);

        if (_database != null) {
          await _database!.close();
          _database = null;
        }

        await importedFile.copy(currentDbPath);
        _database = await _initDB(_dbName);
        
        // Reset the session filename so the imported DB gets its own safe backup file!
        _sessionBackupFileName = null;
        await backupDatabase();
        
        return true;
      }
      return false;
    } catch (e) {
      print("Import Failed: $e");
      return false;
    }
  }

  // 3. WIPE DATABASE (Start Fresh)
  Future<void> wipeDatabase() async {
    final db = await instance.database;
    await db.execute('DELETE FROM profiles');
    
    // Reset the session filename so the wiped (empty) DB gets its own backup file,
    // protecting the previous session's backup from being overwritten with empty data.
    _sessionBackupFileName = null;
    await backupDatabase();
  }
}