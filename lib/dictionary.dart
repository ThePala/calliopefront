import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class DictionaryPage extends StatefulWidget {
  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  String selectedLanguage = 'French';
  List<dynamic> dictionary = [];
  bool isLoading = false;

  Future<void> fetchDictionary() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('$baseUrl/get_dictionary'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'language': selectedLanguage}),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      setState(() {
        dictionary = jsonDecode(response.body)['dictionary'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${jsonDecode(response.body)['error']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E161C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E161C),
        iconTheme: const IconThemeData(color: Colors.white), // Back arrow color
        title: Row(
          children: [
            Image.asset(
              'images/logo.png', // Make sure logo.png is in assets folder and added in pubspec.yaml
              height: 48, // Adjust size as per your need
            ),
            const SizedBox(width: 10), // Space between logo and title
            const Text(
              'Dictionary',
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
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
              dropdownColor: Colors.black,
              style: const TextStyle(
                  color: Color(0xFFE5B28C),
                  fontFamily: 'Crimson',
                  fontWeight: FontWeight.bold),
              iconEnabledColor: Color(0xFFE5B28C),
              items: ['French', 'German', 'Tamil'].map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(
                    language,
                    style: const TextStyle(
                        fontFamily: 'Crimson',
                        color: Color(0xFFE5B28C),
                        fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFFE5B28C),
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                    fontFamily: 'Crimson', fontWeight: FontWeight.bold),
              ),
              onPressed: fetchDictionary,
              child: Text('Fetch'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator(color: Color(0xFFE5B28C))
                : Expanded(
              child: ListView.builder(
                itemCount: dictionary.length,
                itemBuilder: (context, index) {
                  final wordData = dictionary[index];
                  return Card(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        title: Text(
                          wordData['word'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Crimson',
                              color: Colors.white,
                              fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              "Meaning: ${wordData['meaning']}",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Crimson',
                                  color: Color(0xFFE5B28C)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Synonyms: ${wordData['synonyms'].join(', ')}",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Crimson',
                                  color: Color(0xFFE5B28C)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Antonyms: ${wordData['antonyms'].join(', ')}",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Crimson',
                                  color: Color(0xFFE5B28C)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
