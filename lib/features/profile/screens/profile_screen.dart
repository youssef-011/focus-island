import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/common/custom_glass_card.dart';
import '../../app_state/providers/app_state_provider.dart';
import '../profile_avatar_circle.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final profile = appState.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: AppColors.accentMint),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: Column(
          children: [
            CustomGlassCard(
              child: Column(
                children: [
                  ProfileAvatarCircle(
                    avatarId: profile.avatarId,
                    radius: 38,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    profile.name.isEmpty ? 'Focus Explorer' : profile.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.isGuest
                        ? 'Guest profile on this device'
                        : 'Local account progress on this device',
                    style: const TextStyle(
                      color: AppColors.accentMint,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (profile.bio.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      profile.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoChip(
                        icon: Icons.local_florist_rounded,
                        text: appState.favoriteCategoryLabel,
                      ),
                      _InfoChip(
                        icon: Icons.mail_outline_rounded,
                        text: profile.email,
                      ),
                      _InfoChip(
                        icon: Icons.phone_android_rounded,
                        text: profile.phone,
                      ),
                      _InfoChip(
                        icon: Icons.flag_outlined,
                        text: profile.country,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'Focus Sessions',
                  value: '${appState.completedSessionsCount}',
                ),
                _MetricCard(
                  label: 'Focus Time',
                  value: '${appState.totalFocusMinutes} min',
                ),
                _MetricCard(
                  label: 'Current Streak',
                  value: '${appState.currentStreak} days',
                ),
                _MetricCard(
                  label: 'Longest Session',
                  value: '${appState.longestFocusSessionMinutes} min',
                ),
                _MetricCard(
                  label: 'Planted Items',
                  value: '${appState.plantedItemsCount}',
                ),
                _MetricCard(
                  label: 'Achievements',
                  value: '${appState.unlockedAchievementsCount}',
                ),
                _MetricCard(
                  label: 'Top Category',
                  value: appState.favoriteCategoryLabel,
                ),
                _MetricCard(
                  label: 'Focus Score',
                  value: '${appState.personalFocusScore}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({
    required this.label,
    required this.value,
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
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accentMint, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
