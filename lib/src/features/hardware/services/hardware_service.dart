import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

// خدمة التكامل مع الموازين الرقمية
class DigitalScaleService {
  static const MethodChannel _channel = MethodChannel('gold_workshop/scale');
  
  // الاتصال بالميزان
  static Future<bool> connectToScale(String portName) async {
    try {
      final bool result = await _channel.invokeMethod('connectScale', {
        'portName': portName,
        'baudRate': 9600,
        'dataBits': 8,
        'stopBits': 1,
        'parity': 'none',
      });
      return result;
    } catch (e) {
      throw Exception('فشل في الاتصال بالميزان: $e');
    }
  }
  
  // قراءة الوزن
  static Future<double> readWeight() async {
    try {
      final double weight = await _channel.invokeMethod('readWeight');
      return weight;
    } catch (e) {
      throw Exception('فشل في قراءة الوزن: $e');
    }
  }
  
  // معايرة الميزان
  static Future<bool> calibrateScale(double calibrationWeight) async {
    try {
      final bool result = await _channel.invokeMethod('calibrateScale', {
        'weight': calibrationWeight,
      });
      return result;
    } catch (e) {
      throw Exception('فشل في معايرة الميزان: $e');
    }
  }
  
  // إعادة تعيين الميزان
  static Future<bool> resetScale() async {
    try {
      final bool result = await _channel.invokeMethod('resetScale');
      return result;
    } catch (e) {
      throw Exception('فشل في إعادة تعيين الميزان: $e');
    }
  }
  
  // قطع الاتصال
  static Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnectScale');
    } catch (e) {
      throw Exception('فشل في قطع الاتصال: $e');
    }
  }
  
  // التحقق من حالة الاتصال
  static Future<bool> isConnected() async {
    try {
      final bool result = await _channel.invokeMethod('isScaleConnected');
      return result;
    } catch (e) {
      return false;
    }
  }
  
  // الحصول على قائمة المنافذ المتاحة
  static Future<List<String>> getAvailablePorts() async {
    try {
      final List<dynamic> ports = await _channel.invokeMethod('getAvailablePorts');
      return ports.cast<String>();
    } catch (e) {
      return [];
    }
  }
}

// خدمة الطابعات
class PrinterService {
  static const MethodChannel _channel = MethodChannel('gold_workshop/printer');
  
  // طباعة فاتورة
  static Future<bool> printInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final bool result = await _channel.invokeMethod('printInvoice', invoiceData);
      return result;
    } catch (e) {
      throw Exception('فشل في طباعة الفاتورة: $e');
    }
  }
  
  // طباعة باركود
  static Future<bool> printBarcode(String code, String text) async {
    try {
      final bool result = await _channel.invokeMethod('printBarcode', {
        'code': code,
        'text': text,
        'width': 200,
        'height': 50,
      });
      return result;
    } catch (e) {
      throw Exception('فشل في طباعة الباركود: $e');
    }
  }
  
  // طباعة QR كود
  static Future<bool> printQRCode(String data, String text) async {
    try {
      final bool result = await _channel.invokeMethod('printQRCode', {
        'data': data,
        'text': text,
        'size': 100,
      });
      return result;
    } catch (e) {
      throw Exception('فشل في طباعة QR كود: $e');
    }
  }
  
  // طباعة تقرير
  static Future<bool> printReport(Map<String, dynamic> reportData) async {
    try {
      final bool result = await _channel.invokeMethod('printReport', reportData);
      return result;
    } catch (e) {
      throw Exception('فشل في طباعة التقرير: $e');
    }
  }
  
  // الحصول على قائمة الطابعات
  static Future<List<Map<String, String>>> getAvailablePrinters() async {
    try {
      final List<dynamic> printers = await _channel.invokeMethod('getAvailablePrinters');
      return printers.cast<Map<String, String>>();
    } catch (e) {
      return [];
    }
  }
  
  // تعيين الطابعة الافتراضية
  static Future<bool> setDefaultPrinter(String printerName) async {
    try {
      final bool result = await _channel.invokeMethod('setDefaultPrinter', {
        'printerName': printerName,
      });
      return result;
    } catch (e) {
      throw Exception('فشل في تعيين الطابعة الافتراضية: $e');
    }
  }
}

// خدمة ماسح الباركود
class BarcodeService {
  static const MethodChannel _channel = MethodChannel('gold_workshop/barcode');
  
  // مسح باركود
  static Future<String?> scanBarcode() async {
    try {
      final String? result = await _channel.invokeMethod('scanBarcode');
      return result;
    } catch (e) {
      throw Exception('فشل في مسح الباركود: $e');
    }
  }
  
  // مسح QR كود
  static Future<String?> scanQRCode() async {
    try {
      final String? result = await _channel.invokeMethod('scanQRCode');
      return result;
    } catch (e) {
      throw Exception('فشل في مسح QR كود: $e');
    }
  }
  
  // توليد باركود
  static Future<String> generateBarcode(String data) async {
    try {
      final String result = await _channel.invokeMethod('generateBarcode', {
        'data': data,
        'format': 'CODE128',
      });
      return result;
    } catch (e) {
      throw Exception('فشل في توليد الباركود: $e');
    }
  }
  
  // توليد QR كود
  static Future<String> generateQRCode(String data) async {
    try {
      final String result = await _channel.invokeMethod('generateQRCode', {
        'data': data,
        'size': 200,
      });
      return result;
    } catch (e) {
      throw Exception('فشل في توليد QR كود: $e');
    }
  }
}

// خدمة الكاميرا للتصوير
class CameraService {
  static const MethodChannel _channel = MethodChannel('gold_workshop/camera');
  
  // التقاط صورة
  static Future<String?> captureImage() async {
    try {
      final String? imagePath = await _channel.invokeMethod('captureImage');
      return imagePath;
    } catch (e) {
      throw Exception('فشل في التقاط الصورة: $e');
    }
  }
  
  // التقاط صورة متعددة
  static Future<List<String>> captureMultipleImages(int count) async {
    try {
      final List<dynamic> imagePaths = await _channel.invokeMethod('captureMultipleImages', {
        'count': count,
      });
      return imagePaths.cast<String>();
    } catch (e) {
      throw Exception('فشل في التقاط الصور: $e');
    }
  }
  
  // تسجيل فيديو
  static Future<String?> recordVideo(int durationSeconds) async {
    try {
      final String? videoPath = await _channel.invokeMethod('recordVideo', {
        'duration': durationSeconds,
      });
      return videoPath;
    } catch (e) {
      throw Exception('فشل في تسجيل الفيديو: $e');
    }
  }
}

// خدمة الأجهزة المتصلة عبر USB
class USBDeviceService {
  static const MethodChannel _channel = MethodChannel('gold_workshop/usb');
  
  // الحصول على قائمة الأجهزة المتصلة
  static Future<List<Map<String, String>>> getConnectedDevices() async {
    try {
      final List<dynamic> devices = await _channel.invokeMethod('getConnectedDevices');
      return devices.cast<Map<String, String>>();
    } catch (e) {
      return [];
    }
  }
  
  // إرسال بيانات لجهاز USB
  static Future<bool> sendDataToDevice(String deviceId, String data) async {
    try {
      final bool result = await _channel.invokeMethod('sendDataToDevice', {
        'deviceId': deviceId,
        'data': data,
      });
      return result;
    } catch (e) {
      throw Exception('فشل في إرسال البيانات: $e');
    }
  }
  
  // قراءة بيانات من جهاز USB
  static Future<String?> readDataFromDevice(String deviceId) async {
    try {
      final String? data = await _channel.invokeMethod('readDataFromDevice', {
        'deviceId': deviceId,
      });
      return data;
    } catch (e) {
      throw Exception('فشل في قراءة البيانات: $e');
    }
  }
}

// خدمة إدارة الأجهزة
class HardwareManager {
  static final Map<String, StreamController<double>> _weightStreams = {};
  static Timer? _weightTimer;
  
  // بدء مراقبة الوزن
  static Stream<double> startWeightMonitoring() {
    const String streamKey = 'weight_monitoring';
    
    if (_weightStreams.containsKey(streamKey)) {
      return _weightStreams[streamKey]!.stream;
    }
    
    final controller = StreamController<double>.broadcast();
    _weightStreams[streamKey] = controller;
    
    _weightTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      try {
        if (await DigitalScaleService.isConnected()) {
          final weight = await DigitalScaleService.readWeight();
          controller.add(weight);
        }
      } catch (e) {
        // تجاهل الأخطاء في القراءة المستمرة
      }
    });
    
    return controller.stream;
  }
  
  // إيقاف مراقبة الوزن
  static void stopWeightMonitoring() {
    _weightTimer?.cancel();
    _weightTimer = null;
    
    for (final controller in _weightStreams.values) {
      controller.close();
    }
    _weightStreams.clear();
  }
  
  // اختبار جميع الأجهزة
  static Future<Map<String, bool>> testAllDevices() async {
    final results = <String, bool>{};
    
    // اختبار الميزان
    try {
      results['scale'] = await DigitalScaleService.isConnected();
    } catch (e) {
      results['scale'] = false;
    }
    
    // اختبار الطابعات
    try {
      final printers = await PrinterService.getAvailablePrinters();
      results['printer'] = printers.isNotEmpty;
    } catch (e) {
      results['printer'] = false;
    }
    
    // اختبار أجهزة USB
    try {
      final devices = await USBDeviceService.getConnectedDevices();
      results['usb_devices'] = devices.isNotEmpty;
    } catch (e) {
      results['usb_devices'] = false;
    }
    
    return results;
  }
  
  // إعدادات الأجهزة
  static Future<void> saveDeviceSettings(Map<String, dynamic> settings) async {
    // حفظ إعدادات الأجهزة في قاعدة البيانات المحلية
    // يمكن تنفيذ هذا باستخدام SharedPreferences أو قاعدة البيانات
  }
  
  static Future<Map<String, dynamic>> loadDeviceSettings() async {
    // تحميل إعدادات الأجهزة من قاعدة البيانات المحلية
    return {};
  }
}

// نماذج البيانات للأجهزة
class ScaleReading {
  final double weight;
  final DateTime timestamp;
  final String unit;
  final bool isStable;

  ScaleReading({
    required this.weight,
    required this.timestamp,
    this.unit = 'g',
    this.isStable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
      'unit': unit,
      'isStable': isStable,
    };
  }

  factory ScaleReading.fromJson(Map<String, dynamic> json) {
    return ScaleReading(
      weight: json['weight'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      unit: json['unit'] ?? 'g',
      isStable: json['isStable'] ?? true,
    );
  }
}

class PrintJob {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final String status;
  final String? printerName;

  PrintJob({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.status = 'pending',
    this.printerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'printerName': printerName,
    };
  }

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    return PrintJob(
      id: json['id'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'pending',
      printerName: json['printerName'],
    );
  }
}

class DeviceConfiguration {
  final String deviceType;
  final String deviceName;
  final Map<String, dynamic> settings;
  final bool isEnabled;
  final DateTime lastUpdated;

  DeviceConfiguration({
    required this.deviceType,
    required this.deviceName,
    required this.settings,
    this.isEnabled = true,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceType': deviceType,
      'deviceName': deviceName,
      'settings': settings,
      'isEnabled': isEnabled,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory DeviceConfiguration.fromJson(Map<String, dynamic> json) {
    return DeviceConfiguration(
      deviceType: json['deviceType'],
      deviceName: json['deviceName'],
      settings: Map<String, dynamic>.from(json['settings']),
      isEnabled: json['isEnabled'] ?? true,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

