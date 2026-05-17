// Quick Customization Guide for QueueLess UI

// ============================================================================
// 1. CHANGING COLORS
// ============================================================================
// Location: lib/theme/app_theme.dart
//
// Example: Change primary color
//
// Before:
// static const Color primaryColor = Color(0xFF1E3A8A); // Deep Blue
//
// After:
// static const Color primaryColor = Color(0xFF1F2937); // Different shade
//
// This will automatically update all UI elements using primary color!

// ============================================================================
// 2. ADJUSTING SPACING
// ============================================================================
// Location: lib/theme/app_theme.dart
//
// Available spacing constants:
// - paddingSmall = 8
// - paddingMedium = 16
// - paddingLarge = 20
// - paddingExtraLarge = 24
//
// Example: Increase padding in login form
// Replace: padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge)
// With: padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingExtraLarge)

// ============================================================================
// 3. MODIFYING BORDER RADIUS
// ============================================================================
// Location: lib/theme/app_theme.dart
//
// Available border radius options:
// - borderRadiusSmall = 8
// - borderRadiusMedium = 12
// - borderRadiusLarge = 16
//
// Example: Make buttons more rounded
// In ElevatedButtonThemeData:
// Before: borderRadius: BorderRadius.circular(borderRadiusMedium)
// After: borderRadius: BorderRadius.circular(borderRadiusLarge)

// ============================================================================
// 4. CHANGING SPLASH SCREEN ANIMATION
// ============================================================================
// Location: lib/screens/splash_screen.dart
//
// Modify animation duration:
// _animationController = AnimationController(
//   duration: const Duration(milliseconds: 1000), // Change from 1500
//   vsync: this,
// );
//
// Modify animation curve:
// CurvedAnimation(parent: _animationController, curve: Curves.easeOut) // Change from easeIn
//
// Modify initial delay before navigation:
// Future.delayed(const Duration(seconds: 5), () { // Change from 3 seconds

// ============================================================================
// 5. ADDING CUSTOM FONTS
// ============================================================================
// Location: pubspec.yaml
//
// Step 1: Create assets/fonts directory and add .ttf files
// Step 2: Update pubspec.yaml:
// flutter:
//   fonts:
//     - family: Poppins
//       fonts:
//         - asset: assets/fonts/Poppins-Regular.ttf
//         - asset: assets/fonts/Poppins-Bold.ttf
//           weight: 700
//
// Step 3: The theme already references 'Poppins', it will use it if available

// ============================================================================
// 6. ADDING INPUT FIELD VALIDATION
// ============================================================================
// Location: lib/screens/login_screen.dart (or registration_screen.dart)
//
// Example: Add phone number validation
//
// String? _validatePhone(String? value) {
//   if (value == null || value.isEmpty) {
//     return 'Phone is required';
//   }
//   if (!RegExp(r'^\d{10}$').hasMatch(value)) {
//     return 'Phone must be 10 digits';
//   }
//   return null;
// }
//
// Then add TextFormField:
// TextFormField(
//   controller: _phoneController,
//   keyboardType: TextInputType.phone,
//   validator: _validatePhone,
//   decoration: InputDecoration(
//     hintText: 'Enter phone number',
//     prefixIcon: const Icon(Icons.phone),
//   ),
// )

// ============================================================================
// 7. CHANGING BUTTON STYLING
// ============================================================================
// Location: lib/theme/app_theme.dart
//
// Modify ElevatedButtonThemeData style:
// Example - Change button to secondary color:
//
// style: ElevatedButton.styleFrom(
//   backgroundColor: secondaryColor, // Change from primaryColor
//   foregroundColor: Colors.white,
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(borderRadiusMedium),
//   ),
//   padding: const EdgeInsets.symmetric(
//     horizontal: paddingLarge,
//     vertical: paddingMedium,
//   ),
// )

// ============================================================================
// 8. ADDING PLACEHOLDER LOGO/ICON
// ============================================================================
// Location: lib/screens/splash_screen.dart
//
// Replace the current icon in SplashScreen:
// Before:
// child: const Icon(
//   Icons.people_alt_rounded,
//   size: 60,
//   color: Colors.white,
// )
//
// After - Use custom asset:
// child: Image.asset(
//   'assets/logo.png', // Add logo.png to assets folder
//   width: 60,
//   height: 60,
// )

// ============================================================================
// 9. IMPLEMENTING ACTUAL AUTHENTICATION
// ============================================================================
// Location: lib/screens/login_screen.dart
//
// Replace the simulated login with actual API call:
//
// void _handleLogin() async {
//   if (_formKey.currentState!.validate()) {
//     setState(() => _isLoading = true);
//     try {
//       // Call your authentication API
//       final response = await authService.login(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//       // Navigate to home screen or dashboard
//       Navigator.of(context).pushReplacementNamed('/home');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login failed: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
// }

// ============================================================================
// 10. NAVIGATION STRUCTURE
// ============================================================================
// Current flow: Splash → Login ⟷ Registration
//
// To add new screens:
// 1. Create new file: lib/screens/new_screen.dart
// 2. Create StatefulWidget or StatelessWidget
// 3. Update navigation in respective screen:
//    Navigator.of(context).pushReplacement(
//      MaterialPageRoute(builder: (context) => const NewScreen()),
//    );
//
// For better navigation management, consider using named routes:
// In main.dart:
// home: const SplashScreen(),
// routes: {
//   '/login': (context) => const LoginScreen(),
//   '/register': (context) => const RegistrationScreen(),
//   '/home': (context) => const HomeScreen(),
// }

// ============================================================================
// 11. TROUBLESHOOTING
// ============================================================================
//
// Q: Colors not appearing correctly?
// A: Clear build cache with: flutter clean
//    Then run: flutter pub get && flutter run
//
// Q: Fonts not loading?
// A: Ensure font files are in correct directory and pubspec.yaml is updated
//    Run flutter clean and hot restart
//
// Q: Form validation not working?
// A: Check that validator functions return null for valid input
//    Ensure form key is properly initialized and validate is called
//
// Q: Navigation not working?
// A: Verify screen imports are correct
//    Check that routes are properly defined
//    Use named routes for complex navigation

// ============================================================================
// 12. PERFORMANCE TIPS
// ============================================================================
//
// 1. Use const constructors wherever possible (already implemented)
// 2. Avoid rebuilding entire widgets - use StatefulWidget wisely
// 3. Consider using Provider for state management in larger apps
// 4. Profile app with DevTools to identify performance bottlenecks
// 5. Use FutureBuilder for async operations instead of Future.delayed

// ignore_for_file: file_names

// ============================================================================
// 13. ACCESSIBILITY IMPROVEMENTS
// ============================================================================
//
// Add semantic labels to icons:
// Icon(
//   Icons.email_outlined,
//   semanticLabel: 'Email address',
// )
//
// Add tooltip to buttons:
// SizedBox(
//   child: Tooltip(
//     message: 'Submit login form',
//     child: ElevatedButton(...)
//   )
// )
//
// Ensure proper contrast ratios (already done with selected colors)
