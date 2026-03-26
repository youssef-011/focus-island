import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ProgressVisual {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const ProgressVisual({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

class ProgressVisuals {
  static ProgressVisual byKey(String key) {
    switch (key) {
      case 'sprout':
        return const ProgressVisual(
          icon: Icons.grass_rounded,
          backgroundColor: AppColors.lightGreen,
          iconColor: AppColors.background,
        );
      case 'small_plant':
      case 'leaf':
        return const ProgressVisual(
          icon: Icons.eco_rounded,
          backgroundColor: AppColors.accentMint,
          iconColor: AppColors.background,
        );
      case 'young_tree':
      case 'tree':
        return const ProgressVisual(
          icon: Icons.park_rounded,
          backgroundColor: AppColors.primaryGreen,
          iconColor: Colors.white,
        );
      case 'medium_tree':
        return const ProgressVisual(
          icon: Icons.park_rounded,
          backgroundColor: AppColors.gold,
          iconColor: AppColors.background,
        );
      case 'large_tree':
        return const ProgressVisual(
          icon: Icons.forest_rounded,
          backgroundColor: AppColors.riverBlue,
          iconColor: Colors.white,
        );
      case 'mature_tree':
        return const ProgressVisual(
          icon: Icons.nature_rounded,
          backgroundColor: AppColors.riverBlue,
          iconColor: Colors.white,
        );
      case 'sun':
        return const ProgressVisual(
          icon: Icons.wb_sunny_rounded,
          backgroundColor: AppColors.gold,
          iconColor: AppColors.background,
        );
      case 'river':
        return const ProgressVisual(
          icon: Icons.water_drop_rounded,
          backgroundColor: AppColors.riverBlue,
          iconColor: Colors.white,
        );
      case 'island':
        return const ProgressVisual(
          icon: Icons.landscape_rounded,
          backgroundColor: AppColors.oceanBlue,
          iconColor: Colors.white,
        );
      case 'seed':
      default:
        return const ProgressVisual(
          icon: Icons.spa_rounded,
          backgroundColor: AppColors.primaryGreen,
          iconColor: Colors.white,
        );
    }
  }
}
