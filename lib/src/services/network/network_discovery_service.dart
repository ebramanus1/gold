import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/network_constants.dart';
import 'network_config_service.dart';

/// خدمة اكتشاف الخوادم في الشبكة المحلية
class NetworkDiscoveryService {
  static NetworkDiscoveryService? _instance;
  static NetworkDiscoveryService get instance => _instance ??= NetworkDiscoveryService._();
  NetworkDiscoveryService._();

  final Connectivity _connectivity = Connectivity();
  bool _isScanning = false;

  /// فحص الاتصال بالشبكة المحلية
  Future<bool> isConnectedToLocalNetwork() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult == ConnectivityResult.wifi || 
             connectivityResult == ConnectivityResult.ethernet;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على عنوان IP المحلي للجهاز
  Future<String?> getLocalIPAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            // التحقق من أن العنوان في نطاق الشبكة المحلية
            if (addr.address.startsWith('192.168.') || 
                addr.address.startsWith('10.') || 
                addr.address.startsWith('172.')) {
              return addr.address;
            }
          }
        }
      }
    } catch (e) {
      print('خطأ في الحصول على عنوان IP المحلي: $e');
    }
    return null;
  }

  /// اكتشاف الخوادم المتاحة في الشبكة المحلية
  Future<List<String>> discoverServers({
    Duration timeout = const Duration(seconds: 2),
    Function(String)? onServerFound,
  }) async {
    if (_isScanning) return [];
    
    _isScanning = true;
    final List<String> availableServers = [];
    
    try {
      final localIP = await getLocalIPAddress();
      if (localIP == null) {
        _isScanning = false;
        return [];
      }

      // استخراج نطاق الشبكة (مثل 192.168.1.x)
      final networkBase = localIP.substring(0, localIP.lastIndexOf('.'));
      
      // قائمة المهام للفحص المتوازي
      final List<Future<void>> scanTasks = [];
      
      // فحص العناوين الشائعة أولاً
      for (final ip in NetworkConstants.commonLocalIPs) {
        if (ip.startsWith(networkBase)) {
          scanTasks.add(_checkServer(ip, timeout, availableServers, onServerFound));
        }
      }
      
      // فحص نطاق الشبكة (1-254)
      for (int i = 1; i <= 254; i++) {
        final testIP = '$networkBase.$i';
        if (!NetworkConstants.commonLocalIPs.contains(testIP)) {
          scanTasks.add(_checkServer(testIP, timeout, availableServers, onServerFound));
        }
      }
      
      // انتظار انتهاء جميع المهام
      await Future.wait(scanTasks);
      
    } catch (e) {
      print('خطأ في اكتشاف الخوادم: $e');
    } finally {
      _isScanning = false;
    }
    
    return availableServers;
  }

  /// فحص خادم محدد
  Future<void> _checkServer(
    String ip, 
    Duration timeout, 
    List<String> availableServers,
    Function(String)? onServerFound,
  ) async {
    try {
      // فحص منفذ قاعدة البيانات
      final socket = await Socket.connect(
        ip, 
        NetworkConstants.databasePort,
        timeout: timeout,
      );
      
      await socket.close();
      
      if (!availableServers.contains(ip)) {
        availableServers.add(ip);
        onServerFound?.call(ip);
      }
    } catch (e) {
      // الخادم غير متاح على هذا العنوان
    }
  }

  /// فحص اتصال محدد
  Future<bool> testConnection(String host, int port, {Duration? timeout}) async {
    try {
      final socket = await Socket.connect(
        host, 
        port,
        timeout: timeout ?? const Duration(seconds: 5),
      );
      
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// فحص اتصال قاعدة البيانات
  Future<bool> testDatabaseConnection({
    String? host,
    int? port,
    Duration? timeout,
  }) async {
    final config = NetworkConfigService.instance;
    final testHost = host ?? await config.getServerHost();
    final testPort = port ?? await config.getServerPort();
    
    return await testConnection(testHost, testPort, timeout: timeout);
  }

  /// البحث عن أفضل خادم متاح
  Future<String?> findBestServer() async {
    final servers = await discoverServers();
    
    if (servers.isEmpty) return null;
    
    // اختبار كل خادم وإرجاع الأول الذي يستجيب
    for (final server in servers) {
      if (await testDatabaseConnection(host: server)) {
        return server;
      }
    }
    
    return null;
  }

  /// مراقبة حالة الشبكة
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged.asyncExpand((list) => Stream.fromIterable(list));

  /// التحقق من حالة الاتصال الحالية
  Future<NetworkStatus> getNetworkStatus() async {
    final isConnected = await isConnectedToLocalNetwork();
    
    if (!isConnected) {
      return NetworkStatus.disconnected;
    }
    
    final config = NetworkConfigService.instance;
    final host = await config.getServerHost();
    final port = await config.getServerPort();
    
    final canReachServer = await testConnection(host, port);
    
    if (canReachServer) {
      return NetworkStatus.connectedToServer;
    } else {
      return NetworkStatus.connectedNoServer;
    }
  }

  /// إيقاف عملية المسح
  void stopScanning() {
    _isScanning = false;
  }
}

/// حالات الشبكة
enum NetworkStatus {
  disconnected,        // غير متصل بالشبكة
  connectedNoServer,   // متصل بالشبكة لكن لا يمكن الوصول للخادم
  connectedToServer,   // متصل بالشبكة ويمكن الوصول للخادم
}

