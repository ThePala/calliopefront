import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // Getter to initialize the database if it's not already initialized
  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'questions.db'),
      version: 2, // 🔹 Updated version to 2 to trigger upgrade
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE questions ("
                "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                "question TEXT, "
                "options TEXT, "  // 🔹 Added options field
                "answer TEXT, "
                "chapter TEXT, "
                "segment TEXT)"
        );
        print("Database created.");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE questions ADD COLUMN options TEXT");
          print("Database upgraded to version 2.");
        }
      },
    );

    print("Database initialized.");
    return _database!;
  }

  // Store fetched questions into the database
  static Future<void> storeQuestionsLocally(
      List<Map<String, dynamic>> questions, String chapter, String segment) async {
    final db = await database; // Use the getter

    for (var question in questions) {
      List<String> options = [];

      // Ensure correct_answer and wrong_answers exist
      if (question.containsKey('correct_answer')) {
        options.add(question['correct_answer']);
      }
      if (question.containsKey('wrong_answers') && question['wrong_answers'] is List) {
        options.addAll(List<String>.from(question['wrong_answers']));
      }

      // Convert options list to a JSON string
      String optionsJson = jsonEncode(options);

      await db.insert(
        'questions',
        {
          'id': question['id'],
          'chapter': chapter,
          'segment': segment,
          'question': question['question_text'],
          'options': optionsJson,  // Store as a JSON string
          'answer': question['correct_answer'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Fetch stored questions from the database
  static Future<List<Map<String, dynamic>>> getStoredQuestions(
      String chapter, String segment) async {
    final db = await database; // Use the getter
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'chapter = ? AND segment = ?',
      whereArgs: [chapter, segment],
    );

    return List<Map<String, dynamic>>.from(maps.map((question) {
      return {
        'id': question['id'],
        'question': question['question'],
        'options': jsonDecode(question['options'] ?? '[]'), // Handle null case
        'answer': question['answer'],
      };
    }));
  }

  static Future<void> clearQuestionsTable() async {
    final db = await database;
    await db.delete('questions');
    print("All questions deleted.");
  }
}
