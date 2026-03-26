import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class OnboardingStorageService {
  static const String guestUserId = 'guest_local';

  static const String _keyActiveUserId = 'focus_island_active_user_id_v15';
  static const String _profileKeyPrefix = 'focus_island_user_profile_v15_';

  static const String _legacyKeyName = 'user_name';
  static const String _legacyKeyEmail = 'user_email';
  static const String _legacyKeyPhone = 'user_phone';
  static const String _legacyKeyCountry = 'user_country';
  static const String _legacyKeyBio = 'user_bio';
  static const String _legacyKeyAvatarId = 'user_avatar_id';
  static const String _legacyKeyOnboardingCompleted = 'onboarding_completed';

  static String buildLocalUserId(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final sanitized = normalizedEmail.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return 'local_${sanitized.isEmpty ? 'user' : sanitized}';
  }

  Future<void> saveUserData({
    required String name,
    required String email,
    required String phone,
    required String country,
    String bio = '',
    String avatarId = 'seed',
    String? userId,
    bool isOnboardingCompleted = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final resolvedUserId =
        userId ?? await _resolveOrCreateActiveUserId(prefs, email: email);
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      return;
    }

    final profile = UserProfile(
      userId: resolvedUserId,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      country: country.trim().toUpperCase(),
      bio: bio.trim(),
      avatarId: avatarId,
      isOnboardingCompleted: isOnboardingCompleted,
    );

    await updateUserProfile(profile);
  }

  Future<void> setActiveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveUserId, userId);
  }

  Future<void> clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveUserId);
  }

  Future<String?> getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return _resolveActiveUserId(prefs);
  }

  Future<void> setOnboardingCompleted(
    bool completed, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final resolvedUserId = userId ?? await _resolveOrCreateActiveUserId(prefs);
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      return;
    }

    final existingProfile = await getUserProfile(userId: resolvedUserId);
    final updatedProfile = existingProfile.copyWith(
      userId: resolvedUserId,
      isOnboardingCompleted: completed,
    );
    await _writeProfile(prefs, updatedProfile);
    await prefs.setString(_keyActiveUserId, resolvedUserId);
  }

  Future<bool> isOnboardingCompleted() async {
    final activeUserId = await getActiveUserId();
    if (activeUserId == null || activeUserId.isEmpty) {
      return false;
    }

    final profile = await getUserProfile(userId: activeUserId);
    return profile.isOnboardingCompleted;
  }

  Future<String> getUserName() async {
    final profile = await getUserProfile();
    return profile.name;
  }

  Future<String> getUserEmail() async {
    final profile = await getUserProfile();
    return profile.email;
  }

  Future<String> getUserPhone() async {
    final profile = await getUserProfile();
    return profile.phone;
  }

  Future<String> getUserCountry() async {
    final profile = await getUserProfile();
    return profile.country;
  }

  Future<String> getUserBio() async {
    final profile = await getUserProfile();
    return profile.bio;
  }

  Future<String> getUserAvatarId() async {
    final profile = await getUserProfile();
    return profile.avatarId;
  }

  Future<UserProfile> getUserProfile({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final resolvedUserId = userId ?? await _resolveActiveUserId(prefs);

    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      return const UserProfile(
        userId: '',
        name: '',
        email: '',
        phone: '',
        country: 'EG',
        bio: '',
        avatarId: 'seed',
      );
    }

    final rawProfile = prefs.getString(_profileKey(resolvedUserId));
    if (rawProfile != null && rawProfile.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawProfile);
        if (decoded is Map) {
          return UserProfile.fromJson(
            Map<String, dynamic>.from(decoded),
          ).copyWith(userId: resolvedUserId);
        }
      } catch (_) {
        // Fall through to an empty profile for this scope.
      }
    }

    final migratedUserId = await _migrateLegacyProfileIfNeeded(prefs);
    if (migratedUserId == resolvedUserId) {
      return getUserProfile(userId: resolvedUserId);
    }

    return UserProfile(
      userId: resolvedUserId,
      name: '',
      email: '',
      phone: '',
      country: 'EG',
      bio: '',
      avatarId: 'seed',
      isOnboardingCompleted: false,
    );
  }

  Future<void> updateUserProfile(
    UserProfile profile, {
    bool setActiveUser = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final resolvedUserId = profile.userId.isNotEmpty
        ? profile.userId
        : await _resolveOrCreateActiveUserId(
            prefs,
            email: profile.email,
          );

    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      return;
    }

    final normalizedProfile = profile.copyWith(
      userId: resolvedUserId,
      email: profile.email.trim().toLowerCase(),
      phone: profile.phone.trim(),
      country: profile.country.trim().toUpperCase(),
      bio: profile.bio.trim(),
    );

    await _writeProfile(prefs, normalizedProfile);
    if (setActiveUser) {
      await prefs.setString(_keyActiveUserId, resolvedUserId);
    }
  }

  Future<void> clearOnboardingData({
    String? userId,
    bool clearActiveUser = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final resolvedUserId = userId ?? await _resolveActiveUserId(prefs);

    if (resolvedUserId != null && resolvedUserId.isNotEmpty) {
      await prefs.remove(_profileKey(resolvedUserId));
      if (clearActiveUser &&
          prefs.getString(_keyActiveUserId) == resolvedUserId) {
        await prefs.remove(_keyActiveUserId);
      }
    }

    await _clearLegacyKeys(prefs);
  }

  Future<void> _writeProfile(
    SharedPreferences prefs,
    UserProfile profile,
  ) async {
    await prefs.setString(
      _profileKey(profile.userId),
      jsonEncode(profile.toJson()),
    );
  }

  String _profileKey(String userId) => '$_profileKeyPrefix$userId';

  Future<String?> _resolveActiveUserId(SharedPreferences prefs) async {
    final rawUserId = prefs.getString(_keyActiveUserId);
    if (rawUserId != null && rawUserId.isNotEmpty) {
      return rawUserId;
    }

    return _migrateLegacyProfileIfNeeded(prefs);
  }

  Future<String?> _resolveOrCreateActiveUserId(
    SharedPreferences prefs, {
    String email = '',
  }) async {
    final existing = await _resolveActiveUserId(prefs);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final fallbackUserId = email.trim().isNotEmpty
        ? buildLocalUserId(email)
        : guestUserId;
    await prefs.setString(_keyActiveUserId, fallbackUserId);
    return fallbackUserId;
  }

  Future<String?> _migrateLegacyProfileIfNeeded(SharedPreferences prefs) async {
    final hasLegacyData = prefs.containsKey(_legacyKeyName) ||
        prefs.containsKey(_legacyKeyEmail) ||
        prefs.containsKey(_legacyKeyPhone) ||
        prefs.containsKey(_legacyKeyCountry) ||
        prefs.containsKey(_legacyKeyBio) ||
        prefs.containsKey(_legacyKeyAvatarId) ||
        prefs.containsKey(_legacyKeyOnboardingCompleted);

    if (!hasLegacyData) {
      return null;
    }

    final legacyEmail = (prefs.getString(_legacyKeyEmail) ?? '').trim();
    final resolvedUserId = legacyEmail.isNotEmpty
        ? buildLocalUserId(legacyEmail)
        : guestUserId;

    final migratedProfile = UserProfile(
      userId: resolvedUserId,
      name: prefs.getString(_legacyKeyName) ??
          (legacyEmail.isEmpty ? 'Guest Explorer' : ''),
      email: legacyEmail.toLowerCase(),
      phone: prefs.getString(_legacyKeyPhone) ?? '',
      country: (prefs.getString(_legacyKeyCountry) ?? 'EG').toUpperCase(),
      bio: prefs.getString(_legacyKeyBio) ?? '',
      avatarId: prefs.getString(_legacyKeyAvatarId) ?? 'seed',
      isOnboardingCompleted:
          prefs.getBool(_legacyKeyOnboardingCompleted) ?? false,
    );

    await _writeProfile(prefs, migratedProfile);
    await prefs.setString(_keyActiveUserId, resolvedUserId);
    await _clearLegacyKeys(prefs);

    return resolvedUserId;
  }

  Future<void> _clearLegacyKeys(SharedPreferences prefs) async {
    await prefs.remove(_legacyKeyName);
    await prefs.remove(_legacyKeyEmail);
    await prefs.remove(_legacyKeyPhone);
    await prefs.remove(_legacyKeyCountry);
    await prefs.remove(_legacyKeyBio);
    await prefs.remove(_legacyKeyAvatarId);
    await prefs.remove(_legacyKeyOnboardingCompleted);
  }
}
