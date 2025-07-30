import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sufi_one/app/modules/smile/models/area.dart';
import 'package:sufi_one/app/modules/smile/models/dealer.dart';
import 'package:sufi_one/app/modules/smile/models/jabatan.dart';
import 'package:sufi_one/app/modules/smile/models/purpose.dart';
import 'package:sufi_one/app/modules/smile/models/branch.dart';
import 'package:sufi_one/app/modules/smile/models/product.dart';
import 'package:sufi_one/app/modules/smile/models/jabatanSFI.dart';
import 'package:sufi_one/app/modules/smile/models/type.dart';
import 'package:sufi_one/app/modules/smile/models/collection.dart';

class DatabaseHelperSmile {
  static const _databaseName = 'app_database.db';
  static const _databaseVersion =
      1; // Versi tetap, tidak perlu diubah untuk tabel baru

  // Table names
  static const tableJabatan = 'jabatan';
  static const tableMetadata = 'metadata';
  static const tableArea = 'area';
  static const tableType = 'types';
  static const tablePurpose = 'purpose';
  static const tableBranch = 'branches';
  static const tableProduct = 'product';
  static const tableDealer = 'dealers';
  static const tableJabatanSFI = 'jabatanSFI';
  static const tableCollection = 'collection';

  // Singleton instance
  static final DatabaseHelperSmile instance = DatabaseHelperSmile._init();
  DatabaseHelperSmile._init();

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
      onOpen: _onOpen, // Tambahkan onOpen untuk memastikan semua tabel ada
    );
  }

  // Definisikan skema tabel dalam bentuk Map untuk modularitas
  static const Map<String, String> _tableSchemas = {
    tableJabatan: '''
      CREATE TABLE $tableJabatan (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        kode TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableArea: '''
      CREATE TABLE $tableArea (
        code TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableJabatanSFI: '''
      CREATE TABLE $tableJabatanSFI (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        kode TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableType: '''
      CREATE TABLE $tableType (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        kode TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tablePurpose: '''
      CREATE TABLE $tablePurpose (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        kode TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableDealer: '''
      CREATE TABLE $tableDealer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableProduct: '''
      CREATE TABLE $tableProduct (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''',
    tableBranch: '''
      CREATE TABLE $tableBranch (
        code TEXT PRIMARY KEY,
        area_code TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (area_code) REFERENCES $tableArea (code)
      )
    ''',
    tableCollection: '''
      CREATE TABLE $tableCollection (
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
    // Buat semua tabel saat database pertama kali dibuat
    for (var schema in _tableSchemas.values) {
      await db.execute(schema);
    }
    debugPrint('Database tables created.');
  }

  Future<void> _onOpen(Database db) async {
    // Pastikan semua tabel ada setiap kali database dibuka
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

  // --- Metode Generik untuk Insert, Get, dan Clear ---
  Future<void> _insertList<T>(
    String tableName,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final db = await database;
    // Pastikan tabel ada sebelum insert
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
    // Pastikan tabel ada sebelum query
    if (!await tableExists(db, tableName)) {
      await db.execute(_tableSchemas[tableName]!);
      debugPrint('Table $tableName created before query.');
      return []; // Kembalikan list kosong jika tabel baru dibuat
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

  // --- Metode untuk Jabatan ---
  Future<void> insertJabatans(List<Jabatan> jabatans) async =>
      _insertList(tableJabatan, jabatans, (j) => j.toJson());
  Future<List<Jabatan>> getAllJabatan() async =>
      _getAll(tableJabatan, Jabatan.fromJson);
  Future<void> clearJabatans() async => _clearTable(tableJabatan);

  // --- Metode untuk JabatanSFI ---
  Future<void> insertJabatanSFIs(List<JabatanSFI> jabatanSFIs) async =>
      _insertList(tableJabatanSFI, jabatanSFIs, (j) => j.toJson());
  Future<List<JabatanSFI>> getAllJabatanSFI() async =>
      _getAll(tableJabatanSFI, JabatanSFI.fromJson);
  Future<void> clearJabatanSFIs() async => _clearTable(tableJabatanSFI);

  // --- Metode untuk Dealer ---
  Future<void> insertDealers(List<Dealer> dealers) async =>
      _insertList(tableDealer, dealers, (d) => d.toJson());
  Future<List<Dealer>> getAllDealer() async =>
      _getAll(tableDealer, Dealer.fromJson);
  Future<void> clearDealers() async => _clearTable(tableDealer);

  // --- Metode untuk Branch ---
  Future<void> insertBranches(List<Branch> branches) async =>
      _insertList(tableBranch, branches, (b) => b.toJson());
  Future<List<Branch>> getAllBranch() async =>
      _getAll(tableBranch, Branch.fromJson);
  Future<void> clearBranches() async => _clearTable(tableBranch);

  // --- Metode untuk Product ---
  Future<void> insertProducts(List<Product> products) async =>
      _insertList(tableProduct, products, (p) => p.toJson());
  Future<List<Product>> getAllProduct() async =>
      _getAll(tableProduct, Product.fromJson);
  Future<void> clearProducts() async => _clearTable(tableProduct);

  // --- Metode untuk Area ---
  Future<void> insertAreas(List<Area> areas) async =>
      _insertList(tableArea, areas, (a) => a.toJson());
  Future<List<Area>> getAllArea() async => _getAll(tableArea, Area.fromJson);
  Future<void> clearAreas() async => _clearTable(tableArea);

  // --- Metode untuk Purpose ---
  Future<void> insertPurposes(List<Purpose> purposes) async =>
      _insertList(tablePurpose, purposes, (p) => p.toJson());
  Future<List<Purpose>> getAllPurpose() async =>
      _getAll(tablePurpose, Purpose.fromJson);
  Future<void> clearPurposes() async => _clearTable(tablePurpose);

  // --- Metode untuk Type ---
  Future<void> insertTypes(List<Type> types) async =>
      _insertList(tableType, types, (t) => t.toJson());
  Future<List<Type>> getAllType() async => _getAll(tableType, Type.fromJson);
  Future<void> clearTypes() async => _clearTable(tableType);

  // --- Metode untuk Collection ---
  Future<void> insertCollections(List<Collection> collections) async =>
      _insertList(tableCollection, collections, (c) => c.toMap());
  Future<List<Collection>> getAllCollection() async =>
      _getAll(tableCollection, Collection.fromJson);
  Future<void> clearCollections() async => _clearTable(tableCollection);

  // --- Metode untuk Metadata (Timestamp) ---
  Future<DateTime?> getLastUpdate(String key) async {
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

  Future<void> updateLastUpdate(String key) async {
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

  Future<void> deleteLastUpdate(String key) async {
    final db = await database;
    if (await tableExists(db, tableMetadata)) {
      await db.delete(tableMetadata, where: 'key = ?', whereArgs: [key]);
    } else {
      debugPrint('Table $tableMetadata does not exist. Skipping delete.');
    }
  }
}
