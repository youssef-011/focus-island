import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _webLocalBaseUrl = 'http://localhost:3000';
  static const String _androidEmulatorLocalBaseUrl = 'http://10.0.2.2:3000';
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    if (kIsWeb) {
      return _webLocalBaseUrl;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidEmulatorLocalBaseUrl;
      default:
        return _webLocalBaseUrl;
    }
  }

  static Uri buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }
}
