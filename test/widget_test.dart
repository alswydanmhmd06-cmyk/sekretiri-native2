import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sekretiri_flutter/core/theme/app_theme.dart';
import 'package:sekretiri_flutter/features/auth/presentation/welcome_screen.dart';

void main() {
  testWidgets('welcome screen renders in Arabic RTL', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: WelcomeScreen(),
        ),
      ),
    );

    expect(find.text('سكرتيري'), findsOneWidget);
    expect(find.text('رعاية أسهل،\nوتنظيم أفضل'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}
