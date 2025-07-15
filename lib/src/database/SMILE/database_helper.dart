import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sufi_one/app/modules/smile/models/area.dart';
import 'package:sufi_one/app/modules/smile/models/dealer.dart';
import 'package:sufi_one/app/modules/smile/models/jabatan.dart';
import 'package:sufi_one/app/modules/smile/models/purpose.dart';
import 'package:sufi_one/app/modules/smile/models/branch.dart';
import 'package:sufi_one/app/modules/smile/models/product.dart';
import 'package:sufi_one/app/modules/smile/models/jabatanSFI.dart';
import 'package:flutter/foundation.dart';
import 'package:sufi_one/app/modules/smile/models/type.dart';
import 'package:sufi_one/app/modules/smile/models/collection.dart';

class DatabaseHelperSmile {
  static const _databaseName = 'app_database.db';
  static const _databaseVersion = 4;

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
  static const tableCollection = 'collection'; // Tambahkan konstanta ini

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
      onUpgrade: _onUpgrade, // Tambahkan ini agar migrasi bisa berjalan
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
        code TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableJabatanSFI (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        kode TEXT NOT NULL,
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
      CREATE TABLE $tableDealer (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableProduct (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE, 
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
      CREATE TABLE $tableCollection (
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
    debugPrint('Database tables created.');
  }

  // --- Fungsi onUpgrade untuk migrasi database ---
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion...');
    // Contoh migrasi dari versi 2 ke 3 (menambahkan tabel collection_timestamps dan membersihkan product)
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS collection_timestamps(
          collection_name TEXT PRIMARY KEY,
          last_update TEXT
        )
      ''');
      // Membersihkan tabel product jika skema berubah
      await db.execute('DROP TABLE IF EXISTS product');
      await db.execute('''
        CREATE TABLE product(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          code TEXT NOT NULL UNIQUE,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      debugPrint(
        'Database upgraded to v3: Added collection_timestamps, recreated product table.',
      );
    }
    // Migrasi dari versi 3 ke 4 (menambahkan tabel collection dengan kode)
    if (oldVersion < 4) {
      await db.execute(
        'DROP TABLE IF EXISTS $tableCollection',
      ); // Drop jika sudah ada
      await db.execute('''
        CREATE TABLE $tableCollection(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          kode TEXT, -- Tambahkan kode (seperti di jawaban sebelumnya)
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      debugPrint(
        'Database upgraded to v4: Recreated collection table with "kode".',
      );
    }
    // Migrasi dari versi 4 ke 5 (menghapus kolom 'kode' dari tabel 'collection')
    if (oldVersion < 5) {
      await db.execute(
        'DROP TABLE IF EXISTS $tableCollection',
      ); // Drop tabel collection
      await db.execute('''
        CREATE TABLE $tableCollection(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      debugPrint(
        'Database upgraded to v5: Recreated collection table WITHOUT "kode".',
      );

      // Mengubah nama tabel Branches menjadi branches (jika sebelumnya ada Branches)
      // Ini penting jika Anda punya tabel bernama Branches, tapi konstanta Anda adalah tableBranch = 'branches'
      // Untuk memastikan konsistensi, jika ada tabel 'Branches' di DB lama, rename ke 'branches'.
      // Cek dulu apakah tabel 'Branches' ada, untuk menghindari error.
      final tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='Branches'",
      );
      if (tableExists.isNotEmpty) {
        await db.execute('ALTER TABLE Branches RENAME TO branches;');
        debugPrint('Renamed table "Branches" to "branches".');
      }

      // Pastikan tabel metadata sudah ada
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableMetadata (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
      debugPrint('Ensured table "metadata" exists in v5 upgrade.');
    }
    debugPrint('Database upgrade complete.');
  }

  // --- Metode Umum untuk Timestamp (menggunakan tableMetadata Anda) ---
  Future<DateTime?> getLastUpdate(String key) async {
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

  Future<void> updateLastUpdate(String key) async {
    final db = await database;
    await db.insert(tableMetadata, {
      'key': key,
      'value': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteLastUpdate(String key) async {
    final db = await database;
    await db.delete(tableMetadata, where: 'key = ?', whereArgs: [key]);
  }

  // --- Metode untuk Jabatan ---
  Future<void> insertJabatans(List<Jabatan> jabatans) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var jabatan in jabatans) {
        await txn.insert(
          tableJabatan,
          jabatan.toJson(), // Menggunakan toJson() Anda
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Jabatan>> getAllJabatan() async {
    // Menggunakan Jabatans (plural) untuk konsistensi
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableJabatan);
    return List.generate(maps.length, (i) {
      return Jabatan.fromJson(maps[i]); // Asumsi ada fromJson
    });
  }

  Future<void> clearJabatans() async {
    // Clear Jabatans
    final db = await database;
    await db.delete(tableJabatan);
  }

  // --- Metode untuk JabatanSFI ---
  Future<void> insertJabatanSFIs(List<JabatanSFI> jabatanSFIs) async {
    // Menggunakan JabatansSFIs (plural)
    final db = await database;
    await db.transaction((txn) async {
      for (var jabatanSFI in jabatanSFIs) {
        await txn.insert(
          tableJabatanSFI,
          jabatanSFI.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<JabatanSFI>> getAllJabatanSFI() async {
    // Menggunakan JabatansSFIs (plural)
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableJabatanSFI);
    return List.generate(maps.length, (i) {
      return JabatanSFI.fromJson(maps[i]); // Asumsi ada fromJson
    });
  }

  Future<void> clearJabatanSFIs() async {
    // Clear JabatanSFIs
    final db = await database;
    await db.delete(tableJabatanSFI);
  }

  // --- Metode untuk Dealer ---
  Future<void> insertDealers(List<Dealer> dealers) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var dealer in dealers) {
        await txn.insert(
          tableDealer,
          dealer.toJson(), // Menggunakan toJson() Anda
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Dealer>> getAllDealer() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableDealer);
    return List.generate(maps.length, (i) {
      return Dealer.fromJson(maps[i]); // Asumsi ada fromJson
    });
  }

  Future<void> clearDealers() async {
    final db = await database;
    await db.delete(tableDealer);
  }

  // --- Metode untuk Branch ---
  Future<void> insertBranches(List<Branch> branches) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var branch in branches) {
        await txn.insert(
          tableBranch,
          branch.toJson(), // Menggunakan toJson() Anda
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Branch>> getAllBranch() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableBranch);
    return List.generate(maps.length, (i) {
      return Branch.fromJson(maps[i]); // Asumsi ada fromJson
    });
  }

  Future<void> clearBranches() async {
    final db = await database;
    await db.delete(tableBranch);
  }

  // --- Metode untuk Product ---
  Future<void> insertProducts(List<Product> products) async {
    // Menggunakan Products (plural)
    final db = await database;
    await db.transaction((txn) async {
      for (var product in products) {
        await txn.insert(
          tableProduct, // Menggunakan konstanta tableProduct
          product.toJson(), // Menggunakan toJson() Anda
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Product>> getAllProduct() async {
    // Menggunakan Products (plural)
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableProduct);
    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]); // Asumsi ada fromJson
    });
  }

  Future<void> clearProducts() async {
    // Clear Products
    final db = await database;
    await db.delete(tableProduct);
  }

  // --- Metode untuk Area ---
  Future<void> insertAreas(List<Area> areas) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var area in areas) {
        await txn.insert(
          tableArea,
          area.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Area>> getAllArea() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableArea);
    return List.generate(maps.length, (i) {
      return Area.fromJson(maps[i]); // Asumsi ada fromJson
    });
  }

  Future<void> clearAreas() async {
    final db = await database;
    await db.delete(tableArea);
  }

  // --- Metode untuk Purpose ---
  Future<void> insertPurposes(List<Purpose> purposes) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var purpose in purposes) {
        await txn.insert(
          tablePurpose,
          purpose.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Purpose>> getAllPurpose() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tablePurpose);
    return List.generate(maps.length, (i) {
      return Purpose.fromJson(maps[i]); // Asumsi ada fromJson
    });
  }

  Future<void> clearPurposes() async {
    final db = await database;
    await db.delete(tablePurpose);
  }

  // --- Metode untuk Type (VisitType) ---
  Future<void> insertTypes(List<Type> types) async {
    // Menggunakan VisitType
    final db = await database;
    await db.transaction((txn) async {
      for (var type in types) {
        await txn.insert(
          tableType,
          type.toJson(), // Menggunakan toJson() Anda
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Type>> getAllType() async {
    // Menggunakan VisitType
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableType);
    return List.generate(maps.length, (i) {
      return Type.fromJson(maps[i]); // Menggunakan fromJson dari VisitType
    });
  }

  Future<void> clearTypes() async {
    final db = await database;
    await db.delete(tableType);
  }

  // --- Metode untuk Collection ---
  Future<void> insertCollections(List<Collection> collections) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var collection in collections) {
        await txn.insert(
          tableCollection, // Menggunakan konstanta tableCollection
          collection.toMap(), // Menggunakan toMap() dari Collection model
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Collection>> getAllCollection() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableCollection);
    return List.generate(maps.length, (i) {
      return Collection.fromJson(
        maps[i],
      ); // Menggunakan fromJson dari Collection
    });
  }

  Future<void> clearCollections() async {
    final db = await database;
    await db.delete(tableCollection);
  }
}
