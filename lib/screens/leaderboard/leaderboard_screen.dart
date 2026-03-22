import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/leaderboard_provider.dart';
import '../../widgets/leaderboard/leaderboard_card.dart';
import '../../widgets/leaderboard/top_three_podium.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = context.watch<LeaderboardProvider>().users;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Global Ranking'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: Column(
          children: [
            TopThreePodium(users: users.take(3).toList()),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return LeaderboardCard(
                    rank: index + 1,
                    user: users[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}