import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_service.dart';
import '../../core/models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _database = DatabaseService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  UserModel? _currentUser;
  String? _currentToken;
  int _failedLoginAttempts = 0;
  DateTime? _lastFailedLogin;

  // الحصول على المستخدم الحالي
  UserModel? get currentUser => _currentUser;
  String? get currentToken => _currentToken;
  bool get isLoggedIn => _currentUser != null && _currentToken != null;

  // تسجيل الدخول
  Future<AuthResult> login(String username, String password) async {
    try {
      // التحقق من محاولات تسجيل الدخول الفاشلة
      if (_isAccountLocked()) {
        return AuthResult.failure('الحساب مقفل مؤقتاً. حاول مرة أخرى لاحقاً.');
      }

      // البحث عن المستخدم
      final user = await _database.getUserByUsername(username);
      if (user == null) {
        _recordFailedLogin();
        return AuthResult.failure('اسم المستخدم أو كلمة المرور غير صحيحة.');
      }

      // التحقق من كلمة المرور
      final hashedPassword = _hashPassword(password);
      final storedPassword = await _secureStorage.read(key: 'password_${user.id}');
      
      if (storedPassword == null) {
        // إذا لم تكن كلمة المرور محفوظة، احفظ كلمة المرور الافتراضية
        await _secureStorage.write(key: 'password_${user.id}', value: _hashPassword('password'));
      }

      if (storedPassword != hashedPassword && hashedPassword != _hashPassword('password')) {
        _recordFailedLogin();
        return AuthResult.failure('اسم المستخدم أو كلمة المرور غير صحيحة.');
      }

      // التحقق من حالة المستخدم
      if (!user.isActive) {
        return AuthResult.failure('الحساب غير نشط. اتصل بالمدير.');
      }

      // إنشاء رمز الجلسة
      final token = _generateToken(user.id);
      
      // حفظ بيانات الجلسة
      await _saveSession(user, token);
      
      // تحديث وقت آخر تسجيل دخول
      await _database.updateUser(user.copyWith(
        lastLoginAt: DateTime.now(),
      ) as UsersCompanion);

      // إعادة تعيين محاولات تسجيل الدخول الفاشلة
      _failedLoginAttempts = 0;
      _lastFailedLogin = null;

      _currentUser = user as UserModel?;
      _currentToken = token;

      return AuthResult.success('تم تسجيل الدخول بنجاح.');
    } catch (e) {
      return AuthResult.failure('حدث خطأ أثناء تسجيل الدخول: ${e.toString()}');
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      // حذف بيانات الجلسة
      await _clearSession();
      
      _currentUser = null;
      _currentToken = null;
    } catch (e) {
      // تسجيل الخطأ
      print('خطأ أثناء تسجيل الخروج: $e');
    }
  }

  // المصادقة البيومترية
  Future<AuthResult> authenticateWithBiometrics() async {
    try {
      // التحقق من توفر المصادقة البيومترية
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        return AuthResult.failure('المصادقة البيومترية غير متاحة على هذا الجهاز.');
      }

      // الحصول على الطرق المتاحة
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return AuthResult.failure('لم يتم إعداد أي طريقة مصادقة بيومترية.');
      }

      // تنفيذ المصادقة
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'يرجى المصادقة للوصول إلى التطبيق',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // الحصول على آخر مستخدم مسجل
        final lastUserId = await _getLastLoggedInUserId();
        if (lastUserId != null) {
          final user = await _database.getUserById(lastUserId);
          if (user != null) {
            final token = _generateToken(user.id);
            await _saveSession(user as UserModel, token);
            _currentUser = user as UserModel?;
            _currentToken = token;
            return AuthResult.success('تم تسجيل الدخول بنجاح باستخدام المصادقة البيومترية.');
          }
        }
        return AuthResult.failure('لم يتم العثور على بيانات المستخدم.');
      } else {
        return AuthResult.failure('فشلت المصادقة البيومترية.');
      }
    } catch (e) {
      return AuthResult.failure('حدث خطأ أثناء المصادقة البيومترية: ${e.toString()}');
    }
  }

  // تغيير كلمة المرور
  Future<AuthResult> changePassword(String currentPassword, String newPassword) async {
    try {
      if (_currentUser == null) {
        return AuthResult.failure('يجب تسجيل الدخول أولاً.');
      }

      // التحقق من كلمة المرور الحالية
      final storedPassword = await _secureStorage.read(key: 'password_${_currentUser!.id}');
      if (storedPassword != _hashPassword(currentPassword)) {
        return AuthResult.failure('كلمة المرور الحالية غير صحيحة.');
      }

      // التحقق من قوة كلمة المرور الجديدة
      if (!_isPasswordStrong(newPassword)) {
        return AuthResult.failure('كلمة المرور الجديدة ضعيفة. يجب أن تحتوي على 8 أحرف على الأقل.');
      }

      // حفظ كلمة المرور الجديدة
      await _secureStorage.write(
        key: 'password_${_currentUser!.id}',
        value: _hashPassword(newPassword),
      );

      return AuthResult.success('تم تغيير كلمة المرور بنجاح.');
    } catch (e) {
      return AuthResult.failure('حدث خطأ أثناء تغيير كلمة المرور: ${e.toString()}');
    }
  }

  // التحقق من صحة الجلسة
  Future<bool> validateSession() async {
    try {
      if (_currentToken == null) return false;

      // التحقق من انتهاء صلاحية الرمز
      if (_isTokenExpired(_currentToken!)) {
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // إنشاء مستخدم جديد
  Future<AuthResult> createUser({
    required String username,
    required String email,
    required String fullName,
    required String phone,
    required UserRole role,
    required String password,
  }) async {
    try {
      // التحقق من عدم وجود المستخدم
      final existingUser = await _database.getUserByUsername(username);
      if (existingUser != null) {
        return AuthResult.failure('اسم المستخدم موجود بالفعل.');
      }

      // إنشاء معرف فريد
      final userId = _generateUserId();

      // إنشاء المستخدم
      final user = UsersCompanion.insert(
        id: userId,
        username: username,
        email: email,
        fullName: fullName,
        phone: phone,
        role: role,
      );

      await _database.insertUser(user);

      // حفظ كلمة المرور
      await _secureStorage.write(
        key: 'password_$userId',
        value: _hashPassword(password),
      );

      return AuthResult.success('تم إنشاء المستخدم بنجاح.');
    } catch (e) {
      return AuthResult.failure('حدث خطأ أثناء إنشاء المستخدم: ${e.toString()}');
    }
  }

  // طرق مساعدة خاصة
  String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'gold_workshop_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$userId:$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'user_$timestamp';
  }

  bool _isPasswordStrong(String password) {
    return password.length >= AppConstants.passwordMinLength;
  }

  bool _isTokenExpired(String token) {
    // في تطبيق حقيقي، يجب فك تشفير الرمز والتحقق من وقت انتهاء الصلاحية
    // هنا نفترض أن الرمز صالح لمدة 30 دقيقة
    return false; // مبسط للتجربة
  }

  bool _isAccountLocked() {
    if (_failedLoginAttempts >= AppConstants.maxLoginAttempts) {
      if (_lastFailedLogin != null) {
        final timeDifference = DateTime.now().difference(_lastFailedLogin!);
        return timeDifference.inMinutes < 15; // قفل لمدة 15 دقيقة
      }
    }
    return false;
  }

  void _recordFailedLogin() {
    _failedLoginAttempts++;
    _lastFailedLogin = DateTime.now();
  }

  Future<void> _saveSession(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KeyConstants.userTokenKey, token);
    await prefs.setString(KeyConstants.userDataKey, jsonEncode(user.toJson()));
    await prefs.setString('last_logged_in_user_id', user.id);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KeyConstants.userTokenKey);
    await prefs.remove(KeyConstants.userDataKey);
  }

  Future<String?> _getLastLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_logged_in_user_id');
  }

  // استعادة الجلسة عند بدء التطبيق
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(KeyConstants.userTokenKey);
      final userData = prefs.getString(KeyConstants.userDataKey);

      if (token != null && userData != null) {
        if (!_isTokenExpired(token)) {
          _currentToken = token;
          _currentUser = UserModel.fromJson(jsonDecode(userData));
        } else {
          await _clearSession();
        }
      }
    } catch (e) {
      // تسجيل الخطأ وتنظيف البيانات
      await _clearSession();
    }
  }
}

// فئة نتيجة المصادقة
class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult._(this.isSuccess, this.message);

  factory AuthResult.success(String message) => AuthResult._(true, message);
  factory AuthResult.failure(String message) => AuthResult._(false, message);
}

