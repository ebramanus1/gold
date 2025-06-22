import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/network_config_service.dart';
import '../network/network_discovery_service.dart';
import '../database/database_service.dart';

/// خدمة مزامنة البيانات مع الخادم المركزي
class DataSyncService {
  static DataSyncService? _instance;
  static DataSyncService get instance => _instance ??= DataSyncService._();
  DataSyncService._();

  Timer? _syncTimer;
  bool _isSyncing = false;
  final Duration _syncInterval = const Duration(minutes: 5);

  /// بدء المزامنة التلقائية
  void startAutoSync() {
    stopAutoSync(); // إيقاف أي مزامنة سابقة
    
    _syncTimer = Timer.periodic(_syncInterval, (timer) async {
      await performSync();
    });
  }

  /// إيقاف المزامنة التلقائية
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// تنفيذ عملية المزامنة
  Future<SyncResult> performSync() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'عملية مزامنة أخرى قيد التنفيذ',
        syncedRecords: 0,
        failedRecords: 0,
      );
    }

    _isSyncing = true;
    
    try {
      // فحص الاتصال بالشبكة
      final networkService = NetworkDiscoveryService.instance;
      final networkStatus = await networkService.getNetworkStatus();
      
      if (networkStatus != NetworkStatus.connectedToServer) {
        return SyncResult(
          success: false,
          message: 'لا يوجد اتصال بالخادم المركزي',
          syncedRecords: 0,
          failedRecords: 0,
        );
      }

      final database = DatabaseService.instance;
      final unsyncedRecords = await database.getUnsyncedRecords();
      
      if (unsyncedRecords.isEmpty) {
        return SyncResult(
          success: true,
          message: 'جميع البيانات محدثة',
          syncedRecords: 0,
          failedRecords: 0,
        );
      }

      int syncedCount = 0;
      int failedCount = 0;

      // مزامنة كل سجل
      for (final record in unsyncedRecords) {
        try {
          final success = await _syncRecord(record);
          if (success) {
            await database.markAsSynced(record.id);
            syncedCount++;
          } else {
            await database.incrementRetryCount(record.id);
            failedCount++;
          }
        } catch (e) {
          await database.incrementRetryCount(record.id);
          failedCount++;
          print('خطأ في مزامنة السجل ${record.id}: $e');
        }
      }

      return SyncResult(
        success: failedCount == 0,
        message: failedCount == 0 
            ? 'تمت المزامنة بنجاح'
            : 'تمت المزامنة مع بعض الأخطاء',
        syncedRecords: syncedCount,
        failedRecords: failedCount,
      );

    } catch (e) {
      return SyncResult(
        success: false,
        message: 'خطأ في عملية المزامنة: $e',
        syncedRecords: 0,
        failedRecords: 0,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// مزامنة سجل واحد مع الخادم
  Future<bool> _syncRecord(SyncLogData record) async {
    try {
      final config = NetworkConfigService.instance;
      final baseUrl = await config.getApiBaseUrl();
      
      final endpoint = _getEndpointForTable(record.tableName);
      final url = '$baseUrl/$endpoint';
      
      http.Response response;
      
      switch (record.operation) {
        case 'INSERT':
          response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: record.data,
          );
          break;
          
        case 'UPDATE':
          response = await http.put(
            Uri.parse('$url/${record.recordId}'),
            headers: {'Content-Type': 'application/json'},
            body: record.data,
          );
          break;
          
        case 'DELETE':
          response = await http.delete(
            Uri.parse('$url/${record.recordId}'),
            headers: {'Content-Type': 'application/json'},
          );
          break;
          
        default:
          return false;
      }
      
      return response.statusCode >= 200 && response.statusCode < 300;
      
    } catch (e) {
      print('خطأ في مزامنة السجل ${record.id}: $e');
      return false;
    }
  }

  /// الحصول على نقطة النهاية المناسبة لكل جدول
  String _getEndpointForTable(String tableName) {
    switch (tableName) {
      case 'users':
        return 'users';
      case 'gold_items':
        return 'gold-items';
      case 'transactions':
        return 'transactions';
      case 'customers':
        return 'customers';
      case 'transaction_items':
        return 'transaction-items';
      case 'payment_records':
        return 'payment-records';
      default:
        return tableName.replaceAll('_', '-');
    }
  }

  /// مزامنة البيانات من الخادم إلى العميل
  Future<bool> syncFromServer() async {
    try {
      final config = NetworkConfigService.instance;
      final baseUrl = await config.getApiBaseUrl();
      
      // الحصول على آخر تحديث محلي
      final lastSync = await _getLastSyncTimestamp();
      
      // طلب البيانات المحدثة من الخادم
      final response = await http.get(
        Uri.parse('$baseUrl/sync/changes?since=$lastSync'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _applyServerChanges(data);
        await _updateLastSyncTimestamp();
        return true;
      }
      
      return false;
    } catch (e) {
      print('خطأ في مزامنة البيانات من الخادم: $e');
      return false;
    }
  }

  /// تطبيق التغييرات الواردة من الخادم
  Future<void> _applyServerChanges(Map<String, dynamic> changes) async {
    final database = DatabaseService.instance;
    
    // تطبيق التغييرات على كل جدول
    for (final tableName in changes.keys) {
      final tableChanges = changes[tableName] as List<dynamic>;
      
      for (final change in tableChanges) {
        try {
          await _applyTableChange(tableName, change);
        } catch (e) {
          print('خطأ في تطبيق التغيير على $tableName: $e');
        }
      }
    }
  }

  /// تطبيق تغيير على جدول محدد
  Future<void> _applyTableChange(String tableName, Map<String, dynamic> change) async {
    final database = DatabaseService.instance;
    final operation = change['operation'];
    final data = change['data'];
    
    switch (tableName) {
      case 'users':
        await _applyUserChange(operation, data);
        break;
      case 'gold_items':
        await _applyGoldItemChange(operation, data);
        break;
      case 'transactions':
        await _applyTransactionChange(operation, data);
        break;
      case 'customers':
        await _applyCustomerChange(operation, data);
        break;
    }
  }

  /// تطبيق تغييرات المستخدمين
  Future<void> _applyUserChange(String operation, Map<String, dynamic> data) async {
    final database = DatabaseService.instance;
    
    switch (operation) {
      case 'INSERT':
      case 'UPDATE':
        await database.into(database.users).insertOnConflictUpdate(
          UsersCompanion.fromJson(data)
        );
        break;
      case 'DELETE':
        await database.delete(database.users)
          .where((u) => u.id.equals(data['id']))
          .go();
        break;
    }
  }

  /// تطبيق تغييرات عناصر الذهب
  Future<void> _applyGoldItemChange(String operation, Map<String, dynamic> data) async {
    final database = DatabaseService.instance;
    
    switch (operation) {
      case 'INSERT':
      case 'UPDATE':
        await database.into(database.goldItems).insertOnConflictUpdate(
          GoldItemsCompanion.fromJson(data)
        );
        break;
      case 'DELETE':
        await database.delete(database.goldItems)
          .where((g) => g.id.equals(data['id']))
          .go();
        break;
    }
  }

  /// تطبيق تغييرات المعاملات
  Future<void> _applyTransactionChange(String operation, Map<String, dynamic> data) async {
    final database = DatabaseService.instance;
    
    switch (operation) {
      case 'INSERT':
      case 'UPDATE':
        await database.into(database.transactions).insertOnConflictUpdate(
          TransactionsCompanion.fromJson(data)
        );
        break;
      case 'DELETE':
        await database.delete(database.transactions)
          .where((t) => t.id.equals(data['id']))
          .go();
        break;
    }
  }

  /// تطبيق تغييرات العملاء
  Future<void> _applyCustomerChange(String operation, Map<String, dynamic> data) async {
    final database = DatabaseService.instance;
    
    switch (operation) {
      case 'INSERT':
      case 'UPDATE':
        await database.into(database.customers).insertOnConflictUpdate(
          CustomersCompanion.fromJson(data)
        );
        break;
      case 'DELETE':
        await database.delete(database.customers)
          .where((c) => c.id.equals(data['id']))
          .go();
        break;
    }
  }

  /// الحصول على طابع زمني لآخر مزامنة
  Future<String> _getLastSyncTimestamp() async {
    final config = NetworkConfigService.instance;
    await config.initialize();
    // يمكن حفظ هذا في SharedPreferences
    return DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
  }

  /// تحديث طابع زمني لآخر مزامنة
  Future<void> _updateLastSyncTimestamp() async {
    final config = NetworkConfigService.instance;
    await config.initialize();
    // يمكن حفظ هذا في SharedPreferences
  }

  /// فحص حالة المزامنة
  bool get isSyncing => _isSyncing;

  /// تنظيف الموارد
  void dispose() {
    stopAutoSync();
  }
}

/// نتيجة عملية المزامنة
class SyncResult {
  final bool success;
  final String message;
  final int syncedRecords;
  final int failedRecords;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedRecords,
    required this.failedRecords,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, synced: $syncedRecords, failed: $failedRecords)';
  }
}

