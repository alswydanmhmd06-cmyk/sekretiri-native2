import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/notifications_providers.dart';
import '../domain/notification_item.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'subscription_expiring':
        return Icons.hourglass_bottom_rounded;
      case 'subscription_expired':
        return Icons.lock_clock_rounded;
      case 'message':
        return Icons.chat_bubble_rounded;
      case 'appointment':
        return Icons.calendar_month_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text(
          'الإشعارات',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationsRepositoryProvider).markAllRead();
              ref.invalidate(notificationsProvider);
            },
            child: const Text('تعليم الكل كمقروء'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: state.when(
          data: (result) => result.items.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                  children: const [_EmptyNotifications()],
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: result.items.length,
                  itemBuilder: (c, i) => _NotificationTile(
                    item: result.items[i],
                    icon: _iconFor(result.items[i].type),
                    onTap: () async {
                      if (!result.items[i].isRead) {
                        await ref
                            .read(notificationsRepositoryProvider)
                            .markRead(result.items[i].id);
                        ref.invalidate(notificationsProvider);
                      }
                    },
                  ),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
            children: [
              _ErrorBox(
                message: e.toString(),
                onRetry: () => ref.invalidate(notificationsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.icon,
    required this.onTap,
  });
  final NotificationItem item;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isRead ? AppTheme.borderLight : const Color(0xFFBAE6FD),
        ),
        boxShadow: AppTheme.shadowCard,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppTheme.primaryDark),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.body,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              height: 1.6,
              fontSize: 12.5,
            ),
          ),
        ),
        trailing: item.isRead
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: AppTheme.shadowCard,
    ),
    child: const Column(
      children: [
        Icon(Icons.notifications_none_rounded, size: 52, color: AppTheme.primary),
        SizedBox(height: 14),
        Text(
          'لا توجد إشعارات',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'ستظهر هنا تنبيهات المواعيد والرسائل والاشتراك.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, height: 1.7),
        ),
      ],
    ),
  );
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: AppTheme.shadowCard,
    ),
    child: Column(
      children: [
        const Icon(Icons.cloud_off_rounded, color: AppTheme.error, size: 32),
        const SizedBox(height: 10),
        const Text(
          'تعذر تحميل الإشعارات',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
      ],
    ),
  );
}
