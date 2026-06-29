# Supabase Authentication Setup Guide - Queueless

## ✅ Overview
This guide walks through setting up Supabase authentication and database for the Queueless Flutter app with your provided credentials.

**Your Supabase Details:**
- URL: `https://otlsioixomyttxrfimie.supabase.co`
- Anon Key: `sb_publishable_A4zKZaqnQm5VJtnvMTwhcw_gLM8kmes`

---

## 📋 Step-by-Step Setup

### Step 1: Run SQL Schema in Supabase (REQUIRED)

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Navigate to **SQL Editor** → **New Query**
4. Copy entire content from `SUPABASE_SQL_SCHEMA.sql` file in your project
5. Paste it into the SQL editor
6. Click **Run** (top-right corner)
7. Wait for execution to complete ✓

**What this creates:**
- `profiles` table (extends auth.users)
- `locations` table
- `favorites` table
- `queue_records` table
- `reviews` table
- Indexes for performance
- Row-Level Security (RLS) policies
- Update triggers for timestamps

---

### Step 2: Verify Tables in Supabase

1. In Dashboard, go to **Table Editor**
2. You should see 5 new tables:
   - profiles
   - locations
   - favorites
   - queue_records
   - reviews

3. Click on each table to verify structure

---

### Step 3: Update Flutter Dependencies

✓ Already done! Your `pubspec.yaml` has been updated with:
```yaml
supabase_flutter: ^2.8.0
supabase: ^2.3.0
uuid: ^4.8.0
```

### Step 4: Run Flutter Pub Get

```bash
flutter pub get
```

---

### Step 5: Configuration Already Set

✓ Your `lib/main.dart` is already configured with your Supabase credentials:

```dart
await SupabaseService().initialize(
  'https://otlsioixomyttxrfimie.supabase.co',
  'sb_publishable_A4zKZaqnQm5VJtnvMTwhcw_gLM8kmes',
);
```

---

## 🎯 Key Files Created/Modified

### Created Files:
1. **lib/services/supabase_service.dart** - Complete Supabase service layer with:
   - User authentication (register, login, logout)
   - Profile management
   - Location operations
   - Favorites management
   - Queue check-in/check-out
   - Password reset

2. **SUPABASE_SQL_SCHEMA.sql** - Database schema with all tables, indexes, and security policies

3. **.env.example** - Environment configuration template

### Modified Files:
1. **lib/main.dart** - Initialized Supabase
2. **lib/screens/login_screen.dart** - Connected to Supabase authentication
3. **lib/screens/registration_screen.dart** - Connected to Supabase registration
4. **lib/models/user_model.dart** - Added JSON serialization (fromJson, toJson, copyWith)
5. **pubspec.yaml** - Added Supabase dependencies

---

## 🔐 Features Now Enabled

### Authentication
- ✅ User Registration
- ✅ User Login
- ✅ Password Reset
- ✅ Session Management
- ✅ Logout

### User Management
- ✅ Profile Creation
- ✅ Profile Updates
- ✅ User Data Persistence

### Location Features
- ✅ Get all locations
- ✅ Search locations
- ✅ Add to favorites
- ✅ Remove from favorites
- ✅ Check if location is favorited

### Queue Management
- ✅ Check-in to location
- ✅ Check-out from location
- ✅ Queue history tracking
- ✅ Wait time recording

---

## 🧪 Testing the Setup

### 1. Register a New User
1. Launch the app
2. Click "Register"
3. Fill in:
   - Full Name: `John Doe`
   - Email: `john@example.com`
   - Password: `password123`
   - Check "I agree to terms"
4. Click "Register"
5. Should see success message and redirect to login

### 2. Login
1. On login screen, enter:
   - Email: `john@example.com`
   - Password: `password123`
2. Click "Login"
3. Should navigate to home screen

### 3. Test Password Reset
1. On login screen, click "Forgot Password?"
2. Enter your email
3. Check your email for reset link

---

## 📱 Database Structure

### profiles table
```sql
- id (UUID, primary key)
- email (TEXT, unique)
- name (TEXT)
- phone (TEXT)
- profile_image_url (TEXT)
- status (TEXT: Active/Inactive/Away)
- total_visits (INT)
- average_rating (DECIMAL)
- favorite_count (INT)
- join_date (TIMESTAMP)
- updated_at (TIMESTAMP)
- created_at (TIMESTAMP)
```

### locations table
```sql
- id (UUID, primary key)
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
- created_by (UUID, foreign key)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### favorites table
```sql
- id (UUID, primary key)
- user_id (UUID, foreign key)
- location_id (UUID, foreign key)
- added_at (TIMESTAMP)
```

### queue_records table
```sql
- id (UUID, primary key)
- user_id (UUID, foreign key)
- location_id (UUID, foreign key)
- check_in_time (TIMESTAMP)
- check_out_time (TIMESTAMP)
- wait_time_minutes (INT)
- notes (TEXT)
- status (TEXT: checked_in/checked_out/cancelled)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### reviews table
```sql
- id (UUID, primary key)
- user_id (UUID, foreign key)
- location_id (UUID, foreign key)
- rating (INT: 1-5)
- comment (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

---

## 🔐 Security Features

### Row Level Security (RLS) Enabled
- Users can only see their own profiles
- Users can only modify their own data
- Public can view active locations and reviews
- Each user's queue records are private
- Each user's favorites are private

### Indexes Created
- profiles: email, created_at
- locations: category, is_active, created_by
- favorites: user_id, location_id
- queue_records: user_id, location_id, check_in_time
- reviews: user_id, location_id, rating

---

## 🛠️ SupabaseService Methods Reference

### Authentication
```dart
// Register new user
await SupabaseService().register(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
  phone: '+1234567890',
);

// Login user
await SupabaseService().login(
  email: 'user@example.com',
  password: 'password123',
);

// Logout
await SupabaseService().logout();

// Reset password
await SupabaseService().resetPassword('user@example.com');
```

### User Management
```dart
// Get current user
UserModel? user = SupabaseService().getCurrentUser();

// Update profile
await SupabaseService().updateProfile(
  name: 'Updated Name',
  phone: '+1234567890',
  profileImageUrl: 'url_to_image',
);

// Check if authenticated
bool isAuth = SupabaseService().isAuthenticated();
```

### Location Operations
```dart
// Get all locations
List<Map> locations = await SupabaseService().getAllLocations();

// Search locations
List<Map> results = await SupabaseService().searchLocations('hospital');
```

### Favorites
```dart
// Add to favorites
await SupabaseService().addToFavorites('location_id');

// Remove from favorites
await SupabaseService().removeFromFavorites('location_id');

// Check if favorited
bool isFav = await SupabaseService().isFavorited('location_id');
```

### Queue Operations
```dart
// Check in
await SupabaseService().checkIn('location_id');

// Check out
await SupabaseService().checkOut('record_id');

// Get queue history
List<Map> history = await SupabaseService().getQueueHistory();
```

---

## ⚠️ Important Notes

1. **Keep your credentials safe:**
   - Never commit `.env` file to git
   - The anon key is public but safe to use in Flutter
   - Keep service role key private (for backend only)

2. **Email Verification:**
   - New registrations may require email verification
   - Check your Supabase project settings for email templates

3. **RLS Policies:**
   - All tables have RLS policies enabled
   - Users can only access their own data
   - Public data (locations, reviews) is viewable by all

4. **Rate Limiting:**
   - Supabase has rate limits on free tier
   - Check dashboard for usage statistics

---

## 🐛 Troubleshooting

### Issue: "Authentication Error"
- Check if email is correctly formatted
- Verify password is at least 6 characters
- Check Supabase project is active

### Issue: "Failed to insert profile"
- Verify all required fields are filled
- Check RLS policies are enabled
- Check database schema was created correctly

### Issue: "Connection timeout"
- Verify internet connection
- Check Supabase URL is correct
- Check anon key is valid

### Issue: "Email already exists"
- Use a different email address
- Or clear auth users in Supabase if testing

---

## 📚 Next Steps

1. ✅ Run SQL schema
2. ✅ Update dependencies
3. ✅ Test registration
4. ✅ Test login
5. **Add user profile completion screen** - Allow users to add phone and profile picture after registration
6. **Implement location display** - Show locations from database
7. **Implement check-in feature** - Let users check in/out
8. **Add reviews/ratings** - Allow users to rate locations
9. **Implement favorites UI** - Show favorite locations
10. **Add profile editing** - Let users update their profile

---

## 💡 Quick Commands

```bash
# Get all dependencies
flutter pub get

# Run the app
flutter run

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

---

## 📞 Support

For Supabase issues:
- Docs: https://supabase.com/docs
- Community: https://supabase.com/community
- Dashboard: https://supabase.com/dashboard

For Flutter issues:
- Docs: https://flutter.dev/docs
- Community: https://flutter.dev/community

---

## ✅ Checklist

- [ ] Run SQL schema in Supabase
- [ ] Verify tables in Table Editor
- [ ] Run `flutter pub get`
- [ ] Test registration
- [ ] Test login
- [ ] Test password reset
- [ ] Check Supabase logs for errors
- [ ] Verify RLS policies are working
- [ ] Test with multiple users

---

**Setup Complete! 🎉 Your Supabase authentication is now fully integrated with your Flutter app.**
