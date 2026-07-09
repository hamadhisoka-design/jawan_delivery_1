# Jawan Delivery

تطبيق توصيل مبني بـ Flutter. النسخة الحالية تعمل كمنظومة محلية جاهزة للتشغيل، مع:
- تسجيل دخول وتسجيل حسابات
- أدوار: admin / driver / customer
- إنشاء الطلبات ومتابعتها
- إشعارات داخل التطبيق
- محفظة للسائق وطلبات شحن
- لوحة إدارة للحظر، التعديل، والحذف

## بيانات تجريبية مضافة تلقائيًا
- Admin: `admin@jawan.sd`
- Password: `Jawan@2026`

- Driver 1: `driver1@jawan.sd`
- Password: `123456`

- Driver 2: `driver2@jawan.sd`
- Password: `123456`

- Customer: `customer@jawan.sd`
- Password: `123456`

## ملاحظات مهمة للنشر
هذه النسخة تحفظ البيانات محليًا داخل الجهاز. للنشر الحقيقي على Google Play مع مزامنة بين عدة أجهزة، اربطها لاحقًا بقاعدة بيانات سحابية مثل Supabase أو Firebase.

## بناء التطبيق
```bash
flutter pub get
flutter build appbundle --release
```

## ملفات النشر
- `android/app/build.gradle.kts` معدّ لنسخة release
- `android/app/src/main/AndroidManifest.xml` يحتوي على صلاحيات الإنترنت والإشعارات
- استخدم `key.properties` عند إعداد توقيع release
