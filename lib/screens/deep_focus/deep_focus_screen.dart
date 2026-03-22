import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/deep_focus_provider.dart';
import '../../widgets/common/animated_warning_overlay.dart';

class DeepFocusScreen extends StatelessWidget {
  const DeepFocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeepFocusProvider>();

    return PopScope(
      canPop: !provider.isRunning,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && provider.isRunning) {
          provider.triggerWarning();
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
                          if (provider.isRunning) {
                            provider.triggerWarning();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Deep Focus Mode',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.formattedTime,
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
                        value: provider.progress,
                        minHeight: 10,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.lightGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Stay with your island.\nEvery second grows your forest.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: provider.isRunning
                                ? provider.stopFocus
                                : provider.startFocus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightGreen,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              provider.isRunning ? 'Pause' : 'Start',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: provider.resetFocus,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Exit attempts: ${provider.exitAttempts}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedWarningOverlay(visible: provider.showWarning),
          ],
        ),
      ),
    );
  }
}