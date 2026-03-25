class ApiConfig {
  static const String _defaultBaseUrl =
      'https://focus-island.up.railway.app';
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    return _defaultBaseUrl;
  }

  static Uri buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }
}
