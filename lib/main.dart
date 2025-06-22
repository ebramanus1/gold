import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/localization/app_localizations.dart';
import 'src/features/auth/login_screen.dart';
import 'src/features/main/main_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GoldWorkshopApp(),
    ),
  );
}

class GoldWorkshopApp extends ConsumerWidget {
  const GoldWorkshopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final currentTheme = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Gold Workshop AI',
      debugShowCheckedModeBanner: false,
      
      // إعدادات الثيم
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentTheme,
      
      // إعدادات التدويل
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'), // العربية
        Locale('en', 'US'), // الإنجليزية
      ],
      locale: currentLocale,
      
      // إعدادات التوجيه
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
      
      // إعداد اتجاه النص
      builder: (context, child) {
        final languageNotifier = ref.read(languageProvider.notifier);
        return Directionality(
          textDirection: languageNotifier.textDirection,
          child: child!,
        );
      },
    );
  }
}

