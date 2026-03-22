import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DonationProgressCard extends StatelessWidget {
  final int totalTrees;
  final int nextGoal;

  const DonationProgressCard({
    super.key,
    required this.totalTrees,
    required this.nextGoal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (totalTrees / nextGoal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Forest Impact',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$totalTrees / $nextGoal trees',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(AppColors.lightGreen),
            ),
          ),
        ],
      ),
    );
  }
}