// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:queueless/models/location_model.dart';
import 'package:queueless/utils/constants.dart';

class NearbyLocationCard extends StatelessWidget {
  final LocationModel location;
  final VoidCallback? onTap;

  const NearbyLocationCard({Key? key, required this.location, this.onTap})
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    location.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
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
                    const SizedBox(height: 8),
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
                        const SizedBox(width: 8),
                        const Text(
                          '|',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 8),
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
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}
