// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';
import '../services/favorites_provider.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
    final fav = Provider.of<FavoritesProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Favorites'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text('${fav.count} saved', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('locations').stream(primaryKey: ['id']),
        builder: (context, snap) {
          final all = _merge(snap.data);
          final favorites = fav.getFavorites(all);

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 72, color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No Favorites Yet', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Tap the ♥ on any location to save it here', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (_, i) {
              final loc = favorites[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(loc.icon, style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(loc.address, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: _statusColor(loc.status).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(loc.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: _statusColor(loc.status))),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.people, size: 12, color: AppColors.textSecondary),
                              Text(' ${loc.queueCount}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                              const SizedBox(width: 8),
                              const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                              Text(' ${loc.waitTimeMinutes}min', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => fav.toggleFavorite(loc.id),
                      child: const Icon(Icons.favorite, color: AppColors.statusBusy, size: 26),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
