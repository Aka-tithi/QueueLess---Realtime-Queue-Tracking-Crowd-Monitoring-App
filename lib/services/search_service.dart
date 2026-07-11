// ignore_for_file: avoid_print
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:queueless/models/location_model.dart';

class SearchService {
  static List<LocationModel> searchLocations(
    List<LocationModel> locations,
    String query,
  ) {
    if (query.isEmpty) return locations;
    final q = query.toLowerCase();
    return locations
        .where(
          (l) =>
              l.name.toLowerCase().contains(q) ||
              l.category.toLowerCase().contains(q) ||
              l.address.toLowerCase().contains(q),
        )
        .toList();
  }

  static List<LocationModel> filterByCategory(
    List<LocationModel> locations,
    String category,
  ) {
    if (category.isEmpty || category.toLowerCase() == 'all') return locations;
    return locations
        .where((l) => l.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  static List<LocationModel> filterByStatus(
    List<LocationModel> locations,
    String status,
  ) {
    return locations
        .where((l) => l.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  static List<LocationModel> sortByRating(List<LocationModel> locations) {
    final sorted = List<LocationModel>.from(locations);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted;
  }

  static List<LocationModel> sortByWaitTime(List<LocationModel> locations) {
    final sorted = List<LocationModel>.from(locations);
    sorted.sort((a, b) => a.waitTimeMinutes.compareTo(b.waitTimeMinutes));
    return sorted;
  }

  static Future<void> incrementQueue(String locationId, int currentCount) async {
    try {
      final intNumericId = int.tryParse(locationId);
      await Supabase.instance.client
          .from('locations')
          .update({'queue_count': currentCount + 1})
          .eq('id', intNumericId ?? locationId);
    } catch (e) {
      print('Error incrementing queue: $e');
    }
  }

  static Future<void> decrementQueue(String locationId, int currentCount) async {
    if (currentCount <= 0) return;
    try {
      final intNumericId = int.tryParse(locationId);
      await Supabase.instance.client
          .from('locations')
          .update({'queue_count': currentCount - 1})
          .eq('id', intNumericId ?? locationId);
    } catch (e) {
      print('Error decrementing queue: $e');
    }
  }
}