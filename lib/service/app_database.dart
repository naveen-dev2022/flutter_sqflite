import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/diary_entry.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  AppDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('diary_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT NOT NULL,
        date TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_favorite INTEGER NOT NULL
      )
    ''');
  }

  /// Insert
  Future<int> create(DiaryEntry entry) async {
    final db = await instance.database;
    return db.insert('diary', entry.toMap());
  }

  Future<List<DiaryEntry>> readAllEntries({
    String? searchQuery,
    String? moodFilter,
    bool onlyFavorites = false,
  }) async {
    final db = await instance.database;

    String where = '';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      where += 'title LIKE ? OR content LIKE ?';
      whereArgs.addAll(['%$searchQuery', '%$searchQuery']);
    }

    if (moodFilter != null && moodFilter.isNotEmpty && moodFilter != 'All') {
      if (where.isNotEmpty) where += ' AND ';
      where += 'mood = ?';
      whereArgs.add(moodFilter);
    }

    if (onlyFavorites) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'is_favorite = 1';
      // 1 means → favorite (true)
      // 0 means → not favorite (false)
    }

    final result = await db.query(
      'diary',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    return result.map((json) => DiaryEntry.fromMap(json)).toList();
  }

  Future<int> update(DiaryEntry entry) async {
    final db = await instance.database;
    return await db.update(
      'diary',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete('diary', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
