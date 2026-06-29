// ignore_for_file: use_super_parameters, deprecated_member_use, unused_import, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:queueless/models/location_model.dart';
import 'package:queueless/theme/app_theme.dart';
import 'package:queueless/utils/constants.dart';
import 'package:queueless/services/search_service.dart';
import 'package:queueless/services/favorites_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late FavoritesProvider _favoritesProvider;
  List<LocationModel> _searchResults = [];
  String _selectedCategory = '';
  String _selectedStatus = '';
  String _sortBy = 'rating'; // 'rating' or 'waitTime'
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _favoritesProvider = FavoritesProvider();
    _searchResults = mockLocations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    _updateSearchResults();
  }

  void _updateSearchResults() {
    List<LocationModel> results = SearchService.searchLocations(
      mockLocations,
      _searchController.text,
    );

    if (_selectedCategory.isNotEmpty) {
      results = SearchService.filterByCategory(results, _selectedCategory);
    }

    if (_selectedStatus.isNotEmpty) {
      results = SearchService.filterByStatus(results, _selectedStatus);
    }

    if (_sortBy == 'rating') {
      results = SearchService.sortByRating(results);
    } else if (_sortBy == 'waitTime') {
      results = SearchService.sortByWaitTime(results);
    }

    setState(() {
      _searchResults = results;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = '';
      _selectedStatus = '';
      _sortBy = 'rating';
      _isSearching = false;
      _searchResults = mockLocations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Search Locations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryBlue,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _performSearch,
                          decoration: const InputDecoration(
                            hintText: 'Search locations, categories...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterButton(
                        icon: Icons.filter_list,
                        label: 'Filters',
                        onTap: _showFilterModal,
                      ),
                      _buildFilterButton(
                        icon: Icons.sort,
                        label: _sortBy == 'rating' ? 'Rating' : 'Wait Time',
                        onTap: _showSortModal,
                      ),
                      if (_selectedCategory.isNotEmpty ||
                          _selectedStatus.isNotEmpty ||
                          _searchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: _clearFilters,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.statusBusy.withOpacity(0.1),
                                border: Border.all(color: AppColors.statusBusy),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.statusBusy,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.statusBusy,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSearching ? '🔍' : '🏢',
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSearching
                              ? 'No locations found'
                              : 'Enter search term',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSearching
                              ? 'Try different keywords or filters'
                              : 'Search for banks, hospitals, offices...',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final location = _searchResults[index];
                      return _buildSearchResultCard(location);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Banking', 'Healthcare', 'Government', 'Other']
                        .map(
                          (category) => GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _selectedCategory =
                                    _selectedCategory == category
                                    ? ''
                                    : category;
                              });
                              _updateSearchResults();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedCategory == category
                                    ? AppColors.accentTeal
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedCategory == category
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter by Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['empty', 'moderate', 'busy']
                        .map(
                          (status) => GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _selectedStatus = _selectedStatus == status
                                    ? ''
                                    : status;
                              });
                              _updateSearchResults();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedStatus == status
                                    ? _getStatusColor(status)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedStatus == status
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSortOption(
                    title: 'Highest Rating',
                    subtitle: 'Top rated locations first',
                    isSelected: _sortBy == 'rating',
                    onTap: () {
                      setModalState(() => _sortBy = 'rating');
                      _updateSearchResults();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSortOption(
                    title: 'Shortest Wait Time',
                    subtitle: 'Least queue first',
                    isSelected: _sortBy == 'waitTime',
                    onTap: () {
                      setModalState(() => _sortBy = 'waitTime');
                      _updateSearchResults();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.1)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(LocationModel location) {
    final isFavorite = _favoritesProvider.isFavorite(location.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            children: [
              Text(location.icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 15,
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
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _favoritesProvider.toggleFavorite(location.id);
                  setState(() {});
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? AppColors.statusBusy
                      : AppColors.textSecondary,
                  size: 22,
                ),
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
                  vertical: 4,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  const SizedBox(width: 3),
                  Text(
                    location.rating.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 12,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${location.waitTimeMinutes} min',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              // Queue Count
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
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
}
