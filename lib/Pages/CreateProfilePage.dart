import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class CreateProfilePage extends StatelessWidget {
  const CreateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firstNameController = TextEditingController();
    final ageController = TextEditingController();
    final mobileController = TextEditingController();
    final addressController = TextEditingController();

    void addUser() {
      // TODO: Replace with API call
      print({
        "First name": firstNameController.text,
        "Age": ageController.text,
        "Mobile": mobileController.text,
        "Address": addressController.text,
      });
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text("Create Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profile Details",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Fill in your personal information to create your profile.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: "First Name",
                  icon: Icons.person,
                  controller: firstNameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Age",
                  icon: Icons.calendar_today,
                  controller: ageController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Mobile",
                  icon: Icons.phone,
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Address",
                  icon: Icons.home,
                  controller: addressController,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: "Save Profile",
                  onPressed: addUser,
                  color: Colors.indigo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
