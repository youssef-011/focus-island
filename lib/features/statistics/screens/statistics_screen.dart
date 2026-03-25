import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../widgets/common/custom_glass_card.dart';
import '../../../widgets/common/empty_state_card.dart';
import '../../app_state/models/app_progress_models.dart';
import '../../app_state/providers/app_state_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final weeklyData = appState.weeklyFocusMinutes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxMinutes = weeklyData.isEmpty
        ? 1
        : weeklyData
            .map((entry) => entry.value)
            .fold<int>(1, (current, value) => value > current ? value : current);
    final categoryStats = appState.categoryStats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: appState.completedSessionsCount == 0
            ? Center(
                child: EmptyStateCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'No focus stats yet',
                  message:
                      'Once you finish a session, your numbers here will reflect real local progress.',
                  actionLabel: 'Start Focusing',
                  onActionPressed: () =>
                      Navigator.pushNamed(context, '/deep-focus'),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatCard(
                          title: 'Sessions',
                          value: '${appState.completedSessionsCount}',
                          subtitle: 'Completed focus sessions',
                        ),
                        _StatCard(
                          title: 'Focus Time',
                          value: '${appState.totalFocusMinutes} min',
                          subtitle: 'Total focused minutes',
                        ),
                        _StatCard(
                          title: 'Longest Session',
                          value: '${appState.longestFocusSessionMinutes} min',
                          subtitle: 'Your deepest single session',
                        ),
                        _StatCard(
                          title: 'Average',
                          value:
                              '${appState.averageFocusMinutes.toStringAsFixed(0)} min',
                          subtitle: 'Average session length',
                        ),
                        _StatCard(
                          title: 'Streak',
                          value: '${appState.currentStreak} days',
                          subtitle: 'Current focus streak',
                        ),
                        _StatCard(
                          title: 'Top Category',
                          value: appState.favoriteCategoryLabel,
                          subtitle: 'Where your time goes most',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Last 7 Days',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Weekly focus time based on your actual completed sessions.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 180,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: weeklyData.map((entry) {
                                final date = DateTime.parse(entry.key);
                                final heightFactor = entry.value / maxMinutes;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${entry.value}',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: FractionallySizedBox(
                                              heightFactor:
                                                  heightFactor.clamp(0.08, 1.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  gradient: const LinearGradient(
                                                    begin: Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      AppColors.primaryGreen,
                                                      AppColors.lightGreen,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          DateTimeFormatter.formatWeekday(date),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category Breakdown',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Focus Island now tracks where your attention actually goes.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...categoryStats.take(5).map(
                            (category) => _CategoryRow(
                              stat: category,
                              totalFocusMinutes: appState.totalFocusMinutes,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Milestones',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _MilestoneRow(
                            label: 'Unlocked achievements',
                            value: '${appState.unlockedAchievementsCount}',
                          ),
                          _MilestoneRow(
                            label: 'Planted items',
                            value: '${appState.plantedItemsCount}',
                          ),
                          _MilestoneRow(
                            label: 'Claimed rewards',
                            value: '${appState.claimedRewardsCount}',
                          ),
                          _MilestoneRow(
                            label: 'Longest streak',
                            value: '${appState.longestStreak} days',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width -
              (AppConstants.screenHorizontalPadding * 2) -
              12) /
          2,
      child: CustomGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final FocusCategoryStat stat;
  final int totalFocusMinutes;

  const _CategoryRow({
    required this.stat,
    required this.totalFocusMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final share = totalFocusMinutes == 0
        ? 0.0
        : (stat.totalMinutes / totalFocusMinutes).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${stat.totalMinutes} min • ${stat.sessionsCount} sessions',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentMint),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final String label;
  final String value;

  const _MilestoneRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
