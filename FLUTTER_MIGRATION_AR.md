# تحويل سكرتيري إلى Flutter — خطة التنفيذ المرحلية

## القرار المعماري

هذا المستودع بيئة Flutter بحتة: جذر المشروع هو تطبيق العميل (`pubspec.yaml` هنا مباشرة). يبقى Next.js على Vercel هو الخادم والـAPI، وتبقى PostgreSQL وDrizzle ومخطط قاعدة البيانات والترحيلات في مستودع الخادم دون أي اتصال مباشر من تطبيق الهاتف إلى قاعدة البيانات. يتصل Flutter بمسارات `/api/...` الحالية عبر HTTPS؛ صلاحيات الطبيب والمريض والسكرتير تبقى مُتحققاً منها في الخادم، ولا يوضع `DATABASE_URL` أو `JWT_SECRET` أو `ADMIN_SECRET` داخل التطبيق.

## المرحلة المنفذة

- هيكل Flutter أولي بنمط feature-first ومكتبات Riverpod لإدارة الحالة وgo_router للتوجيه وDio لطلبات HTTP.
- ثيم RTL عربي مطابق للوحة الألوان الحالية، وخط Tajawal محلي مرخص بـSIL Open Font License، وأصل الشعار الحالي.
- شاشة ترحيب وشاشة دخول أولية. شاشة الدخول متصلة بـ`POST /api/auth/login` وترسل `email/password/type` كما يطلب الخادم، وتدعم الأدوار `doctor`, `patient`, `secretary` ورسائل الخطأ العربية.
- إدارة Cookie الجلسة: خادم Next يضبط `sekretiri_session` كـHttpOnly/SameSite=Strict؛ Android/iOS يستخدمان CookieManager وSecure Storage، والويب يعتمد كوكي المتصفح مع `withCredentials`.
- لا تُرسل كلمة المرور للتخزين المحلي. بيانات تعريف المستخدم وحدها تحفظ في المخزن الآمن لتجهيز استعادة الواجهة. لا يُنفذ فحص API صامت عند تشغيل التطبيق لأن بعض GET الحالية لديها آثار جانبية أو تهيئة schema؛ عند نقل كل ميزة يجب اعتبار استجابة الخادم، ومعالجة 401 ومسح الجلسة حينها.

> هذه مرحلة تأسيسية وليست تطبيقاً مكافئاً للنسخة الحالية بعد. واجهات التسجيل ولوحات الطبيب والمريض والإدارة والميزات أدناه لم تُنقل بعد. لا توقف أو تحذف مشروع الويب الحالي، ولا ترفع تطبيق Flutter للمستخدمين قبل استكمال التكافؤ والاختبارات.

## شجرة الملفات الحالية

```text
./
├── pubspec.yaml
├── assets/
│   ├── brand/logo.png
│   └── fonts/{Tajawal-Regular.ttf,Tajawal-Bold.ttf,OFL.txt}
├── test/app_user_test.dart
└── lib/
    ├── main.dart
    ├── app.dart
    ├── core/
    │   ├── config/app_config.dart
    │   ├── network/{api_client.dart,secure_cookie_storage.dart,
    │   │          browser_credentials_stub.dart,browser_credentials_web.dart}
    │   └── theme/app_theme.dart
    └── features/
        ├── auth/
        │   ├── data/{auth_repository.dart,auth_providers.dart}
        │   ├── domain/app_user.dart
        │   └── presentation/{auth_gate.dart,welcome_screen.dart,login_screen.dart}
        └── home/presentation/home_screen.dart
```

## جرد التكافؤ الوظيفي المطلوب

| المجال | واجهات الخادم القائمة | أعمال Flutter المطلوبة قبل إطلاقه |
|---|---|---|
| الدخول والخروج | `/api/auth/login`, `/api/auth/logout` | اختبارات الأدوار الثلاثة، استعادة الواجهة، انقضاء JWT بعد 24 ساعة، ومسح الجلسة عند 401/429/انقطاع الاتصال |
| تسجيل الحساب | `/api/auth/register-doctor`, `/api/auth/register-patient` | مطابقة الحقول والتحققات ورسائل الواجهة مع الخادم |
| دليل الأطباء والإعلانات | `/api/doctors`, `/api/doctors/[id]`, `/api/ads` | بحث الأطباء، الملف، التقييمات، التوفر، حالات التحميل/الفشل/الفراغ |
| المواعيد والانتظار | `/api/appointments`, `/api/appointments/[id]`, `/api/admin/appointments` | طلب الموعد للمريض، قائمة الطبيب حسب التاريخ، بدء/إنهاء/إلغاء، موقع المريض في الطابور والتاريخ |
| المرضى والوصفات والأدوية | `/api/admin/patients`, `/api/prescriptions`, `/api/medications/search` | بيانات المريض المخولة، إنشاء/قراءة وصفة، البحث في الأدوية والتحقق من الحقول |
| الرسائل | `/api/messages`, `/api/messages/contacts`, `/api/messages/attachments/[id]` | جهات الاتصال، سجل المحادثة، إرسال نص/صورة، قراءة المرفقات، وصلاحيات الطرفين |
| الإشعارات | `/api/notifications`, `/api/push/register` | قائمة وقراءة التنبيهات. Push يحتاج إعداد Firebase Native مستقل وملفات المفاتيح ولا يُعتبر منقولاً بمجرد نقل شاشة الإشعارات |
| التقييمات | `/api/ratings`, `/api/admin/ratings` | تقييم بعد موعد مؤهل، قائمة الإدارة، ومنع التكرار وفق قواعد الخادم |
| اشتراك الطبيب والمدفوعات | `/api/payments`, `/api/payments/zaincash/return`, `/api/payments/zaincash/webhook` | إبقاء استهلاك متجر Play فقط، عرض انتظار الدفع اليدوي، والتحقق من دورة ZainCash عبر الخادم لا Flutter |
| السكرتير والإدارة | `/api/secretaries`, `/api/admin/*` | إدارة المستخدمين المخولين؛ لوحة الإدارة الحالية تبقى Web فقط ما لم يُعتمد نطاق مستقل لإنشاء Admin Native |
| الحساب والخصوصية | `/delete-account`, السياسات والمساعدة | نقل تجربة حذف الحساب الفعلية بعد التحقق من التنفيذ، والروابط القانونية وسياسة البيانات |

## ضوابط المصادقة والويب

1. لا يمكن لتطبيق Flutter المتصل بـVercel تسجيل الدخول إذا كان `JWT_SECRET` غير مضبوط وقوياً في Vercel؛ إعداد JWT يظل على الخادم فقط.
2. المتصفح لا يسمح لـDart بقراءة كوكي `HttpOnly`؛ لذلك يعتمد Flutter Web على كوكي المتصفح. يجب تقديم نسخة الويب من **الأصل نفسه** الذي يستضيف Next API أو إعداد CORS وSameSite من الخادم بشكل مقصود واختباره. إعداد الخادم الحالي لا يفتح CORS لمضيف Flutter منفصل. تشغيل Flutter Web على `localhost` ضد Vercel لن يعمل افتراضياً مع هذا الإعداد.
3. Android/iOS يستخدمان مدير الكوكي؛ مدة الجلسة القصوى تظل 24 ساعة وفق الخادم، وقد يطلب تسجيل الدخول مجدداً بعد انتهائها.
4. لا تُغيّر أسماء الجداول أو API أثناء نقل العميل. أي حاجة لإضافة endpoint أو تغيير سياسة CORS تُوثق أولاً كقرار مستقل؛ هذه المرحلة لم تضف route للخادم.
5. لا تحفظ بيانات طبية محلياً في Shared Preferences أو سجلات التطبيق. معلومات المرضى لا تظهر إلا بعد API مصرح.
6. تخزين كوكي JWT عبر Secure Storage جزء من حزمة العميل؛ يجب اختبار تثبيت/ترقية التطبيق واستمرارية الجلسة على أجهزة Android/iOS قبل الإطلاق، والتحقق من مسح السجل عند تسجيل الخروج وحذف الحساب.

## إنشاء مجلدات المنصات وتشغيل أولي على Windows

يجب تثبيت Flutter SDK stable وAndroid Studio وAndroid SDK على جهاز Windows. داخل PowerShell:

```powershell
cd E:\sekretiri_v50_flutter_phase1
flutter doctor
powershell -ExecutionPolicy Bypass -File .\setup-platforms.ps1
flutter analyze
flutter test
flutter run
```

السكربت يعمل من جذر مشروع Flutter؛ إذا كانت المنصات موجودة بالفعل يكتفي بـ`flutter pub get`. إذا كان بعض مجلدات المنصات موجوداً فقط، يتوقف بدلاً من استبدال إعدادات جزئية. بناء iOS يحتاج macOS وXcode.

معرّف Android مضبوط على `com.sekretiri.clinic`؛ وبناء Debug يضيف `.flutterdev` ليُثبت بجانب تطبيقك الحالي ولا يستبدله. إصدار Android Release لا يستخدم مفتاح debug: لنشر فعلي يجب إعداد متغيرات بيئة مفتاح **Upload Key** الرسمي الذي تملكه، ورفع `versionCode` إلى رقم أعلى من آخر إصدار نشرته. لا تغيّر `applicationId` أو مفتاح التوقيع إذا كان الهدف تحديث listing قائم في Google Play. هوية iOS المضبوطة مبدئياً `com.sekretiri.clinic` لكنها يجب أن تطابق Bundle ID المملوك في Apple Developer قبل النشر؛ لا يمكن اختبار iOS من بيئة Linux.

```powershell
flutter run -d <emulator-id>
# تخصيص API لبيئة Preview موثوقة فقط، دون وضع أسرار في الأمر:
flutter run -d <emulator-id> --dart-define=API_BASE_URL=https://your-preview.example
```

للعمل مع Android Emulator على خادم محلي يستخدم `http://10.0.2.2:<port>` وإعداداً محلياً مؤقتاً؛ الإنتاج يجب أن يستخدم HTTPS. لا تستخدم بيانات مرضى حقيقية في Preview أو الاختبارات.

## ترتيب الاستكمال ومعايير القبول

1. مطابقة حقول التسجيل والتحقق مع routes الحالية، ثم اختبار التسجيل/الدخول للأدوار الثلاثة.
2. بناء أساس تنقل مفصول حسب الدور، ثم الطبيب: قائمة الانتظار وإدارة الموعد والوصفة.
3. بناء المريض: البحث والحجز وموقع الانتظار والرسائل/الوصفات.
4. الرسائل والإشعارات، ثم ربط Push Native مع Firebase واختبارات صلاحيات/تسليم.
5. الاشتراكات والدفع اليدوي وZainCash مع اختبار العودة وWebhook على بيئة اختبار.
6. إدارة البيانات والحساب وحذف الحساب، واختبارات أمان ووصول شامل وتكافؤ API.
7. اختبارات Flutter unit/widget/integration على Android وiOS وWeb حيث يدعم الخادم النشر عبر الأصل نفسه، ثم اختبار قبول يدوي قبل تحويل المستخدمين.

**معيار عدم مساس البيانات:** مخطط قاعدة البيانات وملفات الترحيل تبقى في مستودع الخادم؛ لا تُعدَّل من هذا المشروع. Flutter لا ينفذ SQL ولا migrations.
