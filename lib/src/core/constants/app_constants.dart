// ثوابت التطبيق الأساسية
class AppConstants {
  // معلومات التطبيق
  static const String appName = 'Gold Workshop AI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'نظام إدارة ورشة الذهب والمجوهرات';
  
  // إعدادات قاعدة البيانات
  static const String databaseName = 'gold_workshop.db';
  static const int databaseVersion = 1;
  
  // إعدادات الشبكة
  
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const String baseUrl = 'https://api.goldworkshop.com';
  
  // إعدادات الأمان
  static const int maxLoginAttempts = 3;
  static const int sessionTimeoutMinutes = 30;
  static const int passwordMinLength = 3;
  
  // إعدادات العملة
  static const String defaultCurrency = 'SAR';
  static const List<String> supportedCurrencies = ['SAR', 'USD', 'EUR', 'AED'];
  
  // إعدادات الذهب
  static const List<String> goldKarats = ['24K', '22K', '21K', '18K', '14K', '10K'];
  static const List<String> goldTypes = ['خام', 'مصنع', 'مستعمل', 'للإصلاح'];
  
  // إعدادات التقارير
  static const List<String> reportFormats = ['PDF', 'Excel', 'CSV'];
  static const int maxReportRecords = 10000;
  
  // إعدادات النسخ الاحتياطي
  static const int autoBackupIntervalHours = 24;
  static const int maxBackupFiles = 30;
  
  // إعدادات الطباعة
  static const String defaultPrinterName = 'Default';
  static const List<String> paperSizes = ['A4', 'A5', 'Receipt'];
  
  // إعدادات الإشعارات
  static const int notificationDisplayDuration = 5000;
  static const List<String> notificationTypes = ['info', 'success', 'warning', 'error'];
}

// ثوابت واجهة المستخدم
class UIConstants {
  // الألوان الأساسية
  static const int primaryColorValue = 0xFFD4AF37; // ذهبي
  static const int secondaryColorValue = 0xFF8B4513; // بني
  static const int accentColorValue = 0xFFFFD700; // أصفر ذهبي
  
  // أحجام الخط
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;
  
  // المسافات
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 48.0;
  
  // أحجام الأيقونات
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // أحجام الأزرار
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  
  // نصف القطر للحواف المدورة
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;
}

// ثوابت المسارات
class PathConstants {
  // مسارات الأصول
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String fontsPath = 'assets/fonts/';
  static const String translationsPath = 'assets/translations/';
  static const String soundsPath = 'assets/sounds/';
  
  // مسارات قاعدة البيانات
  static const String databasePath = 'databases/';
  static const String backupPath = 'backups/';
  static const String reportsPath = 'reports/';
  static const String exportsPath = 'exports/';
  
  // مسارات التكوين
  static const String configPath = 'config/';
  static const String logsPath = 'logs/';
  static const String tempPath = 'temp/';
}

// ثوابت المفاتيح
class KeyConstants {
  // مفاتيح التخزين المحلي
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'selected_theme';
  
  // مفاتيح التفضيلات
  static const String autoBackupKey = 'auto_backup_enabled';
  static const String notificationsKey = 'notifications_enabled';
  static const String biometricKey = 'biometric_enabled';
  static const String darkModeKey = 'dark_mode_enabled';
  
  // مفاتيح التشفير
  static const String encryptionKey = 'encryption_key';
  static const String saltKey = 'salt_key';
}

