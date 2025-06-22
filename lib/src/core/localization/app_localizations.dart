import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// مزود إدارة اللغة
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('ar', 'SA')) {
    _loadLanguage();
  }

  static const String _languageKey = 'selected_language';

  // تحميل اللغة المحفوظة
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'ar';
      
      if (languageCode == 'en') {
        state = const Locale('en', 'US');
      } else {
        state = const Locale('ar', 'SA');
      }
    } catch (e) {
      // في حالة الخطأ، استخدم العربية كافتراضي
      state = const Locale('ar', 'SA');
    }
  }

  // تغيير اللغة
  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      if (languageCode == 'en') {
        state = const Locale('en', 'US');
      } else {
        state = const Locale('ar', 'SA');
      }
    } catch (e) {
      // في حالة الخطأ، لا تغير اللغة
      print('Error changing language: $e');
    }
  }

  // الحصول على اتجاه النص
  TextDirection get textDirection {
    return state.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  // التحقق من كون اللغة عربية
  bool get isArabic => state.languageCode == 'ar';

  // التحقق من كون اللغة إنجليزية
  bool get isEnglish => state.languageCode == 'en';
}

// مزود إدارة المظهر
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const String _themeKey = 'selected_theme';

  // تحميل المظهر المحفوظ
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      
      switch (themeIndex) {
        case 0:
          state = ThemeMode.light;
          break;
        case 1:
          state = ThemeMode.dark;
          break;
        case 2:
          state = ThemeMode.system;
          break;
        default:
          state = ThemeMode.light;
      }
    } catch (e) {
      state = ThemeMode.light;
    }
  }

  // تغيير المظهر
  Future<void> changeTheme(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int themeIndex;
      
      switch (themeMode) {
        case ThemeMode.light:
          themeIndex = 0;
          break;
        case ThemeMode.dark:
          themeIndex = 1;
          break;
        case ThemeMode.system:
          themeIndex = 2;
          break;
      }
      
      await prefs.setInt(_themeKey, themeIndex);
      state = themeMode;
    } catch (e) {
      print('Error changing theme: $e');
    }
  }
}

// كلاس الترجمة
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // النصوص المترجمة
  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // التطبيق العام
      'app_title': 'ورشة الذهب الذكية',
      'app_subtitle': 'نظام إدارة شامل',
      
      // القوائم الرئيسية
      'dashboard': 'لوحة التحكم',
      'clients': 'إدارة العملاء',
      'raw_materials': 'المواد الخام',
      'work_orders': 'أوامر العمل',
      'finished_goods': 'المنتجات النهائية',
      'reports': 'التقارير',
      'settings': 'الإعدادات',
      'users': 'إدارة المستخدمين',
      
      // أزرار عامة
      'add': 'إضافة',
      'edit': 'تعديل',
      'delete': 'حذف',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'close': 'إغلاق',
      'refresh': 'تحديث',
      'search': 'بحث',
      'filter': 'فلتر',
      'clear_filters': 'مسح الفلاتر',
      'export': 'تصدير',
      'print': 'طباعة',
      'view': 'عرض',
      
      // الإعدادات
      'general_settings': 'الإعدادات العامة',
      'language': 'اللغة',
      'theme': 'المظهر',
      'arabic': 'العربية',
      'english': 'الإنجليزية',
      'light_theme': 'المظهر الفاتح',
      'dark_theme': 'المظهر الداكن',
      'system_theme': 'حسب النظام',
      'backup_settings': 'إعدادات النسخ الاحتياطي',
      'notification_settings': 'إعدادات الإشعارات',
      
      // أوامر العمل
      'work_order_management': 'إدارة أوامر العمل',
      'add_work_order': 'إضافة أمر عمل جديد',
      'edit_work_order': 'تعديل أمر العمل',
      'work_order_details': 'تفاصيل أمر العمل',
      'order_number': 'رقم الأمر',
      'client_name': 'اسم العميل',
      'work_type': 'نوع العمل',
      'description': 'الوصف',
      'status': 'الحالة',
      'priority': 'الأولوية',
      'estimated_cost': 'التكلفة المقدرة',
      'creation_date': 'تاريخ الإنشاء',
      'expected_completion': 'الموعد المتوقع',
      'completion_date': 'تاريخ الإنجاز',
      'notes': 'ملاحظات',
      
      // حالات أوامر العمل
      'pending': 'معلق',
      'in_progress': 'قيد التنفيذ',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
      'on_hold': 'متوقف',
      
      // أنواع أوامر العمل
      'manufacturing': 'تصنيع',
      'repair': 'إصلاح',
      'polishing': 'تلميع',
      'custom': 'مخصص',
      
      // الأولوية
      'low': 'منخفضة',
      'medium': 'متوسطة',
      'high': 'عالية',
      'urgent': 'عاجلة',
      
      // المنتجات النهائية
      'finished_goods_management': 'إدارة المنتجات النهائية',
      'add_product': 'إضافة منتج جديد',
      'edit_product': 'تعديل المنتج',
      'product_details': 'تفاصيل المنتج',
      'product_name': 'اسم المنتج',
      'category': 'الفئة',
      'karat': 'العيار',
      'gold_weight': 'وزن الذهب',
      'stone_weight': 'وزن الأحجار',
      'total_weight': 'الوزن الإجمالي',
      'price': 'السعر',
      'quantity': 'الكمية',
      'min_stock_level': 'الحد الأدنى للمخزون',
      'barcode': 'الباركود',
      'creation_date': 'تاريخ الإضافة',
      
      // فئات المنتجات
      'rings': 'خواتم',
      'necklaces': 'قلائد',
      'bracelets': 'أساور',
      'earrings': 'أقراط',
      'pendants': 'دلايات',
      'chains': 'سلاسل',
      'sets': 'طقم',
      'other': 'أخرى',
      
      // التقارير
      'reports_management': 'إدارة التقارير',
      'report_settings': 'إعدادات التقرير',
      'report_type': 'نوع التقرير',
      'from_date': 'من تاريخ',
      'to_date': 'إلى تاريخ',
      'generate_report': 'إنشاء التقرير',
      'generating': 'جاري الإنشاء...',
      'export_report': 'تصدير التقرير',
      'print_report': 'طباعة التقرير',
      
      // أنواع التقارير
      'sales_report': 'تقرير المبيعات',
      'inventory_report': 'تقرير المخزون',
      'work_orders_report': 'تقرير أوامر العمل',
      'financial_report': 'التقرير المالي',
      'gold_movement_report': 'تقرير حركة الذهب',
      
      // الإحصائيات
      'total_products': 'إجمالي المنتجات',
      'low_stock': 'منخفض المخزون',
      'total_value': 'القيمة الإجمالية',
      'total_sales': 'إجمالي المبيعات',
      'active_work_orders': 'أوامر العمل النشطة',
      'inventory_value': 'قيمة المخزون',
      'net_profit': 'صافي الربح',
      
      // رسائل النجاح والخطأ
      'success': 'نجح',
      'error': 'خطأ',
      'work_order_added': 'تم إضافة أمر العمل بنجاح',
      'work_order_updated': 'تم تحديث أمر العمل بنجاح',
      'work_order_deleted': 'تم حذف أمر العمل بنجاح',
      'product_added': 'تم إضافة المنتج بنجاح',
      'product_updated': 'تم تحديث المنتج بنجاح',
      'product_deleted': 'تم حذف المنتج بنجاح',
      'report_generated': 'تم إنشاء التقرير بنجاح',
      'report_exported_pdf': 'تم تصدير التقرير بصيغة PDF',
      'report_exported_excel': 'تم تصدير التقرير بصيغة Excel',
      'report_sent_print': 'تم إرسال التقرير للطباعة',
      
      // التحقق من صحة البيانات
      'required_field': 'هذا الحقل مطلوب',
      'invalid_number': 'رقم غير صحيح',
      'enter_client_name': 'يرجى إدخال اسم العميل',
      'enter_work_description': 'يرجى إدخال وصف العمل',
      'enter_estimated_cost': 'يرجى إدخال التكلفة المقدرة',
      'enter_product_name': 'يرجى إدخال اسم المنتج',
      
      // العملة
      'currency': 'ريال',
      'gram': 'جم',
      
      // تأكيد الحذف
      'confirm_delete': 'تأكيد الحذف',
      'confirm_delete_work_order': 'هل أنت متأكد من حذف أمر العمل رقم',
      'confirm_delete_product': 'هل أنت متأكد من حذف المنتج',
      
      // لا توجد بيانات
      'no_work_orders': 'لا توجد أوامر عمل',
      'no_products': 'لا توجد منتجات',
      'no_data': 'لا توجد بيانات',
      
      // البحث والفلاتر
      'search_work_orders': 'البحث في أوامر العمل...',
      'search_products': 'البحث في المنتجات...',
      
      // الملف الشخصي
      'profile': 'الملف الشخصي',
      'logout': 'تسجيل الخروج',
      'general_manager': 'المدير العام',
    },
    'en': {
      // General App
      'app_title': 'Gold Workshop AI',
      'app_subtitle': 'Comprehensive Management System',
      
      // Main Menus
      'dashboard': 'Dashboard',
      'clients': 'Client Management',
      'raw_materials': 'Raw Materials',
      'work_orders': 'Work Orders',
      'finished_goods': 'Finished Goods',
      'reports': 'Reports',
      'settings': 'Settings',
      'users': 'User Management',
      
      // General Buttons
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'cancel': 'Cancel',
      'close': 'Close',
      'refresh': 'Refresh',
      'search': 'Search',
      'filter': 'Filter',
      'clear_filters': 'Clear Filters',
      'export': 'Export',
      'print': 'Print',
      'view': 'View',
      
      // Settings
      'general_settings': 'General Settings',
      'language': 'Language',
      'theme': 'Theme',
      'arabic': 'Arabic',
      'english': 'English',
      'light_theme': 'Light Theme',
      'dark_theme': 'Dark Theme',
      'system_theme': 'System Theme',
      'backup_settings': 'Backup Settings',
      'notification_settings': 'Notification Settings',
      
      // Work Orders
      'work_order_management': 'Work Order Management',
      'add_work_order': 'Add New Work Order',
      'edit_work_order': 'Edit Work Order',
      'work_order_details': 'Work Order Details',
      'order_number': 'Order Number',
      'client_name': 'Client Name',
      'work_type': 'Work Type',
      'description': 'Description',
      'status': 'Status',
      'priority': 'Priority',
      'estimated_cost': 'Estimated Cost',
      'creation_date': 'Creation Date',
      'expected_completion': 'Expected Completion',
      'completion_date': 'Completion Date',
      'notes': 'Notes',
      
      // Work Order Status
      'pending': 'Pending',
      'in_progress': 'In Progress',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'on_hold': 'On Hold',
      
      // Work Order Types
      'manufacturing': 'Manufacturing',
      'repair': 'Repair',
      'polishing': 'Polishing',
      'custom': 'Custom',
      
      // Priority
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'urgent': 'Urgent',
      
      // Finished Goods
      'finished_goods_management': 'Finished Goods Management',
      'add_product': 'Add New Product',
      'edit_product': 'Edit Product',
      'product_details': 'Product Details',
      'product_name': 'Product Name',
      'category': 'Category',
      'karat': 'Karat',
      'gold_weight': 'Gold Weight',
      'stone_weight': 'Stone Weight',
      'total_weight': 'Total Weight',
      'price': 'Price',
      'quantity': 'Quantity',
      'min_stock_level': 'Min Stock Level',
      'barcode': 'Barcode',
      'creation_date': 'Creation Date',
      
      // Product Categories
      'rings': 'Rings',
      'necklaces': 'Necklaces',
      'bracelets': 'Bracelets',
      'earrings': 'Earrings',
      'pendants': 'Pendants',
      'chains': 'Chains',
      'sets': 'Sets',
      'other': 'Other',
      
      // Reports
      'reports_management': 'Reports Management',
      'report_settings': 'Report Settings',
      'report_type': 'Report Type',
      'from_date': 'From Date',
      'to_date': 'To Date',
      'generate_report': 'Generate Report',
      'generating': 'Generating...',
      'export_report': 'Export Report',
      'print_report': 'Print Report',
      
      // Report Types
      'sales_report': 'Sales Report',
      'inventory_report': 'Inventory Report',
      'work_orders_report': 'Work Orders Report',
      'financial_report': 'Financial Report',
      'gold_movement_report': 'Gold Movement Report',
      
      // Statistics
      'total_products': 'Total Products',
      'low_stock': 'Low Stock',
      'total_value': 'Total Value',
      'total_sales': 'Total Sales',
      'active_work_orders': 'Active Work Orders',
      'inventory_value': 'Inventory Value',
      'net_profit': 'Net Profit',
      
      // Success and Error Messages
      'success': 'Success',
      'error': 'Error',
      'work_order_added': 'Work order added successfully',
      'work_order_updated': 'Work order updated successfully',
      'work_order_deleted': 'Work order deleted successfully',
      'product_added': 'Product added successfully',
      'product_updated': 'Product updated successfully',
      'product_deleted': 'Product deleted successfully',
      'report_generated': 'Report generated successfully',
      'report_exported_pdf': 'Report exported as PDF',
      'report_exported_excel': 'Report exported as Excel',
      'report_sent_print': 'Report sent to printer',
      
      // Validation
      'required_field': 'This field is required',
      'invalid_number': 'Invalid number',
      'enter_client_name': 'Please enter client name',
      'enter_work_description': 'Please enter work description',
      'enter_estimated_cost': 'Please enter estimated cost',
      'enter_product_name': 'Please enter product name',
      
      // Currency
      'currency': 'SAR',
      'gram': 'g',
      
      // Delete Confirmation
      'confirm_delete': 'Confirm Delete',
      'confirm_delete_work_order': 'Are you sure you want to delete work order number',
      'confirm_delete_product': 'Are you sure you want to delete product',
      
      // No Data
      'no_work_orders': 'No work orders',
      'no_products': 'No products',
      'no_data': 'No data',
      
      // Search and Filters
      'search_work_orders': 'Search work orders...',
      'search_products': 'Search products...',
      
      // Profile
      'profile': 'Profile',
      'logout': 'Logout',
      'general_manager': 'General Manager',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // اختصارات للترجمة
  String get appTitle => translate('app_title');
  String get appSubtitle => translate('app_subtitle');
  String get dashboard => translate('dashboard');
  String get clients => translate('clients');
  String get rawMaterials => translate('raw_materials');
  String get workOrders => translate('work_orders');
  String get finishedGoods => translate('finished_goods');
  String get reports => translate('reports');
  String get settings => translate('settings');
  String get users => translate('users');
  String get add => translate('add');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get close => translate('close');
  String get refresh => translate('refresh');
  String get search => translate('search');
  String get filter => translate('filter');
  String get clearFilters => translate('clear_filters');
  String get export => translate('export');
  String get print => translate('print');
  String get view => translate('view');
  String get language => translate('language');
  String get theme => translate('theme');
  String get arabic => translate('arabic');
  String get english => translate('english');
  String get lightTheme => translate('light_theme');
  String get darkTheme => translate('dark_theme');
  String get systemTheme => translate('system_theme');
  String get currency => translate('currency');
  String get gram => translate('gram');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

