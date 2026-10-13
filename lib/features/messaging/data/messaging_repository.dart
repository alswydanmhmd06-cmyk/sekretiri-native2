import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/message_models.dart';

/// Talks to the existing web messaging endpoints. Authentication rides on the
/// persistent session cookie held by the dio cookie jar, so no extra headers
/// are needed. We deliberately avoid sending an `Origin` header — the backend
/// `requireSameOrigin` check passes when `Origin` is absent (native client).
class MessagingRepository {
  MessagingRepository(this.api);
  final ApiClient api;

  Future<List<ChatContact>> contacts() async {
    final r = await api.dio.get('/api/messages/contacts');
    final list = r.data is Map ? r.data['contacts'] : null;
    return list is List
        ? list
              .whereType<Map>()
              .map((e) => ChatContact.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : const [];
  }

  Future<List<ChatMessage>> messages({
    required int otherId,
    required String otherType,
  }) async {
    final r = await api.dio.get(
      '/api/messages',
      queryParameters: {'otherId': otherId, 'otherType': otherType},
    );
    final list = r.data is Map ? r.data['messages'] : null;
    return list is List
        ? list
              .whereType<Map>()
              .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : const [];
  }

  Future<ChatMessage> send({
    required int receiverId,
    required String receiverType,
    String content = '',
    String? imageDataUrl,
  }) async {
    final r = await api.dio.post(
      '/api/messages',
      data: {
        'receiverId': receiverId,
        'receiverType': receiverType,
        if (content.isNotEmpty) 'content': content,
        if (imageDataUrl != null && imageDataUrl.isNotEmpty)
          'imageUrl': imageDataUrl,
      },
    );
    final m = r.data is Map ? r.data['message'] : null;
    if (m is! Map) {
      throw const FormatException('تعذر إرسال الرسالة.');
    }
    return ChatMessage.fromJson(Map<String, dynamic>.from(m));
  }

  Future<void> delete(int messageId) async {
    await api.dio.delete('/api/messages', queryParameters: {'id': messageId});
  }

  /// Fetches an authenticated attachment (chat image) as raw bytes. The path is
  /// the server-provided relative path `/api/messages/attachments/{id}`.
  Future<Uint8List?> attachment(String path) async {
    final r = await api.dio.get<List<int>>(
      path,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = r.data;
    return data == null ? null : Uint8List.fromList(data);
  }
}
