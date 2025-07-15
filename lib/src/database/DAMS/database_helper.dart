import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableStatusAsset (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableKondisiAsset (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableStatusUserAsset (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePosisiUser (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableDivisiUser (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableLokasiUser (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableLantaiUser (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableMetadata (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<int> insertStatusAsset(StatusAsset statusAsset) async {
    final db = await database;
    return await db.insert(tableStatusAsset, statusAsset.toJson());
  }

  Future<List<StatusAsset>> getAllStatusAsset() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableStatusAsset);
    return List.generate(maps.length, (i) {
      return StatusAsset(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<int> insertKondisiAsset(KondisiAsset kondisiAsset) async {
    final db = await database;
    return await db.insert(tableKondisiAsset, kondisiAsset.toJson());
  }

  Future<List<KondisiAsset>> getAllKondisiAsset() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableKondisiAsset);
    return List.generate(maps.length, (i) {
      return KondisiAsset(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<int> insertStatusUserAsset(StatusUserAsset statususerAsset) async {
    final db = await database;
    return await db.insert(tableStatusUserAsset, statususerAsset.toJson());
  }

  Future<List<StatusUserAsset>> getAllStatusUserAsset() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableStatusUserAsset,
    );
    return List.generate(maps.length, (i) {
      return StatusUserAsset(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<int> insertPosisiUser(PosisiUser posisiUser) async {
    final db = await database;
    return await db.insert(tablePosisiUser, posisiUser.toJson());
  }

  Future<List<PosisiUser>> getAllPosisiUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tablePosisiUser);
    return List.generate(maps.length, (i) {
      return PosisiUser(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<int> insertDivisiUser(DivisiUser divisiUser) async {
    final db = await database;
    return await db.insert(tableDivisiUser, divisiUser.toJson());
  }

  Future<List<DivisiUser>> getAllDivisiUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableDivisiUser);
    return List.generate(maps.length, (i) {
      return DivisiUser(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<int> insertLokasiUser(LokasiUser lokasiUser) async {
    final db = await database;
    return await db.insert(tableLokasiUser, lokasiUser.toJson());
  }

  Future<List<LokasiUser>> getAllLokasiUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableLokasiUser);
    return List.generate(maps.length, (i) {
      return LokasiUser(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<int> insertLantaiUser(LantaiUser lantaiUser) async {
    final db = await database;
    return await db.insert(tableLantaiUser, lantaiUser.toJson());
  }

  Future<List<LantaiUser>> getAllLantaiUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableLantaiUser);
    return List.generate(maps.length, (i) {
      return LantaiUser(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<void> updateCollectionTimestamp(String key) async {
    final db = await database;
    await db.insert(tableMetadata, {
      'key': key,
      'value': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DateTime?> getLastUpdateTime(String key) async {
    final db = await database;
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

  Future<void> updateLastTypeUpdateTime() async {
    final db = await database;
    await db.insert(tableMetadata, {
      'key': 'type_last_update', // Kunci unik untuk timestamp Type
      'value': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DateTime?> getLastTypeUpdateTime() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMetadata,
      where: 'key = ?',
      whereArgs: ['type_last_update'], // Kunci unik untuk timestamp Type
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DateTime.parse(maps.first['value']);
    }
    return null;
  }
}
