import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dbhelper.dart';
import 'dbhelper2.dart';
import 'config.dart';
import 'quizpage.dart';

class LearningPathPage extends StatefulWidget {
  @override
  _LearningPathPageState createState() => _LearningPathPageState();
}

class _LearningPathPageState extends State<LearningPathPage> {
  String selectedLanguage = 'German';
  String? selectedChapter;
  String? selectedSegment;
  List<String> chapters = [];
  List<String> segments = [];
  List<Map<String, dynamic>> questions = [];
  // This map holds the progress for each chapter (chapter number -> list of completed segment names)
  Map<int, List<String>> progressMap = {};

  @override
  void initState() {
    super.initState();
    DBHelper.database.then((_) {
      fetchChapters();
      loadProgress();
    });
  }

  Future<void> loadProgress() async {
    List<Map<String, dynamic>> progressList = await DBHelper2.getUserProgress();
    Map<int, List<String>> progressByChapter = {};
    for (var progress in progressList) {
      if (progress['language'] == selectedLanguage) {
        int chapterNumber = progress['chapter_number'];
        progressByChapter[chapterNumber] ??= [];
        progressByChapter[chapterNumber]!.add(progress['segment_name']);
      }
    }
    setState(() {
      progressMap = progressByChapter;
    });
  }

  Future<void> fetchChapters() async {
    Map<String, List<String>> chapterData = {
      'German': ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4'],
      'French': ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4'],
      'Spanish': ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4'],
      'Tamil': ['Chapter 1'],
      'Malayalam': ['Chapter 1']
    };
    setState(() {
      chapters = chapterData[selectedLanguage] ?? [];
      selectedChapter = null;
      selectedSegment = null;
      segments = [];
      questions = [];
    });
  }

  Future<void> fetchSegments(String chapter) async {
    Map<String, List<String>> segmentData = {
      'Chapter 1': ['Introduction', 'Numbers and Days', 'Basic Sentences'],
      'Chapter 2': ['Directions', 'Weather', 'Shopping'],
      'Chapter 3': ['Grammar', 'Vocabulary', 'Conversation'],
      'Chapter 4': ['Advanced Topics', 'Culture', 'Review']
    };
    setState(() {
      selectedChapter = chapter;
      segments = segmentData[chapter] ?? [];
      selectedSegment = null;
      questions = [];
    });
  }

  Future<void> fetchQuestions(String segment) async {
    // Only allow fetching if the segment is unlocked
    print("Sending");
    print(selectedLanguage);
    print(chapters.indexOf(selectedChapter!) + 1);
    print(segment);
    final response = await http.post(
      Uri.parse('$baseUrl/get_questions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "language": selectedLanguage,
        "chapter_number": chapters.indexOf(selectedChapter!) + 1,
        "segment_name": segment
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      if (decodedResponse is Map<String, dynamic> &&
          decodedResponse.containsKey('questions')) {
        List<Map<String, dynamic>> fetchedQuestions =
        List<Map<String, dynamic>>.from(decodedResponse['questions']);
        // Save questions locally using your DBHelper
        await DBHelper.storeQuestionsLocally(fetchedQuestions, selectedChapter!, segment);
        setState(() {
          selectedSegment = segment;
          questions = fetchedQuestions;
        });
      }
    }
  }

  Future<void> startQuiz() async {
    if (selectedChapter == null || selectedSegment == null) return;

    List<Map<String, dynamic>> storedQuestions = await DBHelper.getStoredQuestions(
      selectedChapter!, selectedSegment!,
    );

    if (storedQuestions.isNotEmpty && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizPage(
            questions: storedQuestions,
            language: selectedLanguage,
            chapterNumber: chapters.indexOf(selectedChapter!) + 1,
            segmentNumber: segments.indexOf(selectedSegment!) + 1,
          ),
        ),
      );
    }
  }

  // Returns true if the chapter at index is unlocked.
  // Chapter 1 is always unlocked. Other chapters are unlocked only if the previous chapter has all 3 segments completed.
  bool isChapterUnlocked(int chapterIndex) {
    if (chapterIndex == 0) return true;
    int previousChapterNumber = chapterIndex; // because chapters are 0-indexed, but stored as 1-indexed
    List<String>? previousProgress = progressMap[previousChapterNumber];
    // Assuming each chapter has 3 segments
    return previousProgress != null && previousProgress.length >= 3;
  }

  // Returns true if the segment at segmentIndex is unlocked.
  // Only the immediate next segment (after the completed ones) is unlocked.
  bool isSegmentUnlocked(int segmentIndex) {
    int chapterNumber = chapters.indexOf(selectedChapter!) + 1;
    int completedCount = progressMap[chapterNumber]?.length ?? 0;
    // A segment is unlocked if it is the immediate next one (and not already completed)
    return segmentIndex == completedCount && completedCount < segments.length;
  }

  // Returns true if the segment is already completed.
  bool isSegmentCompleted(int segmentIndex) {
    int chapterNumber = chapters.indexOf(selectedChapter!) + 1;
    int completedCount = progressMap[chapterNumber]?.length ?? 0;
    return segmentIndex < completedCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E161C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E161C),
        iconTheme: const IconThemeData(color: Colors.white), // Back arrow color
        title: Row(
          children: [
            Image.asset(
              'images/logo.png',
              height: 48,
            ),
            const SizedBox(width: 10), // Space between logo and title
            const Text(
              'Learning Path',
              style: TextStyle(
                fontFamily: 'Aurore', // Aurore font
                color: Colors.white,
                fontSize: 22, // Adjust size if needed,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language Dropdown
            DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: Color(0xFF0E161C),
              style: TextStyle(fontFamily: "Crimson", color: Colors.white),
              items: ['German', 'French', 'Spanish', 'Tamil', 'Malayalam']
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (lang) {
                setState(() {
                  selectedLanguage = lang!;
                  fetchChapters();
                  loadProgress();
                });
              },
            ),
            // Chapters ListView
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  bool unlocked = isChapterUnlocked(index);
                  return GestureDetector(
                    onTap: unlocked ? () => fetchSegments(chapters[index]) : null,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? (selectedChapter == chapters[index]
                            ? Color(0xFFE5B28C)
                            : Colors.blueGrey)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              chapters[index],
                              style: TextStyle(
                                  fontFamily: "Crimson",
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (!unlocked) ...[
                              SizedBox(width: 8),
                              Icon(Icons.lock, color: Colors.white),
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Segments ListView (only if a chapter is selected)
            if (segments.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: segments.length,
                  itemBuilder: (context, index) {
                    bool unlocked = isSegmentUnlocked(index);
                    bool completed = isSegmentCompleted(index);
                    return GestureDetector(
                      onTap: unlocked ? () => fetchQuestions(segments[index]) : null,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: completed
                              ? Colors.green
                              : unlocked ? Colors.teal : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                segments[index],
                                style: TextStyle(
                                    fontFamily: "Crimson",
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (!unlocked) ...[
                                SizedBox(width: 8),
                                Icon(Icons.lock, color: Colors.white),
                              ]
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (questions.isNotEmpty)
              ElevatedButton(
                onPressed: startQuiz,
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE5B28C)),
                child: Text('Start Quiz', style: TextStyle(fontFamily: "Crimson", color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
