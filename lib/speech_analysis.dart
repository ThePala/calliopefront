import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'config.dart';

class UploadAudioScreen extends StatefulWidget {
  @override
  _UploadAudioScreenState createState() => _UploadAudioScreenState();
}

class _UploadAudioScreenState extends State<UploadAudioScreen> {
  String? _fileName;
  File? _audioFile;
  Map<String, dynamic>? _analysisResponse;
  String? _textResponse;
  bool _isLoading = false;

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac'],
    );

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadAudioFile() async {
    if (_audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an audio file first!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.parse('$baseUrl/analyze_speech');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', _audioFile!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        setState(() {
          _analysisResponse = jsonResponse["analysis"];
          _textResponse = jsonResponse["text"];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload audio file.')),
        );
      }
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading audio file.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E161C),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            SizedBox(width: 35),
            Image.asset('images/logo.png', width: 70),
            SizedBox(width: 15),
            Text(
              'Speech',
              style: TextStyle(fontFamily: "Aurore", color: Colors.white, fontSize: 36),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            SizedBox(height: 30),
            Center( // Wrap in Center widget
              child: ElevatedButton(
                onPressed: _isLoading ? null : _pickAudioFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE5B28C),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Crimson'),
                ),
                child: Text('Pick Audio File'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                _fileName != null ? 'Selected file: $_fileName' : 'No file selected.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Crimson', color: Colors.white),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadAudioFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Crimson'),
                ),
                child: Text('Upload Audio'),
              ),
            ),
              SizedBox(height: 30),
              if (_isLoading)
                CircularProgressIndicator(
                  color: Color(0xFFE5B28C),
                ),
              SizedBox(height: 30),
              if (_analysisResponse != null)
                Card(
                  elevation: 4,
                  color: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Analysis Result:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Crimson', color: Color(0xFFE5B28C))),
                        const Divider(color: Color(0xFFE5B28C)),
                        const SizedBox(height: 10),
                        Text('Fluency: ${_analysisResponse!["fluency"]}',
                            style: TextStyle(fontSize: 16, fontFamily: 'Crimson', color: Colors.white)),
                        SizedBox(height: 10),
                        Text('Grammar: ${_analysisResponse!["grammar"]}',
                            style: TextStyle(fontSize: 16, fontFamily: 'Crimson', color: Colors.white)),
                        SizedBox(height: 10),
                        Text('Pronunciation: ${_analysisResponse!["pronunciation"]}',
                            style: TextStyle(fontSize: 16, fontFamily: 'Crimson', color: Colors.white)),
                        SizedBox(height: 20),
                        Text('Extracted Text:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Crimson', color: Color(0xFFE5B28C))),
                        SizedBox(height: 10),
                        Text(_textResponse ?? 'No text extracted.',
                            style: TextStyle(fontSize: 16, fontFamily: 'Crimson', color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 30), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }
}
