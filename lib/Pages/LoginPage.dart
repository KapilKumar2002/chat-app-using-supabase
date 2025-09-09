import 'package:first_app/Services/otp_page.dart';
import 'package:first_app/Services/reset_password.dart';
import 'package:first_app/widgets/custom_text_field.dart';
import 'package:first_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:first_app/Pages/HomePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'CreateProfilePage.dart';
import 'SignupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phone = TextEditingController();

  bool notvisible = true;
  bool notVisiblePassword = true;
  Icon passwordIcon = const Icon(Icons.visibility);
  bool emailFormVisibility = true;

  void passwordVisibility() {
    passwordIcon = notVisiblePassword
        ? const Icon(Icons.visibility)
        : const Icon(Icons.visibility_off);
  }

  // Dummy login
  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      final supabase = Supabase.instance.client;
      _isLoading = true;
      setState(() {});
      try {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        final AuthResponse = await supabase.auth
            .signInWithPassword(email: email, password: password);
        if (AuthResponse.session == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something went wrong!")),
          );
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
        );
      } on AuthApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$e")),
        );
      } finally {
        _isLoading = false;
        setState(() {});
      }
    }
  }

  void signinphone() {
    print("Phone login: ${phone.text}");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => OTPPage(
                id: "895623147",
                phone: "874593210",
              )),
    );
  }

  void signInWithGoogle() {
    print("Google login");
  }

  void firstLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CreateProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/login.jpg', height: 200),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (emailFormVisibility) ...[
                      CustomTextField(
                        label: 'Email ID',
                        icon: Icons.alternate_email_outlined,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          CustomTextField(
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            controller: passwordController,
                            isPassword: notvisible,
                          ),
                          IconButton(
                            icon: passwordIcon,
                            onPressed: () {
                              setState(() {
                                notvisible = !notvisible;
                                notVisiblePassword = !notVisiblePassword;
                                passwordVisibility();
                              });
                            },
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.phone_android_rounded),
                          onPressed: () {
                            setState(() {
                              emailFormVisibility = false;
                            });
                          },
                        ),
                      ),
                    ] else ...[
                      CustomTextField(
                        label: 'Phone Number',
                        icon: Icons.phone_android_rounded,
                        controller: phone,
                        keyboardType: TextInputType.phone,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.alternate_email_rounded),
                          onPressed: () {
                            setState(() {
                              emailFormVisibility = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RESETpasswordPage()),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.indigo,
                  ),
                )
              else
                CustomButton(
                  text: "Login",
                  onPressed: () {
                    if (emailFormVisibility) {
                      login();
                    } else {
                      signinphone();
                    }
                  },
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Login with Google",
                onPressed: () {
                  signInWithGoogle();
                  firstLogin();
                },
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "New to the App? ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
