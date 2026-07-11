import 'package:flutter/material.dart';
import '../models/location_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;
  int get count => _favoriteIds.length;

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  List<LocationModel> getFavorites(List<LocationModel> all) =>
      all.where((l) => _favoriteIds.contains(l.id)).toList();
}
