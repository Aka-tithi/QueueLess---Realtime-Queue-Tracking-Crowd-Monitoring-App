import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/favorites_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_screen.dart';
import 'screens/search_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pudolizgmrwalcaqurdc.supabase.co',
    publishableKey: 'sb_publishable_hYrAeYr5eL17OmyOpIqPlQ_hztMxHNJ',
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: const QueueLessApp(),
    ),
  );
}

class QueueLessApp extends StatelessWidget {
  const QueueLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueLess',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegistrationScreen(),
        '/main': (_) => const MainScreen(),
        '/search': (_) => const SearchScreen(),
      },
    );
  }
}
