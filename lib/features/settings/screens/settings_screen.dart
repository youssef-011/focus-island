import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/common/custom_glass_card.dart';
import '../../ambient_sounds/providers/ambient_sound_provider.dart';
import '../../app_state/providers/app_state_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const _SettingsSectionTitle('App'),
            CustomGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SettingsTile(
                    title: 'Focus Island v1.5',
                    subtitle: 'A local-first productivity island by youssef_dev.',
                  ),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    title: 'Active local profile',
                    subtitle: appState.profile.isGuest
                        ? 'Guest Explorer'
                        : (appState.profile.email.isEmpty
                            ? appState.profile.name
                            : appState.profile.email),
                  ),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    title: 'Active API Base URL',
                    subtitle: ApiConfig.baseUrl,
                  ),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    title: 'Unread notifications',
                    subtitle: '${appState.unreadNotificationsCount}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SettingsSectionTitle('Focus'),
            CustomGlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    title: 'Daily focus goal',
                    subtitle:
                        '${appState.todayFocusMinutes} / ${appState.dailyGoalMinutes} minutes today',
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.music_note_rounded,
                      color: AppColors.riverBlue,
                    ),
                    title: const Text(
                      'Ambient sounds',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      appState.ambientSoundPreference.selectedTrackId.isEmpty
                          ? 'Rain and forest loops are available for focus sessions.'
                          : 'Current track: ${appState.ambientSoundPreference.selectedTrackId}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () => Navigator.pushNamed(context, '/sounds'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SettingsSectionTitle('Data'),
            CustomGlassCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.accentMint,
                    ),
                    title: const Text(
                      'Clear notifications',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Remove the current local activity feed.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () => _confirmAction(
                      context,
                      title: 'Clear notifications?',
                      message:
                          'This will remove your current local notifications only.',
                      onConfirm: () async {
                        await context.read<AppStateProvider>().clearNotifications();
                      },
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.warning,
                    ),
                    title: const Text(
                      'Reset island progress',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Clears local sessions, rewards, growth, and achievements.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () => _confirmAction(
                      context,
                      title: 'Reset island progress?',
                      message:
                          'Your local focus history, rewards, achievements, and growth will be cleared. Profile and onboarding data stay intact.',
                      onConfirm: () async {
                        await context.read<AppStateProvider>().resetProgress();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SettingsSectionTitle('Account'),
            CustomGlassCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.warning,
                ),
                title: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Return to the auth entry screen without deleting your local data.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () => _handleLogOut(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldProceed || !context.mounted) {
      return;
    }

    await onConfirm();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings updated successfully.'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Future<void> _handleLogOut(BuildContext context) async {
    final ambientSoundProvider = context.read<AmbientSoundProvider>();
    final authProvider = context.read<AuthProvider>();
    final appStateProvider = context.read<AppStateProvider>();
    final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: const Text(
              'Log out?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Your active session will be cleared, but your local account and progress stay saved on this device.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Log out'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldProceed || !context.mounted) {
      return;
    }

    await ambientSoundProvider.stopPlayback();
    final result = await authProvider.logOut();
    await appStateProvider.reloadForCurrentUser();

    if (!context.mounted) {
      return;
    }

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;

  const _SettingsSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.accentMint,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
