import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_progress_models.dart';

class LocalAppStateService {
  static const String _legacyAppStateKey = 'focus_island_app_state_v15';
  static const String _appStateKeyPrefix = 'focus_island_app_state_v15_';

  Future<AppStateSnapshot> loadState({
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      return AppStateSnapshot.empty();
    }

    final prefs = await SharedPreferences.getInstance();
    final userScopedKey = _keyForUser(userId);
    final rawState = prefs.getString(userScopedKey);

    if (rawState != null && rawState.isNotEmpty) {
      return _decodeSnapshot(rawState);
    }

    final legacyState = prefs.getString(_legacyAppStateKey);
    if (legacyState == null || legacyState.isEmpty) {
      return AppStateSnapshot.empty();
    }

    final snapshot = _decodeSnapshot(legacyState);
    await prefs.setString(userScopedKey, jsonEncode(snapshot.toJson()));
    await prefs.remove(_legacyAppStateKey);
    return snapshot;
  }

  Future<void> saveState(
    String userId,
    AppStateSnapshot snapshot,
  ) async {
    if (userId.trim().isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForUser(userId), jsonEncode(snapshot.toJson()));
  }

  Future<void> clearState(String userId) async {
    if (userId.trim().isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForUser(userId));
  }

  AppStateSnapshot _decodeSnapshot(String rawState) {
    try {
      final decoded = jsonDecode(rawState);
      if (decoded is! Map<String, dynamic>) {
        return AppStateSnapshot.empty();
      }

      return AppStateSnapshot.fromJson(decoded);
    } catch (_) {
      return AppStateSnapshot.empty();
    }
  }

  String _keyForUser(String userId) => '$_appStateKeyPrefix$userId';
}
