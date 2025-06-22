import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// خدمة دعم الموازين الإلكترونية
class ScaleService {
  static const MethodChannel _channel = MethodChannel('gold_workshop/scale');

  // الاتصال بالميزان
  Future<bool> connectToScale() async {
    try {
      final bool result = await _channel.invokeMethod('connectScale');
      return result;
    } on PlatformException catch (e) {
      print('خطأ في الاتصال بالميزان: ${e.message}');
      return false;
    }
  }

  // قطع الاتصال بالميزان
  Future<bool> disconnectFromScale() async {
    try {
      final bool result = await _channel.invokeMethod('disconnectScale');
      return result;
    } on PlatformException catch (e) {
      print('خطأ في قطع الاتصال بالميزان: ${e.message}');
      return false;
    }
  }

  // قراءة الوزن من الميزان
  Future<double?> readWeight() async {
    try {
      final double? weight = await _channel.invokeMethod('readWeight');
      return weight;
    } on PlatformException catch (e) {
      print('خطأ في قراءة الوزن: ${e.message}');
      return null;
    }
  }

  // تصفير الميزان
  Future<bool> tareScale() async {
    try {
      final bool result = await _channel.invokeMethod('tareScale');
      return result;
    } on PlatformException catch (e) {
      print('خطأ في تصفير الميزان: ${e.message}');
      return false;
    }
  }

  // التحقق من حالة الاتصال
  Future<bool> isConnected() async {
    try {
      final bool result = await _channel.invokeMethod('isScaleConnected');
      return result;
    } on PlatformException catch (e) {
      print('خطأ في التحقق من حالة الاتصال: ${e.message}');
      return false;
    }
  }

  // الحصول على معلومات الميزان
  Future<Map<String, dynamic>?> getScaleInfo() async {
    try {
      final Map<String, dynamic>? info = await _channel.invokeMethod('getScaleInfo');
      return info;
    } on PlatformException catch (e) {
      print('خطأ في الحصول على معلومات الميزان: ${e.message}');
      return null;
    }
  }

  // محاكاة قراءة الوزن (للاختبار)
  Future<double> simulateWeightReading() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // إرجاع وزن عشوائي بين 1 و 100 جرام
    return 1.0 + (99.0 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
  }
}

// خدمة دعم ماسحات الباركود
class BarcodeService {
  static const MethodChannel _channel = MethodChannel('gold_workshop/barcode');

  // مسح الباركود
  Future<String?> scanBarcode() async {
    try {
      final String? barcode = await _channel.invokeMethod('scanBarcode');
      return barcode;
    } on PlatformException catch (e) {
      print('خطأ في مسح الباركود: ${e.message}');
      return null;
    }
  }

  // إنشاء باركود
  Future<String> generateBarcode(String itemId) async {
    // إنشاء باركود بناءً على معرف العنصر
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'GW${itemId.padLeft(6, '0')}${timestamp.toString().substring(8)}';
  }

  // التحقق من صحة الباركود
  bool validateBarcode(String barcode) {
    // التحقق من أن الباركود يبدأ بـ GW ويحتوي على الأرقام المطلوبة
    final regex = RegExp(r'^GW\d{6}\d{5}$');
    return regex.hasMatch(barcode);
  }

  // استخراج معرف العنصر من الباركود
  String? extractItemIdFromBarcode(String barcode) {
    if (!validateBarcode(barcode)) return null;
    
    // استخراج معرف العنصر من الباركود (الأرقام من 2 إلى 8)
    final itemIdStr = barcode.substring(2, 8);
    return int.parse(itemIdStr).toString();
  }

  // محاكاة مسح الباركود (للاختبار)
  Future<String> simulateBarcodeScan() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // إرجاع باركود وهمي
    final itemId = (DateTime.now().millisecondsSinceEpoch % 1000).toString();
    return generateBarcode(itemId);
  }
}

// Providers
final scaleServiceProvider = Provider((ref) => ScaleService());
final barcodeServiceProvider = Provider((ref) => BarcodeService());

// Provider لحالة الاتصال بالميزان
final scaleConnectionProvider = StateNotifierProvider<ScaleConnectionNotifier, bool>((ref) {
  return ScaleConnectionNotifier(ref.watch(scaleServiceProvider));
});

class ScaleConnectionNotifier extends StateNotifier<bool> {
  final ScaleService _scaleService;

  ScaleConnectionNotifier(this._scaleService) : super(false);

  Future<void> connect() async {
    final result = await _scaleService.connectToScale();
    state = result;
  }

  Future<void> disconnect() async {
    final result = await _scaleService.disconnectFromScale();
    state = !result;
  }

  Future<void> checkConnection() async {
    final result = await _scaleService.isConnected();
    state = result;
  }
}

// Provider لقراءة الوزن الحالي
final currentWeightProvider = StateNotifierProvider<CurrentWeightNotifier, double?>((ref) {
  return CurrentWeightNotifier(ref.watch(scaleServiceProvider));
});

class CurrentWeightNotifier extends StateNotifier<double?> {
  final ScaleService _scaleService;

  CurrentWeightNotifier(this._scaleService) : super(null);

  Future<void> readWeight() async {
    final weight = await _scaleService.readWeight();
    state = weight;
  }

  Future<void> simulateReading() async {
    final weight = await _scaleService.simulateWeightReading();
    state = weight;
  }

  void clearWeight() {
    state = null;
  }

  Future<void> tareScale() async {
    await _scaleService.tareScale();
    state = 0.0;
  }
}

