import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../data/auth_providers.dart';
import '../data/auth_repository.dart';

/// «نسيت كلمة المرور» — collects the email and asks the server for a reset
/// link. The backend route may not exist yet; in that case the user gets a
/// clear message and a WhatsApp support shortcut.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _done = false;
  String? _error;

  static const _whatsapp = 'https://wa.me/9647858102836';

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).forgotPassword(_email.text);
      if (mounted) setState(() => _done = true);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'تعذر إرسال الطلب. حاول مجدداً.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSupport() async {
    final uri = Uri.tryParse(_whatsapp);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C4A6E), AppTheme.background],
            stops: [0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'رجوع',
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go('/login'),
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0x18FFFFFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'استعادة كلمة المرور',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 30, 28, 16),
                      decoration: const BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(36),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: _done ? _success() : _form(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppTheme.primaryDark,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'نسيت كلمة المرور؟',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'اكتب بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 26),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'البريد الإلكتروني',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'name@example.com',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
          validator: (v) {
            final e = v?.trim() ?? '';
            if (e.isEmpty) return 'أدخل البريد الإلكتروني.';
            if (!e.contains('@') || !e.contains('.')) {
              return 'أدخل بريداً إلكترونياً صالحاً.';
            }
            return null;
          },
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.errorSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.errorBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppTheme.error,
                      height: 1.6,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _openSupport,
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('تواصل مع الدعم عبر واتساب'),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send_rounded),
          label: Text(_loading ? 'جارٍ الإرسال…' : 'إرسال رابط الاستعادة'),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/login'),
            child: const Text('الرجوع إلى تسجيل الدخول'),
          ),
        ),
      ],
    ),
  );

  Widget _success() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 10),
      Center(
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppTheme.success,
            size: 38,
          ),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'تم إرسال الطلب',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 8),
      Text(
        'إذا كان ${_email.text.trim()} مسجلاً لدينا، ستصلك رسالة تحتوي رابط إعادة تعيين كلمة المرور. تفقّد بريدك ومجلد الرسائل غير المرغوب فيها.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textSecondary, height: 1.7),
      ),
      const SizedBox(height: 26),
      FilledButton.icon(
        onPressed: () => context.go('/login'),
        icon: const Icon(Icons.login_rounded),
        label: const Text('العودة لتسجيل الدخول'),
      ),
    ],
  );
}
