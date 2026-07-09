# كيف تحصل على ملف APK

بيئة الأكواد هذه (اللي راجعت فيها المشروع) ما فيها Flutter SDK ولا Android SDK، وما عندها اتصال إنترنت
عشان تنزّلهم. عشان كده ما قدرت أبني ملف الـ APK مباشرة، لكن جهزت لك طريقتين سهلتين:

## الطريقة 1: GitHub Actions (بدون تثبيت أي حاجة على جهازك)

1. اعمل ريبو جديد على GitHub وارفع فيه كل ملفات المشروع (بما فيها مجلد `.github`).
2. روح لتبويب **Actions** في الريبو، هتلاقي workflow اسمه **Build APK** يشتغل تلقائيًا.
   لو ما اشتغل تلقائي، شغّله يدويًا من زر **Run workflow**.
3. لما يخلص (يأخذ حوالي 5-10 دقايق)، روح لصفحة الـ run، وتحت **Artifacts** هتلاقي
   `jawan-delivery-apk` — نزّله، جواه ملف `app-release.apk` جاهز للتثبيت.

هذا البناء بيوقع التطبيق بتوقيع debug (مؤقت) لأنه ما فيه `key.properties`. كويس للتجربة، لكن
قبل النشر على Google Play لازم توقيع release حقيقي (شوف `PLAY_STORE_CHECKLIST.md`).

## الطريقة 2: على جهازك مباشرة

1. ثبّت Flutter (النسخة المطلوبة 3.44.0 أو أحدث، حسب `pubspec.lock`):
   https://docs.flutter.dev/get-started/install
2. من جذر المشروع:
   ```bash
   flutter pub get
   flutter build apk --release
   ```
3. الملف هيطلع في:
   `build/app/outputs/flutter-apk/app-release.apk`

## إيش اتصلح في الكود قبل ما استلمته

- `lib/services/order_service.dart`: `deleteOrder` كانت بتستخدم القيمة اللي بيرجعها
  `removeWhere` وكأنها عدد (وهي أصلاً `void` في Dart) — الكود ده ما كان راح يتصرّف (compile error).
- `lib/screens/admin/admin_screen.dart`: كان فيه سطر جديد خام جوه نص بين quotes مفردة
  (`'...'`) وده غير مسموح في Dart — برضو compile error.
- `android/app/src/main/kotlin/.../MainActivity.kt`: كان تحت package اسمه
  `com.example.jawan_delivery`، بينما الـ namespace/applicationId في `build.gradle.kts`
  هو `sd.jawan.delivery`. الفرق ده كان راح يخلي التطبيق يتثبّت لكن يكرش فورًا عند الفتح
  (التطبيق ما بيلقى الـ MainActivity). نقلته للمسار والـ package الصح.
- `test/widget_test.dart`: كان لسه ملف الاختبار الافتراضي بتاع تطبيق العداد (counter) اللي
  بيجي مع `flutter create`، وما ليهوش علاقة بالتطبيق ده — استبدلته باختبار بسيط لشاشة الدخول.
