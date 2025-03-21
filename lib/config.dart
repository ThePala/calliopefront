import 'dart:io';
import 'package:path_provider/path_provider.dart'; // To access app directory

const String baseUrl = "https://57bb-140-238-162-114.ngrok-free.app";

Future<String?> readMobileNumber() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/cur_mobile.txt';
    final file = File(path);
    if (await file.exists()) {
      String mobileNumber = await file.readAsString();
      return mobileNumber.trim();
    }
  } catch (e) {
    print("Error reading mobile number: $e");
  }
  return null;
}