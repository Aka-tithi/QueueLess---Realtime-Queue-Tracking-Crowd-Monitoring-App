// ignore_for_file: unnecessary_type_check, use_build_context_synchronously, unused_element, use_null_aware_elements, deprecated_member_use, use_super_parameters, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:queueless/models/location_model.dart';
import 'package:queueless/models/user_model.dart';
import 'package:queueless/utils/constants.dart';
import 'package:queueless/services/search_service.dart';
import 'package:queueless/services/favorites_provider.dart';
import 'package:queueless/services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FavoritesProvider _favoritesProvider;
  final SupabaseService _supabaseService = SupabaseService();

  UserModel? _userProfile;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = '';
  List<LocationModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _favoritesProvider = FavoritesProvider();
    _searchResults = mockLocations;
    _fetchBackendProfile();
  }

  Future<void> _fetchBackendProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // সুপাবেস অথেন্টিকেশন সেশন থেকে কারেন্ট ইউজার ডাটা নেওয়া হচ্ছে
      final user = _supabaseService.client.auth.currentUser;
      if (user != null) {
        // মেটাডাটা থেকে নাম নেওয়া হচ্ছে, না থাকলে রেজিস্ট্রেশনের নাম 'tt' ব্যাকআপ রাখা হয়েছে
        String currentUserName = user.userMetadata?['name'] ?? 'tt';
        String currentUserEmail = user.email ?? 'aka@gmail.com';

        setState(() {
          _userProfile = UserModel(
            id: user.id,
            name: currentUserName, // এখানে এখন ডাইনামিক নাম শো করবে
            email: currentUserEmail,
            phone: user.phone ?? '',
            profileImage: '👤',
            status: 'Active',
            totalVisits: 12,
            averageRating: 4.2,
            favoriteCount: 0,
            joinDate: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
            favoriteLocationIds: [],
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching backend profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Profile data update function - Fixed Database Column issue
  Future<void> _updateProfileData({
    required String newName,
    required String newPhone,
    required String newStatus,
    required String newEmoji,
    required String newEmail,
  }) async {
    if (_userProfile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId != null) {
        // সুপাবেসের profiles টেবিলে ডাটা সেভ হচ্ছে
        // আপনার স্ক্রিনশটের এরর ফিক্স করতে 'profile_image' বাদ দিয়ে শুধু name, phone, status পাঠানো হচ্ছে
        await _supabaseService.client
            .from('profiles')
            .update({
              'name': newName,
              'phone': newPhone,
              'status': newStatus,
              // 'profile_image' কলামটি ডাটাবেজে না থাকায় এটি কমেন্ট আউট করা হলো যাতে এরর না আসে।
            })
            .eq('id', userId);

        // অ্যাপের লোকাল স্ক্রিনে বা নিচে ডাটা ইনস্ট্যান্ট আপডেট করার লজিক
        setState(() {
          _userProfile = UserModel(
            id: _userProfile!.id,
            name: newName,
            email: newEmail, // ইমেইল বক্সের নতুন ডাটা এখানে সেট হবে
            phone: newPhone,
            profileImage: newEmoji,
            status: newStatus,
            totalVisits: _userProfile!.totalVisits,
            averageRating: _userProfile!.averageRating,
            favoriteCount: _userProfile!.favoriteCount,
            joinDate: _userProfile!.joinDate,
            favoriteLocationIds: _userProfile!.favoriteLocationIds,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Edit Profile Dialog (Email Box now writable)
  void _showEditProfileDialog() {
    final activeUser = _userProfile ?? mockUser;
    final TextEditingController nameController = TextEditingController(
      text: activeUser.name,
    );
    final TextEditingController phoneController = TextEditingController(
      text: activeUser.phone,
    );
    final TextEditingController statusController = TextEditingController(
      text: activeUser.status,
    );
    final TextEditingController emojiController = TextEditingController(
      text: activeUser.profileImage,
    );
    final TextEditingController emailController = TextEditingController(
      text: activeUser.email,
    ); // ইমেইল কন্ট্রোলার
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: dialogFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Name cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: statusController,
                    decoration: const InputDecoration(
                      labelText: 'Status / Bio',
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emojiController,
                    decoration: const InputDecoration(
                      labelText: 'Profile Avatar Emoji',
                      prefixIcon: Icon(Icons.face),
                      hintText: 'e.g. 👤, 😎',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ইমেইল বক্সটি এখন এডিটেবল (enabled: true) করা হয়েছে
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Email cannot be empty'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _updateProfileData(
                    newName: nameController.text.trim(),
                    newPhone: phoneController.text.trim(),
                    newStatus: statusController.text.trim(),
                    newEmoji: emojiController.text.trim().isEmpty
                        ? '👤'
                        : emojiController.text.trim(),
                    newEmail: emailController.text
                        .trim(), // নতুন ইমেইল পাঠানো হচ্ছে
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filterLocations();
    });
  }

  void _filterLocations() {
    List<LocationModel> results = mockLocations;
    if (_searchQuery.isNotEmpty) {
      results = SearchService.searchLocations(results, _searchQuery);
    }
    if (_selectedCategory.isNotEmpty && _selectedCategory != 'All') {
      results = SearchService.filterByCategory(results, _selectedCategory);
    }
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      );
    }

    final activeUser = _userProfile ?? mockUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          activeUser.profileImage,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        activeUser.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeUser.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activeUser.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryBlue,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  tabs: const [
                    Tab(text: "Activity"),
                    Tab(text: "Favorites"),
                    Tab(text: "Settings"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActivityTab(),
            _buildFavoritesTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Text(location.icon, style: const TextStyle(fontSize: 24)),
            title: Text(
              location.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              location.address,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            trailing: Icon(
              Icons.circle,
              color: location.status == 'busy'
                  ? AppColors.statusBusy
                  : AppColors.statusEmpty,
              size: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    final favoriteLocations = _favoritesProvider.getFavoriteLocations(
      mockLocations,
    );
    if (favoriteLocations.isEmpty) {
      return const Center(child: Text("No favorites added yet."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: favoriteLocations.length,
      itemBuilder: (context, index) {
        final location = favoriteLocations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Text(location.icon, style: const TextStyle(fontSize: 24)),
            title: Text(
              location.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('Wait: ~${location.waitTimeMinutes} mins'),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.statusBusy),
              onPressed: () {
                setState(() {
                  _favoritesProvider.toggleFavorite(location.id);
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        ListTile(
          leading: const Icon(
            Icons.person_outline,
            color: AppColors.primaryBlue,
          ),
          title: const Text(
            "Edit Profile",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showEditProfileDialog(),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.statusBusy),
          title: const Text(
            "Logout",
            style: TextStyle(
              color: AppColors.statusBusy,
              fontFamily: 'Poppins',
            ),
          ),
          onTap: () => _showLogoutDialog(),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusBusy,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _supabaseService.client.auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
