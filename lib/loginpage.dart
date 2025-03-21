import 'package:flutter/material.dart';
import 'otp_login_page.dart'; // Import the OTP login page
import 'dashboard_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dbhelper2.dart';
import 'config.dart';


class LoginPage extends StatelessWidget {

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> saveMobileNumber(String mobileNumber) async {
    final directory = await getApplicationDocumentsDirectory();
    print("File Saving");
    final file = File('${directory.path}/cur_mobile.txt');
    await file.writeAsString(mobileNumber);
    print("File Saved");
  }

  Future<void> fetchUserProgress(String mobileNumber, BuildContext context) async {
    print("fetchUser");
    print(mobileNumber);
    final url = Uri.parse("$baseUrl/get_user_progress");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mobile_number": mobileNumber}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await DBHelper2.clearProgress();

        print(responseData["user_progress"]);
        for (var progress in responseData["user_progress"]) {
          await DBHelper2.insertProgress({
            "chapter_number": progress["chapter_number"],
            "language": progress["language"],
            "segment_name": progress["segment_name"],
            "scores": progress["scores"],
          });
        }

        await saveMobileNumber(mobileNumber);
        print("done1");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage()));
        print("done2");
      } else {
        _showErrorDialog(context, responseData["message"] ?? "Failed to fetch progress.");
      }
    } catch (e) {
      _showErrorDialog(context, "Network error. Please try again.");
    }
  }


  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E161C),
      resizeToAvoidBottomInset: true, // Prevents keyboard causing overflow
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height, // Keeps content aligned properly
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and App Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Calliope',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Aurore',
                        fontSize: 50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),

                // Mobile Number Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: mobileController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Crimson',
                      fontSize: 24,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Mobile Number',
                      hintStyle: const TextStyle(
                        fontFamily: 'Crimson',
                        fontSize: 28,
                        color: Color(0xFF8D8D8D),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Crimson',
                      fontSize: 24,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                        fontFamily: 'Crimson',
                        fontSize: 28,
                        color: Color(0xFF8D8D8D),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Login Button
                ElevatedButton(
                  onPressed: () {
                    String mobileNumber = mobileController.text;
                    print("Mobile number entered is: ");
                    print(mobileNumber);
                    if (mobileNumber.isNotEmpty) {
                      fetchUserProgress(mobileNumber, context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 70),
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFFE5B28C),
                      fontFamily: 'Aurore',
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'or',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                  ),
                ),
                // Login with OTP
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OtpLoginPage()),
                    );
                  },
                  child: const Text(
                    'Login with OTP',
                    style: TextStyle(
                      fontFamily: "Crimson",
                      color: Color(0xFFE5B28C),
                      fontSize: 24,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
