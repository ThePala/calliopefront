import 'package:flutter/material.dart';
import 'package:calliope2/loginpage.dart';
import 'package:calliope2/registerpage.dart';
import 'dart:io';
import 'package:calliope2/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class LoginRegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E161C),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Center(
            child: Image.asset(
              'images/logo.png', // Replace with the actual image name
              width: 200,
              height: 200,
            ),
          ),
 // Reduced gap after the logo
          const Text(
            'Calliope',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontFamily: 'Aurore',
              fontSize: 65, // Reduced font size if needed
            ),
          ),
          const SizedBox(height: 130),
          // Login Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Color(0xFFD9D9D9), // Stroke color
                    width: 1.5, // Increased stroke width
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(vertical: 5), // Reduced padding
                minimumSize: const Size(280, 70), // Reduced button dimensions
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Color(0xFFE5B28C),
                  fontFamily: 'Aurore',
                  fontSize: 40, // Reduced font size if needed
                ),
              ),
            ),
          ),
          const SizedBox(height: 40), // Reduced gap between buttons
          // Register Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()), // Navigate to LoginPage
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Color(0xFFD9D9D9), // Stroke color
                    width: 1.5, // Increased stroke width
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(vertical: 5), // Reduced padding
                minimumSize: const Size(280, 70), // Reduced button dimensions
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Color(0xFFE5B28C),
                  fontFamily: 'Aurore',
                  fontSize: 40, // Reduced font size if needed
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
