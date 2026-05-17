import 'package:flutter/material.dart';
import 'package:queueless/screens/splash_screen.dart';
import 'package:queueless/screens/home_screen.dart';
import 'package:queueless/screens/login_screen.dart';
import 'package:queueless/screens/registration_screen.dart';
import 'package:queueless/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueLess',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
