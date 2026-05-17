import 'package:flutter/material.dart';
import 'package:queueless/utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfileTap;

  const CustomAppBar({Key? key, this.title = 'QueueLess', this.onProfileTap})
    : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 4,
      title: Row(
        children: [
          const Icon(Icons.dashboard, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white, size: 28),
          onPressed: onProfileTap,
        ),
      ],
    );
  }
}
