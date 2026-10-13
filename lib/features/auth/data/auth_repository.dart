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

  Future<AppUser> _register({
    required String path,
    required String objectKey,
    required String type,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        path,
        data: body,
      );
      final obj = response.data?[objectKey];
      if (obj is! Map<String, dynamic>) {
        throw const FormatException('لم تصل بيانات حساب صالحة من الخادم.');
      }
      final id = switch (obj['id']) {
        int v => v,
        String v => int.tryParse(v) ?? 0,
        _ => 0,
      };
      final user = AppUser(
        id: id,
        fullName: obj['fullName'] is String ? obj['fullName'] as String : '',
        email: obj['email'] is String ? obj['email'] as String : '',
        type: type,
        isPaid: obj['isPaid'] is bool ? obj['isPaid'] as bool : null,
      );
      await _api.secureStorage.write(
        key: ApiClient.sessionUserStorageKey,
        value: jsonEncode(user.toJson()),
      );
      return user;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<AppUser> registerPatient(Map<String, dynamic> body) => _register(
    path: '/api/auth/register-patient',
    objectKey: 'patient',
    type: 'patient',
    body: body,
  );

  Future<AppUser> registerDoctor(Map<String, dynamic> body) => _register(
    path: '/api/auth/register-doctor',
    objectKey: 'doctor',
    type: 'doctor',
    body: body,
  );

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

  /// Requests a password-reset email. NOTE: the current web backend does not
  /// expose a forgot-password endpoint yet, so this will typically fail with
  /// HTTP 404/405. The UI treats that as «server side not connected yet» and
  /// guides the user to support. Once the backend route
  /// `POST /api/auth/forgot-password {email}` exists, this starts working with
  /// no client change.
  Future<void> forgotPassword(String email) async {
    try {
      await _api.dio.post<Map<String, dynamic>>(
        '/api/auth/forgot-password',
        data: {'email': email.trim().toLowerCase()},
      );
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code == 404 || code == 405 || code == 501) {
        throw const ApiFailure(
          'خدمة استعادة كلمة المرور عبر البريد غير مفعّلة على الخادم بعد. تواصل مع الدعم لإعادة تعيين كلمة المرور.',
          statusCode: 404,
        );
      }
      throw ApiFailure.fromDio(error);
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
