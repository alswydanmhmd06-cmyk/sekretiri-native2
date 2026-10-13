import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/auth_providers.dart';
import '../data/auth_repository.dart';
import 'auth_form_widgets.dart';

class RegisterDoctorScreen extends ConsumerStatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  ConsumerState<RegisterDoctorScreen> createState() =>
      _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState
    extends ConsumerState<RegisterDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _specialty = TextEditingController();
  final _clinicAddress = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fee = TextEditingController();
  final _cv = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _fullName.dispose();
    _specialty.dispose();
    _clinicAddress.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _fee.dispose();
    _cv.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final body = <String, dynamic>{
      'fullName': _fullName.text.trim(),
      'specialty': _specialty.text.trim(),
      'clinicAddress': _clinicAddress.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim().toLowerCase(),
      'password': _password.text,
    };
    final fee = int.tryParse(_fee.text.trim());
    if (fee != null) body['consultationFee'] = fee;
    if (_cv.text.trim().isNotEmpty) body['cv'] = _cv.text.trim();

    try {
      await ref.read(authProvider.notifier).registerDoctor(body);
      if (mounted) context.go('/');
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'تعذر إنشاء الحساب. حاول مجدداً.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    return AuthFormScaffold(
      title: 'حساب طبيب جديد',
      subtitle: 'أنشئ حساب عيادتك لإدارة المواعيد والمرضى.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthFieldLabel('الاسم الكامل'),
              TextFormField(
                controller: _fullName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'د. الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => validateRequired(v, 'الاسم الكامل'),
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('التخصص'),
              TextFormField(
                controller: _specialty,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'مثال: طب الأسنان',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                validator: (v) => validateRequired(v, 'التخصص'),
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('عنوان العيادة'),
              TextFormField(
                controller: _clinicAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'المدينة، الشارع، المبنى',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => validateRequired(v, 'عنوان العيادة'),
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('رقم الهاتف'),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: '07XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: validatePhone,
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('البريد الإلكتروني'),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('كلمة المرور'),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: '8 أحرف على الأقل مع حرف ورقم',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: validatePassword,
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('سعر الكشفية (د.ع)', optional: true),
              TextFormField(
                controller: _fee,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                ],
                decoration: const InputDecoration(
                  hintText: 'مثال: 25000',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('نبذة / السيرة المهنية', optional: true),
              TextFormField(
                controller: _cv,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'الشهادات، الخبرات، سنوات العمل…',
                  alignLabelWithHint: true,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                AuthErrorBanner(message: _error!),
              ],
              const SizedBox(height: 26),
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
                    : const Icon(Icons.verified_user_rounded),
                label: Text(
                  isLoading ? 'جارٍ الإنشاء…' : 'إنشاء الحساب',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'لديك حساب؟',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  TextButton(
                    onPressed:
                        isLoading ? null : () => context.go('/login'),
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
