import 'package:flutter/material.dart';

class RESETpasswordPage extends StatefulWidget {
  const RESETpasswordPage({super.key});

  @override
  State<StatefulWidget> createState() => _RESETpasswordPageState();
}

class _RESETpasswordPageState extends State<RESETpasswordPage> {
  final TextEditingController email = TextEditingController();

  void resetPassword() {
    // TODO: Replace with your backend password reset API call
    print("Password reset requested for: ${email.text}");
    Navigator.of(context).pop();
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF7F7F7),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 250,
                child: Image.asset('assets/images/reset_password.jpg'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Forgot \nPassword?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Don't worry! It happens. Please enter the email address associated with your account.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildCustomTextField(
                controller: email,
                hint: "Enter your email",
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 30),
              _buildCustomButton(
                label: "Reset Password",
                onPressed: resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
