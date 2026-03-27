import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../widgets/common/custom_glass_card.dart';
import '../../../widgets/island/floating_particles.dart';
import '../../../widgets/island/river_or_sea_widget.dart';
import '../../app_state/providers/app_state_provider.dart';
import '../../auth/providers/auth_provider.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  Future<void> _continueAsGuest(BuildContext context) async {
    final result = await context.read<AuthProvider>().continueAsGuest();

    if (!context.mounted) {
      return;
    }

    if (result.isSuccess) {
      await context.read<AppStateProvider>().reloadForCurrentUser();
      if (!context.mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.needsConfiguration
            ? AppColors.riverBlue
            : AppColors.warning,
      ),
    );
  }

  Future<void> _continueWithGoogle(BuildContext context) async {
    final result = await context.read<AuthProvider>().continueWithGoogle();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.needsConfiguration
            ? AppColors.riverBlue
            : AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF071810),
                    AppColors.background,
                    Color(0xFF0E261C),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -90,
            child: _GlowOrb(
              size: 280,
              color: AppColors.riverBlue.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            top: 150,
            left: -80,
            child: _GlowOrb(
              size: 190,
              color: AppColors.primaryGreen.withValues(alpha: 0.16),
            ),
          ),
          const RiverOrSeaWidget(
            height: 270,
            bottomOffset: -56,
            topRadius: 116,
          ),
          const FloatingParticles(
            count: 18,
            color: AppColors.accentMint,
            maxOpacity: 0.14,
            minSize: 3,
            maxSize: 8,
            verticalDrift: 14,
            padding: EdgeInsets.fromLTRB(16, 36, 16, 90),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 42,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.spa_rounded,
                                  size: 15,
                                  color: AppColors.accentMint,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'A calm world that grows with you',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        AnimatedBuilder(
                          animation: _motionController,
                          builder: (context, child) {
                            final transformation = Curves.easeInOutCubic
                                .transform(
                                  (_motionController.value / 0.74).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                );
                            final bloomProgress = Curves.easeOutCubic.transform(
                              ((_motionController.value - 0.36) / 0.64).clamp(
                                0.0,
                                1.0,
                              ),
                            );
                            final stage = bloomProgress > 0.56
                                ? 2
                                : transformation > 0.34
                                ? 1
                                : 0;

                            return Column(
                              children: [
                                _TransformationScene(
                                  transformation: transformation,
                                  bloomProgress: bloomProgress,
                                  stage: stage,
                                ),
                                const SizedBox(height: 10),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 550),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.12),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _IntroStageCopy(
                                    key: ValueKey(stage),
                                    eyebrow: _stageEyebrow(stage),
                                    title: _stageTitle(stage),
                                    body: _stageBody(stage),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        CustomGlassCard(
                          blur: 16,
                          borderRadius: 30,
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Enter Focus Island',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Choose your path gently. Every option below stays connected to the current real onboarding and app-state flow.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _AuthActionButton(
                                label: 'Continue with Google',
                                icon: const _GoogleBadge(),
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.background,
                                onPressed: authProvider.isBusy
                                    ? null
                                    : () => _continueWithGoogle(context),
                              ),
                              const SizedBox(height: 14),
                              _AuthActionButton(
                                label: 'Create New Account',
                                icon: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 22,
                                ),
                                backgroundColor: AppColors.lightGreen,
                                foregroundColor: AppColors.background,
                                onPressed: authProvider.isBusy
                                    ? null
                                    : () => Navigator.pushNamed(
                                        context,
                                        '/create-account',
                                      ),
                              ),
                              const SizedBox(height: 14),
                              _AuthActionButton(
                                label: 'Continue as Guest',
                                icon: const Icon(
                                  Icons.explore_outlined,
                                  size: 22,
                                ),
                                backgroundColor: AppColors.surfaceDark,
                                foregroundColor: Colors.white,
                                onPressed: authProvider.isBusy
                                    ? null
                                    : () => _continueAsGuest(context),
                                outlined: true,
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: TextButton(
                                  onPressed: authProvider.isBusy
                                      ? null
                                      : () => Navigator.pushNamed(
                                          context,
                                          '/sign-in',
                                        ),
                                  child: const Text(
                                    'I already have an account',
                                    style: TextStyle(
                                      color: AppColors.accentMint,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: authProvider.isBusy
                                    ? const Padding(
                                        key: ValueKey('busy'),
                                        padding: EdgeInsets.only(top: 6),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.lightGreen,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('idle'),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Google sign-in remains an honest placeholder until the real integration is configured.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _stageEyebrow(int stage) {
    switch (stage) {
      case 0:
        return 'Still water';
      case 1:
        return 'First life';
      default:
        return 'Living island';
    }
  }

  String _stageTitle(int stage) {
    switch (stage) {
      case 0:
        return 'A quiet shore waits for your first focus.';
      case 1:
        return 'A single session begins to wake the island.';
      default:
        return 'Small rituals become a world that feels alive.';
    }
  }

  String _stageBody(int stage) {
    switch (stage) {
      case 0:
        return 'Start gently with guest mode, a local account, or your future Google sign-in path.';
      case 1:
        return 'Protect your attention and the first signs of growth begin to appear.';
      default:
        return 'Focus Island turns calm sessions into visible progression, not empty promises.';
    }
  }
}

class _TransformationScene extends StatelessWidget {
  const _TransformationScene({
    required this.transformation,
    required this.bloomProgress,
    required this.stage,
  });

  final double transformation;
  final double bloomProgress;
  final int stage;

  @override
  Widget build(BuildContext context) {
    final stageIcon = stage == 0
        ? Icons.water_drop_rounded
        : stage == 1
        ? Icons.spa_rounded
        : Icons.park_rounded;
    final stageColor = stage == 0
        ? AppColors.riverBlue
        : stage == 1
        ? AppColors.accentMint
        : AppColors.lightGreen;
    final islandScale = 0.76 + (transformation * 0.26);
    final lifeScale = 0.82 + (bloomProgress * 0.28);
    final lagoonGlow = 0.16 + (transformation * 0.12);
    final lifeGlow = 0.14 + (bloomProgress * 0.16);

    return SizedBox(
      height: 420,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 18,
            child: Container(
              width: 260 + (bloomProgress * 60),
              height: 260 + (bloomProgress * 60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    stageColor.withValues(alpha: 0.20 + (bloomProgress * 0.14)),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 42,
            left: 12,
            right: 12,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.softBlue.withValues(alpha: lagoonGlow),
                    AppColors.riverBlue.withValues(alpha: 0.34),
                    AppColors.oceanBlue.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 94,
            child: Transform.scale(
              scale: islandScale,
              child: Container(
                width: 244,
                height: 116,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF4E8D6F),
                      AppColors.primaryGreen,
                      Color(0xFF214D3D),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.background.withValues(alpha: 0.26),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 168,
            child: Transform.scale(
              scale: lifeScale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 142,
                    height: 142,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          stageColor.withValues(alpha: lifeGlow),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: bloomProgress,
                    child: Transform.translate(
                      offset: const Offset(-42, -12),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: AppColors.accentMint,
                        size: 24,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: bloomProgress,
                    child: Transform.translate(
                      offset: const Offset(38, -20),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: AppColors.lightGreen,
                        size: 20,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: Container(
                      key: ValueKey(stage),
                      width: stage == 2 ? 126 : 114,
                      height: stage == 2 ? 126 : 114,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: stage == 2 ? 88 : 78,
                          height: stage == 2 ? 88 : 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stageColor.withValues(alpha: 0.22),
                          ),
                          child: Icon(
                            stageIcon,
                            size: stage == 2 ? 44 : 38,
                            color: stage == 0
                                ? Colors.white
                                : AppColors.background,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroStageCopy extends StatelessWidget {
  const _IntroStageCopy({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            eyebrow,
            style: const TextStyle(
              color: AppColors.accentMint,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Focus Island',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthActionButton extends StatelessWidget {
  const _AuthActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: outlined
                ? const BorderSide(color: Colors.white24)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF4285F4),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
