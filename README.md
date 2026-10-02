# Sekretiri Flutter

مشروع Flutter مستقل. واجهة العميل في هذا المستودع، وواجهة برمجة التطبيقات تبقى على خادم Next.js المنشور (Vercel) دون تضمين كود الويب أو Capacitor هنا.

## التجهيز على Windows

1. ثبّت Flutter SDK (قناة stable) وAndroid Studio، ثم أعد فتح PowerShell ونفّذ `flutter doctor`.
2. من جذر هذا المشروع:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-platforms.ps1
flutter analyze
flutter test
flutter run
```

إذا كانت مجلدات `android` و`ios` و`web` موجودة مسبقاً، يقتصر السكربت على `flutter pub get`.

عنوان الـAPI الافتراضي مضبوط في `lib/core/config/app_config.dart`. لخادم معاينة موثوق:

```powershell
flutter run --dart-define=API_BASE_URL=https://your-preview.example
```

لا تضع أسرار الخادم داخل التطبيق. تفاصيل سياسة الكوكي والويب في `FLUTTER_MIGRATION_AR.md`.

**حالة النقل:** المرحلة الأولى فقط (ترحيب ودخول). ليست بديلاً كاملاً عن التطبيق الحالي حتى تكتمل الميزات والاختبارات.
