import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../config/constants.dart';

/// Storage manager singleton for unified local storage access
class StorageManager {
  static final StorageManager _instance = StorageManager._internal();
  factory StorageManager() => _instance;
  StorageManager._internal();

  late final HiveStorage _hive;
  late final SQLiteStorage _sqlite;
  late final SharedPrefsStorage _prefs;

  bool _initialized = false;

  /// Initialize all storage systems
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters here when needed
    // Hive.registerAdapter(UserProfileAdapter());
    // Hive.registerAdapter(SettingsAdapter());

    // Open Hive boxes
    await Hive.openBox<dynamic>(AppConstants.hiveBoxSettings);
    await Hive.openBox<dynamic>(AppConstants.hiveBoxProfile);
    await Hive.openBox<dynamic>(AppConstants.hiveBoxDashboard);
    await Hive.openBox<dynamic>(AppConstants.hiveBoxPickups);

    _hive = HiveStorage();

    // Initialize SQLite
    _sqlite = SQLiteStorage();
    await _sqlite.initialize();

    // Initialize SharedPreferences
    _prefs = SharedPrefsStorage();
    await _prefs.initialize();

    _initialized = true;
  }

  /// Hive storage for simple data and cache
  HiveStorage get cache => _hive;

  /// SQLite storage for complex/relational data
  SQLiteStorage get database => _sqlite;

  /// SharedPreferences for app state
  SharedPrefsStorage get prefs => _prefs;

  /// Clear all storage (for logout/reset)
  Future<void> clearAll() async {
    await _hive.clear();
    await _sqlite.clear();
    await _prefs.clear();
  }
}

/// Hive storage implementation
class HiveStorage {
  Box<dynamic>? _getBox(String name) {
    if (!Hive.isBoxOpen(name)) return null;
    return Hive.box<dynamic>(name);
  }

  Future<T?> get<T>(String boxName, String key) async {
    final box = _getBox(boxName);
    if (box == null) return null;
    return box.get(key) as T?;
  }

  Future<void> set<T>(String boxName, String key, T value) async {
    final box = _getBox(boxName);
    if (box == null) throw Exception('Box $boxName is not open');
    await box.put(key, value);
  }

  Future<void> delete(String boxName, String key) async {
    final box = _getBox(boxName);
    if (box == null) return;
    await box.delete(key);
  }

  Future<List<T>> getAll<T>(String boxName) async {
    final box = _getBox(boxName);
    if (box == null) return [];
    return box.values.cast<T>().toList();
  }

  Future<void> clearBox(String boxName) async {
    final box = _getBox(boxName);
    if (box == null) return;
    await box.clear();
  }

  Future<void> clear() async {
    await Hive.deleteFromDisk();
  }
}

/// SQLite storage implementation
class SQLiteStorage {
  Database? _database;

  Database? get db => _database;

  Future<void> initialize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppConstants.databaseName);

    _database = await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        student_id TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Profiles table
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        user_id TEXT UNIQUE NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        photo_path TEXT,
        department TEXT,
        year_of_study INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Pickups table
    await db.execute('''
      CREATE TABLE pickups (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        items TEXT NOT NULL,
        qr_code_data TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        scanned_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Meal history table
    await db.execute('''
      CREATE TABLE meal_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        pickup_id TEXT NOT NULL,
        items TEXT NOT NULL,
        total_value REAL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_users_student_id ON users(student_id)');
    await db.execute('CREATE INDEX idx_profiles_user_id ON profiles(user_id)');
    await db.execute('CREATE INDEX idx_pickups_user_id ON pickups(user_id)');
    await db.execute('CREATE INDEX idx_pickups_status ON pickups(status)');
    await db.execute(
        'CREATE INDEX idx_meal_history_user_id ON meal_history(user_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    if (_database == null) throw Exception('Database not initialized');
    return await _database!.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (_database == null) throw Exception('Database not initialized');
    return await _database!.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (_database == null) throw Exception('Database not initialized');
    return await _database!.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (_database == null) throw Exception('Database not initialized');
    return await _database!.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    if (_database == null) throw Exception('Database not initialized');
    await _database!.execute(sql, arguments);
  }

  Future<void> clear() async {
    if (_database == null) return;

    await _database!.delete('meal_history');
    await _database!.delete('pickups');
    await _database!.delete('profiles');
    await _database!.delete('users');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

/// SharedPreferences storage implementation
class SharedPrefsStorage {
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs?.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _prefs?.getDouble(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs?.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    return _prefs?.getStringList(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  Future<T?> getObject<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> setObject<T>(
      String key, T object, Map<String, dynamic> Function(T) toJson) async {
    final json = toJson(object);
    final jsonString = jsonEncode(json);
    await _prefs?.setString(key, jsonString);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}
