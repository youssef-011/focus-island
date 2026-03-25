import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/deep_focus_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/real_forest_provider.dart';
import 'providers/rewards_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';

import 'screens/deep_focus/deep_focus_screen.dart';
import 'screens/island/island_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/real_forest/real_forest_screen.dart';
import 'screens/rewards/daily_rewards_screen.dart';
import 'features/premium/screens/premium_screen.dart';

import 'features/onboarding/screens/intro_screen.dart';
import 'features/onboarding/services/onboarding_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final onboardingService = OnboardingStorageService();
  final bool isCompleted = await onboardingService.isOnboardingCompleted();
  
  runApp(FocusIslandApp(showOnboarding: !isCompleted));
}

class FocusIslandApp extends StatelessWidget {
  final bool showOnboarding;

  const FocusIslandApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => RealForestProvider()),
        ChangeNotifierProvider(create: (_) => DeepFocusProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Focus Island',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF081C15),
        ),
        initialRoute: showOnboarding ? '/intro' : '/',
        routes: {
          '/': (_) => const IslandScreen(),
          '/intro': (_) => const IntroScreen(),
          '/rewards': (_) => const DailyRewardsScreen(),
          '/leaderboard': (_) => const LeaderboardScreen(),
          '/real-forest': (_) => const RealForestScreen(),
          '/deep-focus': (_) => const DeepFocusScreen(),
          '/premium': (_) => const PremiumScreen(),
        },
      ),
    );
  }
}
