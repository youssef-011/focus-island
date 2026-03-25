import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class OnboardingStorageService {
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyPhone = 'user_phone';
  static const String _keyCountry = 'user_country';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  Future<void> saveUserData({
    required String name,
    required String email,
    required String phone,
    required String country,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyCountry, country);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? '';
  }

  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone) ?? '';
  }

  Future<String> getUserCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCountry) ?? 'EG';
  }

  Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return UserProfile(
      name: prefs.getString(_keyName) ?? '',
      email: prefs.getString(_keyEmail) ?? '',
      phone: prefs.getString(_keyPhone) ?? '',
      country: prefs.getString(_keyCountry) ?? 'EG',
      isOnboardingCompleted: prefs.getBool(_keyOnboardingCompleted) ?? false,
    );
  }

  Future<void> clearOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyCountry);
    await prefs.remove(_keyOnboardingCompleted);
  }
}
