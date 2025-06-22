import 'package:flutter_test/flutter_test.dart';
import 'package:gold_workshop_ai/src/services/auth/auth_service.dart';
import 'package:gold_workshop_ai/src/core/models/user_model.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should create user successfully', () async {
      final result = await authService.createUser(
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phone: '+966500000000',
        role: UserRole.sales,
        password: 'password123',
      );

      expect(result.isSuccess, true);
      expect(result.message, 'تم إنشاء المستخدم بنجاح.');
    });

    test('should fail login with invalid credentials', () async {
      final result = await authService.login('invaliduser', 'wrongpassword');

      expect(result.isSuccess, false);
      expect(result.message, contains('غير صحيحة'));
    });

    test('should succeed login with valid credentials', () async {
      // إنشاء مستخدم أولاً
      await authService.createUser(
        username: 'validuser',
        email: 'valid@example.com',
        fullName: 'Valid User',
        phone: '+966500000001',
        role: UserRole.sales,
        password: 'validpassword',
      );

      final result = await authService.login('validuser', 'validpassword');

      expect(result.isSuccess, true);
      expect(authService.isLoggedIn, true);
      expect(authService.currentUser?.username, 'validuser');
    });

    test('should logout successfully', () async {
      // تسجيل دخول أولاً
      await authService.createUser(
        username: 'logoutuser',
        email: 'logout@example.com',
        fullName: 'Logout User',
        phone: '+966500000002',
        role: UserRole.sales,
        password: 'logoutpassword',
      );
      
      await authService.login('logoutuser', 'logoutpassword');
      expect(authService.isLoggedIn, true);

      // تسجيل خروج
      await authService.logout();
      expect(authService.isLoggedIn, false);
      expect(authService.currentUser, null);
    });

    test('should validate password strength', () async {
      final weakPasswordResult = await authService.createUser(
        username: 'weakuser',
        email: 'weak@example.com',
        fullName: 'Weak User',
        phone: '+966500000003',
        role: UserRole.sales,
        password: '123', // كلمة مرور ضعيفة
      );

      expect(weakPasswordResult.isSuccess, false);
      expect(weakPasswordResult.message, contains('ضعيفة'));
    });

    test('should prevent duplicate usernames', () async {
      // إنشاء مستخدم أولاً
      await authService.createUser(
        username: 'duplicate',
        email: 'first@example.com',
        fullName: 'First User',
        phone: '+966500000004',
        role: UserRole.sales,
        password: 'password123',
      );

      // محاولة إنشاء مستخدم بنفس الاسم
      final result = await authService.createUser(
        username: 'duplicate',
        email: 'second@example.com',
        fullName: 'Second User',
        phone: '+966500000005',
        role: UserRole.sales,
        password: 'password456',
      );

      expect(result.isSuccess, false);
      expect(result.message, contains('موجود بالفعل'));
    });

    test('should change password successfully', () async {
      // إنشاء مستخدم وتسجيل دخول
      await authService.createUser(
        username: 'changepass',
        email: 'change@example.com',
        fullName: 'Change User',
        phone: '+966500000006',
        role: UserRole.sales,
        password: 'oldpassword',
      );
      
      await authService.login('changepass', 'oldpassword');

      // تغيير كلمة المرور
      final result = await authService.changePassword('oldpassword', 'newpassword123');

      expect(result.isSuccess, true);
      expect(result.message, contains('تم تغيير كلمة المرور'));
    });

    test('should fail to change password with wrong current password', () async {
      // إنشاء مستخدم وتسجيل دخول
      await authService.createUser(
        username: 'wrongpass',
        email: 'wrong@example.com',
        fullName: 'Wrong User',
        phone: '+966500000007',
        role: UserRole.sales,
        password: 'correctpassword',
      );
      
      await authService.login('wrongpass', 'correctpassword');

      // محاولة تغيير كلمة المرور بكلمة مرور حالية خاطئة
      final result = await authService.changePassword('wrongcurrent', 'newpassword123');

      expect(result.isSuccess, false);
      expect(result.message, contains('غير صحيحة'));
    });
  });
}

