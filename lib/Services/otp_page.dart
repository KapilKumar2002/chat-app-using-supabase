import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import '../Pages/CreateProfilePage.dart';
import '../Pages/HomePage.dart';
import 'package:first_app/Pages/LoginPage.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key, required this.id, required this.phone});

  final String? id;
  final String phone;

  @override
  State<StatefulWidget> createState() => _OTPpageState();
}

class _OTPpageState extends State<OTPPage> {
  // Simulate checking first login from your backend later
  void firstLogin() {
    // TODO: Replace with actual API call to check if first login
    bool isFirstLogin = true; // Just for demo
    if (isFirstLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CreateProfilePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  void verifyOTP(String otp) {
    // TODO: Replace with your backend OTP verification logic
    print("Entered OTP: $otp");
    // Simulate success
    Future.delayed(const Duration(milliseconds: 500), () {
      firstLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    String phoneNumber = widget.phone;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/otp.webp',
                height: 220,
              ),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'A 6-digit code has been sent to \n+91 $phoneNumber',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              OtpTextField(
                numberOfFields: 6,
                borderColor: Colors.transparent,
                focusedBorderColor: Colors.indigo,
                showFieldAsBox: true,
                borderRadius: BorderRadius.circular(12),
                fillColor: const Color(0xFFF7F7F7),
                filled: true,
                showCursor: true,
                fieldWidth: 50,
                onSubmit: verifyOTP,
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  // TODO: Implement resend OTP logic
                  print("Resend OTP");
                },
                child: const Text(
                  "Resend OTP",
                  style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
