import 'dart:io';
import 'package:flutter/material.dart';
import 'package:first_app/widgets/custom_text_field.dart';
import 'package:first_app/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'LoginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  XFile? _imageFile;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool passwordVisible = true;
  bool confirmPasswordVisible = true;

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
      );
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void createUser() async {
    final supabase = Supabase.instance.client;
    if (_formKey.currentState!.validate()) {
      _isLoading = true;
      setState(() {});
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      try {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();
        final name = nameController.text.trim();
        final authResponse =
            await supabase.auth.signUp(email: email, password: password);
        if (authResponse.session == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to create user!")),
          );
          return;
        }
        final response = await supabase.from("USERS").insert({
          "id": authResponse.session?.user.id,
          "email": email,
          "username": name,
        }).select();
        if (response.isNotEmpty) {
          await _upload();
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
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
      }
    }
  }

  Future<void> _upload() async {
    final supabase = Supabase.instance.client;

    if (_imageFile == null) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final bytes = await _imageFile!.readAsBytes();
      final fileExt = _imageFile!.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;
      await supabase.storage.from('images').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: _imageFile!.mimeType),
          );
      final imageUrlResponse = await supabase.storage
          .from('images')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      final userId = supabase.auth.currentUser!.id;
      print(userId);
      await supabase.from('USERS').upsert({
        'id': userId,
        'profile_image': imageUrlResponse,
      });
    } on StorageException catch (error) {
      if (mounted) {
        print(error);
      }
    } catch (error) {
      if (mounted) {
        print(error);
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset(
                'assets/images/signup.jpg',
                height: size.height / 4,
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(120),
                    border: Border.all(width: 2, color: Colors.indigo),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(120),
                    child: SizedBox(
                      child: _imageFile == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                            )
                          : Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      controller: nameController,
                    ),
                    const SizedBox(height: 15),
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
                          isPassword: passwordVisible,
                        ),
                        IconButton(
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        CustomTextField(
                          label: 'Confirm Password',
                          icon: Icons.lock_outline_rounded,
                          controller: confirmPasswordController,
                          isPassword: confirmPasswordVisible,
                        ),
                        IconButton(
                          icon: Icon(
                            confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              confirmPasswordVisible = !confirmPasswordVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'By signing up, you agree to our Terms & Conditions and Privacy Policy',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
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
                  text: "Sign Up",
                  onPressed: createUser,
                ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Joined us before? ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
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
