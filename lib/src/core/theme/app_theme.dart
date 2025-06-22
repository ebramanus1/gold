import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color primaryGold = Color(UIConstants.primaryColorValue);
  static const Color secondaryBrown = Color(UIConstants.secondaryColorValue);
  static const Color accentGold = Color(UIConstants.accentColorValue);
  
  // ألوان إضافية
  static const Color darkGold = Color(0xFFB8860B);
  static const Color lightGold = Color(0xFFFFFACD);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color copper = Color(0xFFB87333);
  
  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // ألوان محايدة
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // الثيم الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(primaryGold),
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.light(
        primary: primaryGold,
        secondary: secondaryBrown,
        tertiary: accentGold,
        surface: white,
        background: grey100,
        error: error,
        onPrimary: white,
        onSecondary: white,
        onSurface: grey900,
        onBackground: grey900,
        onError: white,
      ),
      
      // إعدادات النص
      textTheme: _textTheme,
      
      // إعدادات الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingLarge,
            vertical: UIConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          ),
        ),
      ),
      
      // إعدادات شريط التطبيق
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGold,
        foregroundColor: white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: UIConstants.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: white,
        ),
      ),
      
      // إعدادات البطاقات
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(UIConstants.paddingSmall),
      ),
      
      // إعدادات حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.all(UIConstants.paddingMedium),
      ),
      
      // إعدادات الأيقونات
      iconTheme: const IconThemeData(
        color: grey700,
        size: UIConstants.iconSizeMedium,
      ),
      
      // إعدادات القوائم
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: UIConstants.paddingMedium,
          vertical: UIConstants.paddingSmall,
        ),
      ),
    );
  }

  // الثيم الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(primaryGold),
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: secondaryBrown,
        tertiary: accentGold,
        surface: grey800,
        background: grey900,
        error: error,
        onPrimary: black,
        onSecondary: white,
        onSurface: white,
        onBackground: white,
        onError: white,
      ),
      
      textTheme: _textTheme.apply(
        bodyColor: white,
        displayColor: white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingLarge,
            vertical: UIConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          ),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: grey800,
        foregroundColor: white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: UIConstants.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: white,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: grey800,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(UIConstants.paddingSmall),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.all(UIConstants.paddingMedium),
      ),
      
      iconTheme: const IconThemeData(
        color: white,
        size: UIConstants.iconSizeMedium,
      ),
      
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: UIConstants.paddingMedium,
          vertical: UIConstants.paddingSmall,
        ),
      ),
    );
  }

  // نمط النص
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
    ),
    displaySmall: TextStyle(
      fontSize: UIConstants.fontSizeXLarge,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
    ),
    headlineLarge: TextStyle(
      fontSize: UIConstants.fontSizeLarge,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
    ),
    headlineSmall: TextStyle(
      fontSize: UIConstants.fontSizeMedium,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
    ),
    bodyLarge: TextStyle(
      fontSize: UIConstants.fontSizeMedium,
      fontWeight: FontWeight.normal,
      fontFamily: 'Cairo',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontFamily: 'Cairo',
    ),
    bodySmall: TextStyle(
      fontSize: UIConstants.fontSizeSmall,
      fontWeight: FontWeight.normal,
      fontFamily: 'Cairo',
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFamily: 'Cairo',
    ),
    labelMedium: TextStyle(
      fontSize: UIConstants.fontSizeSmall,
      fontWeight: FontWeight.w500,
      fontFamily: 'Cairo',
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      fontFamily: 'Cairo',
    ),
  );

  // إنشاء MaterialColor من Color
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

