import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_workshop_ai/main.dart';

void main() {
  group('Main App Widget Tests', () {
    testWidgets('should create app without errors', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));

      // التحقق من عدم وجود أخطاء
      expect(tester.takeException(), isNull);
    });

    testWidgets('should show login screen initially', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));
      await tester.pumpAndSettle();

      // التحقق من وجود شاشة تسجيل الدخول
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.text('اسم المستخدم'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
    });

    testWidgets('should have proper app title', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));

      // الحصول على MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // التحقق من العنوان
      expect(materialApp.title, 'Gold Workshop AI');
    });

    testWidgets('should support RTL direction', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));
      await tester.pumpAndSettle();

      // التحقق من اتجاه النص
      final directionality = tester.widget<Directionality>(find.byType(Directionality));
      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('should have Arabic locale by default', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));

      // الحصول على MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // التحقق من اللغة
      expect(materialApp.locale, const Locale('ar', 'SA'));
    });

    testWidgets('should support both Arabic and English locales', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));

      // الحصول على MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // التحقق من اللغات المدعومة
      expect(materialApp.supportedLocales, contains(const Locale('ar', 'SA')));
      expect(materialApp.supportedLocales, contains(const Locale('en', 'US')));
    });

    testWidgets('should have proper theme configuration', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));

      // الحصول على MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // التحقق من وجود الثيمات
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      expect(materialApp.themeMode, ThemeMode.system);
    });

    testWidgets('should not show debug banner', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));

      // الحصول على MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // التحقق من إخفاء شعار التطوير
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('should have proper initial route', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));

      // الحصول على MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // التحقق من المسار الأولي
      expect(materialApp.initialRoute, '/login');
    });

    testWidgets('should have defined routes', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));

      // الحصول على MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // التحقق من وجود المسارات
      expect(materialApp.routes, isNotNull);
      expect(materialApp.routes!.containsKey('/login'), true);
      expect(materialApp.routes!.containsKey('/dashboard'), true);
    });
  });

  group('App Integration Tests', () {
    testWidgets('should navigate from login to dashboard', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));
      await tester.pumpAndSettle();

      // التحقق من وجود شاشة تسجيل الدخول
      expect(find.text('تسجيل الدخول'), findsOneWidget);

      // ملء بيانات تسجيل الدخول
      await tester.enterText(find.byType(TextFormField).first, 'admin');
      await tester.enterText(find.byType(TextFormField).last, 'password');

      // الضغط على زر تسجيل الدخول
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // التحقق من الانتقال إلى لوحة التحكم
      expect(find.text('لوحة التحكم'), findsOneWidget);
    });

    testWidgets('should show error for invalid login', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));
      await tester.pumpAndSettle();

      // ملء بيانات خاطئة
      await tester.enterText(find.byType(TextFormField).first, 'wronguser');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpass');

      // الضغط على زر تسجيل الدخول
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // التحقق من عرض رسالة خطأ
      expect(find.text('خطأ'), findsOneWidget);
      expect(find.text('بيانات الدخول غير صحيحة'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));
      await tester.pumpAndSettle();

      // الضغط على زر تسجيل الدخول بدون ملء البيانات
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // التحقق من رسائل التحقق
      expect(find.text('يرجى إدخال اسم المستخدم'), findsOneWidget);
      expect(find.text('يرجى إدخال كلمة المرور'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      // بناء التطبيق
      await tester.pumpWidget(const ProviderScope(child: GoldWorkshopApp()));
      await tester.pumpAndSettle();

      // العثور على حقل كلمة المرور
      final passwordField = find.byType(TextFormField).last;
      final visibilityToggle = find.byIcon(Icons.visibility_off);

      // التحقق من أن كلمة المرور مخفية
      final textFormField = tester.widget<TextFormField>(passwordField);
      expect(textFormField.obscureText, true);

      // الضغط على زر إظهار/إخفاء كلمة المرور
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // التحقق من تغيير الأيقونة
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}

