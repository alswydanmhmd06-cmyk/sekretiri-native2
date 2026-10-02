import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import 'browser_credentials_stub.dart'
    if (dart.library.html) 'browser_credentials_web.dart'
    as browser;
import 'secure_cookie_storage.dart';

class ApiClient {
  ApiClient._({
    required this.dio,
    required this.cookieJar,
    required this.secureStorage,
    required this.baseUri,
  });

  final Dio dio;
  final CookieJar cookieJar;
  final FlutterSecureStorage secureStorage;
  final Uri baseUri;

  static const sessionUserStorageKey = 'sekretiri.session.user';

  static Future<ApiClient> create({String? baseUrl}) async {
    final resolvedBaseUrl = (baseUrl ?? AppConfig.apiBaseUrl).trim();
    final baseUri = Uri.parse(resolvedBaseUrl);
    if (!baseUri.hasScheme || baseUri.host.isEmpty) {
      throw ArgumentError.value(
        resolvedBaseUrl,
        'baseUrl',
        'A valid API URL is required.',
      );
    }
    if (baseUri.scheme != 'https' &&
        baseUri.host != 'localhost' &&
        baseUri.host != '10.0.2.2') {
      throw ArgumentError.value(
        resolvedBaseUrl,
        'baseUrl',
        'HTTPS is required except for local development.',
      );
    }

    const secureStorage = FlutterSecureStorage();
    final CookieJar cookieJar;
    if (kIsWeb) {
      // Browser-managed HttpOnly cookies are not readable by Dart/JavaScript.
      cookieJar = WebCookieJar();
    } else {
      final persistentJar = PersistCookieJar(
        persistSession: true,
        ignoreExpires: false,
        storage: SecureCookieStorage(secureStorage),
      );
      await persistentJar.forceInit();
      cookieJar = persistentJar;
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: '${baseUri.origin}/',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );
    browser.configureBrowserCredentials(dio);
    dio.interceptors.add(CookieManager(cookieJar));

    return ApiClient._(
      dio: dio,
      cookieJar: cookieJar,
      secureStorage: secureStorage,
      baseUri: baseUri,
    );
  }

  Future<void> clearSession() async {
    await cookieJar.delete(baseUri);
    await secureStorage.delete(key: sessionUserStorageKey);
  }

  void close() => dio.close(force: true);
}
