import 'package:path/path.dart';
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

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'umlalazi_census.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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
        notes TEXT
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // DATABASE MIGRATIONS
  // ---------------------------------------------------------------------------

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE sites ADD COLUMN latitude REAL');

      await db.execute(
          'ALTER TABLE sites ADD COLUMN longitude REAL');

      await db.execute(
          'ALTER TABLE sites ADD COLUMN address TEXT');

      await db.execute(
          'ALTER TABLE sites ADD COLUMN landmark TEXT');

      await db.execute(
          'ALTER TABLE sites ADD COLUMN description TEXT');

      await db.execute(
          'ALTER TABLE sites ADD COLUMN household_head TEXT');

      await db.execute(
          'ALTER TABLE sites ADD COLUMN household_size INTEGER');

      await db.execute(
          'ALTER TABLE sites ADD COLUMN phone_number TEXT');

      await db.execute(
          'ALTER TABLE sites ADD COLUMN services TEXT');

      await db.execute(
          'ALTER TABLE sites ADD COLUMN notes TEXT');
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
      where: 'id = ?',
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
      where: 'id = ?',
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
      where: 'id = ?',
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
        name LIKE ?
        OR village LIKE ?
        OR household_head LIKE ?
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
        ) ??
        0;

    final today = Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(*)
            FROM sites
            WHERE registered_at >= ?
            ''',
            [startOfToday.toIso8601String()],
          ),
        ) ??
        0;

    final week = Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(*)
            FROM sites
            WHERE registered_at >= ?
            ''',
            [startOfWeek.toIso8601String()],
          ),
        ) ??
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
      villageCounts[row['village'] as String] =
          row['cnt'] as int;
    }

    final typeRows = await db.rawQuery('''
      SELECT type,
             COUNT(*) AS cnt
      FROM sites
      GROUP BY type
    ''');

    final Map<SiteType, int> typeCounts = {};

    for (final row in typeRows) {
      typeCounts[
          SiteTypeX.fromString(row['type'] as String)] =
          row['cnt'] as int;
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
      ),
      Site(
        name: 'Thandi Spaza Shop',
        village: 'eSikhawini',
        type: SiteType.business,
        registeredAt: now.subtract(
          const Duration(minutes: 15),
        ),
      ),
      Site(
        name: 'Zion Christian Church',
        village: 'Mandlakazi',
        type: SiteType.church,
        registeredAt: now.subtract(
          const Duration(minutes: 30),
        ),
      ),
      Site(
        name: 'Ulundi Primary School',
        village: 'Ulundi',
        type: SiteType.school,
        registeredAt: now.subtract(
          const Duration(hours: 1),
        ),
      ),
    ];

    for (final site in samples) {
      await insertSite(site);
    }
  }
}