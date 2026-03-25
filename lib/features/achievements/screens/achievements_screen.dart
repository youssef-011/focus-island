import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../app_state/progress_visuals.dart';
import '../../app_state/providers/app_state_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = context.watch<AppStateProvider>().achievements;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: achievements.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            final visual = ProgressVisuals.byKey(achievement.visualKey);

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? Colors.white.withValues(alpha: 0.09)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: achievement.isUnlocked
                      ? visual.backgroundColor.withValues(alpha: 0.55)
                      : Colors.white24,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: visual.backgroundColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      visual.icon,
                      color: visual.iconColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.isUnlocked
                          ? AppColors.lightGreen
                          : Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    achievement.isUnlocked
                        ? 'Unlocked ${DateTimeFormatter.formatRelativeDate(achievement.unlockedAt!)}'
                        : '${achievement.currentValue}/${achievement.targetValue} progress',
                    style: TextStyle(
                      color: achievement.isUnlocked
                          ? AppColors.accentMint
                          : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
