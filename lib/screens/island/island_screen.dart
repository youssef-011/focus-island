import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../features/app_state/progress_visuals.dart';
import '../../features/app_state/providers/app_state_provider.dart';
import '../../features/navigation/widgets/focus_drawer.dart';
import '../../features/profile/profile_avatar_circle.dart';
import '../../widgets/common/custom_glass_card.dart';
import '../../widgets/island/floating_particles.dart';
import '../../widgets/island/river_or_sea_widget.dart';

class IslandScreen extends StatefulWidget {
  const IslandScreen({super.key});

  @override
  State<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends State<IslandScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const double _heroEntranceWindow = 0.14;
  late final AnimationController _motionController;
  bool _hasPlayedHeroEntrance = false;

  @override
  void initState() {
    super.initState();
    _motionController =
        AnimationController(vsync: this, duration: const Duration(seconds: 7))
          ..addListener(() {
            if (!_hasPlayedHeroEntrance &&
                _motionController.value >= _heroEntranceWindow) {
              _hasPlayedHeroEntrance = true;
            }
          })
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  Future<void> _showDailyGoalEditor(AppStateProvider appState) async {
    final controller = TextEditingController(
      text: appState.dailyGoalMinutes.toString(),
    );
    var selectedGoal = appState.dailyGoalMinutes;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + bottomInset),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Focus Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Choose a calm target for today. Your goal resets naturally every new day.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [60, 90, 120].map((goal) {
                        final isSelected = selectedGoal == goal;
                        return ChoiceChip(
                          label: Text('$goal min'),
                          selected: isSelected,
                          selectedColor: AppColors.lightGreen.withValues(
                            alpha: 0.25,
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.lightGreen
                                : Colors.white24,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              selectedGoal = goal;
                              controller.text = '$goal';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Custom goal in minutes',
                        hintText: '10 - 360',
                        labelStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null) {
                          return;
                        }
                        selectedGoal = parsed.clamp(10, 360);
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final parsed = int.tryParse(
                                controller.text.trim(),
                              );
                              final goal = (parsed ?? selectedGoal).clamp(
                                10,
                                360,
                              );
                              await appState.updateDailyGoalMinutes(goal);
                              if (!context.mounted) {
                                return;
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightGreen,
                              foregroundColor: AppColors.background,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Save Goal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final profile = appState.profile;
    final stage = appState.currentGrowthStage;
    final stageVisual = ProgressVisuals.byKey(stage.visualKey);
    final displayName = profile.name.trim().isEmpty ? 'Explorer' : profile.name;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const FocusDrawer(),
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _motionController,
        builder: (context, child) {
          final entrancePhase = (_motionController.value / _heroEntranceWindow)
              .clamp(0.0, 1.0);
          final entryBoost = _hasPlayedHeroEntrance
              ? 0.0
              : math.sin(entrancePhase * math.pi);

          return Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF071A13),
                        AppColors.background,
                        Color(0xFF0A241B),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -120,
                right: -80,
                child: _AmbientGlow(
                  size: 260,
                  color: AppColors.riverBlue.withValues(
                    alpha: 0.18 + (entryBoost * 0.10),
                  ),
                ),
              ),
              Positioned(
                top: 210,
                left: -60,
                child: _AmbientGlow(
                  size: 170,
                  color: AppColors.primaryGreen.withValues(
                    alpha: 0.16 + (entryBoost * 0.08),
                  ),
                ),
              ),
              const RiverOrSeaWidget(
                height: 230,
                bottomOffset: -44,
                topRadius: 88,
              ),
              FloatingParticles(
                count: 16,
                color: AppColors.accentMint,
                maxOpacity: 0.11 + (entryBoost * 0.06),
                minSize: 3,
                maxSize: 8 + (entryBoost * 1.4),
                verticalDrift: 12 + (entryBoost * 6),
                padding: const EdgeInsets.fromLTRB(18, 60, 18, 72),
              ),
              SafeArea(
                child: appState.isLoading && !appState.isInitialized
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.lightGreen,
                        ),
                      )
                    : Column(
                        children: [
                          _buildHeader(appState),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ImmersiveHero(
                                    displayName: displayName,
                                    appState: appState,
                                    stageVisual: stageVisual,
                                    motionValue: _motionController.value,
                                    entryBoost: entryBoost,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/real-forest',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  CustomGlassCard(
                                    blur: 16,
                                    borderRadius: 30,
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      18,
                                    ),
                                    child: Column(
                                      children: [
                                        _DailyGoalCard(
                                          todayFocusMinutes:
                                              appState.todayFocusMinutes,
                                          dailyGoalMinutes:
                                              appState.dailyGoalMinutes,
                                          remainingMinutes: appState
                                              .remainingDailyGoalMinutes,
                                          progress: appState.dailyGoalProgress,
                                          isGoalReached:
                                              appState.isDailyGoalReached,
                                          celebratedGoalToday:
                                              appState.celebratedGoalToday,
                                          onEditGoal: () =>
                                              _showDailyGoalEditor(appState),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildMainActionCard(
                                          context,
                                          title: 'Deep Focus Mode',
                                          subtitle:
                                              '${appState.currentStreak} day streak • ${appState.totalFocusMinutes} focus minutes',
                                          icon:
                                              Icons.center_focus_strong_rounded,
                                          color: AppColors.primaryGreen,
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            '/deep-focus',
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildSmallCard(
                                                title: 'Forest',
                                                subtitle:
                                                    '${appState.plantedItemsCount} planted items',
                                                icon: Icons.forest_rounded,
                                                color: AppColors.accentMint,
                                                onTap: () =>
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/real-forest',
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildSmallCard(
                                                title: 'Rewards',
                                                subtitle:
                                                    appState.nextAvailableReward ==
                                                        null
                                                    ? '${appState.claimedRewardsCount} claimed'
                                                    : '1 ready to claim',
                                                icon:
                                                    Icons.card_giftcard_rounded,
                                                color: AppColors.gold,
                                                onTap: () =>
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/rewards',
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildSmallCard(
                                                title: 'Timeline',
                                                subtitle:
                                                    '${appState.completedSessionsCount} recorded sessions',
                                                icon: Icons.timeline_rounded,
                                                color: AppColors.riverBlue,
                                                onTap: () =>
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/timeline',
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildSmallCard(
                                                title: 'Statistics',
                                                subtitle:
                                                    '${appState.totalFocusMinutes} focus minutes',
                                                icon: Icons.bar_chart_rounded,
                                                color: AppColors.lightGreen,
                                                onTap: () =>
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/statistics',
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppStateProvider appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notifications'),
                  ),
                  if (appState.unreadNotificationsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          appState.unreadNotificationsCount > 9
                              ? '9+'
                              : '${appState.unreadNotificationsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: ProfileAvatarCircle(
                  avatarId: appState.profile.avatarId,
                  radius: 18,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImmersiveHero extends StatelessWidget {
  const _ImmersiveHero({
    required this.displayName,
    required this.appState,
    required this.stageVisual,
    required this.motionValue,
    required this.entryBoost,
    required this.onTap,
  });

  final String displayName;
  final AppStateProvider appState;
  final ProgressVisual stageVisual;
  final double motionValue;
  final double entryBoost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pulse = math.sin(motionValue * math.pi * 2);
    final pulseValue = (pulse + 1) / 2;
    final growthStrength = (0.46 + (appState.growthProgress * 0.54)).clamp(
      0.0,
      1.0,
    );
    final stageGlow = Color.lerp(
      AppColors.primaryGreen,
      stageVisual.backgroundColor,
      0.56,
    )!;
    final glowIntensity = entryBoost * 0.14;
    final worldScaleBoost = entryBoost * 0.045;
    final heroScaleBoost = entryBoost * 0.06;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 500,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.22),
                    radius: 0.92,
                    colors: [
                      stageGlow.withValues(
                        alpha: 0.15 + (pulseValue * 0.08) + glowIntensity,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'Welcome back, $displayName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.completedSessionsCount == 0
                        ? 'Your world is still quiet. One real session is enough to wake it.'
                        : 'Your island evolves from real focus, not dashboard filler.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.88),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 108,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  appState.currentGrowthStage.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 144,
              left: 24,
              right: 24,
              child: Text(
                appState.currentGrowthStage.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
            Positioned(
              top: 138,
              child: Container(
                width:
                    (232 + (appState.growthProgress * 54)) *
                    (1 + (entryBoost * 0.08)),
                height:
                    (232 + (appState.growthProgress * 54)) *
                    (1 + (entryBoost * 0.08)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      stageGlow.withValues(
                        alpha: 0.18 + (pulseValue * 0.09) + glowIntensity,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 58,
              left: 10,
              right: 10,
              child: Container(
                height: 154,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.softBlue.withValues(alpha: 0.12),
                      AppColors.riverBlue.withValues(alpha: 0.30),
                      AppColors.oceanBlue.withValues(alpha: 0.68),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              child: Transform.scale(
                scale:
                    0.94 +
                    (appState.growthProgress * 0.10) +
                    (pulse * 0.015) +
                    worldScaleBoost,
                child: Container(
                  width: 236 + (appState.growthProgress * 44),
                  height: 116 + (appState.growthProgress * 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF5A9A77),
                        AppColors.primaryGreen,
                        Color(0xFF224C3B),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.background.withValues(alpha: 0.28),
                        blurRadius: 26 + (entryBoost * 12),
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 162,
              child: Transform.scale(
                scale:
                    0.92 +
                    (appState.growthProgress * 0.16) +
                    (pulse * 0.02) +
                    heroScaleBoost,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            stageGlow.withValues(
                              alpha: 0.16 + (pulseValue * 0.10) + glowIntensity,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: (growthStrength + (entryBoost * 0.20)).clamp(
                        0.0,
                        1.0,
                      ),
                      child: Transform.translate(
                        offset: const Offset(-48, -18),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 24,
                          color: AppColors.accentMint,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: (growthStrength + (entryBoost * 0.20)).clamp(
                        0.0,
                        1.0,
                      ),
                      child: Transform.translate(
                        offset: const Offset(42, -26),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 20,
                          color: AppColors.lightGreen,
                        ),
                      ),
                    ),
                    Container(
                      width: 132 + (appState.growthProgress * 20),
                      height: 132 + (appState.growthProgress * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(
                          alpha: 0.10 + (entryBoost * 0.05),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.12 + (entryBoost * 0.05),
                          ),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 94 + (appState.growthProgress * 14),
                          height: 94 + (appState.growthProgress * 14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stageVisual.backgroundColor.withValues(
                              alpha:
                                  0.24 +
                                  (growthStrength * 0.08) +
                                  (entryBoost * 0.06),
                            ),
                          ),
                          child: Icon(
                            stageVisual.icon,
                            color: stageVisual.iconColor,
                            size: 48 + (appState.growthProgress * 6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 14,
              right: 14,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: appState.growthProgress,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(stageGlow),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    appState.focusMinutesToNextGrowth == 0
                        ? 'This growth arc is complete. Your island now feels fully awake.'
                        : 'Next evolution in ${appState.focusMinutesToNextGrowth} focus minutes.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _HeroStatPill(
                        icon: Icons.local_fire_department_rounded,
                        label: '${appState.currentStreak} day streak',
                      ),
                      _HeroStatPill(
                        icon: Icons.schedule_rounded,
                        label: '${appState.totalFocusMinutes} min focused',
                      ),
                      _HeroStatPill(
                        icon: Icons.eco_rounded,
                        label: '${appState.plantedItemsCount} planted',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.todayFocusMinutes,
    required this.dailyGoalMinutes,
    required this.remainingMinutes,
    required this.progress,
    required this.isGoalReached,
    required this.celebratedGoalToday,
    required this.onEditGoal,
  });

  final int todayFocusMinutes;
  final int dailyGoalMinutes;
  final int remainingMinutes;
  final double progress;
  final bool isGoalReached;
  final bool celebratedGoalToday;
  final VoidCallback onEditGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.riverBlue.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: AppColors.accentMint,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track your real focus minutes for today.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEditGoal,
                icon: const Icon(Icons.edit_outlined, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$todayFocusMinutes / $dailyGoalMinutes min',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                isGoalReached ? AppColors.gold : AppColors.lightGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isGoalReached
                ? 'Today\'s goal is complete. Every extra session now becomes bonus growth for your island.'
                : '$remainingMinutes more minutes to reach today\'s goal.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (celebratedGoalToday || isGoalReached) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                celebratedGoalToday ? 'Goal reached today' : 'Goal complete',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  const _HeroStatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
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

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

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
