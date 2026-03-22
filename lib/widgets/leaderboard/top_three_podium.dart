import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/leaderboard_user_model.dart';

class TopThreePodium extends StatelessWidget {
  final List<LeaderboardUserModel> users;

  const TopThreePodium({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    if (users.length < 3) return const SizedBox.shrink();

    final second = users[1];
    final first = users[0];
    final third = users[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _podiumItem(second, 2, 100, AppColors.silver)),
        const SizedBox(width: 12),
        Expanded(child: _podiumItem(first, 1, 140, AppColors.gold)),
        const SizedBox(width: 12),
        Expanded(child: _podiumItem(third, 3, 80, AppColors.bronze)),
      ],
    );
  }

  Widget _podiumItem(
      LeaderboardUserModel user,
      int rank,
      double height,
      Color color,
      ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.25),
          child: Text(
            '$rank',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          user.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${user.trees} trees',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color),
          ),
        ),
      ],
    );
  }
}