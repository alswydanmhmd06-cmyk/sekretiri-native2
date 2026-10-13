import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/auth_providers.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _accountType = 'doctor';
  bool _obscurePassword = true;
  String? _errorMessage;
  late AnimationController _headerCtrl;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: AppTheme.animNormal,
    );
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(
          parent: _headerCtrl,
          curve: Curves.easeOutCubic,
        ));
    _headerFade =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _headerCtrl,
          curve: Curves.easeOut,
        ));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).signIn(
            email: _emailController.text,
            password: _passwordController.text,
            accountType: _accountType,
          );
      if (mounted) context.go('/');
    } on ApiFailure catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              'تعذر تسجيل الدخول. تحقق من البيانات وحاول مجدداً.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C4A6E), AppTheme.background],
            stops: [0.32, 0.32],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  // ── Header (on teal) ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'رجوع',
                            onPressed: () => context.go('/'),
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
                          FadeTransition(
                            opacity: _headerFade,
                            child: SlideTransition(
                              position: _headerSlide,
                              child: Container(
                                width: 48,
                                height: 48,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Image.asset(
                                  'assets/brand/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Form card (white, overlapping the gradient) ──
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
                      decoration: const BoxDecoration(
                        color: AppTheme.background,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(36)),
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Drag handle
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: AppTheme.border,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              // Welcome text
                              Text(
                                'مرحباً بعودتك',
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 8),
                              const Text(
                                'أدخل بيانات حسابك للمتابعة.',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 15,
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 100.ms, duration: 400.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 28),
                              // Account type
                              _FieldLabel('نوع الحساب')
                                  .animate()
                                  .fadeIn(delay: 150.ms, duration: 350.ms),
                              const SizedBox(height: 8),
                              _AccountTypeSelector(
                                value: _accountType,
                                enabled: !isLoading,
                                onChanged: (v) =>
                                    setState(() => _accountType = v),
                              )
                                  .animate()
                                  .fadeIn(
                                      delay: 200.ms, duration: 350.ms)
                                  .slideY(begin: 0.08, end: 0),
                              const SizedBox(height: 22),
                              // Email
                              _FieldLabel('البريد الإلكتروني')
                                  .animate()
                                  .fadeIn(delay: 250.ms, duration: 350.ms),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.email,
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'name@example.com',
                                  prefixIcon:
                                      Icon(Icons.mail_outline_rounded),
                                ),
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty)
                                    return 'أدخل البريد الإلكتروني.';
                                  if (!email.contains('@') ||
                                      !email.contains('.'))
                                    return 'أدخل بريداً إلكترونياً صالحاً.';
                                  return null;
                                },
                              )
                                  .animate()
                                  .fadeIn(
                                      delay: 300.ms, duration: 350.ms)
                                  .slideY(begin: 0.08, end: 0),
                              const SizedBox(height: 18),
                              // Password
                              _FieldLabel('كلمة المرور')
                                  .animate()
                                  .fadeIn(delay: 350.ms, duration: 350.ms),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.password
                                ],
                                onFieldSubmitted: (_) =>
                                    isLoading ? null : _submit(),
                                decoration: InputDecoration(
                                  hintText: 'أدخل كلمة المرور',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'إظهار كلمة المرور'
                                        : 'إخفاء كلمة المرور',
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword =
                                              !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'أدخل كلمة المرور.'
                                        : null,
                              )
                                  .animate()
                                  .fadeIn(
                                      delay: 400.ms, duration: 350.ms)
                                  .slideY(begin: 0.08, end: 0),
                              // Forgot password link
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => context.push('/forgot-password'),
                                  child: const Text('نسيت كلمة المرور؟'),
                                ),
                              ).animate().fadeIn(delay: 420.ms, duration: 350.ms),
                              // Error message
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                _ErrorBanner(message: _errorMessage!)
                                    .animate()
                                    .fadeIn(duration: 250.ms)
                                    .shake(
                                      duration: 400.ms,
                                      delay: 100.ms,
                                      hz: 3,
                                    ),
                              ],
                              const SizedBox(height: 28),
                              // Submit button
                              FilledButton.icon(
                                onPressed: isLoading ? null : _submit,
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(
                                  isLoading
                                      ? 'جارٍ تسجيل الدخول…'
                                      : 'تسجيل الدخول',
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                      delay: 450.ms, duration: 350.ms)
                                  .slideY(begin: 0.12, end: 0),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'ليس لديك حساب؟',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () =>
                                            context.go('/register-patient'),
                                    child: const Text('إنشاء حساب جديد'),
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(delay: 500.ms, duration: 350.ms),
                              const SizedBox(height: 6),
                              // Security note
                              const Text(
                                'تُرسل بيانات الدخول إلى خادم التطبيق عبر HTTPS. لا تُحفظ كلمة المرور على الجهاز.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                  height: 1.6,
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                      delay: 550.ms, duration: 350.ms),
                            ],
                          ),
                        ),
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
}

// ══════════════════════════════════════════════════════════════
//  Sub-widgets
// ══════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: AppTheme.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
  );
}

/// Three horizontal chips — doctor / patient / secretary —
class _AccountTypeSelector extends StatelessWidget {
  const _AccountTypeSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  static const _options = [
    (key: 'doctor', icon: Icons.medical_services_rounded, label: 'طبيب'),
    (key: 'patient', icon: Icons.person_rounded, label: 'مريض'),
    (key: 'secretary', icon: Icons.badge_rounded, label: 'سكرتير'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((opt) {
        final selected = value == opt.key;
        return Expanded(
          child: GestureDetector(
            onTap: enabled ? () => onChanged(opt.key) : null,
            child: AnimatedContainer(
              duration: AppTheme.animNormal,
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary
                    : AppTheme.surfaceDim,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.border,
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(
                    opt.icon,
                    size: 22,
                    color: selected
                        ? Colors.white
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.errorSurface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      border: Border.all(color: AppTheme.errorBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppTheme.error,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Color(0xFFB91C1C),
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}
