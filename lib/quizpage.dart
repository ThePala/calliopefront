import 'package:flutter/material.dart';
import 'dart:math';
import 'config.dart';
import 'dbhelper.dart'; // Import your DBHelper
import 'dbhelper2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'learningpath.dart';

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String language;
  final int chapterNumber;
  final int segmentNumber;

  QuizPage({
    required this.questions,
    required this.language,
    required this.chapterNumber,
    required this.segmentNumber,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  int lives = 3;
  List<String> shuffledOptions = [];
  String? selectedAnswer;
  bool submitted = false;
  String correctAnswer = '';

  @override
  void initState() {
    super.initState();
    _shuffleOptions();
  }

  void _shuffleOptions() {
    if (widget.questions.isNotEmpty) {
      correctAnswer = widget.questions[currentQuestionIndex]['answer'];
      shuffledOptions = List<String>.from(widget.questions[currentQuestionIndex]['options'] ?? []);
      shuffledOptions.shuffle(Random());
    }
  }
  Future<void> sendProgressToBackend(String mobileNumber) async {
    final url = Uri.parse('$baseUrl/save_progress');

    final body = {
      "mobile_number": mobileNumber,
      "language": widget.language,
      "chapter_number": widget.chapterNumber,
      "segment_name": getSegmentName(), // <-- here
      "scores": score,
    };

    print(body);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Progress sent successfully!");
      } else {
        print("Failed to send progress: ${response.body}");
      }
    } catch (e) {
      print("Error sending progress: $e");
    }
  }

  void _showFailurePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Failed", style: TextStyle(fontFamily: "Crimson", color: Color(0xFFE5B28C))),
        content: const Text("You have lost all lives. Try again!",
            style: TextStyle(fontFamily: "Crimson", color: Color(0xFFE5B28C))),
        backgroundColor: const Color(0xFF0E161C),
        actions: [
          TextButton(
            onPressed: () async {
              await Future.delayed(const Duration(milliseconds: 400));
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LearningPathPage()),
                    (Route<dynamic> route) => false,
              );
            },

            child: Text("OK", style: TextStyle(fontFamily: "Crimson", color: Color(0xFFE5B28C))),
          ),
        ],
      ),
    );
  }

  void submitAnswer() {
    if (!submitted) {
      setState(() {
        if (selectedAnswer != correctAnswer) {
          lives--;
        } else {
          score++;
        }
        submitted = true;
      });

      if (lives == 0) {
        _showFailurePopup();
      }
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        submitted = false;
        _shuffleOptions();
      });
    } else {
      _showResult();
    }
  }

  final Map<String, List<String>> chapterSegments = {
    'Chapter 1': ['Introduction', 'Numbers and Days', 'Basic Sentences'],
    'Chapter 2': ['Directions', 'Weather', 'Shopping'],
    'Chapter 3': ['Grammar', 'Vocabulary', 'Conversation'],
    'Chapter 4': ['Advanced Topics', 'Culture', 'Review']
  };

  String getSegmentName() {
    String chapterKey = 'Chapter ${widget.chapterNumber}';
    if (chapterSegments.containsKey(chapterKey) &&
        widget.segmentNumber > 0 &&
        widget.segmentNumber <= chapterSegments[chapterKey]!.length) {
      return chapterSegments[chapterKey]![widget.segmentNumber - 1]; // Subtract 1 since list is 0-indexed
    }
    return "Segment ${widget.segmentNumber}";
  }

  void _showResult() async {
    // Clear questions table
    await DBHelper.clearQuestionsTable();

    // Insert progress locally
    Map<String, dynamic> progress = {
      'chapter_number': widget.chapterNumber,
      'language': widget.language,
      'segment_name': getSegmentName(), // <-- here
      'scores': score,
    };
    await DBHelper2.insertProgress(progress);
    print("Progress saved locally: $progress");

    // Read mobile number
    String? mobileNumber = await readMobileNumber();
    print("Mobile number: $mobileNumber");

    // Send progress to backend
    if (mobileNumber != null) {
      await sendProgressToBackend(mobileNumber);
    }

    // Show result dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Completed", style: TextStyle(fontFamily: "Crimson", color: Color(0xFFE5B28C))),
        content: Text("Your score: $score / ${widget.questions.length}",
            style: const TextStyle(fontFamily: "Crimson", color: Color(0xFFE5B28C))),
        backgroundColor: Color(0xFF0E161C),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK", style: TextStyle(fontFamily: "Crimson", color: Color(0xFFE5B28C))),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFF0E161C),
        appBar: AppBar(title: const Text("Quiz", style: TextStyle(fontFamily: "Crimson"))),
        body: const Center(
          child: Text("No questions available.", style: TextStyle(color: Color(0xFFE5B28C), fontSize: 18, fontFamily: "Crimson")),
        ),
      );
    }

    String questionText = widget.questions[currentQuestionIndex]['question'] ?? "No question available.";

    return Scaffold(
      backgroundColor: Color(0xFF0E161C),
      appBar: AppBar(
        title: Text("Quiz", style: TextStyle(fontFamily: "Crimson")),
        actions: [
          Row(
            children: List.generate(3, (index) {
              return Icon(
                index < lives ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              );
            }),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${currentQuestionIndex + 1}/${widget.questions.length}",
              style: TextStyle(fontSize: 28, fontFamily: "Aurore", color: Color(0xFFE5B28C)),
            ),
            SizedBox(height: 16),
            Text(
              questionText,
              style: TextStyle(fontSize: 34, fontFamily: "Crimson", color: Color(0xFFFFFFFF)),
            ),
            SizedBox(height: 100),
            Expanded(
              child: shuffledOptions.isEmpty
                  ? Text("No options available.", style: TextStyle(color: Colors.red, fontFamily: "Crimson"))
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: shuffledOptions.length,
                itemBuilder: (context, index) {
                  String option = shuffledOptions[index];
                  bool isCorrect = option == correctAnswer;
                  bool isSelected = option == selectedAnswer;

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: submitted
                          ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Color(0xFF0E161C)))
                          : (isSelected ? Colors.blueGrey : Color(0xFF0E161C)),
                      foregroundColor: submitted
                          ? (isCorrect ? Colors.white : (isSelected ? Colors.white : Color(0xFFE5B28C)))
                          : Color(0xFFE5B28C),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    onPressed: submitted
                        ? null
                        : () {
                      setState(() {
                        selectedAnswer = option;
                      });
                    },
                    child: Text(
                      option,
                      style: TextStyle(
                        fontFamily: "Crimson",
                        fontSize: 22,
                        color: submitted
                            ? (isCorrect ? Color(0xFF39EF2E) : (isSelected ? Color(0xFFEF2E2E) : Color(0xFFE5B28C)))
                            : Color(0xFFE5B28C),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (!submitted)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.check, color: Color(0xFFE5B28C), size: 32),
                  onPressed: selectedAnswer != null ? submitAnswer : null,
                ),
              ),
            if (submitted)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward, color: Color(0xFFE5B28C), size: 32),
                  onPressed: nextQuestion,
                ),
              ),
          ],
        ),
      ),
    );
  }
}