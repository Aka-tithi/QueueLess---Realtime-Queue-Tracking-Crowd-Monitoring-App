// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:queueless/models/location_model.dart';

class FavoritesProvider extends ChangeNotifier {
  List<String> _favoriteIds = ['1', '2', '4', '5'];

  List<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String locationId) {
    return _favoriteIds.contains(locationId);
  }

  void toggleFavorite(String locationId) {
    if (_favoriteIds.contains(locationId)) {
      _favoriteIds.remove(locationId);
    } else {
      _favoriteIds.add(locationId);
    }
    notifyListeners();
  }

  void addFavorite(String locationId) {
    if (!_favoriteIds.contains(locationId)) {
      _favoriteIds.add(locationId);
      notifyListeners();
    }
  }

  void removeFavorite(String locationId) {
    if (_favoriteIds.contains(locationId)) {
      _favoriteIds.remove(locationId);
      notifyListeners();
    }
  }

  List<LocationModel> getFavoriteLocations(List<LocationModel> allLocations) {
    return allLocations
        .where((location) => _favoriteIds.contains(location.id))
        .toList();
  }

  int get favoriteCount => _favoriteIds.length;
}
