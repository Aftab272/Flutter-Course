import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/city_model.dart';
import '../models/weather_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('weather_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // App Settings Table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Saved Cities / Favourites Table
    await db.execute('''
      CREATE TABLE saved_cities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cityName TEXT NOT NULL,
        country TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        isFavourite INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Weather Cache Table
    await db.execute('''
      CREATE TABLE weather_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        locationKey TEXT UNIQUE NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        weatherJson TEXT NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');

    // Recent Searches Table
    await db.execute('''
      CREATE TABLE recent_searches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cityName TEXT NOT NULL,
        country TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        searchedAt TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('app_settings', {
      'key': 'temperature_unit',
      'value': 'celsius',
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Insert default cities (e.g., New York, London, Tokyo, Paris)
    await db.insert('saved_cities', {
      'cityName': 'New York',
      'country': 'US',
      'latitude': 40.7128,
      'longitude': -74.0060,
      'isFavourite': 1,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await db.insert('saved_cities', {
      'cityName': 'London',
      'country': 'UK',
      'latitude': 51.5074,
      'longitude': -0.1278,
      'isFavourite': 1,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await db.insert('saved_cities', {
      'cityName': 'Tokyo',
      'country': 'JP',
      'latitude': 35.6762,
      'longitude': 139.6503,
      'isFavourite': 1,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await db.insert('saved_cities', {
      'cityName': 'Paris',
      'country': 'FR',
      'latitude': 48.8566,
      'longitude': 2.3522,
      'isFavourite': 1,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations safely without deleting user data
  }

  // --- App Settings Operations ---
  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isNotEmpty) {
      return results.first['value'] as String?;
    }
    return null;
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {
        'key': key,
        'value': value,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Saved Cities Operations ---
  Future<List<CityLocation>> getSavedCities() async {
    final db = await database;
    final results = await db.query('saved_cities', orderBy: 'createdAt DESC');
    return results.map((map) => CityLocation.fromMap(map)).toList();
  }

  Future<int> insertCity(CityLocation city) async {
    final db = await database;
    // Check if city already exists
    final existing = await db.query(
      'saved_cities',
      where: 'cityName = ? AND country = ?',
      whereArgs: [city.cityName, city.country],
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return await db.insert('saved_cities', city.toMap());
  }

  Future<void> deleteCity(int id) async {
    final db = await database;
    await db.delete('saved_cities', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCityFavourite(int id, bool isFavourite) async {
    final db = await database;
    await db.update(
      'saved_cities',
      {'isFavourite': isFavourite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Weather Cache Operations ---
  Future<void> cacheWeather(String locationKey, double lat, double lon, WeatherData weather) async {
    final db = await database;
    await db.insert(
      'weather_cache',
      {
        'locationKey': locationKey.toLowerCase(),
        'latitude': lat,
        'longitude': lon,
        'weatherJson': jsonEncode(weather.toJson()),
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<WeatherData?> getCachedWeather(String locationKey) async {
    final db = await database;
    final results = await db.query(
      'weather_cache',
      where: 'locationKey = ?',
      whereArgs: [locationKey.toLowerCase()],
    );
    if (results.isNotEmpty) {
      final jsonStr = results.first['weatherJson'] as String;
      return WeatherData.fromJson(jsonDecode(jsonStr));
    }
    return null;
  }

  // --- Recent Searches Operations ---
  Future<List<RecentSearch>> getRecentSearches() async {
    final db = await database;
    final results = await db.query('recent_searches', orderBy: 'searchedAt DESC', limit: 10);
    return results.map((map) => RecentSearch.fromMap(map)).toList();
  }

  Future<void> addRecentSearch(RecentSearch search) async {
    final db = await database;
    // Remove duplicate if exists
    await db.delete(
      'recent_searches',
      where: 'cityName = ? AND country = ?',
      whereArgs: [search.cityName, search.country],
    );
    await db.insert('recent_searches', search.toMap());
  }

  Future<void> clearRecentSearches() async {
    final db = await database;
    await db.delete('recent_searches');
  }

  // --- Backup & Restore Data Export/Import ---
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    final settings = await db.query('app_settings');
    final cities = await db.query('saved_cities');
    final cache = await db.query('weather_cache');
    final recents = await db.query('recent_searches');

    return {
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'app_settings': settings,
      'saved_cities': cities,
      'weather_cache': cache,
      'recent_searches': recents,
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear current tables to restore safely
      await txn.delete('app_settings');
      await txn.delete('saved_cities');
      await txn.delete('weather_cache');
      await txn.delete('recent_searches');

      if (data['app_settings'] != null) {
        for (var item in data['app_settings']) {
          await txn.insert('app_settings', Map<String, Object?>.from(item));
        }
      }
      if (data['saved_cities'] != null) {
        for (var item in data['saved_cities']) {
          await txn.insert('saved_cities', Map<String, Object?>.from(item));
        }
      }
      if (data['weather_cache'] != null) {
        for (var item in data['weather_cache']) {
          await txn.insert('weather_cache', Map<String, Object?>.from(item));
        }
      }
      if (data['recent_searches'] != null) {
        for (var item in data['recent_searches']) {
          await txn.insert('recent_searches', Map<String, Object?>.from(item));
        }
      }
    });
  }
}
