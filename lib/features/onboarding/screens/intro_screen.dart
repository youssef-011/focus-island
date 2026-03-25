import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../app_state/providers/app_state_provider.dart';
import '../../auth/providers/auth_provider.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryGreen.withValues(alpha: 0.9),
                        AppColors.riverBlue.withValues(alpha: 0.9),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightGreen.withValues(alpha: 0.22),
                        blurRadius: 30,
                        spreadRadius: 3,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.spa_rounded,
                      size: 62,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  'Focus Island',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Enter gently, protect your focus, and let your island grow from real progress.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.55,
                  ),
                ),
              ),
              const Spacer(),
              _AuthActionButton(
                label: 'Continue with Google',
                icon: const _GoogleBadge(),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.background,
                onPressed:
                    authProvider.isBusy ? null : () => _continueWithGoogle(context),
              ),
              const SizedBox(height: 14),
              _AuthActionButton(
                label: 'Create New Account',
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
                backgroundColor: AppColors.lightGreen,
                foregroundColor: AppColors.background,
                onPressed: authProvider.isBusy
                    ? null
                    : () => Navigator.pushNamed(context, '/create-account'),
              ),
              const SizedBox(height: 14),
              _AuthActionButton(
                label: 'Continue as Guest',
                icon: const Icon(Icons.explore_outlined, size: 22),
                backgroundColor: AppColors.surfaceDark,
                foregroundColor: Colors.white,
                onPressed:
                    authProvider.isBusy ? null : () => _continueAsGuest(context),
                outlined: true,
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: authProvider.isBusy
                      ? null
                      : () => Navigator.pushNamed(context, '/sign-in'),
                  child: const Text(
                    'I already have an account',
                    style: TextStyle(
                      color: AppColors.accentMint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              if (authProvider.isBusy)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.lightGreen,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthActionButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final bool outlined;

  const _AuthActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.outlined = false,
  });

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
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
