/// ثوابت الشبكة المحلية
class NetworkConstants {
  // إعدادات قاعدة البيانات المحلية
  static const String defaultServerHost = '192.168.1.100'; // عنوان IP الافتراضي للخادم
  static const int defaultServerPort = 5432; // منفذ PostgreSQL الافتراضي
  static const String defaultDatabaseName = 'gold_workshop_db';
  static const String defaultUsername = 'gold_user';
  static const String defaultPassword = 'gold_password';
  
  // إعدادات الاتصال
  static const int connectionTimeout = 30; // ثانية
  static const int maxRetries = 3;
  static const int retryDelay = 2; // ثانية
  
  // إعدادات الشبكة المحلية
  static const String localNetworkRange = '192.168.1.0/24';
  static const List<String> commonLocalIPs = [
    '192.168.1.1',
    '192.168.1.100',
    '192.168.1.101',
    '192.168.1.102',
    '192.168.0.1',
    '192.168.0.100',
    '10.0.0.1',
    '10.0.0.100',
  ];
  
  // منافذ الخدمات
  static const int databasePort = 5432;
  static const int webServerPort = 8080;
  static const int apiServerPort = 3000;
  
  // مسارات API المحلية
  static String getApiBaseUrl(String host, [int port = 3000]) {
    return 'http://$host:$port/api';
  }
  
  static String getDatabaseUrl(String host, String database, String username, String password, [int port = 5432]) {
    return 'postgresql://$username:$password@$host:$port/$database';
  }
}

