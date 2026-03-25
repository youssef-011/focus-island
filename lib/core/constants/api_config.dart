import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:3000';
  static const String _webBaseUrl = 'http://localhost:3000';

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    if (kIsWeb) {
      return _webBaseUrl;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidEmulatorBaseUrl;
      default:
        return _webBaseUrl;
    }
  }

  static Uri buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }
}
