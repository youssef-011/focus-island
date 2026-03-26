import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../onboarding/models/user_profile.dart';
import '../../onboarding/services/onboarding_storage_service.dart';
import '../models/auth_action_result.dart';
import '../utils/password_hasher.dart';

enum AuthMode {
  guest,
  localAccount,
  google,
}

class AuthLocalStorageService {
  AuthLocalStorageService({
    OnboardingStorageService? onboardingStorageService,
  }) : _onboardingStorageService =
            onboardingStorageService ?? OnboardingStorageService();

  final OnboardingStorageService _onboardingStorageService;

  static const String _keyCurrentAuthMode = 'focus_island_auth_mode';
  static const String _keyLocalAccountEmail = 'focus_island_local_account_email';
  static const String _keyLocalAccountName = 'focus_island_local_account_name';
  static const String _keyLocalAccountPasswordHash =
      'focus_island_local_account_password_hash';
  static const String _keyLocalAccountProfile =
      'focus_island_local_account_profile_json';

  Future<AuthActionResult> createLocalAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final existingEmail = prefs.getString(_keyLocalAccountEmail);

    if (existingEmail != null && existingEmail.isNotEmpty) {
      return const AuthActionResult.failure(
        'A local account already exists on this device. Please sign in instead.',
      );
    }

    final profile = UserProfile(
      userId: OnboardingStorageService.buildLocalUserId(normalizedEmail),
      name: name.trim(),
      email: normalizedEmail,
      phone: '',
      country: 'EG',
      bio: '',
      avatarId: 'seed',
      isOnboardingCompleted: true,
    );

    await prefs.setString(_keyLocalAccountName, profile.name);
    await prefs.setString(_keyLocalAccountEmail, normalizedEmail);
    await prefs.setString(
      _keyLocalAccountPasswordHash,
      PasswordHasher.hash(password),
    );
    await prefs.setString(_keyLocalAccountProfile, jsonEncode(profile.toJson()));
    await prefs.setString(_keyCurrentAuthMode, AuthMode.localAccount.name);

    await _onboardingStorageService.updateUserProfile(profile);
    await _onboardingStorageService.setOnboardingCompleted(
      true,
      userId: profile.userId,
    );

    return const AuthActionResult.success(
      'Your account is ready. Welcome to Focus Island.',
    );
  }

  Future<AuthActionResult> signInWithLocalAccount({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_keyLocalAccountEmail);
    final storedPasswordHash = prefs.getString(_keyLocalAccountPasswordHash);

    if (storedEmail == null || storedPasswordHash == null) {
      return const AuthActionResult.failure(
        'No local account exists on this device yet. Create one first.',
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != storedEmail.trim().toLowerCase()) {
      return const AuthActionResult.failure(
        'We could not find a local account with that email on this device.',
      );
    }

    if (PasswordHasher.hash(password) != storedPasswordHash) {
      return const AuthActionResult.failure(
        'Incorrect password. Please try again.',
      );
    }

    final localUserId = OnboardingStorageService.buildLocalUserId(storedEmail);
    final storedProfile = await _loadLocalAccountProfile(prefs);
    final namespacedProfile = await _onboardingStorageService.getUserProfile(
      userId: localUserId,
    );

    final activeProfile = _resolveLocalAccountProfile(
      storedProfile: storedProfile,
      namespacedProfile: namespacedProfile,
      fallbackName: prefs.getString(_keyLocalAccountName) ?? 'Focus Explorer',
      storedEmail: storedEmail,
      localUserId: localUserId,
    );

    await prefs.setString(_keyCurrentAuthMode, AuthMode.localAccount.name);
    await _onboardingStorageService.updateUserProfile(
      activeProfile.copyWith(isOnboardingCompleted: true),
    );
    await _onboardingStorageService.setOnboardingCompleted(
      true,
      userId: localUserId,
    );

    return const AuthActionResult.success('Welcome back.');
  }

  Future<AuthActionResult> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    final existingGuestProfile = await _onboardingStorageService.getUserProfile(
      userId: OnboardingStorageService.guestUserId,
    );

    final hasExistingGuestData = existingGuestProfile.name.isNotEmpty ||
        existingGuestProfile.bio.isNotEmpty ||
        existingGuestProfile.phone.isNotEmpty ||
        existingGuestProfile.isOnboardingCompleted;

    final guestProfile = hasExistingGuestData
        ? existingGuestProfile.copyWith(isOnboardingCompleted: true)
        : const UserProfile(
            userId: OnboardingStorageService.guestUserId,
            name: 'Guest Explorer',
            email: '',
            phone: '',
            country: 'EG',
            bio: 'Exploring Focus Island in guest mode.',
            avatarId: 'seed',
            isOnboardingCompleted: true,
          );

    await prefs.setString(_keyCurrentAuthMode, AuthMode.guest.name);
    await _onboardingStorageService.updateUserProfile(guestProfile);
    await _onboardingStorageService.setOnboardingCompleted(
      true,
      userId: guestProfile.userId,
    );

    return const AuthActionResult.success('Continuing as guest.');
  }

  Future<AuthActionResult> signInWithGoogle() async {
    return const AuthActionResult.requiresConfiguration(
      'Google sign-in is not configured in this build yet. You can create a local account or continue as guest for now.',
    );
  }

  Future<AuthActionResult> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await _onboardingStorageService.clearActiveSession();
    await prefs.remove(_keyCurrentAuthMode);
    return const AuthActionResult.success('You have been logged out.');
  }

  Future<String?> getSavedLocalAccountEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocalAccountEmail);
  }

  Future<AuthMode?> getCurrentAuthMode() async {
    final prefs = await SharedPreferences.getInstance();
    final rawMode = prefs.getString(_keyCurrentAuthMode);

    if (rawMode == null || rawMode.isEmpty) {
      return null;
    }

    for (final mode in AuthMode.values) {
      if (mode.name == rawMode) {
        return mode;
      }
    }

    return null;
  }

  Future<void> syncCurrentProfileToLocalAccount(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final mode = await getCurrentAuthMode();

    if (mode != AuthMode.localAccount) {
      return;
    }

    final normalizedProfile = profile.copyWith(
      userId: profile.userId.isEmpty
          ? OnboardingStorageService.buildLocalUserId(profile.email)
          : profile.userId,
    );

    await prefs.setString(_keyLocalAccountName, normalizedProfile.name);
    await prefs.setString(_keyLocalAccountEmail, normalizedProfile.email);
    await prefs.setString(
      _keyLocalAccountProfile,
      jsonEncode(normalizedProfile.toJson()),
    );
  }

  UserProfile _resolveLocalAccountProfile({
    required UserProfile? storedProfile,
    required UserProfile namespacedProfile,
    required String fallbackName,
    required String storedEmail,
    required String localUserId,
  }) {
    if (storedProfile != null &&
        (storedProfile.userId.isNotEmpty ||
            storedProfile.name.isNotEmpty ||
            storedProfile.email.isNotEmpty)) {
      return storedProfile.copyWith(userId: localUserId);
    }

    if (namespacedProfile.userId.isNotEmpty &&
        (namespacedProfile.name.isNotEmpty ||
            namespacedProfile.email.isNotEmpty ||
            namespacedProfile.bio.isNotEmpty ||
            namespacedProfile.phone.isNotEmpty)) {
      return namespacedProfile.copyWith(userId: localUserId);
    }

    return UserProfile(
      userId: localUserId,
      name: fallbackName,
      email: storedEmail,
      phone: '',
      country: 'EG',
      bio: '',
      avatarId: 'seed',
      isOnboardingCompleted: true,
    );
  }

  Future<UserProfile?> _loadLocalAccountProfile(SharedPreferences prefs) async {
    final rawProfile = prefs.getString(_keyLocalAccountProfile);
    if (rawProfile == null || rawProfile.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawProfile);
      if (decoded is! Map) {
        return null;
      }

      return UserProfile.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}
