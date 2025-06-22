import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoldPriceService {
  static const String _apiKey = 'YOUR_API_KEY'; // يجب الحصول على مفتاح API
  static const String _baseUrl = 'https://api.metals.live/v1/spot';
  static const String _fallbackUrl = 'https://api.goldapi.io/api';
  
  // الحصول على أسعار الذهب الحالية
  static Future<GoldPrices> getCurrentPrices() async {
    try {
      // محاولة الحصول على الأسعار من المصدر الأساسي
      final response = await http.get(
        Uri.parse('$_baseUrl/gold'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GoldPrices.fromJson(data);
      } else {
        // محاولة المصدر البديل
        return await _getFallbackPrices();
      }
    } catch (e) {
      // في حالة عدم توفر الإنترنت، استخدام الأسعار المحفوظة محلياً
      return await _getLocalPrices();
    }
  }
  
  // الحصول على أسعار الذهب التاريخية
  static Future<List<HistoricalPrice>> getHistoricalPrices({
    required DateTime startDate,
    required DateTime endDate,
    String currency = 'USD',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/gold/history')
            .replace(queryParameters: {
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'currency': currency,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> prices = data['prices'] ?? [];
        return prices.map((price) => HistoricalPrice.fromJson(price)).toList();
      } else {
        throw Exception('فشل في جلب الأسعار التاريخية');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بخدمة الأسعار: $e');
    }
  }
  
  // تحديث الأسعار تلقائياً
  static Future<void> updatePricesAutomatically() async {
    try {
      final prices = await getCurrentPrices();
      await _savePricesLocally(prices);
      
      // إرسال إشعار بالتحديث
      _notifyPriceUpdate(prices);
    } catch (e) {
      print('فشل في تحديث الأسعار تلقائياً: $e');
    }
  }
  
  // حساب سعر الذهب حسب العيار
  static double calculateKaratPrice(double goldPrice24k, int karat) {
    final purity = karat / 24.0;
    return goldPrice24k * purity;
  }
  
  // تحويل العملة
  static Future<double> convertCurrency(double amount, String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return amount;
    
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rate = data['rates'][toCurrency] ?? 1.0;
        return amount * rate;
      } else {
        // استخدام معدل افتراضي
        return _getDefaultExchangeRate(fromCurrency, toCurrency) * amount;
      }
    } catch (e) {
      // استخدام معدل افتراضي في حالة الخطأ
      return _getDefaultExchangeRate(fromCurrency, toCurrency) * amount;
    }
  }
  
  // الحصول على أسعار من مصدر بديل
  static Future<GoldPrices> _getFallbackPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$_fallbackUrl/XAU/USD'),
        headers: {
          'x-access-token': _apiKey,
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GoldPrices.fromFallbackJson(data);
      } else {
        throw Exception('فشل في جلب الأسعار من المصدر البديل');
      }
    } catch (e) {
      throw Exception('خطأ في المصدر البديل: $e');
    }
  }
  
  // الحصول على الأسعار المحفوظة محلياً
  static Future<GoldPrices> _getLocalPrices() async {
    // قراءة الأسعار من قاعدة البيانات المحلية أو SharedPreferences
    // هذه قيم افتراضية في حالة عدم وجود أسعار محفوظة
    return GoldPrices(
      gold24k: 2000.0,
      gold22k: 1833.33,
      gold21k: 1750.0,
      gold18k: 1500.0,
      currency: 'USD',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      source: 'محلي',
      isOffline: true,
    );
  }
  
  // حفظ الأسعار محلياً
  static Future<void> _savePricesLocally(GoldPrices prices) async {
    // حفظ الأسعار في قاعدة البيانات المحلية أو SharedPreferences
    // يمكن تنفيذ هذا باستخدام Hive أو SQLite
  }
  
  // إشعار بتحديث الأسعار
  static void _notifyPriceUpdate(GoldPrices prices) {
    // إرسال إشعار للمستخدمين بتحديث الأسعار
    // يمكن استخدام NotificationService
  }
  
  // الحصول على معدل صرف افتراضي
  static double _getDefaultExchangeRate(String fromCurrency, String toCurrency) {
    // معدلات صرف افتراضية للعملات الشائعة
    final Map<String, Map<String, double>> rates = {
      'USD': {
        'SAR': 3.75,
        'AED': 3.67,
        'EUR': 0.85,
        'GBP': 0.73,
      },
      'SAR': {
        'USD': 0.27,
        'AED': 0.98,
        'EUR': 0.23,
        'GBP': 0.19,
      },
    };
    
    return rates[fromCurrency]?[toCurrency] ?? 1.0;
  }
}

// نموذج أسعار الذهب
class GoldPrices {
  final double gold24k;
  final double gold22k;
  final double gold21k;
  final double gold18k;
  final String currency;
  final DateTime lastUpdated;
  final String source;
  final bool isOffline;
  final double? change24h;
  final double? changePercent24h;

  GoldPrices({
    required this.gold24k,
    required this.gold22k,
    required this.gold21k,
    required this.gold18k,
    required this.currency,
    required this.lastUpdated,
    required this.source,
    this.isOffline = false,
    this.change24h,
    this.changePercent24h,
  });

  factory GoldPrices.fromJson(Map<String, dynamic> json) {
    final price24k = json['price']?.toDouble() ?? 0.0;
    return GoldPrices(
      gold24k: price24k,
      gold22k: GoldPriceService.calculateKaratPrice(price24k, 22),
      gold21k: GoldPriceService.calculateKaratPrice(price24k, 21),
      gold18k: GoldPriceService.calculateKaratPrice(price24k, 18),
      currency: json['currency'] ?? 'USD',
      lastUpdated: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      source: json['source'] ?? 'API',
      change24h: json['change_24h']?.toDouble(),
      changePercent24h: json['change_percent_24h']?.toDouble(),
    );
  }

  factory GoldPrices.fromFallbackJson(Map<String, dynamic> json) {
    final price24k = json['price']?.toDouble() ?? 0.0;
    return GoldPrices(
      gold24k: price24k,
      gold22k: GoldPriceService.calculateKaratPrice(price24k, 22),
      gold21k: GoldPriceService.calculateKaratPrice(price24k, 21),
      gold18k: GoldPriceService.calculateKaratPrice(price24k, 18),
      currency: json['currency'] ?? 'USD',
      lastUpdated: DateTime.parse(json['ts'] ?? DateTime.now().toIso8601String()),
      source: 'Fallback API',
      change24h: json['ch']?.toDouble(),
      changePercent24h: json['chp']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gold24k': gold24k,
      'gold22k': gold22k,
      'gold21k': gold21k,
      'gold18k': gold18k,
      'currency': currency,
      'lastUpdated': lastUpdated.toIso8601String(),
      'source': source,
      'isOffline': isOffline,
      'change24h': change24h,
      'changePercent24h': changePercent24h,
    };
  }

  // الحصول على السعر حسب العيار
  double getPriceByKarat(int karat) {
    switch (karat) {
      case 24:
        return gold24k;
      case 22:
        return gold22k;
      case 21:
        return gold21k;
      case 18:
        return gold18k;
      default:
        return GoldPriceService.calculateKaratPrice(gold24k, karat);
    }
  }

  // التحقق من حداثة الأسعار
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inMinutes < 30; // الأسعار حديثة إذا كانت أقل من 30 دقيقة
  }

  // اتجاه السعر
  PriceTrend get trend {
    if (change24h == null) return PriceTrend.neutral;
    if (change24h! > 0) return PriceTrend.up;
    if (change24h! < 0) return PriceTrend.down;
    return PriceTrend.neutral;
  }
}

// نموذج السعر التاريخي
class HistoricalPrice {
  final DateTime date;
  final double price;
  final double? high;
  final double? low;
  final double? open;
  final double? close;
  final String currency;

  HistoricalPrice({
    required this.date,
    required this.price,
    this.high,
    this.low,
    this.open,
    this.close,
    this.currency = 'USD',
  });

  factory HistoricalPrice.fromJson(Map<String, dynamic> json) {
    return HistoricalPrice(
      date: DateTime.parse(json['date']),
      price: json['price']?.toDouble() ?? 0.0,
      high: json['high']?.toDouble(),
      low: json['low']?.toDouble(),
      open: json['open']?.toDouble(),
      close: json['close']?.toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'price': price,
      'high': high,
      'low': low,
      'open': open,
      'close': close,
      'currency': currency,
    };
  }
}

// اتجاه السعر
enum PriceTrend {
  up,
  down,
  neutral
}

// إعدادات تحديث الأسعار
class PriceUpdateSettings {
  final bool autoUpdate;
  final Duration updateInterval;
  final List<String> currencies;
  final bool notifyOnChange;
  final double notificationThreshold;

  PriceUpdateSettings({
    this.autoUpdate = true,
    this.updateInterval = const Duration(minutes: 15),
    this.currencies = const ['USD', 'SAR'],
    this.notifyOnChange = true,
    this.notificationThreshold = 1.0, // 1% تغيير
  });

  factory PriceUpdateSettings.fromJson(Map<String, dynamic> json) {
    return PriceUpdateSettings(
      autoUpdate: json['autoUpdate'] ?? true,
      updateInterval: Duration(minutes: json['updateIntervalMinutes'] ?? 15),
      currencies: List<String>.from(json['currencies'] ?? ['USD', 'SAR']),
      notifyOnChange: json['notifyOnChange'] ?? true,
      notificationThreshold: json['notificationThreshold']?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoUpdate': autoUpdate,
      'updateIntervalMinutes': updateInterval.inMinutes,
      'currencies': currencies,
      'notifyOnChange': notifyOnChange,
      'notificationThreshold': notificationThreshold,
    };
  }
}

// خدمة مراقبة الأسعار
class PriceMonitoringService {
  static Timer? _updateTimer;
  static GoldPrices? _lastPrices;

  // بدء مراقبة الأسعار
  static void startMonitoring(PriceUpdateSettings settings) {
    if (!settings.autoUpdate) return;

    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(settings.updateInterval, (timer) async {
      try {
        final newPrices = await GoldPriceService.getCurrentPrices();
        
        if (_lastPrices != null && settings.notifyOnChange) {
          final changePercent = ((newPrices.gold24k - _lastPrices!.gold24k) / _lastPrices!.gold24k) * 100;
          
          if (changePercent.abs() >= settings.notificationThreshold) {
            _sendPriceChangeNotification(newPrices, changePercent);
          }
        }
        
        _lastPrices = newPrices;
      } catch (e) {
        print('خطأ في مراقبة الأسعار: $e');
      }
    });
  }

  // إيقاف مراقبة الأسعار
  static void stopMonitoring() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // إرسال إشعار تغيير السعر
  static void _sendPriceChangeNotification(GoldPrices prices, double changePercent) {
    // تنفيذ إرسال الإشعار
    final direction = changePercent > 0 ? 'ارتفع' : 'انخفض';
    final message = 'سعر الذهب $direction بنسبة ${changePercent.abs().toStringAsFixed(2)}%';
    
    // يمكن استخدام NotificationService هنا
    print('إشعار: $message');
  }
}

// Providers للاستخدام مع Riverpod
final goldPriceServiceProvider = Provider<GoldPriceService>((ref) {
  return GoldPriceService();
});

final currentGoldPricesProvider = FutureProvider<GoldPrices>((ref) async {
  return await GoldPriceService.getCurrentPrices();
});

final historicalGoldPricesProvider = FutureProvider.family<List<HistoricalPrice>, Map<String, dynamic>>((ref, params) async {
  return await GoldPriceService.getHistoricalPrices(
    startDate: params['startDate'] as DateTime,
    endDate: params['endDate'] as DateTime,
    currency: params['currency'] as String? ?? 'USD',
  );
});

final priceUpdateSettingsProvider = StateProvider<PriceUpdateSettings>((ref) {
  return PriceUpdateSettings();
});

