import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/deep_focus_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/real_forest_provider.dart';
import 'providers/rewards_provider.dart';

import 'screens/deep_focus/deep_focus_screen.dart';
import 'screens/island/island_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/real_forest/real_forest_screen.dart';
import 'screens/rewards/daily_rewards_screen.dart';

void main() {
  runApp(const FocusIslandApp());
}

class FocusIslandApp extends StatelessWidget {
  const FocusIslandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => RealForestProvider()),
        ChangeNotifierProvider(create: (_) => DeepFocusProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Focus Island',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF081C15),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const IslandScreen(),
          '/rewards': (_) => const DailyRewardsScreen(),
          '/leaderboard': (_) => const LeaderboardScreen(),
          '/real-forest': (_) => const RealForestScreen(),
          '/deep-focus': (_) => const DeepFocusScreen(),
        },
      ),
    );
  }
}