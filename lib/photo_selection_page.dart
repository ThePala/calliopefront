import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:calliope2/extracttext.dart';

class PhotoSelectionPage extends StatefulWidget {
  @override
  _PhotoSelectionPageState createState() => _PhotoSelectionPageState();
}

class _PhotoSelectionPageState extends State<PhotoSelectionPage> {
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
      appBar: AppBar(
        title: const Text('Choose an Option'),
        backgroundColor: const Color(0xFF0E161C),
      ),
      backgroundColor: const Color(0xFF0E161C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload from Gallery'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take a Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
