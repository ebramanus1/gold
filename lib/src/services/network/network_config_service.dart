import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/network_constants.dart';

/// خدمة إدارة إعدادات الشبكة المحلية
class NetworkConfigService {
  static const String _serverHostKey = 'server_host';
  static const String _serverPortKey = 'server_port';
  static const String _databaseNameKey = 'database_name';
  static const String _usernameKey = 'database_username';
  static const String _passwordKey = 'database_password';
  static const String _isOfflineModeKey = 'is_offline_mode';
  static const String _autoDiscoverKey = 'auto_discover_server';

  static NetworkConfigService? _instance;
  static NetworkConfigService get instance => _instance ??= NetworkConfigService._();
  NetworkConfigService._();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // الحصول على عنوان الخادم
  Future<String> getServerHost() async {
    await initialize();
    return _prefs?.getString(_serverHostKey) ?? NetworkConstants.defaultServerHost;
  }

  // تعيين عنوان الخادم
  Future<void> setServerHost(String host) async {
    await initialize();
    await _prefs?.setString(_serverHostKey, host);
  }

  // الحصول على منفذ الخادم
  Future<int> getServerPort() async {
    await initialize();
    return _prefs?.getInt(_serverPortKey) ?? NetworkConstants.defaultServerPort;
  }

  // تعيين منفذ الخادم
  Future<void> setServerPort(int port) async {
    await initialize();
    await _prefs?.setInt(_serverPortKey, port);
  }

  // الحصول على اسم قاعدة البيانات
  Future<String> getDatabaseName() async {
    await initialize();
    return _prefs?.getString(_databaseNameKey) ?? NetworkConstants.defaultDatabaseName;
  }

  // تعيين اسم قاعدة البيانات
  Future<void> setDatabaseName(String name) async {
    await initialize();
    await _prefs?.setString(_databaseNameKey, name);
  }

  // الحصول على اسم المستخدم
  Future<String> getUsername() async {
    await initialize();
    return _prefs?.getString(_usernameKey) ?? NetworkConstants.defaultUsername;
  }

  // تعيين اسم المستخدم
  Future<void> setUsername(String username) async {
    await initialize();
    await _prefs?.setString(_usernameKey, username);
  }

  // الحصول على كلمة المرور
  Future<String> getPassword() async {
    await initialize();
    return _prefs?.getString(_passwordKey) ?? NetworkConstants.defaultPassword;
  }

  // تعيين كلمة المرور
  Future<void> setPassword(String password) async {
    await initialize();
    await _prefs?.setString(_passwordKey, password);
  }

  // الحصول على حالة الوضع غير المتصل
  Future<bool> isOfflineMode() async {
    await initialize();
    return _prefs?.getBool(_isOfflineModeKey) ?? false;
  }

  // تعيين الوضع غير المتصل
  Future<void> setOfflineMode(bool isOffline) async {
    await initialize();
    await _prefs?.setBool(_isOfflineModeKey, isOffline);
  }

  // الحصول على حالة الاكتشاف التلقائي
  Future<bool> isAutoDiscoverEnabled() async {
    await initialize();
    return _prefs?.getBool(_autoDiscoverKey) ?? true;
  }

  // تعيين الاكتشاف التلقائي
  Future<void> setAutoDiscover(bool enabled) async {
    await initialize();
    await _prefs?.setBool(_autoDiscoverKey, enabled);
  }

  // الحصول على سلسلة الاتصال الكاملة
  Future<String> getConnectionString() async {
    final host = await getServerHost();
    final port = await getServerPort();
    final database = await getDatabaseName();
    final username = await getUsername();
    final password = await getPassword();
    
    return NetworkConstants.getDatabaseUrl(host, database, username, password, port);
  }

  // الحصول على عنوان API الأساسي
  Future<String> getApiBaseUrl() async {
    final host = await getServerHost();
    return NetworkConstants.getApiBaseUrl(host, NetworkConstants.apiServerPort);
  }

  // حفظ جميع الإعدادات دفعة واحدة
  Future<void> saveConfiguration({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
    bool? offlineMode,
    bool? autoDiscover,
  }) async {
    await initialize();
    
    await Future.wait([
      setServerHost(host),
      setServerPort(port),
      setDatabaseName(database),
      setUsername(username),
      setPassword(password),
      if (offlineMode != null) setOfflineMode(offlineMode),
      if (autoDiscover != null) setAutoDiscover(autoDiscover),
    ]);
  }

  // إعادة تعيين الإعدادات للقيم الافتراضية
  Future<void> resetToDefaults() async {
    await initialize();
    
    await Future.wait([
      setServerHost(NetworkConstants.defaultServerHost),
      setServerPort(NetworkConstants.defaultServerPort),
      setDatabaseName(NetworkConstants.defaultDatabaseName),
      setUsername(NetworkConstants.defaultUsername),
      setPassword(NetworkConstants.defaultPassword),
      setOfflineMode(false),
      setAutoDiscover(true),
    ]);
  }

  // الحصول على جميع الإعدادات
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'serverHost': await getServerHost(),
      'serverPort': await getServerPort(),
      'databaseName': await getDatabaseName(),
      'username': await getUsername(),
      'password': await getPassword(),
      'isOfflineMode': await isOfflineMode(),
      'autoDiscover': await isAutoDiscoverEnabled(),
    };
  }
}

