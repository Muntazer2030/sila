// lib/data/database_helper.dart
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sila/models/profile_model.dart';
import 'package:sila/models/campaign_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const String _dbName = 'sila_database.db';

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

    // Bumped to version 5 to add Campaigns
    return await openDatabase(path, version: 5, onCreate: _createDB, onUpgrade: _upgradeDB);
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
    
    await db.execute('''
      CREATE TABLE campaigns (
        id TEXT PRIMARY KEY,
        name TEXT, description TEXT, startDate TEXT, endDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE campaign_invites (
        campaignId TEXT, profileId TEXT,
        PRIMARY KEY (campaignId, profileId)
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
    if (oldVersion < 5) {
      try {
        await db.execute("CREATE TABLE IF NOT EXISTS campaigns (id TEXT PRIMARY KEY, name TEXT, description TEXT, startDate TEXT, endDate TEXT)");
        await db.execute("CREATE TABLE IF NOT EXISTS campaign_invites (campaignId TEXT, profileId TEXT, PRIMARY KEY (campaignId, profileId))");
      } catch (_) {}
    }
  }

  // ==================== PROFILES ====================
  Future<int> insertProfile(ProfileModel profile) async {
    final db = await instance.database;
    int res = await db.insert('profiles', profile.toMap());
    await backupDatabase();
    return res;
  }

  Future<List<ProfileModel>> getAllProfiles() async {
    final db = await instance.database;
    final result = await db.query('profiles');
    return result.map((json) => ProfileModel.fromMap(json)).toList();
  }

  Future<List<ProfileModel>> getProfilesByCategory(String mainCategory) async {
    final db = await instance.database;
    final result = await db.query('profiles', where: 'mainCategory = ?', whereArgs: [mainCategory]);
    return result.map((json) => ProfileModel.fromMap(json)).toList();
  }

  Future<int> updateProfile(ProfileModel profile) async {
    final db = await instance.database;
    profile.updatedAt = DateTime.now().toIso8601String().split('T')[0];
    int res = await db.update('profiles', profile.toMap(), where: 'id = ?', whereArgs: [profile.id]);
    await backupDatabase();
    return res;
  }

  Future<int> deleteProfile(String id) async {
    final db = await instance.database;
    int res = await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
    await db.delete('campaign_invites', where: 'profileId = ?', whereArgs: [id]); // cleanup
    await backupDatabase();
    return res;
  }

  // ==================== CAMPAIGNS ====================
  Future<List<CampaignModel>> getAllCampaigns() async {
    final db = await instance.database;
    final result = await db.query('campaigns');
    return result.map((json) => CampaignModel.fromMap(json)).toList();
  }

  Future<int> insertCampaign(CampaignModel campaign) async {
    final db = await instance.database;
    int res = await db.insert('campaigns', campaign.toMap());
    await backupDatabase();
    return res;
  }

  Future<int> updateCampaign(CampaignModel campaign) async {
    final db = await instance.database;
    int res = await db.update('campaigns', campaign.toMap(), where: 'id = ?', whereArgs: [campaign.id]);
    await backupDatabase();
    return res;
  }

  Future<int> deleteCampaign(String id) async {
    final db = await instance.database;
    int res = await db.delete('campaigns', where: 'id = ?', whereArgs: [id]);
    await db.delete('campaign_invites', where: 'campaignId = ?', whereArgs: [id]); // cleanup invites
    await backupDatabase();
    return res;
  }

  // ==================== CAMPAIGN INVITES ====================
  Future<List<String>> getInvitedProfileIds(String campaignId) async {
    final db = await instance.database;
    final result = await db.query('campaign_invites', columns: ['profileId'], where: 'campaignId = ?', whereArgs: [campaignId]);
    return result.map((json) => json['profileId'] as String).toList();
  }

  Future<void> addInvite(String campaignId, String profileId) async {
    final db = await instance.database;
    try {
      await db.insert('campaign_invites', {'campaignId': campaignId, 'profileId': profileId});
      await backupDatabase();
    } catch (e) {
      // Ignore if already exists (Primary Key constraint)
    }
  }

  Future<void> removeInvite(String campaignId, String profileId) async {
    final db = await instance.database;
    await db.delete('campaign_invites', where: 'campaignId = ? AND profileId = ?', whereArgs: [campaignId, profileId]);
    await backupDatabase();
  }


  // ==========================================================
  // SYSTEM MANAGEMENT (Kept exactly the same)
  // ==========================================================
  Future<void> backupDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? backupDir = prefs.getString('backup_dir');

      if (backupDir != null && backupDir.isNotEmpty) {
        final dbPath = await getDatabasesPath();
        final currentDbPath = join(dbPath, _dbName);
        
        File currentDb = File(currentDbPath);
        if (await currentDb.exists()) {
          if (_sessionBackupFileName == null) {
            String timestamp = DateTime.now().toString().replaceAll(RegExp(r'[:. ]'), '-');
            _sessionBackupFileName = 'Sila_Backup_$timestamp.db';
          }
          String destinationPath = join(backupDir, _sessionBackupFileName!);
          await currentDb.copy(destinationPath);
        }
      }
    } catch (e) { print("Backup Failed: $e"); }
  }

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
        _sessionBackupFileName = null;
        await backupDatabase();
        return true;
      }
      return false;
    } catch (e) { return false; }
  }

  Future<void> wipeDatabase() async {
    final db = await instance.database;
    await db.execute('DELETE FROM profiles');
    await db.execute('DELETE FROM campaigns');
    await db.execute('DELETE FROM campaign_invites');
    _sessionBackupFileName = null;
    await backupDatabase();
  }
}