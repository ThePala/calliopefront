import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper2 {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'user_progress.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            chapter_number INTEGER,
            language TEXT,
            segment_name TEXT,
            scores INTEGER
          )
        ''');
      },
    );
  }

  // Insert progress data
  static Future<void> insertProgress(Map<String, dynamic> progress) async {
    final db = await database;
    await db.insert('user_progress', progress, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Clear progress table
  static Future<void> clearProgress() async {
    final db = await database;
    await db.delete('user_progress');
  }

  // Fetch all progress
  static Future<List<Map<String, dynamic>>> getUserProgress() async {
    final db = await database;
    return await db.query('user_progress');
  }
}