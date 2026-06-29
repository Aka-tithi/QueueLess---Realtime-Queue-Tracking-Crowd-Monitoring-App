# Supabase Quick Reference - Queueless

## 🚀 Getting Started

### Initialize (Already done in main.dart)
```dart
await SupabaseService().initialize(
  'https://otlsioixomyttxrfimie.supabase.co',
  'sb_publishable_A4zKZaqnQm5VJtnvMTwhcw_gLM8kmes',
);
```

### Access Service
```dart
final supabase = SupabaseService();
```

---

## 👤 Authentication

### Register
```dart
final result = await SupabaseService().register(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
  phone: '+1234567890',
);

if (result['success'] == true) {
  print('Registered: ${result['user']}');
} else {
  print('Error: ${result['message']}');
}
```

### Login
```dart
final result = await SupabaseService().login(
  email: 'user@example.com',
  password: 'password123',
);

if (result['success'] == true) {
  UserModel user = result['user'];
  print('Logged in as: ${user.name}');
}
```

### Logout
```dart
await SupabaseService().logout();
```

### Reset Password
```dart
final result = await SupabaseService().resetPassword('user@example.com');
print(result['message']); // "Check your email for reset link"
```

### Check Authentication
```dart
bool isLoggedIn = SupabaseService().isAuthenticated();
if (isLoggedIn) {
  print('User is logged in');
}
```

### Get Current User
```dart
UserModel? user = SupabaseService().getCurrentUser();
if (user != null) {
  print('User: ${user.name}');
}
```

---

## 👥 Profile Management

### Update Profile
```dart
final result = await SupabaseService().updateProfile(
  name: 'Jane Doe',
  phone: '+1987654321',
  profileImageUrl: 'https://example.com/image.jpg',
);

if (result['success'] == true) {
  UserModel updatedUser = result['user'];
}
```

---

## 📍 Locations

### Get All Locations
```dart
List<Map<String, dynamic>> locations = 
    await SupabaseService().getAllLocations();

for (var location in locations) {
  print('${location['name']} - ${location['address']}');
}
```

### Search Locations
```dart
List<Map<String, dynamic>> results = 
    await SupabaseService().searchLocations('hospital');

for (var location in results) {
  print(location['name']);
}
```

---

## ❤️ Favorites

### Add to Favorites
```dart
final result = await SupabaseService().addToFavorites('location_id');

if (result['success'] == true) {
  print('Added to favorites');
}
```

### Remove from Favorites
```dart
final result = 
    await SupabaseService().removeFromFavorites('location_id');

if (result['success'] == true) {
  print('Removed from favorites');
}
```

### Check if Favorited
```dart
bool isFavorited = 
    await SupabaseService().isFavorited('location_id');

if (isFavorited) {
  print('This location is in your favorites');
}
```

---

## 📋 Queue Operations

### Check In
```dart
final result = await SupabaseService().checkIn('location_id');

if (result['success'] == true) {
  print('Checked in successfully');
  print(result['data']); // Contains record ID
}
```

### Check Out
```dart
final result = await SupabaseService().checkOut('record_id');

if (result['success'] == true) {
  print('Checked out successfully');
}
```

### Get Queue History
```dart
List<Map<String, dynamic>> history = 
    await SupabaseService().getQueueHistory();

for (var record in history) {
  print('${record['location_id']} - ${record['check_in_time']}');
}
```

---

## 🔐 Session Management

### Listen to Auth State Changes
```dart
SupabaseService().authStateChanges.listen((authState) {
  print('Auth state changed: ${authState.event}');
});
```

### Get Current Session
```dart
Session? session = SupabaseService().getCurrentSession();

if (session != null) {
  print('Access Token: ${session.accessToken}');
}
```

---

## 🏗️ Database Tables Reference

### profiles
- id (UUID)
- email (TEXT)
- name (TEXT)
- phone (TEXT)
- profile_image_url (TEXT)
- status (Active/Inactive/Away)
- total_visits (INT)
- average_rating (DECIMAL)
- favorite_count (INT)
- join_date (TIMESTAMP)
- updated_at (TIMESTAMP)
- created_at (TIMESTAMP)

### locations
- id (UUID)
- name (TEXT)
- description (TEXT)
- address (TEXT)
- latitude (DECIMAL)
- longitude (DECIMAL)
- category (TEXT)
- phone (TEXT)
- operating_hours (TEXT)
- average_wait_time (INT)
- average_rating (DECIMAL)
- total_reviews (INT)
- is_active (BOOLEAN)
- created_by (UUID)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### favorites
- id (UUID)
- user_id (UUID)
- location_id (UUID)
- added_at (TIMESTAMP)

### queue_records
- id (UUID)
- user_id (UUID)
- location_id (UUID)
- check_in_time (TIMESTAMP)
- check_out_time (TIMESTAMP)
- wait_time_minutes (INT)
- notes (TEXT)
- status (checked_in/checked_out/cancelled)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### reviews
- id (UUID)
- user_id (UUID)
- location_id (UUID)
- rating (INT: 1-5)
- comment (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

---

## 🔄 Response Format

All methods return `Map<String, dynamic>` with:

```dart
{
  'success': bool,
  'message': String,
  'user': UserModel?, // For auth methods
  'data': dynamic?, // Additional data
}
```

### Example
```dart
{
  'success': true,
  'message': 'Login successful!',
  'user': UserModel(
    id: 'uuid...',
    name: 'John Doe',
    email: 'john@example.com',
    // ...
  ),
}
```

---

## ⚡ Common Patterns

### Complete Login Flow
```dart
void loginUser() async {
  final result = await SupabaseService().login(
    email: emailController.text,
    password: passwordController.text,
  );

  if (result['success'] == true) {
    UserModel user = result['user'];
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    showError(result['message']);
  }
}
```

### Complete Registration Flow
```dart
void registerUser() async {
  final result = await SupabaseService().register(
    email: emailController.text,
    password: passwordController.text,
    name: nameController.text,
    phone: phoneController.text,
  );

  if (result['success'] == true) {
    showSuccess('Registration successful! Check your email.');
    Navigator.pushReplacementNamed(context, '/login');
  } else {
    showError(result['message']);
  }
}
```

### Load User Favorites
```dart
void loadFavorites() async {
  final locations = await SupabaseService().getAllLocations();
  
  List<Map> favorites = [];
  for (var location in locations) {
    bool isFav = await SupabaseService()
        .isFavorited(location['id']);
    if (isFav) {
      favorites.add(location);
    }
  }
  
  setState(() {
    favoriteLocations = favorites;
  });
}
```

### Add Location to Favorites
```dart
void toggleFavorite(String locationId) async {
  bool isFav = await SupabaseService().isFavorited(locationId);
  
  if (isFav) {
    await SupabaseService().removeFromFavorites(locationId);
  } else {
    await SupabaseService().addToFavorites(locationId);
  }
  
  setState(() {});
}
```

---

## 🚨 Error Handling

```dart
try {
  final result = await SupabaseService().login(
    email: 'user@example.com',
    password: 'password',
  );

  if (result['success'] != true) {
    print('Login failed: ${result['message']}');
  }
} catch (e) {
  print('Error: ${e.toString()}');
}
```

---

## 🔗 Useful Links

- Supabase Dashboard: https://supabase.com/dashboard
- Supabase Docs: https://supabase.com/docs
- Flutter Documentation: https://flutter.dev/docs
- Dart Documentation: https://dart.dev/guides

---

**Last Updated:** 2024
**Version:** 1.0
