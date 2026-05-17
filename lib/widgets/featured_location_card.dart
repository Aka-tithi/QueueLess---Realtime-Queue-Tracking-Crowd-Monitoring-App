// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:queueless/models/location_model.dart';
import 'package:queueless/utils/constants.dart';

class FeaturedLocationCard extends StatelessWidget {
  final LocationModel location;
  final VoidCallback? onTap;

  const FeaturedLocationCard({Key? key, required this.location, this.onTap})
    : super(key: key);

  Color statusColor(String status) {
    switch (status) {
      case 'busy':
        return AppColors.statusBusy;
      case 'moderate':
        return AppColors.statusModerate;
      default:
        return AppColors.statusEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppSpacing.lg / 1.5),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentTeal,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                location.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              location.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              location.address,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: statusColor(location.status),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${location.queueCount} people',
                          style: const TextStyle(
                            color: AppColors.accentTeal,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${location.waitTimeMinutes} min',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
