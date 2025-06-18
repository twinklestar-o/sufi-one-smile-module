import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../app/modules/smile/models/jabatan.dart';

class DatabaseHelper {
  static const _databaseName = 'app_database.db';
  static const _databaseVersion = 1;

  // Table names
  static const tableJabatan = 'jabatan';
  static const tableMetadata = 'metadata';

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
}
