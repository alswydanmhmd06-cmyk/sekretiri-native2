import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../ads/presentation/ads_carousel.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C4A6E),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Hero section (teal) ──
                  _HeroSection(),
                  // ── White sheet: ads + actions ──
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: _BottomSection(),
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
//  Hero — logo, tagline, benefits (all on teal gradient)
// ══════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _LanguageBadge()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.15, end: 0),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.asset(
                  'assets/brand/logo.png',
                  fit: BoxFit.contain,
                ),
              )
                  .animate()
                  .scale(
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.6, 0.6),
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(width: 14),
              const Text(
                'سكرتيري',
                style: TextStyle(
                  color: AppTheme.textOnPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideX(begin: 0.2, end: 0),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'رعاية أسهل،\nوتنظيم أفضل',
            style: TextStyle(
              color: AppTheme.textOnPrimary,
              height: 1.25,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 500.ms)
              .slideY(begin: 0.12, end: 0),
          const SizedBox(height: 14),
          const Text(
            'منصة تربط الطبيب والمريض لإدارة المواعيد\nوالانتظار والتواصل في مكان واحد.',
            style: TextStyle(
              color: AppTheme.textOnPrimarySoft,
              height: 1.7,
              fontSize: 15,
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 500.ms)
              .slideY(begin: 0.12, end: 0),
          const SizedBox(height: 24),
          _BenefitChip(
            icon: Icons.calendar_month_rounded,
            label: 'مواعيد وقائمة انتظار واضحة',
          )
              .animate()
              .fadeIn(delay: 450.ms, duration: 400.ms)
              .slideX(begin: 0.15, end: 0),
          const SizedBox(height: 10),
          _BenefitChip(
            icon: Icons.medical_services_rounded,
            label: 'خدمات الطبيب والمريض في حساب واحد',
          )
              .animate()
              .fadeIn(delay: 530.ms, duration: 400.ms)
              .slideX(begin: 0.15, end: 0),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Bottom — ads carousel, greeting, login button, social, note
// ══════════════════════════════════════════════════════════════
class _BottomSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // ── Promotional doctor cards ──
          const AdsCarousel()
              .animate()
              .fadeIn(delay: 300.ms, duration: 450.ms),
          // Greeting
          Text('أهلاً بك', style: Theme.of(context).textTheme.headlineMedium)
              .animate()
              .fadeIn(delay: 650.ms, duration: 400.ms)
              .slideY(begin: 0.12, end: 0),
          const SizedBox(height: 6),
          const Text(
            'سجّل الدخول للمتابعة إلى حسابك.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 400.ms)
              .slideY(begin: 0.12, end: 0),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login_rounded),
            label: const Text('تسجيل الدخول'),
          )
              .animate()
              .fadeIn(delay: 750.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0)
              .then()
              .shimmer(
                duration: 1200.ms,
                color: const Color(0x22FFFFFF),
                delay: 800.ms,
              ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/register-patient'),
                  icon: const Icon(Icons.person_add_alt_rounded, size: 20),
                  label: const Text('تسجيل كمريض'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/register-doctor'),
                  icon: const Icon(Icons.medical_services_rounded, size: 20),
                  label: const Text('تسجيل كطبيب'),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),
          const SizedBox(height: 22),
          _SocialLinks().animate().fadeIn(delay: 850.ms, duration: 400.ms),
          const SizedBox(height: 22),
          const Text(
            'تجربة طبية حديثة لإدارة المواعيد والانتظار والتواصل.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 950.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Sub-widgets
// ══════════════════════════════════════════════════════════════

class _LanguageBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0x18FFFFFF),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0x28FFFFFF)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.language_rounded, color: Colors.white, size: 18),
        SizedBox(width: 7),
        Text(
          'العربية',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0x1AFFFFFF),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0x24FFFFFF)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SocialLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'تواصل معنا عبر',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIcon(
              icon: Icons.facebook_rounded,
              label: 'فيسبوك',
              url: 'https://www.facebook.com/share/1ENr2oLJ1S/',
              gradient: const LinearGradient(
                colors: [Color(0xFF1877F2), Color(0xFF0A57D9)],
              ),
            ),
            const SizedBox(width: 20),
            _SocialIcon(
              icon: Icons.camera_alt_rounded,
              label: 'انستغرام',
              url: 'https://www.instagram.com/sekr_teri?stkn=azV1MGtuZmhtcTc=',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF09433),
                  Color(0xFFDC2743),
                  Color(0xFFBC1888),
                ],
              ),
            ),
            const SizedBox(width: 20),
            _SocialIcon(
              icon: Icons.chat_rounded,
              label: 'واتساب',
              url: 'https://wa.me/9647858102836',
              gradient: const LinearGradient(
                colors: [Color(0xFF25D366), Color(0xFF128C7E)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({
    required this.icon,
    required this.label,
    required this.url,
    required this.gradient,
  });

  final IconData icon;
  final String label;
  final String url;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      (gradient is LinearGradient
                              ? (gradient as LinearGradient).colors.first
                              : AppTheme.primary)
                          .withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
