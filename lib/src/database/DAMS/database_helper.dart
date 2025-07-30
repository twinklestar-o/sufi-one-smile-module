import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sufi_one/app/modules/DAMS/model/divisi_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/kondisi_asset.dart';
import 'package:sufi_one/app/modules/DAMS/model/lantai_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/lokasi_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/posisi_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/status_asset.dart';
import 'package:sufi_one/app/modules/DAMS/model/status_user_asset.dart';

class DatabaseHelperDams {
  static const _databaseName = 'app_database.db';
  static const _databaseVersion = 1;

  // Table names
  static const tableStatusAsset = 'statusAsset';
  static const tableKondisiAsset = 'kondisiAsset';
  static const tableStatusUserAsset = 'statusUserAsset';
  static const tablePosisiUser = 'posisiUser';
  static const tableDivisiUser = 'divisiUser';
  static const tableLokasiUser = 'lokasiUser';
  static const tableLantaiUser = 'lantaiUser';
  static const tableMetadata = 'metadata';

  // Singleton instance
  static final DatabaseHelperDams instance = DatabaseHelperDams._init();
  DatabaseHelperDams._init();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }

  // Define table schemas in a Map for modularity
  static const Map<String, String> _tableSchemas = {
    tableStatusAsset: '''
      CREATE TABLE $tableStatusAsset (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableKondisiAsset: '''
      CREATE TABLE $tableKondisiAsset (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableStatusUserAsset: '''
      CREATE TABLE $tableStatusUserAsset (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tablePosisiUser: '''
      CREATE TABLE $tablePosisiUser (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableDivisiUser: '''
      CREATE TABLE $tableDivisiUser (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableLokasiUser: '''
      CREATE TABLE $tableLokasiUser (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableLantaiUser: '''
      CREATE TABLE $tableLantaiUser (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableMetadata: '''
      CREATE TABLE $tableMetadata (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''',
  };

  Future<void> _onCreate(Database db, int version) async {
    // Create all tables when the database is first created
    for (var schema in _tableSchemas.values) {
      await db.execute(schema);
    }
    debugPrint('Database tables created.');
  }

  Future<void> _onOpen(Database db) async {
    // Ensure all tables exist when the database is opened
    for (var tableName in _tableSchemas.keys) {
      if (!await tableExists(db, tableName)) {
        await db.execute(_tableSchemas[tableName]!);
        debugPrint('Table $tableName created on open.');
      }
    }
  }

  Future<bool> tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  // --- Generic Methods for Insert, Get, and Clear ---
  Future<int> _insert<T>(
    String tableName,
    T item,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final db = await database;
    if (!await tableExists(db, tableName)) {
      await db.execute(_tableSchemas[tableName]!);
      debugPrint('Table $tableName created before insert.');
    }
    return await db.insert(tableName, toJson(item));
  }

  Future<void> _insertList<T>(
    String tableName,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final db = await database;
    if (!await tableExists(db, tableName)) {
      await db.execute(_tableSchemas[tableName]!);
      debugPrint('Table $tableName created before insert.');
    }
    await db.transaction((txn) async {
      for (var item in items) {
        await txn.insert(
          tableName,
          toJson(item),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<T>> _getAll<T>(
    String tableName,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final db = await database;
    if (!await tableExists(db, tableName)) {
      await db.execute(_tableSchemas[tableName]!);
      debugPrint('Table $tableName created before query.');
      return [];
    }
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => fromJson(maps[i]));
  }

  Future<void> _clearTable(String tableName) async {
    final db = await database;
    if (await tableExists(db, tableName)) {
      await db.delete(tableName);
    } else {
      debugPrint('Table $tableName does not exist. Skipping delete.');
    }
  }

  // --- StatusAsset Methods ---
  Future<int> insertStatusAsset(StatusAsset statusAsset) async =>
      _insert(tableStatusAsset, statusAsset, (s) => s.toJson());
  Future<void> insertStatusAssets(List<StatusAsset> statusAssets) async =>
      _insertList(tableStatusAsset, statusAssets, (s) => s.toJson());
  Future<List<StatusAsset>> getAllStatusAsset() async =>
      _getAll(tableStatusAsset, StatusAsset.fromJson);
  Future<void> clearStatusAssets() async => _clearTable(tableStatusAsset);

  // --- KondisiAsset Methods ---
  Future<int> insertKondisiAsset(KondisiAsset kondisiAsset) async =>
      _insert(tableKondisiAsset, kondisiAsset, (k) => k.toJson());
  Future<void> insertKondisiAssets(List<KondisiAsset> kondisiAssets) async =>
      _insertList(tableKondisiAsset, kondisiAssets, (k) => k.toJson());
  Future<List<KondisiAsset>> getAllKondisiAsset() async =>
      _getAll(tableKondisiAsset, KondisiAsset.fromJson);
  Future<void> clearKondisiAssets() async => _clearTable(tableKondisiAsset);

  // --- StatusUserAsset Methods ---
  Future<int> insertStatusUserAsset(StatusUserAsset statusUserAsset) async =>
      _insert(tableStatusUserAsset, statusUserAsset, (s) => s.toJson());
  Future<void> insertStatusUserAssets(
    List<StatusUserAsset> statusUserAssets,
  ) async =>
      _insertList(tableStatusUserAsset, statusUserAssets, (s) => s.toJson());
  Future<List<StatusUserAsset>> getAllStatusUserAsset() async =>
      _getAll(tableStatusUserAsset, StatusUserAsset.fromJson);
  Future<void> clearStatusUserAssets() async =>
      _clearTable(tableStatusUserAsset);

  // --- PosisiUser Methods ---
  Future<int> insertPosisiUser(PosisiUser posisiUser) async =>
      _insert(tablePosisiUser, posisiUser, (p) => p.toJson());
  Future<void> insertPosisiUsers(List<PosisiUser> posisiUsers) async =>
      _insertList(tablePosisiUser, posisiUsers, (p) => p.toJson());
  Future<List<PosisiUser>> getAllPosisiUser() async =>
      _getAll(tablePosisiUser, PosisiUser.fromJson);
  Future<void> clearPosisiUsers() async => _clearTable(tablePosisiUser);

  // --- DivisiUser Methods ---
  Future<int> insertDivisiUser(DivisiUser divisiUser) async =>
      _insert(tableDivisiUser, divisiUser, (d) => d.toJson());
  Future<void> insertDivisiUsers(List<DivisiUser> divisiUsers) async =>
      _insertList(tableDivisiUser, divisiUsers, (d) => d.toJson());
  Future<List<DivisiUser>> getAllDivisiUser() async =>
      _getAll(tableDivisiUser, DivisiUser.fromJson);
  Future<void> clearDivisiUsers() async => _clearTable(tableDivisiUser);

  // --- LokasiUser Methods ---
  Future<int> insertLokasiUser(LokasiUser lokasiUser) async =>
      _insert(tableLokasiUser, lokasiUser, (l) => l.toJson());
  Future<void> insertLokasiUsers(List<LokasiUser> lokasiUsers) async =>
      _insertList(tableLokasiUser, lokasiUsers, (l) => l.toJson());
  Future<List<LokasiUser>> getAllLokasiUser() async =>
      _getAll(tableLokasiUser, LokasiUser.fromJson);
  Future<void> clearLokasiUsers() async => _clearTable(tableLokasiUser);

  // --- LantaiUser Methods ---
  Future<int> insertLantaiUser(LantaiUser lantaiUser) async =>
      _insert(tableLantaiUser, lantaiUser, (l) => l.toJson());
  Future<void> insertLantaiUsers(List<LantaiUser> lantaiUsers) async =>
      _insertList(tableLantaiUser, lantaiUsers, (l) => l.toJson());
  Future<List<LantaiUser>> getAllLantaiUser() async =>
      _getAll(tableLantaiUser, LantaiUser.fromJson);
  Future<void> clearLantaiUsers() async => _clearTable(tableLantaiUser);

  // --- Metadata (Timestamp) Methods ---
  Future<DateTime?> getLastUpdateTime(String key) async {
    final db = await database;
    if (!await tableExists(db, tableMetadata)) {
      await db.execute(_tableSchemas[tableMetadata]!);
      debugPrint('Table $tableMetadata created before metadata query.');
    }
    final List<Map<String, dynamic>> maps = await db.query(
      tableMetadata,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return DateTime.parse(maps.first['value']);
    }
    return null;
  }

  Future<void> updateCollectionTimestamp(String key) async {
    final db = await database;
    if (!await tableExists(db, tableMetadata)) {
      await db.execute(_tableSchemas[tableMetadata]!);
      debugPrint('Table $tableMetadata created before metadata update.');
    }
    await db.insert(tableMetadata, {
      'key': key,
      'value': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateLastTypeUpdateTime() async {
    await updateCollectionTimestamp('type_last_update');
  }

  Future<DateTime?> getLastTypeUpdateTime() async {
    return getLastUpdateTime('type_last_update');
  }

  Future<void> deleteLastUpdate(String key) async {
    final db = await database;
    if (await tableExists(db, tableMetadata)) {
      await db.delete(tableMetadata, where: 'key = ?', whereArgs: [key]);
    } else {
      debugPrint('Table $tableMetadata does not exist. Skipping delete.');
    }
  }
}
