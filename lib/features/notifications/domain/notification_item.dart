class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
    id: _i(j['id']) ?? 0,
    type: j['type']?.toString() ?? '',
    title: j['title']?.toString() ?? '',
    body: j['body']?.toString() ?? '',
    isRead: j['isRead'] == true,
    createdAt: DateTime.tryParse('${j['createdAt']}')?.toLocal(),
  );
}

class NotificationsResult {
  const NotificationsResult(this.items, this.unreadCount);
  final List<NotificationItem> items;
  final int unreadCount;
}

int? _i(Object? v) => v is int ? v : int.tryParse('$v');
