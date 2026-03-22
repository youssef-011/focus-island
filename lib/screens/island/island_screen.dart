import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/island/floating_particles.dart';
import '../../widgets/island/river_or_sea_widget.dart';

class IslandScreen extends StatelessWidget {
  const IslandScreen({super.key});

  Widget _menuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const RiverOrSeaWidget(),
          const FloatingParticles(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Focus Island V5',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Grow your island, protect your focus, and build a real forest.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGreen,
                              AppColors.lightGreen.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightGreen.withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🌴 🌳 🌸',
                            style: TextStyle(fontSize: 46),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      _menuButton(
                        context,
                        title: 'Daily Rewards',
                        icon: Icons.calendar_month,
                        route: '/rewards',
                      ),
                      const SizedBox(height: 12),
                      _menuButton(
                        context,
                        title: 'Global Ranking',
                        icon: Icons.leaderboard,
                        route: '/leaderboard',
                      ),
                      const SizedBox(height: 12),
                      _menuButton(
                        context,
                        title: 'Real Forest',
                        icon: Icons.forest,
                        route: '/real-forest',
                      ),
                      const SizedBox(height: 12),
                      _menuButton(
                        context,
                        title: 'Deep Focus Mode',
                        icon: Icons.center_focus_strong,
                        route: '/deep-focus',
                      ),
                    ],
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