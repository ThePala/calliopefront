import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExtractTextPage extends StatefulWidget {
  final File image;

  ExtractTextPage({required this.image});

  @override
  _ExtractTextPageState createState() => _ExtractTextPageState();
}

class _ExtractTextPageState extends State<ExtractTextPage> {
  String _graphHtml = '';
  bool _showGraph = false;
  bool _isLoading = false;
  String _extractedText = '';
  int _characterCount = 0;
  int _wordCount = 0;
  List<MapEntry<String, int>> _top5 = [];
  List<MapEntry<String, int>> _bottom5 = [];
  String _feedback = '';

  Widget _buildGraphWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
      <html>
      <head>
        <style>
          body {
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100%;
          }

          canvas, svg {
            width: 200% !important;
            height: 110% !important;
          }
        </style>
      </head>
      <body>
        <div>
          ${_graphHtml}
        </div>
      </body>
      </html>
    ''');

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      child: WebViewWidget(controller: controller),
    );
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('$baseUrl/analyze_text');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('user_file', widget.image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);

        setState(() {
          _extractedText = jsonResponse['extracted text'] ?? '';
          _characterCount = jsonResponse['character_count'] ?? 0;
          _wordCount = jsonResponse['word_count'] ?? 0;
          _feedback = jsonResponse['feedback'] ?? '';

          final top5List = (jsonResponse['top_5'] as List?) ?? [];
          final bottom5List = (jsonResponse['bottom_5'] as List?) ?? [];
          final scores = (jsonResponse['scores'] as Map<String, dynamic>?) ?? {};

          _top5 = top5List
              .where((letter) => letter is String && scores.containsKey(letter))
              .map((letter) => MapEntry(letter as String, scores[letter] as int))
              .toList();

          _bottom5 = bottom5List
              .where((letter) => letter is String && scores.containsKey(letter))
              .map((letter) => MapEntry(letter as String, scores[letter] as int))
              .toList();
        });

        // Fetch graph
        final graphResponse = await http.get(Uri.parse('$baseUrl/graph'));
        if (graphResponse.statusCode == 200) {
          setState(() {
            _graphHtml = graphResponse.body;
            _showGraph = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load graph')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _viewFullImage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(child: Image.file(widget.image)),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E161C),
      appBar: AppBar(
        backgroundColor: Color(0xFF0E161C),
        title: Row(
          children: [
            Image.asset('images/logo.png', height: 50),
            SizedBox(width: 20),
            Text('Handwriting',
                style: TextStyle(
                    fontFamily: 'Aurore', fontSize: 36, color: Colors.white)),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onDoubleTap: _viewFullImage,
                    child: Image.file(widget.image, height: 300),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: const BorderSide(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Retake',
                            style: TextStyle(
                                color: Color(0xFFE5B28C),
                                fontFamily: 'Crimson',
                                fontSize: 20)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _uploadImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: const BorderSide(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                        ),
                        child: const Text('Analyze',
                            style: TextStyle(
                                color: Color(0xFFE5B28C),
                                fontFamily: 'Crimson',
                                fontSize: 20)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Extracted Text:',
                    style: TextStyle(
                        fontFamily: "Crimson",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE5B28C))),
                Text(_extractedText,
                    style: TextStyle(
                        fontFamily: "Crimson", fontSize: 18, color: Colors.white)),
                const Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Top 5 Letters:',
                              style: TextStyle(
                                  fontFamily: "Crimson",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE5B28C))),
                          ..._top5.map((e) => Text('${e.key}: ${e.value}',
                              style: TextStyle(
                                  fontFamily: "Crimson",
                                  fontSize: 18,
                                  color: Colors.white))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bottom 5 Letters:',
                              style: TextStyle(
                                  fontFamily: "Crimson",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE5B28C))),
                          ..._bottom5.map((e) => Text('${e.key}: ${e.value}',
                              style: TextStyle(
                                  fontFamily: "Crimson",
                                  fontSize: 18,
                                  color: Colors.white))),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const Text('Feedback:',
                    style: TextStyle(
                        fontFamily: "Crimson",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE5B28C))),
                Text(_feedback,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontFamily: "Crimson", fontSize: 18, color: Colors.white)),
                const SizedBox(height: 20),
                const Text('Graph:',
                    style: TextStyle(
                        fontFamily: "Crimson",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE5B28C))),
                if (_showGraph) _buildGraphWebView(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFE5B28C)),
              ),
            ),
        ],
      ),
    );
  }
}
