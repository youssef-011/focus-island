import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../widgets/common/empty_state_card.dart';
import '../../app_state/models/app_progress_models.dart';
import '../../app_state/providers/app_state_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final notifications = appState.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          if (appState.unreadNotificationsCount > 0)
            TextButton(
              onPressed: () => context
                  .read<AppStateProvider>()
                  .markAllNotificationsAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(color: AppColors.accentMint),
              ),
            ),
        ],
      ),
      body: appState.isLoading && !appState.isInitialized
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.lightGreen),
            )
          : Padding(
              padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
              child: notifications.isEmpty
                  ? const Center(
                      child: EmptyStateCard(
                        icon: Icons.notifications_off_rounded,
                        title: 'No notifications yet',
                        message:
                            'Complete focus sessions and claim rewards to build a real activity feed here.',
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return InkWell(
                          onTap: () => context
                              .read<AppStateProvider>()
                              .markNotificationAsRead(notification.id),
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: notification.isRead
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : AppColors.lightGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: notification.isRead
                                    ? Colors.white24
                                    : AppColors.lightGreen.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _NotificationLeading(
                                  type: notification.type,
                                  isRead: notification.isRead,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (!notification.isRead)
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                color: AppColors.accentMint,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        notification.message,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          height: 1.45,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        DateTimeFormatter.formatShortDateTime(
                                          notification.createdAt,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _NotificationLeading extends StatelessWidget {
  final AppNotificationType type;
  final bool isRead;

  const _NotificationLeading({
    required this.type,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      AppNotificationType.focusCompleted => Icons.timer_outlined,
      AppNotificationType.rewardEarned => Icons.card_giftcard_rounded,
      AppNotificationType.streakUpdated => Icons.local_fire_department_rounded,
      AppNotificationType.plantEvolved => Icons.forest_rounded,
      AppNotificationType.challengeCompleted => Icons.emoji_events_rounded,
    };

    final backgroundColor = isRead
        ? Colors.white12
        : AppColors.primaryGreen.withValues(alpha: 0.25);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: isRead ? Colors.white70 : AppColors.accentMint,
      ),
    );
  }
}
