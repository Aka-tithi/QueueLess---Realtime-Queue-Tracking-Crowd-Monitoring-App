// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:queueless/utils/constants.dart';

class LocationBanner extends StatelessWidget {
  final String city;
  final VoidCallback? onChange;
  final VoidCallback? onGps;

  const LocationBanner({
    Key? key,
    this.city = 'Dhaka',
    this.onChange,
    this.onGps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue.withOpacity(0.12),
        border: Border.all(color: AppColors.secondaryBlue, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.accentTeal),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    city,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: onChange,
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: AppColors.accentTeal,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              IconButton(
                onPressed: onGps,
                icon: const Icon(
                  Icons.my_location,
                  color: AppColors.accentTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
