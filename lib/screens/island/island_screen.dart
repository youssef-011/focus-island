import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../features/app_state/progress_visuals.dart';
import '../../features/app_state/providers/app_state_provider.dart';
import '../../features/navigation/widgets/focus_drawer.dart';
import '../../features/profile/profile_avatar_circle.dart';
import '../../widgets/island/floating_particles.dart';
import '../../widgets/island/river_or_sea_widget.dart';

class IslandScreen extends StatefulWidget {
  const IslandScreen({super.key});

  @override
  State<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends State<IslandScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                              final parsed = int.tryParse(controller.text.trim());
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
      body: Stack(
        children: [
          const RiverOrSeaWidget(),
          const FloatingParticles(),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, $displayName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                appState.completedSessionsCount == 0
                                    ? 'Your island is ready for its first real session.'
                                    : 'Your island is growing from your real local progress.',
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(alpha: 0.82),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 28),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/real-forest'),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primaryGreen.withValues(alpha: 0.92),
                                        AppColors.riverBlue.withValues(alpha: 0.9),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.lightGreen.withValues(alpha: 0.2),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 124,
                                        height: 124,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.18),
                                          ),
                                        ),
                                        child: Icon(
                                          stageVisual.icon,
                                          color: stageVisual.iconColor,
                                          size: 62,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        stage.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        stage.subtitle,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          height: 1.45,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(999),
                                        child: LinearProgressIndicator(
                                          value: appState.growthProgress,
                                          minHeight: 10,
                                          backgroundColor:
                                              Colors.white.withValues(alpha: 0.16),
                                          valueColor: const AlwaysStoppedAnimation(
                                            AppColors.accentMint,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        appState.focusMinutesToNextGrowth == 0
                                            ? 'Tap to review your full forest details.'
                                            : 'Next evolution in ${appState.focusMinutesToNextGrowth} focus minutes. Tap for growth details.',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _DailyGoalCard(
                                todayFocusMinutes: appState.todayFocusMinutes,
                                dailyGoalMinutes: appState.dailyGoalMinutes,
                                remainingMinutes: appState.remainingDailyGoalMinutes,
                                progress: appState.dailyGoalProgress,
                                isGoalReached: appState.isDailyGoalReached,
                                celebratedGoalToday: appState.celebratedGoalToday,
                                onEditGoal: () => _showDailyGoalEditor(appState),
                              ),
                              const SizedBox(height: 30),
                              _buildMainActionCard(
                                context,
                                title: 'Deep Focus Mode',
                                subtitle:
                                    '${appState.currentStreak} day streak • ${appState.totalFocusMinutes} focus minutes',
                                icon: Icons.center_focus_strong_rounded,
                                color: AppColors.primaryGreen,
                                onTap: () => Navigator.pushNamed(context, '/deep-focus'),
                              ),
                              const SizedBox(height: 22),
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
                                          Navigator.pushNamed(context, '/real-forest'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildSmallCard(
                                      title: 'Rewards',
                                      subtitle: appState.nextAvailableReward == null
                                          ? '${appState.claimedRewardsCount} claimed'
                                          : '1 ready to claim',
                                      icon: Icons.card_giftcard_rounded,
                                      color: AppColors.gold,
                                      onTap: () => Navigator.pushNamed(context, '/rewards'),
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
                                          Navigator.pushNamed(context, '/timeline'),
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
                                          Navigator.pushNamed(context, '/statistics'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
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
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
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
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2)),
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
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white70,
                ),
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
