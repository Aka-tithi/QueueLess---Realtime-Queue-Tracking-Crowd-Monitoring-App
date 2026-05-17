// ignore_for_file: prefer_final_fields, use_super_parameters, unused_import

import 'package:flutter/material.dart';
import 'package:queueless/models/location_model.dart';
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
  int _currentIndex = 0;
  String _city = 'Dhaka';

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onProfileTap: () {
          /* TODO: profile */
        },
      ),
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocationBanner(
                city: _city,
                onChange: () {
                  /* TODO */
                },
                onGps: () {
                  /* TODO */
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration.collapsed(
                                  hintText: 'Search locations...',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                /* TODO: filter */
                              },
                              icon: const Icon(
                                Icons.filter_list,
                                color: AppColors.accentTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                      children: const [
                        QuickStatsCard(label: 'Queues Tracked', value: '12'),
                        QuickStatsCard(label: 'Active Locations', value: '8'),
                        QuickStatsCard(label: 'Avg Wait', value: '15 min'),
                        QuickStatsCard(label: 'Avg Rating', value: '4.2★'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Featured
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: mockLocations.length,
                  itemBuilder: (context, index) {
                    final loc = mockLocations[index];
                    return FeaturedLocationCard(
                      location: loc,
                      onTap: () {
                        /* TODO */
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Nearby
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: mockLocations
                      .map(
                        (loc) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: NearbyLocationCard(
                            location: loc,
                            onTap: () {
                              /* TODO */
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      /* TODO: view all */
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
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}
