// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, deprecated_member_use

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

  UserModel? get currentUser => _currentUser;

  Future<void> signOut() async {
    await _client.auth.signOut();
    _currentUser = null;
  }

  // =========================================================================
  // 🚀 Real-time Locations Stream
  // =========================================================================

  Stream<List<Map<String, dynamic>>> getLocationsStream() {
    return _client
        .from('locations')
        .stream(primaryKey: ['id'])
        .order('id', ascending: true);
  }

  // =========================================================================
  // ❤️ Favorites Features
  // =========================================================================

  Future<Map<String, dynamic>> addToFavorites(String locationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null)
        return {'success': false, 'message': 'User not logged in'};

      final locationIdInt = int.tryParse(locationId);
      if (locationIdInt == null) {
        return {'success': false, 'message': 'Invalid location ID'};
      }

      await _client.from('favorites').insert({
        'user_id': userId,
        'location_id': locationIdInt,
      });
      return {'success': true, 'message': 'Added to favorites!'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> removeFromFavorites(String locationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null)
        return {'success': false, 'message': 'User not logged in'};

      final locationIdInt = int.tryParse(locationId);
      if (locationIdInt == null) {
        return {'success': false, 'message': 'Invalid location ID'};
      }

      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('location_id', locationIdInt);
      return {'success': true, 'message': 'Removed from favorites!'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('favorites')
          .select('locations(*)')
          .eq('user_id', userId);

      return (response as List<dynamic>)
          .map((e) => e['locations'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  // =========================================================================
  // 🎟️ Queue Management
  // =========================================================================

  Future<Map<String, dynamic>> checkIn(String locationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null)
        return {'success': false, 'message': 'User not authenticated'};

      final response = await _client
          .from('queue_records')
          .insert({
            'user_id': userId,
            'location_id': locationId,
            'check_in_time': DateTime.now().toIso8601String(),
            'status': 'waiting',
          })
          .select()
          .single();

      return {
        'success': true,
        'message': 'Checked in successfully!',
        'data': response,
      };
    } catch (e) {
      return {'success': false, 'message': 'Check-in failed: ${e.toString()}'};
    }
  }

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

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
