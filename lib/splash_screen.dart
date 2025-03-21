import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:calliope2/main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _blinkController;
  final Random _random = Random();

  final List<String> words = ["Hello", "Hola", "Bonjour", "Hallo", "Ciao", "Olá", "Привет", "こんにちは", "你好", "안녕하세요", "مرحبا", "नमस्ते"];

  final List<Rect> _usedPositions = []; // Store used positions
  late Rect _logoRect; // Store logo area

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    Timer(Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginRegisterPage()),
      );
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    _usedPositions.clear(); // Clear old positions

    // Define logo rect in the center
    const double logoSize = 150;
    final double logoLeft = (screenWidth - logoSize) / 2;
    final double logoTop = (screenHeight - logoSize) / 2;
    _logoRect = Rect.fromLTWH(logoLeft, logoTop, logoSize, logoSize);

    return Scaffold(
      backgroundColor: Colors.black26,
      body: Stack(
        children: [
          ...words.map((word) {
            const double wordWidth = 120;
            const double wordHeight = 50;
            Rect newPos;

            // Retry till we get a non-overlapping and non-logo position
            int attempts = 0;
            do {
              double left = _random.nextDouble() * (screenWidth - wordWidth);
              double top = _random.nextDouble() * (screenHeight - wordHeight);

              newPos = Rect.fromLTWH(left, top, wordWidth, wordHeight);
              attempts++;
            } while ((_isOverlapping(newPos) || _logoRect.overlaps(newPos)) && attempts < 100);

            _usedPositions.add(newPos);

            return Positioned(
              left: newPos.left,
              top: newPos.top,
              child: AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _blinkController.value,
                    child: child,
                  );
                },
                child: textStyle(word),
              ),
            );
          }).toList(),

          // Center logo
          Center(
            child: Image.asset(
              'images/logo.png',
              width: logoSize,
              height: logoSize,
            ),
          ),
        ],
      ),
    );
  }

  // Check overlap with existing words
  bool _isOverlapping(Rect newRect) {
    for (Rect used in _usedPositions) {
      if (used.overlaps(newRect)) {
        return true;
      }
    }
    return false;
  }

  Widget textStyle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE5B28C),
      ),
    );
  }
}
