import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Pages/HomePage.dart';
import 'Pages/LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://ogiaivovkmdvjwagyumy.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9naWFpdm92a21kdmp3YWd5dW15Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxMjM3ODUsImV4cCI6MjA3MjY5OTc4NX0.IJlWSl7JyFVMoDrCzXmgJ6Agd5PG6BLMpEInOYBHLTk",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Temporary logic — replace with your own authentication check later
  Widget page() {
    bool isLoggedIn = false; // Change based on your auth state
    if (!isLoggedIn) {
      return LoginPage();
    } else {
      return MyHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: page(),
    );
  }
}
