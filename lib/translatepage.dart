import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class TranslatePage extends StatefulWidget {
  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String selectedLanguage = "French"; // Default language
  String translatedText = "";
  TextEditingController inputController = TextEditingController();
  bool isLoading = false; // Loading state

  final List<String> languages = [
    "French", "Italian", "Spanish", "Portuguese", "Romanian",
    "German", "Dutch", "Swedish", "Norwegian", "Danish", "Finnish",
    "Polish", "Hungarian", "Czech", "Slovak", "Tamil", "Telugu",
    "Malayalam", "Kannada", "Hindi", "Bengali"
  ];

  Future<void> translateText() async {
    String inputText = inputController.text.trim();
    if (inputText.isEmpty) return;

    setState(() {
      isLoading = true;
      translatedText = ""; // Clear old text when loading
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": inputText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          translatedText = data['translations'][selectedLanguage] ?? "Translation not available";
        });
      } else {
        setState(() {
          translatedText = "Error: Could not fetch translation";
        });
      }
    } catch (e) {
      setState(() {
        translatedText = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0E161C),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/logo.png', height: 40),
            SizedBox(width: 10),
            Text("Translate", style: TextStyle(fontFamily: 'Aurore', fontSize: 36, color: Colors.white)),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF0E161C),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedLanguage,
                  dropdownColor: Color(0xFF0E161C),
                  style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Crimson'),
                  items: languages
                      .map((lang) => DropdownMenuItem(
                    value: lang,
                    child: Text(lang),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: inputController,
              style: const TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'Crimson'),
              decoration: const InputDecoration(
                labelText: "Enter text",
                labelStyle: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'Crimson'),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : translateText,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shadowColor: Colors.transparent,
              ),
              child: Text("Translate", style: TextStyle(color: Color(0xFFE5B28C), fontFamily: 'Crimson', fontSize: 20)),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white)) // Loading animation
                : Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1E1F22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                translatedText,
                style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'Crimson'),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
