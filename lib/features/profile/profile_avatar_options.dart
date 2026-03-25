import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ProfileAvatarOption {
  final String id;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const ProfileAvatarOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

class ProfileAvatarOptions {
  static const List<ProfileAvatarOption> all = [
    ProfileAvatarOption(
      id: 'seed',
      label: 'Seed',
      icon: Icons.spa_rounded,
      backgroundColor: AppColors.primaryGreen,
      iconColor: Colors.white,
    ),
    ProfileAvatarOption(
      id: 'leaf',
      label: 'Leaf',
      icon: Icons.eco_rounded,
      backgroundColor: AppColors.lightGreen,
      iconColor: AppColors.background,
    ),
    ProfileAvatarOption(
      id: 'tree',
      label: 'Tree',
      icon: Icons.park_rounded,
      backgroundColor: AppColors.riverBlue,
      iconColor: Colors.white,
    ),
    ProfileAvatarOption(
      id: 'island',
      label: 'Island',
      icon: Icons.landscape_rounded,
      backgroundColor: AppColors.oceanBlue,
      iconColor: Colors.white,
    ),
    ProfileAvatarOption(
      id: 'sun',
      label: 'Sun',
      icon: Icons.wb_sunny_rounded,
      backgroundColor: AppColors.gold,
      iconColor: AppColors.background,
    ),
  ];

  static ProfileAvatarOption byId(String? id) {
    return all.firstWhere(
      (option) => option.id == id,
      orElse: () => all.first,
    );
  }
}
