// ignore_for_file: prefer_final_fields, use_super_parameters, unused_import

import 'package:flutter/material.dart';
import 'package:queueless/models/location_model.dart';
import 'package:queueless/services/supabase_service.dart';
import 'package:queueless/theme/app_theme.dart';
import 'package:queueless/utils/constants.dart';
import 'package:queueless/widgets/custom_app_bar.dart';
import 'package:queueless/widgets/location_banner.dart';
import 'package:queueless/widgets/quick_stats_card.dart';
import 'package:queueless/widgets/featured_location_card.dart';
import 'package:queueless/widgets/nearby_location_card.dart';
import 'package:queueless/widgets/custom_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int _currentIndex = 0;
  String _city = 'Dhaka';
  String _searchQuery = ''; // ফিল্টারিং ও সার্চের জন্য

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  // শহর পরিবর্তনের ডায়ালগ ফাংশন
  Future<void> _showCityDialog() async {
    List<String> cities = ['Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi'];
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text(
          'Select City',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        children: cities
            .map(
              (c) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, c),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  child: Text(c, style: const TextStyle(fontFamily: 'Poppins')),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) setState(() => _city = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onProfileTap: () {
          Navigator.pushNamed(context, '/profile');
        },
      ),
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _supabaseService.getLocationsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
              );
            }

            // ডাটাবেজে ডাটা না থাকলে প্রোফাইলের অ্যাক্টিভিটির মতো mockLocations ব্যাকআপ হিসেবে ব্যবহার হবে
            List<LocationModel> baseLocations = [];
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              baseLocations = snapshot.data!
                  .map((json) => LocationModel.fromJson(json))
                  .toList();
            } else {
              baseLocations = List.from(mockLocations);
            }

            // সিটি ফিল্টার এবং সার্চ লজিক
            List<LocationModel> filteredLocations = baseLocations.where((loc) {
              final String cityName = loc.address.toLowerCase();
              final String locName = loc.name.toLowerCase();

              return cityName.contains(_city.toLowerCase()) &&
                  locName.contains(_searchQuery.toLowerCase());
            }).toList();

            // সেফগার্ড: যদি ফিল্টার করার পর কোনো ডাটা ম্যাচ না করে (যেমন: Khulna এর ডাটা), তবে স্ক্রিন খালি না রেখে baseLocations দেখাবে
            final List<LocationModel> displayLocations =
                filteredLocations.isNotEmpty
                ? filteredLocations
                : baseLocations;

            // কুইক স্ট্যাটসের (Quick Stats) লাইভ ক্যালকুলেশন
            int totalActive = displayLocations.length;
            double avgWait = displayLocations.isEmpty
                ? 0
                : displayLocations
                          .map((l) => l.waitTimeMinutes)
                          .reduce((a, b) => a + b) /
                      totalActive;
            double avgRating = displayLocations.isEmpty
                ? 0
                : displayLocations
                          .map((l) => l.rating)
                          .reduce((a, b) => a + b) /
                      totalActive;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocationBanner(
                    city: _city,
                    onChange:
                        _showCityDialog, // শহর পরিবর্তনের অ্যাকশন কানেক্ট করা হলো
                    onGps: () {
                      /* GPS Logic */
                    },
                  ),

                  // সার্চ বার
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search locations...',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: const Icon(
                          Icons.filter_list,
                          color: AppColors.accentTeal,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ==================== Quick Stats ====================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Stats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            const QuickStatsCard(
                              label: 'Queues Tracked',
                              value: '12',
                            ),
                            QuickStatsCard(
                              label: 'Active Locations',
                              value: '$totalActive',
                            ),
                            QuickStatsCard(
                              label: 'Avg Wait',
                              value: '${avgWait.toStringAsFixed(0)} min',
                            ),
                            QuickStatsCard(
                              label: 'Avg Rating',
                              value: '${avgRating.toStringAsFixed(1)}★',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ==================== Popular Locations ====================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: const Text(
                      'Popular Locations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: displayLocations.isEmpty
                        ? const Center(
                            child: Text(
                              'No popular locations found here.',
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: displayLocations.length,
                            itemBuilder: (context, index) {
                              return FeaturedLocationCard(
                                location: displayLocations[index],
                                onTap: () {
                                  /* Details Screen */
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ==================== Nearby Locations ====================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: const Text(
                      'Nearby Locations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: displayLocations.isEmpty
                        ? const Center(
                            child: Text(
                              'No nearby locations found here.',
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          )
                        : Column(
                            children: displayLocations
                                .map(
                                  (loc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: NearbyLocationCard(
                                      location: loc,
                                      onTap: () {
                                        /* Details Screen */
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),

                  const SizedBox(height: 12),
                  // ==================== View All Locations Button ====================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // এখানে baseLocations (সবগুলো লোকেশন) আর্গুমেন্ট হিসেবে পাঠানো হলো
                          Navigator.pushNamed(
                            context,
                            '/search',
                            arguments: baseLocations,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View All Locations',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
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

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/search');
        break;
      case 2:
        Navigator.pushNamed(context, '/favorites');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}
