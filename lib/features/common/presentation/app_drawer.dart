import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../messaging/presentation/contacts_screen.dart';

/// Reusable side menu (Drawer) shared by doctor & patient dashboards.
/// Items are ordered by everyday priority for the end user.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({required this.user, super.key});

  final AppUser user;

  static const _appVersion = '0.2.9';
  static const _whatsapp = 'https://wa.me/9647858102836';
  static const _facebook = 'https://www.facebook.com/share/1ENr2oLJ1S/';
  static const _instagram =
      'https://www.instagram.com/sekr_teri?stkn=azV1MGtuZmhtcTc=';

  String get _typeLabel {
    if (user.isPatient) return 'مريض';
    if (user.isSecretary) return 'سكرتير';
    return 'طبيب';
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الرابط')),
      );
    }
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('هذه الميزة ستُضاف في تحديث قادم.')),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).pop();
    context.push('/notifications');
  }

  void _openMessages(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text(
              'الرسائل',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: MessagesContactsView(user: user),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = AppConfig.apiBaseUrl;
    return Drawer(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            _Header(name: user.fullName, email: user.email, type: _typeLabel),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // ── 1) سريع الوصول ──
                  const _SectionLabel('سريع الوصول'),
                  _Item(
                    icon: Icons.chat_bubble_rounded,
                    label: 'الرسائل',
                    onTap: () => _openMessages(context),
                  ),
                  _Item(
                    icon: Icons.notifications_rounded,
                    label: 'الإشعارات',
                    onTap: () => _openNotifications(context),
                  ),
                  _Item(
                    icon: Icons.support_agent_rounded,
                    label: 'المساعدة والدعم',
                    onTap: () => _open(context, _whatsapp),
                  ),

                  const _Divider(),
                  // ── 2) التطبيق ──
                  const _SectionLabel('التطبيق'),
                  _Item(
                    icon: Icons.star_rounded,
                    label: 'قيّم التطبيق',
                    onTap: () => _soon(context),
                  ),
                  _Item(
                    icon: Icons.info_outline_rounded,
                    label: 'حول التطبيق',
                    trailing: const Text(
                      'الإصدار $_appVersion',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'سكرتيري',
                      applicationVersion: 'الإصدار $_appVersion',
                      applicationLegalese: 'نظام إدارة العيادة الذكي',
                    ),
                  ),
                  _Item(
                    icon: Icons.public_rounded,
                    label: 'حسابات التواصل',
                    children: [
                      _SubItem(
                        icon: Icons.chat_rounded,
                        label: 'واتساب',
                        color: const Color(0xFF25D366),
                        onTap: () => _open(context, _whatsapp),
                      ),
                      _SubItem(
                        icon: Icons.camera_alt_rounded,
                        label: 'انستغرام',
                        color: const Color(0xFFDC2743),
                        onTap: () => _open(context, _instagram),
                      ),
                      _SubItem(
                        icon: Icons.facebook_rounded,
                        label: 'فيسبوك',
                        color: const Color(0xFF1877F2),
                        onTap: () => _open(context, _facebook),
                      ),
                    ],
                  ),

                  const _Divider(),
                  // ── 3) قانوني ──
                  const _SectionLabel('قانوني'),
                  _Item(
                    icon: Icons.privacy_tip_rounded,
                    label: 'سياسة الخصوصية',
                    onTap: () => _open(context, '$base/privacy'),
                  ),
                  _Item(
                    icon: Icons.description_rounded,
                    label: 'شروط الاستخدام',
                    onTap: () => _open(context, '$base/terms'),
                  ),
                  _Item(
                    icon: Icons.delete_forever_rounded,
                    label: 'طلب حذف الحساب',
                    danger: true,
                    onTap: () => _open(context, '$base/delete-account'),
                  ),
                ],
              ),
            ),
            const _Divider(),
            // ── تسجيل الخروج ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: _Item(
                icon: Icons.logout_rounded,
                label: 'تسجيل الخروج',
                danger: true,
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(authProvider.notifier).signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Sub-widgets
// ═════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  const _Header({required this.name, required this.email, required this.type});
  final String name, email, type;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
    decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0x33FFFFFF),
              child: Text(
                name.isNotEmpty ? name.characters.first : 'س',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x1FFFFFFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Text(
                type,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name.isEmpty ? 'سكرتيري' : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFE0F2FE), fontSize: 13),
          ),
        ],
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, color: AppTheme.border),
  );
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.children,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final List<Widget>? children;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.error : AppTheme.textPrimary;
    final iconColor = danger ? AppTheme.error : AppTheme.primaryDark;
    final titleStyle = TextStyle(
      color: color,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
    if (children != null && children!.isNotEmpty) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: iconColor),
          title: Text(label, style: titleStyle),
          childrenPadding: const EdgeInsets.only(bottom: 6),
          shape: const Border(),
          children: children!,
        ),
      );
    }
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: titleStyle),
      trailing: trailing,
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.comfortable,
    );
  }
}

class _SubItem extends StatelessWidget {
  const _SubItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsetsDirectional.only(start: 56, end: 16),
    leading: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 19),
    ),
    title: Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    ),
    dense: true,
    onTap: onTap,
  );
}

