import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../widgets/common/empty_state_card.dart';
import '../../app_state/providers/app_state_provider.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final sessions = appState.focusSessions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: sessions.isEmpty
            ? Center(
                child: EmptyStateCard(
                  icon: Icons.timeline_rounded,
                  title: 'Your focus history starts here',
                  message:
                      'Finish your first focus session and your timeline will begin to reflect real progress.',
                  actionLabel: 'Start a Session',
                  onActionPressed: () =>
                      Navigator.pushNamed(context, '/deep-focus'),
                ),
              )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: sessions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            _categoryIconFor(session.categoryId),
                            color: AppColors.accentMint,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      session.categoryLabel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${session.durationMinutes} min',
                                      style: const TextStyle(
                                        color: AppColors.accentMint,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DateTimeFormatter.formatShortDateTime(
                                  session.completedAt,
                                ),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                session.interruptionCount == 0
                                    ? 'Completed without exit attempts'
                                    : '${session.interruptionCount} exit attempts resisted',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
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
    );
  }
}

IconData _categoryIconFor(String categoryId) {
  switch (categoryId) {
    case 'study':
      return Icons.school_rounded;
    case 'coding':
      return Icons.code_rounded;
    case 'reading':
      return Icons.menu_book_rounded;
    case 'painting':
      return Icons.palette_outlined;
    case 'writing':
      return Icons.edit_note_rounded;
    case 'workout':
      return Icons.fitness_center_rounded;
    case 'meditation':
      return Icons.self_improvement_rounded;
    case 'custom':
      return Icons.label_outline_rounded;
    default:
      return Icons.timer_rounded;
  }
}
