import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/ambient_sounds/providers/ambient_sound_provider.dart';
import 'features/ambient_sounds/screens/ambient_sounds_screen.dart';
import 'features/app_state/providers/app_state_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/create_account_screen.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/feedback/services/device_notification_service.dart';
import 'providers/deep_focus_provider.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/statistics/screens/statistics_screen.dart';
import 'features/timeline/screens/timeline_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/achievements/screens/achievements_screen.dart';

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

  await deviceNotificationService.initialize();

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
        ChangeNotifierProvider(create: (_) => AppStateProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AppStateProvider, AmbientSoundProvider>(
          create: (_) => AmbientSoundProvider(),
          update: (_, appState, ambientProvider) {
            final provider = ambientProvider ?? AmbientSoundProvider();
            provider.attachAppState(appState);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<
          AppStateProvider,
          AmbientSoundProvider,
          DeepFocusProvider
        >(
          create: (_) => DeepFocusProvider(),
          update: (_, appState, ambientProvider, deepFocusProvider) {
            final provider = deepFocusProvider ?? DeepFocusProvider();
            provider.attachAppState(appState);
            provider.attachAmbientSound(ambientProvider);
            return provider;
          },
        ),
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
          '/notifications': (_) => const NotificationsScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/timeline': (_) => const TimelineScreen(),
          '/statistics': (_) => const StatisticsScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/achievements': (_) => const AchievementsScreen(),
          '/sounds': (_) => const AmbientSoundsScreen(),
          '/create-account': (_) => const CreateAccountScreen(),
          '/sign-in': (_) => const SignInScreen(),
        },
      ),
    );
  }
}
