// ignore_for_file: unused_import, use_super_parameters, deprecated_member_use, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:queueless/models/location_model.dart';
import 'package:queueless/theme/app_theme.dart';
import 'package:queueless/utils/constants.dart';
import 'package:queueless/services/favorites_provider.dart';
import 'package:queueless/widgets/custom_bottom_navigation.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoritesProvider _favoritesProvider;
  int _currentIndex = 2; // Favorites tab index

  @override
  void initState() {
    super.initState();
    _favoritesProvider = FavoritesProvider();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favoritesProvider.getFavoriteLocations(mockLocations);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'My Favorites',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('❤️', style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  const Text(
                    'No Favorites Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Add locations to your favorites\nfrom search or home screen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/search');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Explore Locations',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentTeal.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: AppColors.accentTeal, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${favorites.length} favorite${favorites.length > 1 ? 's' : ''} saved',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentTeal,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: favorites
                        .map((location) => _buildFavoriteCard(location))
                        .toList(),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _handleNavigation(index);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(LocationModel location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location.icon, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _favoritesProvider.removeFavorite(location.id);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Removed from favorites'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.statusBusy,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.favorite,
                  color: AppColors.statusBusy,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.accentTeal.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  location.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentTeal,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(location.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getStatusColor(location.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  location.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(location.status),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber[600]),
                  const SizedBox(width: 4),
                  Text(
                    location.rating.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${location.waitTimeMinutes} min',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.people, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    location.queueCount.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // TODO: View location details
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'empty':
        return AppColors.statusEmpty;
      case 'moderate':
        return AppColors.statusModerate;
      case 'busy':
        return AppColors.statusBusy;
      default:
        return AppColors.textSecondary;
    }
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/search');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}
