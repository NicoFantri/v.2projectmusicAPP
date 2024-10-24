import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicapp/app/modules/home/views/home_view.dart';
import 'package:musicapp/app/modules/home/views/login_view.dart';
import 'package:musicapp/app/modules/home/views/start_screen.dart';
//import 'package:musicapp/app/modules/home/views/profile_view.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Music App',
      debugShowCheckedModeBanner: false, // Removes debug banner
      initialRoute: '/', // Set initial route to onboarding
      getPages: [
        GetPage(name: '/', page: () => OnboardingView()), // Onboarding as initial screen
        GetPage(name: '/login', page: () => LoginView()), // Login screen
        GetPage(name: '/home', page: () => HomeView()), // Home screen
      ],
      theme: ThemeData(
        primaryColor: Color(0xFF5079FF),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins', // Make sure to add this font to pubspec.yaml
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF5079FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}