# QueueLess - Project Structure

## Directory Layout
```
lib/
├── main.dart                  # App entry point, Supabase init, route table, MultiProvider
├── models/
│   ├── location_model.dart    # LocationModel + mockLocations list (50+ entries)
│   └── user_model.dart        # UserModel with fromJson / toJson / copyWith
├── screens/
│   ├── splash_screen.dart     # Initial loading / auth redirect
│   ├── login_screen.dart      # Email+password login, forgot password dialog
│   ├── registration_screen.dart
│   ├── home_screen.dart       # StreamBuilder over locations, popular + nearby lists
│   ├── search_screen.dart     # Full location search with filters
│   ├── favorites_screen.dart  # User's saved locations
│   └── profile_screen.dart    # User stats and account management
├── services/
│   ├── supabase_service.dart  # Singleton: auth, favorites CRUD, queue check-in/out
│   ├── favorites_provider.dart# ChangeNotifier for in-memory favorites state
│   ├── queue_service.dart     # Supabase stream for live queue data per location
│   └── search_service.dart    # Static search/filter logic over LocationModel list
├── theme/
│   └── app_theme.dart         # AppTheme class: colors, spacing constants, ThemeData
├── utils/
│   └── constants.dart         # AppColors and other app-wide constants
└── widgets/
    ├── custom_app_bar.dart
    ├── custom_bottom_navigation.dart
    ├── featured_location_card.dart  # Horizontal card for popular locations
    ├── nearby_location_card.dart    # Vertical list card for nearby locations
    ├── location_banner.dart
    └── quick_stats_card.dart
```

## Route Table (main.dart)
| Route | Screen |
|-------|--------|
| `/splash` | SplashScreen |
| `/login` | LoginScreen |
| `/register` | RegistrationScreen |
| `/home` | HomeScreen |
| `/search` | SearchScreen |
| `/favorites` | FavoritesScreen |
| `/profile` | ProfileScreen |

## Architectural Patterns
- **StatefulWidget + setState** for local UI state (loading flags, form fields, search query)
- **Provider (ChangeNotifier)** for cross-screen shared state (FavoritesProvider)
- **Singleton service** (SupabaseService) for backend operations
- **StreamBuilder** for real-time Supabase data on HomeScreen
- **Named routes** for navigation (pushReplacementNamed / pushNamed)
- **Mock data + DB merge** — mockLocations are always shown; DB records are merged in if not duplicate

## Key Relationships
```
main.dart
  └─ MultiProvider → FavoritesProvider
  └─ MaterialApp → routes

HomeScreen
  └─ StreamBuilder (Supabase locations stream)
  └─ _mergeLocations(mockLocations + DB)
  └─ FeaturedLocationCard / NearbyLocationCard
  └─ SearchService.searchLocations()

SupabaseService (singleton)
  └─ Supabase.instance.client
  └─ favorites table CRUD
  └─ queue_records table (check-in / check-out)
```

## Platform Support
Android, iOS, Web, Windows, macOS (standard Flutter multi-platform setup)
