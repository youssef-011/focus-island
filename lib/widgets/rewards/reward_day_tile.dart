import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reward_day_model.dart';

class RewardDayTile extends StatelessWidget {
  final RewardDayModel day;

  const RewardDayTile({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;

    if (day.isClaimed) {
      bgColor = AppColors.lightGreen.withValues(alpha: 0.22);
      borderColor = AppColors.lightGreen;
    } else if (day.isToday) {
      bgColor = AppColors.gold.withValues(alpha: 0.18);
      borderColor = AppColors.gold;
    } else if (day.isLocked) {
      bgColor = Colors.white.withValues(alpha: 0.05);
      borderColor = Colors.white24;
    } else {
      bgColor = Colors.white.withValues(alpha: 0.08);
      borderColor = Colors.white30;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Day ${day.day}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day.isClaimed ? '🌱' : (day.isToday ? '🌳' : '•'),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              day.rewardTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}