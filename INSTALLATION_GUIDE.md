# دليل التثبيت - Gold Workshop AI

## متطلبات النظام

### الحد الأدنى للمتطلبات
- **نظام التشغيل:** Windows 10/11، macOS 10.14+، أو Ubuntu 18.04+
- **الذاكرة:** 4 GB RAM (يُنصح بـ 8 GB)
- **مساحة التخزين:** 2 GB مساحة فارغة
- **المعالج:** Intel i3 أو AMD Ryzen 3 أو أحدث
- **الشبكة:** اتصال إنترنت للميزات السحابية (اختياري)

### المتطلبات الموصى بها
- **الذاكرة:** 8 GB RAM أو أكثر
- **مساحة التخزين:** 5 GB مساحة فارغة
- **المعالج:** Intel i5 أو AMD Ryzen 5 أو أحدث
- **الشاشة:** دقة 1920x1080 أو أعلى

## تثبيت Flutter SDK

### Windows
1. قم بتحميل Flutter SDK من [الموقع الرسمي](https://flutter.dev/docs/get-started/install/windows)
2. استخرج الملف المضغوط إلى مجلد (مثل `C:\flutter`)
3. أضف مسار Flutter إلى متغير البيئة PATH:
   - افتح "System Properties" → "Environment Variables"
   - أضف `C:\flutter\bin` إلى PATH
4. افتح Command Prompt وتحقق من التثبيت:
   ```cmd
   flutter doctor
   ```

### macOS
1. قم بتحميل Flutter SDK من [الموقع الرسمي](https://flutter.dev/docs/get-started/install/macos)
2. استخرج الملف إلى مجلد (مثل `~/flutter`)
3. أضف Flutter إلى PATH في ملف `.zshrc` أو `.bash_profile`:
   ```bash
   export PATH="$PATH:~/flutter/bin"
   ```
4. أعد تحميل الملف:
   ```bash
   source ~/.zshrc
   ```
5. تحقق من التثبيت:
   ```bash
   flutter doctor
   ```

### Linux (Ubuntu)
1. قم بتحميل Flutter SDK:
   ```bash
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
   ```
2. استخرج الملف:
   ```bash
   tar xf flutter_linux_3.24.5-stable.tar.xz
   ```
3. أضف Flutter إلى PATH:
   ```bash
   echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```
4. تحقق من التثبيت:
   ```bash
   flutter doctor
   ```

## تثبيت المتطلبات الإضافية

### Android Studio (للتطوير على Android)
1. قم بتحميل وتثبيت [Android Studio](https://developer.android.com/studio)
2. افتح Android Studio وثبت Android SDK
3. قم بتثبيت Flutter plugin من Settings → Plugins

### Xcode (للتطوير على iOS - macOS فقط)
1. ثبت Xcode من App Store
2. قم بتشغيل:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

### Visual Studio Code (اختياري)
1. قم بتحميل وتثبيت [VS Code](https://code.visualstudio.com/)
2. ثبت Flutter extension من Extensions marketplace

## تثبيت قاعدة البيانات

### SQLite (افتراضي)
SQLite مدمج مع Flutter ولا يحتاج تثبيت إضافي.

### PostgreSQL (اختياري للشبكة المحلية)
#### Windows
1. قم بتحميل PostgreSQL من [الموقع الرسمي](https://www.postgresql.org/download/windows/)
2. اتبع معالج التثبيت
3. احفظ كلمة مرور المستخدم `postgres`

#### macOS
```bash
brew install postgresql
brew services start postgresql
```

#### Linux
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

## تثبيت المشروع

### 1. استنساخ المشروع
```bash
git clone https://github.com/ebramanus1/gold.git
cd gold
```

### 2. تثبيت التبعيات
```bash
flutter pub get
```

### 3. إعداد قاعدة البيانات
#### للاستخدام مع SQLite (افتراضي)
لا حاجة لإعداد إضافي، سيتم إنشاء قاعدة البيانات تلقائياً.

#### للاستخدام مع PostgreSQL
1. أنشئ قاعدة بيانات جديدة:
   ```sql
   CREATE DATABASE gold_workshop;
   CREATE USER gold_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE gold_workshop TO gold_user;
   ```

2. حدث ملف الإعدادات `lib/src/core/config/database_config.dart`:
   ```dart
   static const String host = 'localhost';
   static const int port = 5432;
   static const String database = 'gold_workshop';
   static const String username = 'gold_user';
   static const String password = 'your_password';
   ```

### 4. إعداد الأجهزة (اختياري)

#### الموازين الرقمية
1. تأكد من توصيل الميزان عبر USB أو Serial
2. حدد المنفذ الصحيح في إعدادات التطبيق
3. اختبر الاتصال من قائمة الأجهزة

#### الطابعات
1. ثبت تعريفات الطابعة
2. تأكد من إعداد الطابعة كطابعة افتراضية
3. اختبر الطباعة من إعدادات التطبيق

#### ماسحات الباركود
1. تأكد من توصيل الماسح
2. اختبر المسح من قائمة الأجهزة

## تشغيل التطبيق

### للتطوير
```bash
# للويب
flutter run -d chrome

# لسطح المكتب (Windows)
flutter run -d windows

# لسطح المكتب (macOS)
flutter run -d macos

# لسطح المكتب (Linux)
flutter run -d linux
```

### بناء التطبيق للإنتاج

#### Windows
```bash
flutter build windows --release
```
الملفات ستكون في: `build/windows/x64/runner/Release/`

#### macOS
```bash
flutter build macos --release
```
الملفات ستكون في: `build/macos/Build/Products/Release/`

#### Linux
```bash
flutter build linux --release
```
الملفات ستكون في: `build/linux/x64/release/bundle/`

#### الويب
```bash
flutter build web --release
```
الملفات ستكون في: `build/web/`

## الإعداد الأولي

### 1. تشغيل التطبيق لأول مرة
1. شغل التطبيق
2. ستظهر شاشة الإعداد الأولي
3. أدخل معلومات الورشة:
   - اسم الورشة
   - العنوان
   - رقم الهاتف
   - البريد الإلكتروني

### 2. إنشاء حساب المدير
1. أدخل اسم المستخدم
2. أدخل كلمة المرور
3. أكد كلمة المرور
4. أدخل البريد الإلكتروني

### 3. إعداد قاعدة البيانات
1. اختر نوع قاعدة البيانات (SQLite أو PostgreSQL)
2. إذا اخترت PostgreSQL، أدخل بيانات الاتصال
3. اختبر الاتصال
4. أنشئ الجداول الأساسية

### 4. إعداد الأجهزة
1. اذهب إلى إعدادات الأجهزة
2. أضف الموازين والطابعات
3. اختبر كل جهاز
4. احفظ الإعدادات

### 5. إعداد النسخ الاحتياطي
1. اختر مجلد النسخ الاحتياطي المحلي
2. إعداد النسخ الاحتياطي التلقائي (اختياري)
3. إعداد النسخ الاحتياطي السحابي (اختياري)

## استكشاف الأخطاء وإصلاحها

### مشاكل شائعة

#### خطأ في تثبيت التبعيات
```bash
flutter clean
flutter pub get
```

#### مشاكل في قاعدة البيانات
1. تأكد من تشغيل خدمة PostgreSQL
2. تحقق من بيانات الاتصال
3. تأكد من صلاحيات المستخدم

#### مشاكل في الأجهزة
1. تحقق من توصيل الأجهزة
2. تأكد من تثبيت التعريفات
3. اختبر الأجهزة خارج التطبيق

#### مشاكل في الأداء
1. تأكد من توفر الذاكرة الكافية
2. أغلق التطبيقات غير الضرورية
3. تحقق من مساحة القرص الصلب

### الحصول على المساعدة
- **الوثائق:** راجع ملف USER_MANUAL.md
- **المشاكل التقنية:** راجع ملف DEVELOPMENT_REPORT.md
- **الدعم:** تواصل مع فريق التطوير

## التحديثات

### التحديث اليدوي
1. قم بتحميل الإصدار الجديد
2. أنشئ نسخة احتياطية من البيانات
3. ثبت الإصدار الجديد
4. استعد البيانات إذا لزم الأمر

### التحديث التلقائي (قريباً)
سيتم إضافة نظام التحديث التلقائي في الإصدارات القادمة.

## الأمان

### النسخ الاحتياطي
- أنشئ نسخ احتياطية دورية
- احفظ النسخ في مكان آمن
- اختبر استعادة النسخ الاحتياطية

### كلمات المرور
- استخدم كلمات مرور قوية
- غير كلمات المرور دورياً
- لا تشارك كلمات المرور

### الشبكة
- استخدم شبكة آمنة
- فعل جدار الحماية
- حدث نظام التشغيل بانتظام

---

للمزيد من المعلومات، راجع الملفات التالية:
- `USER_MANUAL.md` - دليل المستخدم
- `API_DOCUMENTATION.md` - وثائق API
- `DATABASE_SCHEMA.md` - مخطط قاعدة البيانات

