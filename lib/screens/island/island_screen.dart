import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/navigation/widgets/focus_drawer.dart';
import '../../features/onboarding/services/onboarding_storage_service.dart';
import '../../widgets/island/floating_particles.dart';
import '../../widgets/island/river_or_sea_widget.dart';

class IslandScreen extends StatefulWidget {
  const IslandScreen({super.key});

  @override
  State<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends State<IslandScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await OnboardingStorageService().getUserName();
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const FocusDrawer(),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const RiverOrSeaWidget(),
          const FloatingParticles(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(),
                        const SizedBox(height: 30),
                        _buildIslandHero(),
                        const SizedBox(height: 40),
                        _buildSectionTitle('Daily Focus'),
                        _buildMainActionCard(
                          title: 'Deep Focus Mode',
                          subtitle: 'Stay focused and grow your forest',
                          icon: Icons.center_focus_strong_rounded,
                          color: AppColors.primaryGreen,
                          onTap: () => Navigator.pushNamed(context, '/deep-focus'),
                        ),
                        const SizedBox(height: 20),
                        _buildGridSection(),
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

  Widget _buildHeader() {
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
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceDark,
                child: Icon(Icons.person_outline_rounded, color: AppColors.accentMint, size: 20),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _userName != null && _userName!.isNotEmpty 
              ? 'Welcome back, $_userName' 
              : 'Welcome back',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your island is waiting to grow.',
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildIslandHero() {
    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.lightGreen.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGreen.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '🌴',
            style: TextStyle(fontSize: 80),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMainActionCard({
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
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                color: color.withOpacity(0.1),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSmallCard(
                title: 'Real Forest',
                icon: Icons.forest_rounded,
                color: AppColors.accentMint,
                onTap: () => Navigator.pushNamed(context, '/real-forest'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmallCard(
                title: 'Leaderboard',
                icon: Icons.leaderboard_rounded,
                color: AppColors.riverBlue,
                onTap: () => Navigator.pushNamed(context, '/leaderboard'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallCard(
                title: 'Rewards',
                icon: Icons.calendar_month_rounded,
                color: AppColors.gold,
                onTap: () => Navigator.pushNamed(context, '/rewards'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmallCard(
                title: 'Premium',
                icon: Icons.star_rounded,
                color: AppColors.accentMint,
                isPlus: true,
                onTap: () => Navigator.pushNamed(context, '/premium'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPlus = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                if (isPlus)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PLUS',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
