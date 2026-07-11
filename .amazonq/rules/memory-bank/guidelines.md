# QueueLess - Development Guidelines

## Code Quality Standards

### Lint & Ignore Directives
- Use `// ignore_for_file:` only for specific, justified rules at the top of a file
- Common suppressions in this codebase:
  - `use_build_context_synchronously` — async methods that use context after await
  - `avoid_print` — service files that use `print()` for debug logging
  - `deprecated_member_use` — theme/color APIs pending migration
  - `unused_import` — model files with conditional imports
- Never suppress lint rules globally; always scope to the file

### Null Safety
- Use null-aware operators consistently: `?.`, `??`, `??=`
- Guard async context usage with `if (!mounted) return;` before any `setState` or `ScaffoldMessenger` call after an `await`
- Prefer `?.toString() ?? 'fallback'` over force-unwrapping in `fromJson` factories

---

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | PascalCase | `LocationModel`, `FavoritesProvider` |
| Files | snake_case | `location_model.dart`, `home_screen.dart` |
| Private fields | `_camelCase` | `_isLoading`, `_emailController` |
| Constants (class-level) | `camelCase` static const | `AppTheme.primaryColor`, `AppColors.statusBusy` |
| Spacing constants | semantic names | `AppSpacing.lg`, `AppTheme.paddingLarge` |
| Route strings | `/kebab-case` | `'/home'`, `'/favorites'` |
| DB column names | `snake_case` | `queue_count`, `wait_time_minutes`, `user_id` |

---

## Widget Patterns

### Screen Structure
Every screen follows this skeleton:
```dart
class FooScreen extends StatefulWidget {
  const FooScreen({super.key});
  @override
  State<FooScreen> createState() => _FooScreenState();
}

class _FooScreenState extends State<FooScreen> {
  // 1. Controllers / state fields
  // 2. @override dispose() — always dispose controllers
  // 3. Private helper methods (_handleX, _validateX, _buildX)
  // 4. @override build()
}
```

### Loading State Pattern
```dart
bool _isLoading = false;

// In async handler:
setState(() => _isLoading = true);
try {
  // await operation
} catch (e) {
  // handle
} finally {
  if (!mounted) return;
  setState(() => _isLoading = false);
}

// In button:
ElevatedButton(
  onPressed: _isLoading ? null : _handleAction,
  child: _isLoading
      ? const SizedBox(height: 24, width: 24,
          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
      : const Text('Action'),
)
```

### Form Validation Pattern
```dart
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Field is required';
  // regex check
  return null;
}

// Trigger:
if (!_formKey.currentState!.validate()) return;
```

### SnackBar Feedback Pattern
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    backgroundColor: AppTheme.accentColor,  // success
    // or AppTheme.errorColor for errors
  ),
);
```

---

## State Management

### Local UI State → setState
Use `setState` for screen-local state: loading flags, form input, search query, toggle visibility.

### Cross-Screen Shared State → Provider
Use `ChangeNotifier` + `Provider.of<T>(context)` for state shared across screens.

```dart
// Provider setup (main.dart)
MultiProvider(
  providers: [ChangeNotifierProvider(create: (_) => FavoritesProvider())],
  child: const MyApp(),
)

// Consuming
final favoritesProvider = Provider.of<FavoritesProvider>(context);
favoritesProvider.toggleFavorite(locationId);
```

### Real-time Data → StreamBuilder
```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: Supabase.instance.client.from('locations').stream(primaryKey: ['id']),
  builder: (context, snapshot) {
    final data = snapshot.data ?? [];
    // build UI
  },
)
```

---

## Supabase Patterns

### Direct Client Access (preferred in screens)
```dart
Supabase.instance.client.auth.signInWithPassword(email: ..., password: ...);
Supabase.instance.client.from('table').select().eq('col', value);
```

### Service Layer (SupabaseService singleton)
Use for reusable backend operations (favorites, queue check-in/out):
```dart
final service = SupabaseService();
final result = await service.addToFavorites(locationId);
if (result['success'] == true) { ... }
```

### Service Return Convention
All mutating service methods return `Map<String, dynamic>` with:
```dart
{'success': true,  'message': 'Done!'}
{'success': false, 'message': 'Error: ...'}
```

### Auth Guard Pattern
```dart
final userId = Supabase.instance.client.auth.currentUser?.id;
if (userId == null) return {'success': false, 'message': 'User not logged in'};
```

---

## Model Patterns

### fromJson — Defensive Parsing
Always use null-coalescing chains for DB fields that may vary:
```dart
name: json['name']?.toString() ?? json['location_name']?.toString() ?? 'Unknown',
queueCount: json['queue_count'] is int
    ? json['queue_count']
    : int.tryParse(json['queue_count']?.toString() ?? '') ?? 0,
```

### Standard Model Methods
All models implement:
- `factory ModelName.fromJson(Map<String, dynamic> json)`
- `Map<String, dynamic> toJson()`
- `ModelName copyWith({...})` for immutable updates
- `@override String toString()` for debug output

### Mock Data
Each model file exports a companion mock constant for development/fallback:
```dart
final LocationModel mockLocation = LocationModel(...);
final List<LocationModel> mockLocations = [...];
final UserModel mockUser = UserModel(...);
```

---

## Theming & Styling

### Two Color Systems (use consistently per file context)
- `AppTheme.*` (from `lib/theme/app_theme.dart`) — used in auth screens and theme config
- `AppColors.*` (from `lib/utils/constants.dart`) — used in home/search/widget files

Do not mix both in the same widget file. Prefer `AppColors` for new widgets.

### Spacing
Use `AppTheme.padding*` or `AppSpacing.*` constants instead of magic numbers:
```dart
// Preferred
padding: const EdgeInsets.all(AppSpacing.lg)
// Avoid
padding: const EdgeInsets.all(16)
```

### Text Styles
Always use `Theme.of(context).textTheme.*` or explicit `TextStyle` with `fontFamily: 'Poppins'`:
```dart
style: Theme.of(context).textTheme.displayMedium
// or
style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
```

### Border Radius
Use `BorderRadius.circular(12)` (medium) as the standard for cards and inputs.

---

## Navigation
- Use `Navigator.of(context).pushReplacementNamed('/route')` for auth flow transitions (login → home)
- Use `Navigator.pushNamed(context, '/route')` for additive navigation (home → search)
- All routes are declared in `MaterialApp.routes` in `main.dart`

---

## Platform-Specific Notes
- **Android**: `MainActivity.kt` is a minimal `FlutterActivity` subclass — do not add logic there
- **Windows**: `win32_window.cpp` is Flutter-generated boilerplate — do not modify
- **iOS/macOS**: Runner files are Flutter-generated — do not modify
- All platform runner files are auto-generated; custom logic belongs in `lib/`
