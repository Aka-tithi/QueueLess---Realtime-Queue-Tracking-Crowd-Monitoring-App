// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';
import '../services/favorites_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _city = 'Dhaka';
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Healthcare', 'Banking', 'Government'];

  List<LocationModel> _merge(List<Map<String, dynamic>>? db) {
    final combined = List<LocationModel>.from(mockLocations);
    if (db != null) {
      for (final j in db) {
        final loc = LocationModel.fromJson(j);
        if (!combined.any((l) => l.id == loc.id)) combined.add(loc);
      }
    }
    return combined;
  }

  Color _statusColor(String s) {
    if (s == 'busy') return AppColors.statusBusy;
    if (s == 'moderate') return AppColors.statusModerate;
    return AppColors.statusEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final favProv = Provider.of<FavoritesProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('locations').stream(primaryKey: ['id']),
        builder: (context, snap) {
          final all = _merge(snap.data);
          final popular = (List<LocationModel>.from(all)..sort((a, b) => b.rating.compareTo(a.rating))).take(10).toList();
          final filtered = _selectedCategory == 'All' ? all : all.where((l) => l.category == _selectedCategory).toList();
          final avgWait = all.isEmpty ? 0 : (all.map((l) => l.waitTimeMinutes).reduce((a, b) => a + b) / all.length).round();
          final avgRating = all.isEmpty ? 0.0 : (all.map((l) => l.rating).reduce((a, b) => a + b) / all.length);

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.accent, size: 18),
                            const SizedBox(width: 4),
                            Text(_city, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _showCityDialog(),
                              child: Text('Change', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 12, decoration: TextDecoration.underline, decorationColor: AppColors.accent)),
                            ),
                            const Spacer(),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Good day! 👋', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                        Text('Find your queue status', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
                    child: TextField(
                      readOnly: true,
                      onTap: () => Navigator.pushNamed(context, '/search'),
                      decoration: InputDecoration(
                        hintText: 'Search locations...',
                        hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats
                      _sectionTitle('Quick Stats'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _statCard('Queues\nTracked', '${all.length}', Icons.queue, AppColors.primary),
                          const SizedBox(width: 10),
                          _statCard('Active\nLocations', '${all.where((l) => l.status != 'empty').length}', Icons.location_on, AppColors.statusModerate),
                          const SizedBox(width: 10),
                          _statCard('Avg Wait\n(min)', '$avgWait', Icons.timer_outlined, AppColors.statusBusy),
                          const SizedBox(width: 10),
                          _statCard('Avg\nRating', avgRating.toStringAsFixed(1), Icons.star, Colors.amber),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Popular Locations
                      _sectionTitle('⭐ Popular Locations'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 170,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: popular.length,
                          itemBuilder: (_, i) => _popularCard(popular[i], favProv),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category Filter
                      _sectionTitle('📍 Nearby Locations'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (_, i) {
                            final selected = _categories[i] == _selectedCategory;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCategory = _categories[i]),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: selected ? AppColors.primary : AppColors.cardBorder),
                                ),
                                child: Text(_categories[i],
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500,
                                        color: selected ? Colors.white : AppColors.textSecondary)),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filtered.take(6).map((loc) => _nearbyCard(loc, favProv)),
                      const SizedBox(height: 12),

                      // View All Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/search'),
                          icon: const Icon(Icons.list_alt),
                          label: Text('View All Locations (${all.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary));

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(label, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _popularCard(LocationModel loc, FavoritesProvider fav) {
    return GestureDetector(
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.02)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.icon, style: const TextStyle(fontSize: 28)),
                GestureDetector(
                  onTap: () => fav.toggleFavorite(loc.id),
                  child: Icon(fav.isFavorite(loc.id) ? Icons.favorite : Icons.favorite_border,
                      color: fav.isFavorite(loc.id) ? AppColors.statusBusy : AppColors.textSecondary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(loc.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: _statusColor(loc.status).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(loc.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: _statusColor(loc.status))),
            ),
            const SizedBox(height: 4),
            Text('${loc.queueCount} people • ${loc.waitTimeMinutes}min',
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _nearbyCard(LocationModel loc, FavoritesProvider fav) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(loc.icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(loc.address, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: _statusColor(loc.status).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(loc.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: _statusColor(loc.status))),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.people, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text('${loc.queueCount}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text('${loc.waitTimeMinutes}min', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => fav.toggleFavorite(loc.id),
            child: Icon(fav.isFavorite(loc.id) ? Icons.favorite : Icons.favorite_border,
                color: fav.isFavorite(loc.id) ? AppColors.statusBusy : AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showCityDialog() {
    final cities = ['Dhaka', 'Chattogram', 'Sylhet', 'Rajshahi', 'Khulna', 'Barishal'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select City', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: cities.map((c) => ListTile(
            title: Text(c, style: GoogleFonts.poppins()),
            trailing: _city == c ? const Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () { setState(() => _city = c); Navigator.pop(ctx); },
          )).toList(),
        ),
      ),
    );
  }
}
