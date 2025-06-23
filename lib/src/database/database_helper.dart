import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sufi_one/app/modules/smile/models/area.dart';
import '../../app/modules/smile/models/jabatan.dart';
import '../../app/modules/smile/models/type.dart';
import 'package:sufi_one/app/modules/smile/models/purpose.dart';
import 'package:sufi_one/app//modules/smile/models/branch.dart';



class DatabaseHelper {
  static const _databaseName = 'app_database.db';
  static const _databaseVersion = 1;

  // Table names
  static const tableJabatan = 'jabatan';
  static const tableMetadata = 'metadata';
  static const tableArea = 'area';
  static const tableType = 'types';
  static const tablePurpose = 'purpose';
  static const tableBranch = 'Branches';

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

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
      CREATE TABLE $tableJabatan (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        kode TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableArea (
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableType (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        kode TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE $tablePurpose (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        kode TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE $tableBranch (
    code TEXT PRIMARY KEY,
    area_code TEXT NOT NULL,
    name TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (area_code) REFERENCES $tableArea (code)
  )
''');

    await db.execute('''
      CREATE TABLE $tableMetadata (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }





  Future<int> insertJabatan(Jabatan jabatan) async {
    final db = await database;
    return await db.insert(tableJabatan, jabatan.toJson());
  }

  Future<List<Jabatan>> getAllJabatan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableJabatan);
    return List.generate(maps.length, (i) {
      return Jabatan(
        id: maps[i]['id'],
        name: maps[i]['name'],
        kode: maps[i]['kode'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<void> insertBranch(Branch branch) async {
    final db = await database;
    await db.insert(
      tableBranch,
      branch.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Branch>> getAllBranches() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableBranch);

    return List.generate(maps.length, (i) {
      return Branch.fromJson(maps[i]);
    });
  }


  Future<int> insertArea(Area area) async {
    final db = await database;
    return await db.insert(tableArea, area.toJson());
  }
  Future<int> insertPurpose(Purpose purpose) async {
  final db = await database;
  return await db.insert(tablePurpose, purpose.toJson());
  }


  Future<List<Area>> getAllArea() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableArea);
    return List.generate(maps.length, (i) {
      return Area(
        code: maps[i]['code'],
        name: maps[i]['name'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<void> updateCollectionTimestamp() async {
    final db = await database;
    await db.insert(tableMetadata, {
      'key': 'jabatan_last_update',
      'value': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DateTime?> getLastUpdateTime() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMetadata,
      where: 'key = ?',
      whereArgs: ['jabatan_last_update'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DateTime.parse(maps.first['value']);
    }
    return null;
  }

  Future<List<Purpose>> getAllPurpose() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(tablePurpose);
  return List.generate(maps.length, (i) {
  return Purpose(
  id: maps[i]['id'],
  name: maps[i]['name'],
  kode: maps[i]['kode'],
  createdAt: maps[i]['created_at'],
  updatedAt: maps[i]['updated_at'],
  );
  });
  }



  Future<int> insertType(Type type) async {
    final db = await database;
    return await db.insert(
      tableType,
      type.toJson(), // <<< Asumsi model Type memiliki toJson()
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Type>> getAllType() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableType);
    return List.generate(maps.length, (i) {
      return Type.fromJson(
        maps[i],
      ); // <<< Asumsi model Type memiliki fromJson()
    });
  }

  Future<void> clearAllType() async {
    final db = await database;
    await db.delete(tableType);
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
