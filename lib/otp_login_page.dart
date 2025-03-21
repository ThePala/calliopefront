import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_page.dart';
import 'config.dart';

class OtpLoginPage extends StatefulWidget {
  @override
  _OtpLoginPageState createState() => _OtpLoginPageState();
}

class _OtpLoginPageState extends State<OtpLoginPage> {
  bool isOtpSent = false;
  bool isButtonDisabled = true;
  int secondsRemaining = 0;
  late Timer timer;
  String verificationId = "";

  final TextEditingController mobileNumberController = TextEditingController();
  final List<TextEditingController> otpControllers =
  List.generate(4, (index) => TextEditingController());

  void startOtpTimer() {
    setState(() {
      isButtonDisabled = true;
      secondsRemaining = 15;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          isButtonDisabled = mobileNumberController.text.isEmpty;
          timer.cancel();
        }
      });
    });
  }

  void checkMobileNumber() {
    setState(() {
      isButtonDisabled = mobileNumberController.text.isEmpty;
    });
  }

  Future<bool> _checkAccountExists(String mobileNumber) async {
    String apiUrl = "$baseUrl/check_user";
    var url = Uri.parse(apiUrl);
    var headers = {'Content-Type': 'application/json'};
    print(mobileNumber);

    var body = json.encode({'mobile_number': mobileNumber});
    print("Body: $body");

    try {
      var response = await http.post(url, headers: headers, body: body);
      print("Check exists API:");
      print(response.statusCode);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This mobile number is not registered.')),
        );
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking account. Please try again later.')),
        );
        return false;
      }
    } catch (e) {
      print("Error: \$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error. Please try again later.')),
      );
      return false;
    }
  }

  Future<String?> _sendOTP(String mobileNumber, BuildContext context) async {
    if (!await _checkAccountExists(mobileNumber)) {
      return null;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request sent. Wait for 60 seconds')),
    );
    String apiUrl = "https://cpaas.messagecentral.com/verification/v3/send";
    String authToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJDLUU0MTRFRDE5NTE5RjRCNSIsImlhdCI6MTczOTEwMzk0MSwiZXhwIjoxODk2NzgzOTQxfQ.SSkAmumOLsaCJrM9yuEy6D6rvy7t3vVErz--dZvUB0K41046nUqzhNraibvhHib5Wzfq-nks-UMawX80TL6CcA";

    var url = Uri.parse('$apiUrl?countryCode=91&flowType=SMS&mobileNumber=$mobileNumber');
    var headers = {'authToken': authToken};

    var response = await http.post(url, headers: headers);
    print(url);
    print(response.statusCode);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      String verificationId = res["data"]["verificationId"].toString();
      return verificationId;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending OTP. Please try again later.')),
      );
      return null;
    }
  }

  Future<void> _verifyOTP() async {
    String otp = otpControllers.map((controller) => controller.text).join();
    String apiUrl = 'https://cpaas.messagecentral.com/verification/v3/validateOtp';
    String authToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJDLUU0MTRFRDE5NTE5RjRCNSIsImlhdCI6MTczOTEwMzk0MSwiZXhwIjoxODk2NzgzOTQxfQ.SSkAmumOLsaCJrM9yuEy6D6rvy7t3vVErz--dZvUB0K41046nUqzhNraibvhHib5Wzfq-nks-UMawX80TL6CcA";

    var url = Uri.parse('$apiUrl?verificationId=$verificationId&code=$otp');
    var headers = {'authToken': authToken};

    var response = await http.get(url, headers: headers);
    print("Response Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      String verificationStatus = res["data"]["verificationStatus"].toString();

      if (verificationStatus == "VERIFICATION_COMPLETED") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully Logged In')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong OTP Entered')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to verify OTP')),
      );
    }
  }

  @override
  void dispose() {
    timer.cancel();
    mobileNumberController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E161C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo.png', width: 80, height: 80),
            const SizedBox(height: 10),
            const Text(
              'Calliope',
              style: TextStyle(color: Colors.white, fontFamily: 'Aurore', fontSize: 40),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: mobileNumberController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => checkMobileNumber(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Mobile Number',
                  hintStyle: const TextStyle(color: Color(0xFF8D8D8D), fontFamily: 'Oraniembaum'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonDisabled
                  ? null
                  : () async {
                String mobileNumber = mobileNumberController.text;
                String? vid = await _sendOTP(mobileNumber, context);
                if (vid != null) {
                  setState(() {
                    verificationId = vid;
                    isOtpSent = true;
                  });
                  startOtpTimer();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: isButtonDisabled ? Colors.grey : const Color(0xFFE5B28C),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                shadowColor: Colors.transparent,
              ),
              child: Text(
                isButtonDisabled
                    ? (secondsRemaining > 0 ? 'Resend OTP in $secondsRemaining' : 'Send OTP')
                    : 'Send OTP',
                style: TextStyle(
                  color: isButtonDisabled ? Colors.grey : const Color(0xFFE5B28C),
                  fontSize: 18,
                  fontFamily: 'Aurore',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextField(
                    controller: otpControllers[index],
                    enabled: isOtpSent,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                    maxLength: 1,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isOtpSent ? Colors.white : Colors.grey[400],
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isOtpSent ? _verifyOTP : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Color(0xFFE5B28C), width: 2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Login',
                style: TextStyle(color: Color(0xFFE5B28C), fontSize: 24, fontFamily: 'Aurore'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}