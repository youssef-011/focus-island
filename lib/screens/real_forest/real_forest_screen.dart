import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_formatter.dart';
import '../../features/app_state/progress_visuals.dart';
import '../../features/app_state/providers/app_state_provider.dart';
import '../../widgets/common/custom_glass_card.dart';
import '../../widgets/common/empty_state_card.dart';

class RealForestScreen extends StatelessWidget {
  const RealForestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final stage = appState.currentGrowthStage;
    final entries = appState.forestEntries;
    final stageVisual = ProgressVisuals.byKey(stage.visualKey);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Forest'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: stageVisual.backgroundColor.withValues(
                              alpha: 0.22,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            stageVisual.icon,
                            color: stageVisual.iconColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stage.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stage.subtitle,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: appState.growthProgress,
                      minHeight: 10,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.lightGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appState.focusMinutesToNextGrowth == 0
                          ? 'You reached the highest growth stage available in v1.5.'
                          : 'Next evolution in ${appState.focusMinutesToNextGrowth} more focus minutes.',
                      style: const TextStyle(
                        color: AppColors.accentMint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${appState.totalFocusMinutes} focus minutes • ${entries.length} planted items',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Growth History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (entries.isEmpty)
                EmptyStateCard(
                  icon: Icons.forest_outlined,
                  title: 'Your forest is still empty',
                  message:
                      'Complete focus sessions to plant your first item and start a real local growth history.',
                  actionLabel: 'Start Focusing',
                  onActionPressed: () =>
                      Navigator.pushNamed(context, '/deep-focus'),
                )
              else
                ...entries.map((entry) {
                  final visual = ProgressVisuals.byKey(entry.visualKey);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: visual.backgroundColor.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            visual.icon,
                            color: visual.iconColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                entry.description,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Unlocked at ${entry.milestoneFocusMinutes} focus minutes • ${DateTimeFormatter.formatDate(entry.unlockedAt)}',
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
                }),
            ],
          ),
        ),
      ),
    );
  }
}
