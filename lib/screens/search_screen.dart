// ignore_for_file: deprecated_member_use, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';
import '../services/favorites_provider.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _category = '';
  String _status = '';
  String _sort = 'rating';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

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

  List<LocationModel> _filter(List<LocationModel> all) {
    var list = all;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((l) => l.name.toLowerCase().contains(q) || l.address.toLowerCase().contains(q) || l.category.toLowerCase().contains(q)).toList();
    }
    if (_category.isNotEmpty) list = list.where((l) => l.category == _category).toList();
    if (_status.isNotEmpty) list = list.where((l) => l.status == _status).toList();
    if (_sort == 'rating') list.sort((a, b) => b.rating.compareTo(a.rating));
    if (_sort == 'wait') list.sort((a, b) => a.waitTimeMinutes.compareTo(b.waitTimeMinutes));
    if (_sort == 'queue') list.sort((a, b) => a.queueCount.compareTo(b.queueCount));
    return list;
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
        title: const Text('Search Locations'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search hospitals, banks, offices...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.close), onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); })
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All', _category.isEmpty, () => setState(() => _category = '')),
                      _filterChip('Healthcare', _category == 'Healthcare', () => setState(() => _category = _category == 'Healthcare' ? '' : 'Healthcare')),
                      _filterChip('Banking', _category == 'Banking', () => setState(() => _category = _category == 'Banking' ? '' : 'Banking')),
                      _filterChip('Government', _category == 'Government', () => setState(() => _category = _category == 'Government' ? '' : 'Government')),
                      const SizedBox(width: 8),
                      _sortChip(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('locations').stream(primaryKey: ['id']),
        builder: (context, snap) {
          final results = _filter(_merge(snap.data));
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text('No locations found', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('Try different keywords', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (_, i) => _locationCard(results[i], fav),
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : Colors.white.withOpacity(0.4)),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? AppColors.primary : Colors.white)),
      ),
    );
  }

  Widget _sortChip() {
    final labels = {'rating': 'Top Rated', 'wait': 'Least Wait', 'queue': 'Least Queue'};
    return GestureDetector(
      onTap: () {
        final keys = labels.keys.toList();
        final next = keys[(keys.indexOf(_sort) + 1) % keys.length];
        setState(() => _sort = next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(labels[_sort]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _locationCard(LocationModel loc, FavoritesProvider fav) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
                    _tag(loc.category, AppColors.primary.withOpacity(0.1), AppColors.primary),
                    const SizedBox(width: 6),
                    _tag(loc.status.toUpperCase(), _statusColor(loc.status).withOpacity(0.1), _statusColor(loc.status)),
                    const Spacer(),
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    Text(' ${loc.rating}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people, size: 12, color: AppColors.textSecondary),
                    Text(' ${loc.queueCount} people', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                    const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                    Text(' ${loc.waitTimeMinutes} min', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => fav.toggleFavorite(loc.id),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(fav.isFavorite(loc.id) ? Icons.favorite : Icons.favorite_border,
                  color: fav.isFavorite(loc.id) ? AppColors.statusBusy : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
  );
}
