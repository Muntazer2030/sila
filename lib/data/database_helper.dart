
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:sila/models/profile_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sila_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Create the Profiles Table
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        name TEXT,
        entityType TEXT,
        mainCategory TEXT,
        subCategory TEXT,
        governorate TEXT,
        region TEXT,
        status TEXT,
        importance TEXT,
        dataSource TEXT,
        primaryPhone TEXT,
        secondaryPhone TEXT,
        email TEXT,
        website TEXT,
        contactPerson TEXT,
        bestContactTime TEXT,
        preferredContactMethod TEXT,
        contactNotes TEXT,
        facebookUrl TEXT,
        tiktokUrl TEXT,
        instagramUrl TEXT,
        twitterUrl TEXT,
        youtubeUrl TEXT,
        snapchatUrl TEXT,
        telegramUrl TEXT,
        linkedinUrl TEXT,
        isVerified INTEGER,
        followersCount TEXT,
        audienceType TEXT,
        ageGroup TEXT,
        interactionLevel TEXT
      )
    ''');
  }

  Future<int> insertProfile(ProfileModel profile) async {
    final db = await instance.database;
    return await db.insert('profiles', profile.toMap());
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
    return db.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteProfile(String id) async {
    final db = await instance.database;
    return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }
}