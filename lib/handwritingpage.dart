import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:calliope2/extracttext.dart';

class HandwritingPage extends StatefulWidget {
  @override
  _HandwritingPageState createState() => _HandwritingPageState();
}

class _HandwritingPageState extends State<HandwritingPage> {
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExtractTextPage(image: _image!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E161C),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Handwriting Title in the Same Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/logo.png', // Replace with the actual image path
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Handwriting',
                      style: TextStyle(
                        fontFamily: "Aurore",
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        // Info icon functionality can be added here
                      },
                      icon: const Icon(
                        Icons.info,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                // Information Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'First time using our Handwriting AI?',
                          style: TextStyle(
                            fontSize: 26,
                            fontFamily: 'Crimson',
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Write this text to let us know about your handwriting',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Crimson',
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '“A quick brown fox\njumps over a lazy dog”',
                          style: TextStyle(
                            fontSize: 22,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Crimson',
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Using this, we can\n\n'
                              'Help improve your handwriting\n'
                              'Focus on your mistakes\n'
                              'Provide detailed stroke analysis',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Crimson',
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: const Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Crimson',
                          color: Color(0xFFE5B28C), // E5B28C color
                        ),
                      ),
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Colors.white), // White Stroke
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        'Take a Photo',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Crimson',
                          color: Color(0xFFE5B28C), // E5B28C color
                        ),
                      ),
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Colors.white), // White Stroke
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // White Back Button Positioned at the Top Left
          Positioned(
            top: 40, // Adjust based on safe area
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

}
