import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<AppUser> signIn({
    required String email,
    required String password,
    required String accountType,
  }) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'type': accountType,
        },
      );
      final userJson = response.data?['user'];
      if (userJson is! Map<String, dynamic>) {
        throw const FormatException('لم تصل بيانات حساب صالحة من الخادم.');
      }
      final user = AppUser.fromJson(userJson);
      await _api.secureStorage.write(
        key: ApiClient.sessionUserStorageKey,
        value: jsonEncode(user.toJson()),
      );
      return user;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  /// Reads only the cached identity shell. It does not call a route that may
  /// mutate application data just to validate a JWT. Each protected API request
  /// remains authoritative; feature repositories must clear on HTTP 401.
  Future<AppUser?> restoreCachedUser() async {
    final encoded = await _api.secureStorage.read(
      key: ApiClient.sessionUserStorageKey,
    );
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) return null;
      return AppUser.fromJson(decoded);
    } on FormatException {
      await _api.clearSession();
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _api.dio.post<void>('/api/auth/logout');
    } on DioException {
      // Clear local secrets even when the device is offline. The server-side
      // JWT expires after 24 hours; a later API request remains server-checked.
    } finally {
      await _api.clearSession();
    }
  }
}

class ApiFailure implements Exception {
  const ApiFailure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiFailure.fromDio(DioException error) {
    final responseData = error.response?.data;
    final message = responseData is Map && responseData['error'] is String
        ? responseData['error'] as String
        : switch (error.type) {
            DioExceptionType.connectionTimeout ||
            DioExceptionType.sendTimeout ||
            DioExceptionType.receiveTimeout =>
              'انتهت مهلة الاتصال. تحقق من الإنترنت ثم أعد المحاولة.',
            DioExceptionType.connectionError =>
              'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.',
            _ => 'تعذر تسجيل الدخول حالياً. حاول مرة أخرى.',
          };
    return ApiFailure(message, statusCode: error.response?.statusCode);
  }

  @override
  String toString() => message;
}
