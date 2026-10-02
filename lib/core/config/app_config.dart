import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const appName = 'سكرتيري';
  static const _productionApiBaseUrl =
      'https://sekretiri-clinic-feyez4vkk-vvt5.vercel.app';
  static const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    final configured = _configuredApiBaseUrl.trim();
    if (configured.isNotEmpty) return _stripTrailingSlash(configured);

    // Web must be served from the same origin as Next.js because the current
    // API uses SameSite=Strict HttpOnly cookies and does not enable CORS.
    if (kIsWeb && Uri.base.hasScheme && Uri.base.host.isNotEmpty) {
      return _stripTrailingSlash(Uri.base.origin);
    }
    return _productionApiBaseUrl;
  }

  static String _stripTrailingSlash(String value) =>
      value.replaceFirst(RegExp(r'/+$'), '');
}
