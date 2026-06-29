import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  late final SupabaseClient _client;
  UserModel? _currentUser;

  /// Initialize Supabase
  Future<void> initialize(String url, String anonKey) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
    _checkAuthStatus();
  }

  SupabaseClient get client => _client;

  /// Check if user is already logged in
  void _checkAuthStatus() {
    final session = _client.auth.currentSession;
    if (session != null) {
      _loadUserProfile();
    }
  }

  /// Load user profile from database
  Future<void> _loadUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = UserModel.fromJson(response);
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Step 1: Create auth user
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Failed to create account. Please try again.',
        };
      }

      // Step 2: Create user profile in database
      final userId = authResponse.user!.id;
      await _client.from('profiles').insert({
        'id': userId,
        'email': email,
        'name': name,
        'phone': phone,
        'status': 'Active',
        'total_visits': 0,
        'average_rating': 0.0,
        'favorite_count': 0,
        'join_date': DateTime.now().toIso8601String(),
      });

      // Load the created profile
      await _loadUserProfile();

      return {
        'success': true,
        'message':
            'Account created successfully! Please check your email to verify.',
        'user': _currentUser,
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      // Load user profile
      await _loadUserProfile();

      return {
        'success': true,
        'message': 'Login successful!',
        'user': _currentUser,
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      _currentUser = null;
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  /// Get current user
  UserModel? getCurrentUser() {
    return _currentUser;
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      final updateData = {'name': name, 'phone': phone};

      if (profileImageUrl != null) {
        updateData['profile_image_url'] = profileImageUrl;
      }

      await _client.from('profiles').update(updateData).eq('id', userId);

      await _loadUserProfile();

      return {
        'success': true,
        'message': 'Profile updated successfully!',
        'user': _currentUser,
      };
    } catch (e) {
      return {'success': false, 'message': 'Update failed: ${e.toString()}'};
    }
  }

  /// Add location to favorites
  Future<Map<String, dynamic>> addToFavorites(String locationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      await _client.from('favorites').insert({
        'user_id': userId,
        'location_id': locationId,
      });

      // Update favorite count
      await _loadUserProfile();

      return {'success': true, 'message': 'Added to favorites!'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to add to favorites: ${e.toString()}',
      };
    }
  }

  /// Remove location from favorites
  Future<Map<String, dynamic>> removeFromFavorites(String locationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('location_id', locationId);

      // Update favorite count
      await _loadUserProfile();

      return {'success': true, 'message': 'Removed from favorites!'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to remove from favorites: ${e.toString()}',
      };
    }
  }

  /// Check if location is favorited
  Future<bool> isFavorited(String locationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _client
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('location_id', locationId);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get all locations
  Future<List<Map<String, dynamic>>> getAllLocations() async {
    try {
      final response = await _client
          .from('locations')
          .select()
          .eq('is_active', true);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
    }
  }

  /// Search locations by name or category
  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    try {
      final response = await _client
          .from('locations')
          .select()
          .eq('is_active', true)
          .or('name.ilike.%$query%,category.ilike.%$query%');

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  /// Get user's queue history
  Future<List<Map<String, dynamic>>> getQueueHistory() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('queue_records')
          .select()
          .eq('user_id', userId)
          .order('check_in_time', ascending: false);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error fetching queue history: $e');
      return [];
    }
  }

  /// Check in to a location
  Future<Map<String, dynamic>> checkIn(String locationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      final response = await _client.from('queue_records').insert({
        'user_id': userId,
        'location_id': locationId,
        'check_in_time': DateTime.now().toIso8601String(),
        'status': 'checked_in',
      });

      return {
        'success': true,
        'message': 'Checked in successfully!',
        'data': response,
      };
    } catch (e) {
      return {'success': false, 'message': 'Check-in failed: ${e.toString()}'};
    }
  }

  /// Check out from a location
  Future<Map<String, dynamic>> checkOut(String recordId) async {
    try {
      await _client
          .from('queue_records')
          .update({
            'check_out_time': DateTime.now().toIso8601String(),
            'status': 'checked_out',
          })
          .eq('id', recordId);

      return {'success': true, 'message': 'Checked out successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Check-out failed: ${e.toString()}'};
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }

  /// Get current session
  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return {
        'success': true,
        'message': 'Password reset email sent! Check your inbox.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send reset email: ${e.toString()}',
      };
    }
  }
}
