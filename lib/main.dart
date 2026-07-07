import 'package:flutter/material.dart';
import 'package:queueless/services/supabase_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'theme/app_theme.dart';

// main function to run the app
void main() async {
  // নিশ্চিত করে যে ফ্ল্যাটার ফ্রেমওয়ার্কের বাইন্ডিংগুলো আগে সঠিকভাবে লোড হয়েছে
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase with your credentials
    await SupabaseService().initialize(
      'https://otlsioixomyttxrfimie.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90bHNpb2l4b215dHR4cmZpbWllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0NTAxMTcsImV4cCI6MjA5NzAyNjExN30.tNCVPdhUrkvx4rbhnE_xbPaUZ4M0mzfAUAH2bZm-jW0',
    );

    // কনসোলে চেক করার জন্য
    debugPrint('Supabase Initialized Successfully');
  } catch (e) {
    debugPrint('Supabase Initialization Error: $e');
  }

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
        '/profile': (context) => const ProfileScreen(),
        '/search': (context) => const SearchScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
