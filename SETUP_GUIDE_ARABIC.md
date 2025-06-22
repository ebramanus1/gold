# دليل الإعداد والتشغيل - نظام إدارة ورشة الذهب

## متطلبات النظام

### البرمجيات المطلوبة
- Flutter SDK (3.2.6 أو أحدث)
- PostgreSQL Server (12 أو أحدث)
- Dart SDK (مضمن مع Flutter)

### متطلبات الأجهزة
- ذاكرة وصول عشوائي: 8 جيجابايت كحد أدنى
- مساحة تخزين: 2 جيجابايت للتطبيق و 5 جيجابايت لقاعدة البيانات
- معالج: Intel i5 أو AMD Ryzen 5 أو أفضل

## إعداد قاعدة البيانات

### 1. تثبيت PostgreSQL

#### Windows
```bash
# تحميل وتثبيت PostgreSQL من الموقع الرسمي
# https://www.postgresql.org/download/windows/
```

#### macOS
```bash
# باستخدام Homebrew
brew install postgresql
brew services start postgresql
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2. إنشاء قاعدة البيانات

```sql
-- الاتصال بـ PostgreSQL كمستخدم postgres
sudo -u postgres psql

-- إنشاء قاعدة البيانات
CREATE DATABASE gold_workshop;

-- إنشاء مستخدم للتطبيق (اختياري)
CREATE USER gold_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE gold_workshop TO gold_user;

-- الخروج
\q
```

### 3. تحديث إعدادات الاتصال

في ملف `lib/src/services/database/postgresql_service.dart`:

```dart
// تحديث إعدادات الاتصال
String _host = 'localhost';        // عنوان الخادم
int _port = 5432;                  // منفذ PostgreSQL
String _database = 'gold_workshop'; // اسم قاعدة البيانات
String _username = 'postgres';      // اسم المستخدم
String _password = 'your_password'; // كلمة المرور
```

## إعداد التطبيق

### 1. تثبيت Flutter

#### Windows
```bash
# تحميل Flutter SDK من الموقع الرسمي
# https://docs.flutter.dev/get-started/install/windows

# إضافة Flutter إلى PATH
# تحديث متغيرات البيئة
```

#### macOS
```bash
# تحميل Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# إضافة إلى .zshrc أو .bash_profile
echo 'export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"' >> ~/.zshrc
```

#### Linux
```bash
# تحميل Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# إضافة إلى .bashrc
echo 'export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"' >> ~/.bashrc
```

### 2. التحقق من التثبيت

```bash
flutter doctor
```

### 3. تثبيت تبعيات المشروع

```bash
cd /path/to/GoldWorkshop_AI_Modified
flutter pub get
```

## تشغيل التطبيق

### 1. التحقق من الأجهزة المتاحة

```bash
flutter devices
```

### 2. تشغيل التطبيق

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

#### Linux
```bash
flutter run -d linux
```

### 3. بناء التطبيق للإنتاج

#### Windows
```bash
flutter build windows --release
```

#### macOS
```bash
flutter build macos --release
```

#### Linux
```bash
flutter build linux --release
```

## إعداد الشبكة المحلية

### 1. إعداد PostgreSQL للوصول عبر الشبكة

#### تحرير ملف postgresql.conf
```bash
# العثور على ملف التكوين
sudo find /etc -name "postgresql.conf" 2>/dev/null

# تحرير الملف
sudo nano /etc/postgresql/[VERSION]/main/postgresql.conf

# تحديث السطر التالي
listen_addresses = '*'  # أو عنوان IP محدد
```

#### تحرير ملف pg_hba.conf
```bash
# تحرير ملف المصادقة
sudo nano /etc/postgresql/[VERSION]/main/pg_hba.conf

# إضافة السطر التالي للسماح بالاتصالات من الشبكة المحلية
host    all             all             192.168.1.0/24          md5
```

#### إعادة تشغيل PostgreSQL
```bash
sudo systemctl restart postgresql
```

### 2. تحديث إعدادات التطبيق

```dart
// في postgresql_service.dart
String _host = '192.168.1.100';  // عنوان IP للخادم
```

## استكشاف الأخطاء

### مشاكل قاعدة البيانات

#### خطأ الاتصال
```
Error: Connection refused
```
**الحل**: التأكد من تشغيل PostgreSQL وصحة إعدادات الاتصال

#### خطأ المصادقة
```
Error: Authentication failed
```
**الحل**: التحقق من اسم المستخدم وكلمة المرور

### مشاكل Flutter

#### خطأ التبعيات
```bash
flutter clean
flutter pub get
```

#### خطأ البناء
```bash
flutter doctor
flutter upgrade
```

## الاختبار

### 1. اختبار قاعدة البيانات

```sql
-- الاتصال بقاعدة البيانات
psql -h localhost -U postgres -d gold_workshop

-- التحقق من الجداول
\dt

-- اختبار إدراج بيانات
SELECT * FROM users;
```

### 2. اختبار التطبيق

1. تشغيل التطبيق
2. تسجيل الدخول بـ:
   - اسم المستخدم: `admin`
   - كلمة المرور: `password`
3. التنقل بين الشاشات
4. إضافة عميل جديد
5. إضافة مادة خام جديدة

## النسخ الاحتياطي

### نسخ احتياطي لقاعدة البيانات

```bash
# إنشاء نسخة احتياطية
pg_dump -h localhost -U postgres gold_workshop > backup.sql

# استعادة النسخة الاحتياطية
psql -h localhost -U postgres gold_workshop < backup.sql
```

### نسخ احتياطي للتطبيق

```bash
# نسخ مجلد المشروع
cp -r GoldWorkshop_AI_Modified GoldWorkshop_AI_Modified_backup
```

## الأمان

### 1. كلمات المرور
- استخدام كلمات مرور قوية لقاعدة البيانات
- تغيير كلمة المرور الافتراضية للمدير

### 2. الشبكة
- استخدام VPN للوصول عن بُعد
- تقييد الوصول لعناوين IP محددة

### 3. النسخ الاحتياطي
- نسخ احتياطي يومي لقاعدة البيانات
- تخزين النسخ في مواقع متعددة

## الدعم الفني

### سجلات الأخطاء

#### PostgreSQL
```bash
# عرض سجلات PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-[VERSION]-main.log
```

#### Flutter
```bash
# تشغيل مع سجلات مفصلة
flutter run --verbose
```

### معلومات الاتصال

للحصول على الدعم الفني، يرجى توفير:
1. نسخة نظام التشغيل
2. نسخة Flutter
3. نسخة PostgreSQL
4. رسالة الخطأ الكاملة
5. خطوات إعادة إنتاج المشكلة

---

**آخر تحديث**: 2025-01-21
**الإصدار**: 1.0.0

