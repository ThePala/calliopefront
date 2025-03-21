import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'main.dart'; // Replace with actual main.dart widget
import 'handwritingpage.dart';
import 'learningpath.dart';
import 'translatepage.dart';
import 'speech_analysis.dart';
import 'dictionary.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E161C),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenHeight = constraints.maxHeight;
          double topPadding = screenHeight * 0.06;
          double topPadding2 = screenHeight * 0.1;
          double streakPosition = screenHeight * 0.25;
          double buttonStartPosition = screenHeight * 0.50;

          return Stack(
            children: [
              // Logout Icon at Top-Right
              Positioned(
                top: topPadding,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ),

              // Logo
              Positioned(
                top: topPadding,
                left: 70,
                child: Image.asset('images/logo.png', width: 100, height: 100),
              ),

              Positioned(
                top: topPadding2,
                left: 200,
                child: const Text(
                  'Calliope',
                  style: TextStyle(fontFamily: "Aurore", color: Colors.white, fontSize: 36),
                ),
              ),

              // Streak box
              Positioned(
                top: streakPosition,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color(0x15B8B8B8),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Daily Goals',
                        style: TextStyle(
                          color: Color(0xFFE5B28C),
                          fontSize: 24,
                          fontFamily: 'Crimson',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_box, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '5 minutes per day',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Crimson',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons
              Positioned(
                top: buttonStartPosition,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Learning Path
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildRoundedButton(context, 'Learning Path', fullWidth: true, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LearningPathPage()),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // First Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRoundedButton(context, 'Translate', onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TranslatePage()),
                          );
                        }),
                        const SizedBox(width: 15),
                        Stack(
                          children: [
                            _buildRoundedButton(context, 'Writing', onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HandwritingPage()),
                              );
                            }),
                            Positioned(
                              right: 10,
                              top: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'New!',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Second Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRoundedButton(context, 'Speaking', onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UploadAudioScreen()),
                          );
                        }),
                        const SizedBox(width: 15),
                        _buildRoundedButton(context, 'Dictionary', onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DictionaryPage()),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoundedButton(BuildContext context, String text, {VoidCallback? onTap, bool fullWidth = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? 350 : 175,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE5B28C),
              fontSize: 36,
              fontFamily: 'Crimson',
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0E161C),
          title: const Text(
            "Confirm Logout",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // Delete cur_mobile.txt
                try {
                  final directory = await getApplicationDocumentsDirectory();
                  final file = File('${directory.path}/cur_mobile.txt');
                  if (await file.exists()) {
                    await file.delete();
                  }
                } catch (e) {
                  print('Error deleting file: $e');
                }

                // Delete both databases
                try {
                  var databasesPath = await getDatabasesPath();
                  await deleteDatabase('$databasesPath/questions.db');
                  await deleteDatabase('$databasesPath/user_progress.db');
                } catch (e) {
                  print('Error deleting databases: $e');
                }

                // Navigate back to MainPage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginRegisterPage()), // Replace MainPage
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
