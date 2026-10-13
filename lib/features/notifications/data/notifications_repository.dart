import '../../../core/network/api_client.dart';
import '../domain/notification_item.dart';

/// In-app notifications served by GET /api/notifications. Marking read uses
/// PATCH {id} for a single item or PATCH {all:true} for the whole list.
class NotificationsRepository {
  NotificationsRepository(this.api);
  final ApiClient api;

  Future<NotificationsResult> list() async {
    final r = await api.dio.get('/api/notifications');
    final data = r.data is Map ? r.data as Map : const {};
    final raw = data['notifications'];
    final items = raw is List
        ? raw
              .whereType<Map>()
              .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <NotificationItem>[];
    final unread = data['unreadCount'] is int
        ? data['unreadCount'] as int
        : items.where((n) => !n.isRead).length;
    return NotificationsResult(items, unread);
  }

  Future<void> markRead(int id) async {
    await api.dio.patch('/api/notifications', data: {'id': id});
  }

  Future<void> markAllRead() async {
    await api.dio.patch('/api/notifications', data: {'all': true});
  }
}
