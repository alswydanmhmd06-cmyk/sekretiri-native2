import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/domain/app_user.dart';
import '../data/messaging_providers.dart';
import '../domain/message_models.dart';
import 'conversation_screen.dart';

/// Embeddable list of conversation contacts. Used both as the doctor's
/// «الرسائل» tab and as a standalone screen reached from the drawer.
class MessagesContactsView extends ConsumerWidget {
  const MessagesContactsView({required this.user, super.key});

  final AppUser user;

  /// The other participant type is always the opposite role.
  String get _otherType => user.isPatient ? 'doctor' : 'patient';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(contactsProvider),
      child: contacts.when(
        data: (list) => list.isEmpty
            ? ListView(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                children: const [_EmptyContacts()],
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: list.length,
                itemBuilder: (c, i) => _ContactTile(
                  contact: list[i],
                  otherType: _otherType,
                  user: user,
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          children: [
            _ErrorBox(
              message: e.toString(),
              onRetry: () => ref.invalidate(contactsProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.otherType,
    required this.user,
  });

  final ChatContact contact;
  final String otherType;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final isDoctorContact = otherType == 'doctor';
    final title = isDoctorContact ? 'د. ${contact.name}' : contact.name;
    final subtitle = isDoctorContact
        ? (contact.specialty ?? '')
        : contact.phone;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadowCard,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          backgroundImage:
              (contact.photoUrl != null && contact.photoUrl!.startsWith('http'))
              ? NetworkImage(contact.photoUrl!)
              : null,
          child: (contact.photoUrl == null || !contact.photoUrl!.startsWith('http'))
              ? Text(
                  contact.name.isNotEmpty ? contact.name.characters.first : '?',
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12.5,
                ),
              ),
        trailing: const Icon(
          Icons.chevron_left_rounded,
          color: AppTheme.textMuted,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConversationScreen(
              user: user,
              otherId: contact.id,
              otherType: otherType,
              title: title,
              subtitle: isDoctorContact ? contact.specialty : null,
              photoUrl: contact.photoUrl,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts();
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
        Icon(Icons.forum_rounded, size: 52, color: AppTheme.primary),
        SizedBox(height: 14),
        Text(
          'لا توجد محادثات بعد',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'تظهر المحادثة بعد إكمال الزيارة والفحص. بعدها تقدر تتواصل مع الطرف الآخر من هنا.',
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
          'تعذر تحميل المحادثات',
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
