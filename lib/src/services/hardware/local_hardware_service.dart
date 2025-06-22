import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// خدمة التكامل مع الأجهزة الطرفية المحلية
class LocalHardwareService {
  static LocalHardwareService? _instance;
  static LocalHardwareService get instance => _instance ??= LocalHardwareService._();
  LocalHardwareService._();

  // قنوات الاتصال مع الأجهزة
  static const MethodChannel _scaleChannel = MethodChannel('gold_workshop/scale');
  static const MethodChannel _barcodeChannel = MethodChannel('gold_workshop/barcode');
  static const MethodChannel _printerChannel = MethodChannel('gold_workshop/printer');
  static const MethodChannel _serialChannel = MethodChannel('gold_workshop/serial');

  // حالة الاتصال بالأجهزة
  bool _isScaleConnected = false;
  bool _isBarcodeConnected = false;
  bool _isPrinterConnected = false;

  // معلومات الأجهزة المتصلة
  Map<String, dynamic> _connectedDevices = {};

  /// تهيئة خدمة الأجهزة
  Future<void> initialize() async {
    try {
      await _initializeSerialPorts();
      await _detectConnectedDevices();
    } catch (e) {
      print('خطأ في تهيئة خدمة الأجهزة: $e');
    }
  }

  /// تهيئة المنافذ التسلسلية
  Future<void> _initializeSerialPorts() async {
    try {
      await _serialChannel.invokeMethod('initialize');
    } catch (e) {
      print('خطأ في تهيئة المنافذ التسلسلية: $e');
    }
  }

  /// اكتشاف الأجهزة المتصلة
  Future<void> _detectConnectedDevices() async {
    await _detectScale();
    await _detectBarcodeScanner();
    await _detectPrinter();
  }

  /// اكتشاف الميزان الرقمي
  Future<void> _detectScale() async {
    try {
      final result = await _scaleChannel.invokeMethod('detect');
      _isScaleConnected = result['connected'] ?? false;
      
      if (_isScaleConnected) {
        _connectedDevices['scale'] = result;
        print('تم اكتشاف الميزان: ${result['name']}');
      }
    } catch (e) {
      _isScaleConnected = false;
      print('خطأ في اكتشاف الميزان: $e');
    }
  }

  /// اكتشاف ماسح الباركود
  Future<void> _detectBarcodeScanner() async {
    try {
      final result = await _barcodeChannel.invokeMethod('detect');
      _isBarcodeConnected = result['connected'] ?? false;
      
      if (_isBarcodeConnected) {
        _connectedDevices['barcode'] = result;
        print('تم اكتشاف ماسح الباركود: ${result['name']}');
      }
    } catch (e) {
      _isBarcodeConnected = false;
      print('خطأ في اكتشاف ماسح الباركود: $e');
    }
  }

  /// اكتشاف الطابعة
  Future<void> _detectPrinter() async {
    try {
      final result = await _printerChannel.invokeMethod('detect');
      _isPrinterConnected = result['connected'] ?? false;
      
      if (_isPrinterConnected) {
        _connectedDevices['printer'] = result;
        print('تم اكتشاف الطابعة: ${result['name']}');
      }
    } catch (e) {
      _isPrinterConnected = false;
      print('خطأ في اكتشاف الطابعة: $e');
    }
  }

  /// قراءة الوزن من الميزان الرقمي
  Future<ScaleReading?> readWeight() async {
    if (!_isScaleConnected) {
      throw Exception('الميزان غير متصل');
    }

    try {
      final result = await _scaleChannel.invokeMethod('readWeight');
      
      if (result['success']) {
        return ScaleReading(
          weight: result['weight'].toDouble(),
          unit: result['unit'] ?? 'g',
          stable: result['stable'] ?? false,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception(result['error'] ?? 'خطأ في قراءة الوزن');
      }
    } catch (e) {
      throw Exception('خطأ في قراءة الوزن: $e');
    }
  }

  /// معايرة الميزان
  Future<bool> calibrateScale({double? referenceWeight}) async {
    if (!_isScaleConnected) {
      throw Exception('الميزان غير متصل');
    }

    try {
      final result = await _scaleChannel.invokeMethod('calibrate', {
        'referenceWeight': referenceWeight,
      });
      
      return result['success'] ?? false;
    } catch (e) {
      print('خطأ في معايرة الميزان: $e');
      return false;
    }
  }

  /// إعادة تعيين الميزان (تصفير)
  Future<bool> tareScale() async {
    if (!_isScaleConnected) {
      throw Exception('الميزان غير متصل');
    }

    try {
      final result = await _scaleChannel.invokeMethod('tare');
      return result['success'] ?? false;
    } catch (e) {
      print('خطأ في تصفير الميزان: $e');
      return false;
    }
  }

  /// مسح الباركود
  Future<BarcodeResult?> scanBarcode() async {
    if (!_isBarcodeConnected) {
      throw Exception('ماسح الباركود غير متصل');
    }

    try {
      final result = await _barcodeChannel.invokeMethod('scan');
      
      if (result['success']) {
        return BarcodeResult(
          data: result['data'],
          format: result['format'] ?? 'UNKNOWN',
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception(result['error'] ?? 'خطأ في مسح الباركود');
      }
    } catch (e) {
      throw Exception('خطأ في مسح الباركود: $e');
    }
  }

  /// طباعة إيصال
  Future<bool> printReceipt(ReceiptData receipt) async {
    if (!_isPrinterConnected) {
      throw Exception('الطابعة غير متصلة');
    }

    try {
      final result = await _printerChannel.invokeMethod('printReceipt', {
        'header': receipt.header,
        'items': receipt.items.map((item) => item.toMap()).toList(),
        'footer': receipt.footer,
        'total': receipt.total,
        'copies': receipt.copies,
      });
      
      return result['success'] ?? false;
    } catch (e) {
      print('خطأ في الطباعة: $e');
      return false;
    }
  }

  /// طباعة ملصق
  Future<bool> printLabel(LabelData label) async {
    if (!_isPrinterConnected) {
      throw Exception('الطابعة غير متصلة');
    }

    try {
      final result = await _printerChannel.invokeMethod('printLabel', {
        'text': label.text,
        'barcode': label.barcode,
        'qrCode': label.qrCode,
        'size': label.size,
        'copies': label.copies,
      });
      
      return result['success'] ?? false;
    } catch (e) {
      print('خطأ في طباعة الملصق: $e');
      return false;
    }
  }

  /// الحصول على قائمة المنافذ التسلسلية المتاحة
  Future<List<String>> getAvailableSerialPorts() async {
    try {
      final result = await _serialChannel.invokeMethod('getAvailablePorts');
      return List<String>.from(result['ports'] ?? []);
    } catch (e) {
      print('خطأ في الحصول على المنافذ التسلسلية: $e');
      return [];
    }
  }

  /// فتح اتصال تسلسلي
  Future<bool> openSerialConnection({
    required String port,
    int baudRate = 9600,
    int dataBits = 8,
    int stopBits = 1,
    String parity = 'none',
  }) async {
    try {
      final result = await _serialChannel.invokeMethod('openConnection', {
        'port': port,
        'baudRate': baudRate,
        'dataBits': dataBits,
        'stopBits': stopBits,
        'parity': parity,
      });
      
      return result['success'] ?? false;
    } catch (e) {
      print('خطأ في فتح الاتصال التسلسلي: $e');
      return false;
    }
  }

  /// إغلاق اتصال تسلسلي
  Future<bool> closeSerialConnection(String port) async {
    try {
      final result = await _serialChannel.invokeMethod('closeConnection', {
        'port': port,
      });
      
      return result['success'] ?? false;
    } catch (e) {
      print('خطأ في إغلاق الاتصال التسلسلي: $e');
      return false;
    }
  }

  /// إرسال بيانات عبر المنفذ التسلسلي
  Future<bool> sendSerialData(String port, Uint8List data) async {
    try {
      final result = await _serialChannel.invokeMethod('sendData', {
        'port': port,
        'data': data,
      });
      
      return result['success'] ?? false;
    } catch (e) {
      print('خطأ في إرسال البيانات: $e');
      return false;
    }
  }

  /// قراءة بيانات من المنفذ التسلسلي
  Future<Uint8List?> readSerialData(String port) async {
    try {
      final result = await _serialChannel.invokeMethod('readData', {
        'port': port,
      });
      
      if (result['success']) {
        return Uint8List.fromList(List<int>.from(result['data']));
      }
      
      return null;
    } catch (e) {
      print('خطأ في قراءة البيانات: $e');
      return null;
    }
  }

  /// فحص حالة الاتصال بالأجهزة
  Future<Map<String, bool>> getDeviceStatus() async {
    await _detectConnectedDevices();
    
    return {
      'scale': _isScaleConnected,
      'barcode': _isBarcodeConnected,
      'printer': _isPrinterConnected,
    };
  }

  /// الحصول على معلومات الأجهزة المتصلة
  Map<String, dynamic> getConnectedDevices() {
    return Map.from(_connectedDevices);
  }

  // Getters للحالة
  bool get isScaleConnected => _isScaleConnected;
  bool get isBarcodeConnected => _isBarcodeConnected;
  bool get isPrinterConnected => _isPrinterConnected;

  /// تنظيف الموارد
  void dispose() {
    // إغلاق جميع الاتصالات
  }
}

/// نتيجة قراءة الميزان
class ScaleReading {
  final double weight;
  final String unit;
  final bool stable;
  final DateTime timestamp;

  ScaleReading({
    required this.weight,
    required this.unit,
    required this.stable,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ScaleReading(weight: $weight $unit, stable: $stable, time: $timestamp)';
  }
}

/// نتيجة مسح الباركود
class BarcodeResult {
  final String data;
  final String format;
  final DateTime timestamp;

  BarcodeResult({
    required this.data,
    required this.format,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'BarcodeResult(data: $data, format: $format, time: $timestamp)';
  }
}

/// بيانات الإيصال للطباعة
class ReceiptData {
  final String header;
  final List<ReceiptItem> items;
  final String footer;
  final double total;
  final int copies;

  ReceiptData({
    required this.header,
    required this.items,
    required this.footer,
    required this.total,
    this.copies = 1,
  });
}

/// عنصر في الإيصال
class ReceiptItem {
  final String name;
  final double quantity;
  final double price;
  final double total;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

/// بيانات الملصق للطباعة
class LabelData {
  final String text;
  final String? barcode;
  final String? qrCode;
  final String size;
  final int copies;

  LabelData({
    required this.text,
    this.barcode,
    this.qrCode,
    this.size = 'medium',
    this.copies = 1,
  });
}

