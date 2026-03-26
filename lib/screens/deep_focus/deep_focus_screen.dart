import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../features/app_state/providers/app_state_provider.dart';
import '../../providers/deep_focus_provider.dart';
import '../../widgets/common/animated_warning_overlay.dart';

class DeepFocusScreen extends StatefulWidget {
  const DeepFocusScreen({super.key});

  @override
  State<DeepFocusScreen> createState() => _DeepFocusScreenState();
}

class _DeepFocusScreenState extends State<DeepFocusScreen> {
  final TextEditingController _customCategoryController =
      TextEditingController();
  int _lastCompletionToken = 0;
  bool _didBindCustomCategory = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBindCustomCategory) {
      return;
    }

    final focusProvider = context.read<DeepFocusProvider>();
    _customCategoryController.text = focusProvider.customCategoryLabel;
    _customCategoryController.addListener(() {
      context
          .read<DeepFocusProvider>()
          .setCustomCategoryLabel(_customCategoryController.text);
    });
    _didBindCustomCategory = true;
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusProvider = context.watch<DeepFocusProvider>();
    final appState = context.watch<AppStateProvider>();
    final completionResult = focusProvider.lastCompletionResult;

    if (focusProvider.completionToken != _lastCompletionToken) {
      _lastCompletionToken = focusProvider.completionToken;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: Text(
              completionResult?.dailyGoalReachedNow == true
                  ? 'Session Complete + Goal Reached'
                  : 'Session Complete',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              focusProvider.completionMessage,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  focusProvider.acknowledgeCompletion();
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      });
    }

    return PopScope(
      canPop: !focusProvider.isRunning,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && focusProvider.isRunning) {
          focusProvider.triggerWarning();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () {
                          if (focusProvider.isRunning) {
                            focusProvider.triggerWarning();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            const Text(
                              'Deep Focus Mode',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              focusProvider.canEditSessionSetup
                                  ? 'Set your session gently before you begin.'
                                  : 'Reset the timer if you want to change the session setup.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 22),
                            if (focusProvider.canEditSessionSetup)
                              _SessionSetupCard(
                                controller: _customCategoryController,
                              )
                            else
                              _LockedSetupCard(
                                durationLabel: focusProvider.durationLabel,
                                categoryLabel:
                                    focusProvider.selectedCategoryLabel,
                              ),
                            const SizedBox(height: 28),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _SummaryPill(
                                  icon: Icons.schedule_rounded,
                                  text:
                                      '${focusProvider.selectedDurationMinutes} minutes',
                                ),
                                _SummaryPill(
                                  icon: _categoryIconFor(
                                    focusProvider.selectedCategoryId,
                                  ),
                                  text: focusProvider.selectedCategoryLabel,
                                ),
                              ],
                            ),
                            const SizedBox(height: 26),
                            Text(
                              focusProvider.formattedTime,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 220,
                              child: LinearProgressIndicator(
                                value: focusProvider.progress,
                                minHeight: 10,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.lightGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              appState.completedSessionsCount == 0
                                  ? 'Finish this first session to start your real island growth.'
                                  : 'Every completed session updates your forest, streak, rewards, timeline, and category insights.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Current Streak',
                                      value: '${appState.currentStreak} days',
                                    ),
                                  ),
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Focus Time',
                                      value: '${appState.totalFocusMinutes} min',
                                    ),
                                  ),
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Growth',
                                      value: appState.currentGrowthStage.title,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: focusProvider.isRunning
                                        ? focusProvider.stopFocus
                                        : focusProvider.startFocus,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.lightGreen,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: Text(
                                      focusProvider.isRunning ? 'Pause' : 'Start',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: focusProvider.resetFocus,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white30,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text('Reset'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Exit attempts resisted: ${focusProvider.exitAttempts}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedWarningOverlay(visible: focusProvider.showWarning),
          ],
        ),
      ),
    );
  }
}

class _SessionSetupCard extends StatelessWidget {
  final TextEditingController controller;

  const _SessionSetupCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final focusProvider = context.watch<DeepFocusProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                color: AppColors.accentMint,
              ),
              const SizedBox(width: 10),
              const Text(
                'Session Setup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                focusProvider.durationLabel,
                style: const TextStyle(
                  color: AppColors.accentMint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Focus duration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: focusProvider.selectedDurationMinutes.toDouble(),
            min: DeepFocusProvider.minDurationMinutes.toDouble(),
            max: DeepFocusProvider.maxDurationMinutes.toDouble(),
            divisions:
                (DeepFocusProvider.maxDurationMinutes -
                        DeepFocusProvider.minDurationMinutes) ~/
                    5,
            label: '${focusProvider.selectedDurationMinutes} min',
            activeColor: AppColors.lightGreen,
            inactiveColor: Colors.white12,
            onChanged: (value) {
              context
                  .read<DeepFocusProvider>()
                  .setDurationMinutes(value.round());
            },
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: DeepFocusProvider.quickDurationOptions.map((minutes) {
              final isSelected =
                  focusProvider.selectedDurationMinutes == minutes;

              return ChoiceChip(
                label: Text('$minutes min'),
                selected: isSelected,
                onSelected: (_) => context
                    .read<DeepFocusProvider>()
                    .setDurationMinutes(minutes),
                selectedColor: AppColors.lightGreen.withValues(alpha: 0.26),
                backgroundColor: Colors.white.withValues(alpha: 0.04),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.lightGreen : Colors.white24,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const Text(
            'What are you focusing on?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: DeepFocusProvider.categoryOptions.map((option) {
              final isSelected = focusProvider.selectedCategoryId == option.id;
              return ChoiceChip(
                avatar: Icon(
                  _categoryIconFor(option.id),
                  size: 18,
                  color: isSelected ? AppColors.accentMint : Colors.white70,
                ),
                label: Text(option.label),
                selected: isSelected,
                onSelected: (_) =>
                    context.read<DeepFocusProvider>().selectCategory(option.id),
                selectedColor: AppColors.primaryGreen.withValues(alpha: 0.28),
                backgroundColor: Colors.white.withValues(alpha: 0.04),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.lightGreen : Colors.white24,
                ),
              );
            }).toList(),
          ),
          if (focusProvider.selectedCategoryId == 'custom') ...[
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLength: 24,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                counterStyle: const TextStyle(color: Colors.white38),
                hintText: 'Add your custom focus label',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LockedSetupCard extends StatelessWidget {
  final String durationLabel;
  final String categoryLabel;

  const _LockedSetupCard({
    required this.durationLabel,
    required this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LockedSetupItem(
              label: 'Duration',
              value: durationLabel,
            ),
          ),
          Expanded(
            child: _LockedSetupItem(
              label: 'Category',
              value: categoryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedSetupItem extends StatelessWidget {
  final String label;
  final String value;

  const _LockedSetupItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accentMint, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
