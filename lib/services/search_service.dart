import 'package:queueless/models/location_model.dart';

class SearchService {
  static List<LocationModel> searchLocations(
    List<LocationModel> locations,
    String query,
  ) {
    if (query.isEmpty) {
      return locations;
    }

    return locations
        .where(
          (location) =>
              location.name.toLowerCase().contains(query.toLowerCase()) ||
              location.address.toLowerCase().contains(query.toLowerCase()) ||
              location.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  static List<LocationModel> filterByCategory(
    List<LocationModel> locations,
    String category,
  ) {
    if (category.isEmpty) {
      return locations;
    }

    return locations
        .where((location) => location.category == category)
        .toList();
  }

  static List<LocationModel> filterByStatus(
    List<LocationModel> locations,
    String status,
  ) {
    if (status.isEmpty) {
      return locations;
    }

    return locations.where((location) => location.status == status).toList();
  }

  static List<LocationModel> sortByRating(List<LocationModel> locations) {
    final sorted = [...locations];
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted;
  }

  static List<LocationModel> sortByWaitTime(List<LocationModel> locations) {
    final sorted = [...locations];
    sorted.sort((a, b) => a.waitTimeMinutes.compareTo(b.waitTimeMinutes));
    return sorted;
  }
}
