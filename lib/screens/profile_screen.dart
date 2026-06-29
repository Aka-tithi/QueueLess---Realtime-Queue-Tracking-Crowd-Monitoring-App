// ignore_for_file: use_null_aware_elements, deprecated_member_use, use_super_parameters, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:queueless/models/location_model.dart';
import 'package:queueless/models/user_model.dart';
import 'package:queueless/utils/constants.dart';
import 'package:queueless/services/search_service.dart';
import 'package:queueless/services/favorites_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FavoritesProvider _favoritesProvider;
  String _searchQuery = '';
  String _selectedCategory = '';
  List<LocationModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _favoritesProvider = FavoritesProvider();
    _searchResults = mockLocations;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filterResults();
    });
  }

  void _filterResults() {
    List<LocationModel> results = SearchService.searchLocations(
      mockLocations,
      _searchQuery,
    );

    if (_selectedCategory.isNotEmpty) {
      results = SearchService.filterByCategory(results, _selectedCategory);
    }

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryBlue,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryBlueDark,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Profile Avatar and User Info
                      Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                mockUser.profileImage,
                                style: const TextStyle(fontSize: 50),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            mockUser.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.accentTeal.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accentTeal,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  mockUser.status,
                                  style: const TextStyle(
                                    color: AppColors.accentTeal,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // User Stats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              title: 'Visits',
                              value: mockUser.totalVisits.toString(),
                              icon: '📍',
                            ),
                            _buildStatCard(
                              title: 'Rating',
                              value: mockUser.averageRating.toString(),
                              icon: '⭐',
                            ),
                            _buildStatCard(
                              title: 'Favorites',
                              value: mockUser.favoriteCount.toString(),
                              icon: '❤️',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Recent'),
                  Tab(text: 'Favorites'),
                  Tab(text: 'Settings'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Recent Activity Tab
            _buildRecentActivityTab(),
            // Favorites Tab
            _buildFavoritesTab(),
            // Settings Tab
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: _updateSearch,
                    decoration: const InputDecoration(
                      hintText: 'Search visited locations...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: _selectedCategory.isEmpty,
                  onTap: () {
                    setState(() => _selectedCategory = '');
                    _filterResults();
                  },
                ),
                _buildFilterChip(
                  label: 'Banking',
                  selected: _selectedCategory == 'Banking',
                  onTap: () {
                    setState(() => _selectedCategory = 'Banking');
                    _filterResults();
                  },
                ),
                _buildFilterChip(
                  label: 'Healthcare',
                  selected: _selectedCategory == 'Healthcare',
                  onTap: () {
                    setState(() => _selectedCategory = 'Healthcare');
                    _filterResults();
                  },
                ),
                _buildFilterChip(
                  label: 'Government',
                  selected: _selectedCategory == 'Government',
                  onTap: () {
                    setState(() => _selectedCategory = 'Government');
                    _filterResults();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Recent Locations List
          if (_searchResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Text('🔍', style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text(
                      'No locations found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Try adjusting your search',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _searchResults
                  .map((location) => _buildLocationCard(location))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final favorites = _favoritesProvider.getFavoriteLocations(mockLocations);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (favorites.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Text('❤️', style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 16),
                    const Text(
                      'No favorites yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start adding locations to your favorites',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                Text(
                  '${favorites.length} Favorite${favorites.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: favorites
                      .map((location) => _buildFavoriteCard(location))
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingSection('Account'),
          _buildSettingItem(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
          ),
          _buildSettingItem(
            icon: Icons.email,
            title: 'Email Address',
            subtitle: mockUser.email,
          ),
          _buildSettingItem(
            icon: Icons.phone,
            title: 'Phone Number',
            subtitle: mockUser.phone,
          ),
          const SizedBox(height: 24),
          _buildSettingSection('Preferences'),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification settings',
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingSection('About'),
          _buildSettingItem(
            icon: Icons.info,
            title: 'About QueueLess',
            subtitle: 'Version 1.0.0',
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                _showLogoutConfirmDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusBusy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          fontFamily: 'Poppins',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
            ),
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildLocationCard(LocationModel location) {
    final isFavorite = _favoritesProvider.isFavorite(location.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(location.icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${location.address} • ${location.category}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber[600]),
                    const SizedBox(width: 3),
                    Text(
                      location.rating.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
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
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
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
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(LocationModel location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Text(location.icon, style: const TextStyle(fontSize: 36)),
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
                  _favoritesProvider.removeFavorite(location.id);
                  setState(() {});
                },
                icon: const Icon(
                  Icons.favorite,
                  color: AppColors.statusBusy,
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
              // Stats Row
              Row(
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
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Wait Time
                  Row(
                    children: [
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
                  const SizedBox(width: 12),
                  // Queue Count
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
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
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentTeal : Colors.white,
          border: Border.all(
            color: selected ? AppColors.accentTeal : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from QueueLess?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusBusy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
