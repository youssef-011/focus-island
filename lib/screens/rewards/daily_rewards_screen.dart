import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_formatter.dart';
import '../../features/app_state/providers/app_state_provider.dart';
import '../../widgets/common/custom_glass_card.dart';
import '../../widgets/common/empty_state_card.dart';

class DailyRewardsScreen extends StatelessWidget {
  const DailyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final rewards = appState.rewardTrack;
    final nextReward = appState.nextAvailableReward;
    final upcomingReward = appState.upcomingReward;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: appState.completedSessionsCount == 0
            ? Center(
                child: EmptyStateCard(
                  icon: Icons.card_giftcard_rounded,
                  title: 'No rewards unlocked yet',
                  message:
                      'Rewards in Focus Island v1.5 come from real completed focus time only.',
                  actionLabel: 'Start Focusing',
                  onActionPressed: () =>
                      Navigator.pushNamed(context, '/deep-focus'),
                ),
              )
            : Column(
                children: [
                  CustomGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reward Track',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextReward != null
                              ? 'Your next reward is ready to claim right now.'
                              : upcomingReward == null
                                  ? 'You have claimed every currently unlocked reward.'
                                  : 'Your next milestone unlocks in ${appState.focusMinutesToNextReward} more focus minutes.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: nextReward == null
                                ? null
                                : () =>
                                    context.read<AppStateProvider>().claimNextReward(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightGreen,
                              foregroundColor: AppColors.background,
                              disabledBackgroundColor:
                                  AppColors.lightGreen.withValues(alpha: 0.35),
                            ),
                            child: Text(
                              nextReward == null
                                  ? 'No Reward Ready'
                                  : 'Claim ${nextReward.title}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: rewards.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: reward.isClaimed
                                ? AppColors.lightGreen.withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: reward.isClaimed
                                  ? AppColors.lightGreen.withValues(alpha: 0.38)
                                  : reward.isAvailable
                                      ? AppColors.gold.withValues(alpha: 0.45)
                                      : Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: reward.isClaimed
                                      ? AppColors.lightGreen.withValues(
                                          alpha: 0.2,
                                        )
                                      : reward.isAvailable
                                          ? AppColors.gold.withValues(alpha: 0.18)
                                          : Colors.white10,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  reward.isClaimed
                                      ? Icons.check_circle_rounded
                                      : reward.isAvailable
                                          ? Icons.card_giftcard_rounded
                                          : Icons.lock_outline_rounded,
                                  color: reward.isClaimed
                                      ? AppColors.accentMint
                                      : reward.isAvailable
                                          ? AppColors.gold
                                          : Colors.white54,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reward.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      reward.description,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      reward.isClaimed
                                          ? 'Claimed ${DateTimeFormatter.formatRelativeDate(reward.claimedAt!)}'
                                          : reward.isAvailable
                                              ? 'Ready to claim now'
                                              : 'Unlocks at ${reward.focusMinuteTarget} focus minutes',
                                      style: TextStyle(
                                        color: reward.isAvailable
                                            ? AppColors.gold
                                            : reward.isClaimed
                                                ? AppColors.accentMint
                                                : Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
