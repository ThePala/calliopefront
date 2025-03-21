import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> registerUser() async {

    print(_usernameController);
    print(_mobileController);
    print(_passwordController);
    final url = Uri.parse('$baseUrl/register_user');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'mobile_number': _mobileController.text,
        'password': _passwordController.text,
      }),
    );

    print(response.statusCode);

    if (response.statusCode == 201) {
      // Handle success
      print('User registered successfully');
    } else {

      // Handle error
      print('Registration failed: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E161C),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and App Name (Aligned Horizontally)
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

                // Username Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _usernameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Crimson',
                      fontSize: 24,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Username',
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

                // Mobile Number Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _mobileController,
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
                    controller: _passwordController,
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

                // Register Button
                ElevatedButton(
                  onPressed: registerUser,
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
                    'Register',
                    style: TextStyle(
                      color: Color(0xFFE5B28C),
                      fontFamily: 'Aurore',
                      fontSize: 30,
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
