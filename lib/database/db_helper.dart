import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/site.dart';

/// Singleton wrapper around the local SQLite database.
///
/// Android & iOS only.
/// Offline-first architecture.
class DBHelper {
  DBHelper._internal();

  static final DBHelper instance = DBHelper._internal();

  static Database? _db;
  static Future<Database>? _dbFuture;

  Future<Database> get database async {
    if (_db!= null) return _db!;
    _dbFuture??= _initDb();
    _db = await _dbFuture!;
    return _db!;
  }

  static const String _dbFileName = 'umlalazi_census.db';
  static const String _backupFolderName = 'db_backups';
  static const String _exportFolderName = 'db_exports';

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbFileName);

    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<String> get _currentDatabasePath async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbFileName);
  }

  Future<Directory> _storageDirectory() async {
    final external = await getExternalStorageDirectory();
    if (external!= null) {
      return external;
    }
    return getApplicationDocumentsDirectory();
  }

  Future<Directory> _ensureDirectory(String folderName) async {
    final baseDir = await _storageDirectory();
    final dir = Directory(join(baseDir.path, folderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> exportDatabase() async {
    final sourcePath = await _currentDatabasePath;
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Database file not found.');
    }

    final exportDir = await _ensureDirectory(_exportFolderName);
    final targetPath = join(
      exportDir.path,
      'database_export_${DateTime.now().millisecondsSinceEpoch}.db',
    );
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  Future<String> backupDatabase() async {
    final sourcePath = await _currentDatabasePath;
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Database file not found.');
    }

    final backupDir = await _ensureDirectory(_backupFolderName);
    final targetPath = join(
      backupDir.path,
      'database_backup_${DateTime.now().millisecondsSinceEpoch}.db',
    );
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  Future<List<String>> getBackupFiles() async {
    final backupDir = await _ensureDirectory(_backupFolderName);
    final files = backupDir
       .listSync()
       .whereType<File>()
       .where((file) => file.path.toLowerCase().endsWith('.db'))
       .toList();

    files.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );

    return files.map((file) => file.path).toList();
  }

  Future<String?> restoreLatestBackup() async {
    final backupFiles = await getBackupFiles();
    if (backupFiles.isEmpty) {
      return null;
    }

    await close();

    final currentDbPath = await _currentDatabasePath;
    final currentDbFile = File(currentDbPath);
    final latestBackup = File(backupFiles.first);

    if (await currentDbFile.exists()) {
      await currentDbFile.delete();
    }

    await latestBackup.copy(currentDbPath);
    _db = null;
    _dbFuture = null;
    await database;
    return latestBackup.path;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _dbFuture = null;
  }

  // ---------------------------------------------------------------------------
  // CREATE DATABASE
  // ---------------------------------------------------------------------------

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        village TEXT NOT NULL,
        type TEXT NOT NULL,
        registered_at TEXT NOT NULL,
        image_path TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        landmark TEXT,
        description TEXT,
        household_head TEXT,
        household_size INTEGER,
        phone_number TEXT,
        services TEXT,
        notes TEXT,
        site_code TEXT,
        province TEXT,
        district TEXT,
        municipality TEXT,
        ward TEXT,
        traditional_authority TEXT,
        section TEXT,
        distance_from_landmark REAL,
        directions TEXT
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // DATABASE MIGRATIONS
  // ---------------------------------------------------------------------------

  Future<bool> _columnExists(Database db, String table, String column) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((row) => row['name'] == column);
  }

  Future<void> _addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    if (!await _columnExists(db, table, column)) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // v1 -> v2: Add location + household fields
    if (oldVersion < 2) {
      await _addColumnIfNotExists(db, 'sites', 'latitude', 'REAL');
      await _addColumnIfNotExists(db, 'sites', 'longitude', 'REAL');
      await _addColumnIfNotExists(db, 'sites', 'address', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'landmark', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'description', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'household_head', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'household_size', 'INTEGER');
      await _addColumnIfNotExists(db, 'sites', 'phone_number', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'services', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'notes', 'TEXT');
    }

    // v2 -> v3: Add admin boundary fields
    if (oldVersion < 3) {
      await _addColumnIfNotExists(db, 'sites', 'site_code', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'province', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'district', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'municipality', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'ward', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'traditional_authority', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'section', 'TEXT');
      await _addColumnIfNotExists(db, 'sites', 'distance_from_landmark', 'REAL');
      await _addColumnIfNotExists(db, 'sites', 'directions', 'TEXT');
    }
  }

  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------

  Future<int> insertSite(Site site) async {
    final db = await database;

    return db.insert(
      'sites',
      site.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  Future<int> updateSite(Site site) async {
    final db = await database;

    return db.update(
      'sites',
      site.toMap(),
      where: 'id =?',
      whereArgs: [site.id],
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  Future<int> deleteSite(int id) async {
    final db = await database;

    return db.delete(
      'sites',
      where: 'id =?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // GET ALL
  // ---------------------------------------------------------------------------

  Future<List<Site>> getAllSites({int? limit}) async {
    final db = await database;

    final rows = await db.query(
      'sites',
      orderBy: 'registered_at DESC',
      limit: limit,
    );

    return rows.map((e) => Site.fromMap(e)).toList();
  }

  // ---------------------------------------------------------------------------
  // GET BY ID
  // ---------------------------------------------------------------------------

  Future<Site?> getSite(int id) async {
    final db = await database;

    final rows = await db.query(
      'sites',
      where: 'id =?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Site.fromMap(rows.first);
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  Future<List<Site>> searchSites(String query) async {
    final db = await database;

    final rows = await db.query(
      'sites',
      where: '''
        name LIKE?
        OR village LIKE?
        OR household_head LIKE?
      ''',
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
      ],
      orderBy: 'registered_at DESC',
    );

    return rows.map((e) => Site.fromMap(e)).toList();
  }

  // ---------------------------------------------------------------------------
  // DASHBOARD STATS
  // ---------------------------------------------------------------------------

  Future<DashboardStats> getDashboardStats() async {
    final db = await database;

    final now = DateTime.now();

    final startOfToday = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final startOfWeek = startOfToday.subtract(
      Duration(days: now.weekday - 1),
    );

    final total = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM sites',
          ),
        )??
        0;

    final today = Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(*)
            FROM sites
            WHERE registered_at >=?
            ''',
            [startOfToday.toIso8601String()],
          ),
        )??
        0;

    final week = Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(*)
            FROM sites
            WHERE registered_at >=?
            ''',
            [startOfWeek.toIso8601String()],
          ),
        )??
        0;

    final villageRows = await db.rawQuery('''
      SELECT village,
             COUNT(*) AS cnt
      FROM sites
      GROUP BY village
      ORDER BY cnt DESC
    ''');

    final Map<String, int> villageCounts = {};

    for (final row in villageRows) {
      final village = row['village']?.toString()?? '';
      final count = row['cnt'] is int
         ? row['cnt'] as int
          : int.tryParse(row['cnt']?.toString()?? '')?? 0;
      if (village.isNotEmpty) {
        villageCounts[village] = count;
      }
    }

    final typeRows = await db.rawQuery('''
      SELECT type,
             COUNT(*) AS cnt
      FROM sites
      GROUP BY type
    ''');

    final Map<SiteType, int> typeCounts = {};

    for (final row in typeRows) {
      final typeValue = row['type']?.toString()?? '';
      final typeCount = row['cnt'] is int
         ? row['cnt'] as int
          : int.tryParse(row['cnt']?.toString()?? '')?? 0;
      typeCounts[SiteTypeX.fromString(typeValue)] = typeCount;
    }

    return DashboardStats(
      totalSites: total,
      registeredToday: today,
      registeredThisWeek: week,
      villageCount: villageCounts.length,
      countsByType: typeCounts,
      countsByVillage: villageCounts,
    );
  }

  // ---------------------------------------------------------------------------
  // DEMO DATA
  // ---------------------------------------------------------------------------

  Future<void> seedIfEmpty() async {
    final existing = await getAllSites(limit: 1);

    if (existing.isNotEmpty) return;

    final now = DateTime.now();

    final samples = [
      Site(
        name: 'Dlamini Residence',
        village: 'KwaMbonambi',
        type: SiteType.house,
        registeredAt: now,
        siteCode: '',
        province: '',
        district: '',
        municipality: '',
        ward: '',
        traditionalAuthority: '',
        section: '',
        directions: '',
      ),
      Site(
        name: 'Thandi Spaza Shop',
        village: 'eSikhawini',
        type: SiteType.business,
        registeredAt: now.subtract(
          const Duration(minutes: 15),
        ),
        siteCode: '',
        province: '',
        district: '',
        municipality: '',
        ward: '',
        traditionalAuthority: '',
        section: '',
        directions: '',
      ),
      Site(
        name: 'Zion Christian Church',
        village: 'Mandlakazi',
        type: SiteType.church,
        registeredAt: now.subtract(
          const Duration(minutes: 30),
        ),
        siteCode: '',
        province: '',
        district: '',
        municipality: '',
        ward: '',
        traditionalAuthority: '',
        section: '',
        directions: '',
      ),
      Site(
        name: 'Ulundi Primary School',
        village: 'Ulundi',
        type: SiteType.school,
        registeredAt: now.subtract(
          const Duration(hours: 1),
        ),
        siteCode: '',
        province: '',
        district: '',
        municipality: '',
        ward: '',
        traditionalAuthority: '',
        section: '',
        directions: '',
      ),
    ];

    for (final site in samples) {
      await insertSite(site);
    }
  }
}