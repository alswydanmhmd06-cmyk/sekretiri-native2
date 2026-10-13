import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/auth_providers.dart';
import '../data/auth_repository.dart';
import 'auth_form_widgets.dart';

class RegisterPatientScreen extends ConsumerStatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  ConsumerState<RegisterPatientScreen> createState() =>
      _RegisterPatientScreenState();
}

class _RegisterPatientScreenState
    extends ConsumerState<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _age = TextEditingController();
  final _chronic = TextEditingController();
  final _allergies = TextEditingController();
  String? _bloodType;
  bool _obscure = true;
  String? _error;

  static const _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _age.dispose();
    _chronic.dispose();
    _allergies.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final body = <String, dynamic>{
      'fullName': _fullName.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim().toLowerCase(),
      'password': _password.text,
    };
    final age = int.tryParse(_age.text.trim());
    if (age != null) body['age'] = age;
    if (_bloodType != null) body['bloodType'] = _bloodType;
    if (_chronic.text.trim().isNotEmpty) {
      body['chronicDiseases'] = _chronic.text.trim();
    }
    if (_allergies.text.trim().isNotEmpty) {
      body['allergies'] = _allergies.text.trim();
    }

    try {
      await ref.read(authProvider.notifier).registerPatient(body);
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
      title: 'حساب مريض جديد',
      subtitle: 'أنشئ حسابك لحجز المواعيد ومتابعة صحتك.',
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
                  hintText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => validateRequired(v, 'الاسم الكامل'),
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
              const AuthFieldLabel('العمر', optional: true),
              TextFormField(
                controller: _age,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: const InputDecoration(
                  hintText: 'مثال: 30',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('فصيلة الدم', optional: true),
              DropdownButtonFormField<String>(
                initialValue: _bloodType,
                decoration: const InputDecoration(
                  hintText: 'اختر فصيلة الدم',
                  prefixIcon: Icon(Icons.bloodtype_outlined),
                ),
                items: _bloodTypes
                    .map((b) =>
                        DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _bloodType = v),
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('أمراض مزمنة', optional: true),
              TextFormField(
                controller: _chronic,
                decoration: const InputDecoration(
                  hintText: 'مثال: ضغط، سكري',
                  prefixIcon: Icon(Icons.monitor_heart_outlined),
                ),
              ),
              const SizedBox(height: 18),
              const AuthFieldLabel('حساسية', optional: true),
              TextFormField(
                controller: _allergies,
                decoration: const InputDecoration(
                  hintText: 'مثال: بنسلين',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
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
                    : const Icon(Icons.person_add_alt_1_rounded),
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
