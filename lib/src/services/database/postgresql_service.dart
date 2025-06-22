import 'package:postgres/postgres.dart';
import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../core/models/client_model.dart';
import '../../core/models/raw_material_model.dart';
import '../../core/models/work_order_model.dart';
import '../../core/models/finished_goods_model.dart';
import '../../core/models/audit_log_model.dart';
import '../../core/models/transaction_model.dart';
import '../../core/models/invoice_model.dart';


/// خدمة قاعدة بيانات PostgreSQL
/// مسؤولة عن إدارة الاتصال وتنفيذ الاستعلامات
class PostgreSQLService {
  Connection? _connection;
  String? _host;
  int? _port;
  String? _database;
  String? _username;
  String? _password;
  bool _isConnected = false;

  // Singleton pattern
  static PostgreSQLService? _instance;
  PostgreSQLService._internal();

  factory PostgreSQLService() {
    _instance ??= PostgreSQLService._internal();
    return _instance!;
  }

  // إضافة خاصية instance للتوافق مع الكود الموجود
  static PostgreSQLService get instance => PostgreSQLService();

  /// تكوين إعدادات قاعدة البيانات
  void configure({
    String? host,
    int? port,
    String? database,
    String? username,
    String? password,
  }) {
    _host = host ?? 'localhost';
    _port = port ?? 5432;
    _database = database ?? 'gold_workshop';
    _username = username ?? 'postgres';
    _password = password ?? '';
  }

  /// إنشاء اتصال مع قاعدة البيانات
  Future<bool> connect() async {
    if (_isConnected && _connection != null) {
      return true;
    }

    try {
      // التأكد من وجود الإعدادات
      if (_host == null || _database == null || _username == null) {
        throw Exception('يجب تكوين إعدادات قاعدة البيانات أولاً');
      }

      _connection = await Connection.open(
        Endpoint(
          host: _host!,
          port: _port!,
          database: _database!,
          username: _username!,
          password: _password!,
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 10),
          queryTimeout: Duration(seconds: 30),
          applicationName: 'Gold Workshop AI',
        ),
      );

      _isConnected = true;
      print('✅ تم الاتصال بقاعدة البيانات بنجاح');
      print('📊 معلومات الاتصال: ${connectionInfo}');

      // اختبار الاتصال
      await testConnection();

      return true;
    } catch (e) {
      _isConnected = false;
      _connection = null;
      print('❌ خطأ في الاتصال بقاعدة البيانات: $e');
      return false;
    }
  }

  /// اختبار الاتصال بقاعدة البيانات
  Future<bool> testConnection() async {
    try {
      final result = await query('SELECT 1 as test');
      return result.isNotEmpty && result.first['test'] == 1;
    } catch (e) {
      print('❌ فشل في اختبار الاتصال: $e');
      return false;
    }
  }

  /// قطع الاتصال مع قاعدة البيانات
  Future<void> disconnect() async {
    try {
      if (_connection != null) {
        await _connection!.close();
        _connection = null;
        _isConnected = false;
        print('🔌 تم قطع الاتصال مع قاعدة البيانات');
      }
    } catch (e) {
      print('❌ خطأ في قطع الاتصال: $e');
    }
  }

  /// تنفيذ استعلام SELECT
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    await _ensureConnection();

    try {
      print('🔍 تنفيذ استعلام: $sql');
      if (parameters != null && parameters.isNotEmpty) {
        print('📋 المعاملات: $parameters');
      }

      final result = await _connection!.execute(
        sql,
        parameters: parameters?.values.toList(),
      );

      final List<Map<String, dynamic>> rows = [];

      for (final row in result) {
        final Map<String, dynamic> rowMap = {};
        for (int i = 0; i < result.schema.columns.length; i++) {
          final columnName = result.schema.columns[i].columnName;
          if (columnName != null) {
            rowMap[columnName] = row[i];
          }
        }
        rows.add(rowMap);
      }

      print('✅ تم تنفيذ الاستعلام بنجاح - عدد الصفوف: ${rows.length}');
      return rows;

    } catch (e) {
      print('❌ خطأ في تنفيذ الاستعلام: $e');
      print('📝 الاستعلام: $sql');
      rethrow;
    }
  }

  /// تنفيذ استعلام INSERT/UPDATE/DELETE
  Future<int> execute(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    await _ensureConnection();

    try {
      print('⚡ تنفيذ أمر: $sql');
      if (parameters != null && parameters.isNotEmpty) {
        print('📋 المعاملات: $parameters');
      }

      final result = await _connection!.execute(
        sql,
        parameters: parameters?.values.toList(),
      );

      final affectedRows = result.affectedRows;
      print('✅ تم تنفيذ الأمر بنجاح - الصفوف المتأثرة: $affectedRows');

      return affectedRows;

    } catch (e) {
      print('❌ خطأ في تنفيذ الأمر: $e');
      print('📝 الأمر: $sql');
      rethrow;
    }
  }

  /// تنفيذ استعلام INSERT وإرجاع المفتاح الأساسي
  Future<T?> insertAndReturnId<T>(
    String sql, {
    Map<String, dynamic>? parameters,
    String idColumn = 'id',
  }) async {
    await _ensureConnection();

    try {
      // إضافة RETURNING clause إذا لم تكن موجودة
      String finalSql = sql;
      if (!sql.toUpperCase().contains('RETURNING')) {
        finalSql = '$sql RETURNING $idColumn';
      }

      print('🆔 تنفيذ إدراج مع إرجاع المفتاح: $finalSql');
      if (parameters != null && parameters.isNotEmpty) {
        print('📋 المعاملات: $parameters');
      }

      final result = await _connection!.execute(
        finalSql,
        parameters: parameters?.values.toList(),
      );

      if (result.isNotEmpty) {
        final id = result.first[0] as T;
        print('✅ تم الإدراج بنجاح - المفتاح: $id');
        return id;
      }

      return null;

    } catch (e) {
      print('❌ خطأ في الإدراج: $e');
      print('📝 الاستعلام: $sql');
      rethrow;
    }
  }

  /// تنفيذ مجموعة استعلامات في معاملة واحدة
  Future<T> transaction<T>(Future<T> Function() queries) async {
    await _ensureConnection();

    try {
      print('🔄 بدء معاملة قاعدة البيانات');

      final result = await _connection!.runTx((session) async {
        // تنفيذ الاستعلامات داخل المعاملة
        return await queries();
      });

      print('✅ تم تنفيذ المعاملة بنجاح');
      return result;

    } catch (e) {
      print('❌ خطأ في تنفيذ المعاملة: $e');
      rethrow;
    }
  }

  /// تنفيذ استعلام مع إرجاع صف واحد فقط
  Future<Map<String, dynamic>?> queryOne(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    final results = await query(sql, parameters: parameters);
    return results.isNotEmpty ? results.first : null;
  }

  /// تنفيذ استعلام عد الصفوف
  Future<int> count(String table, {String? whereClause, Map<String, dynamic>? parameters}) async {
    String sql = 'SELECT COUNT(*) as count FROM $table';
    if (whereClause != null) {
      sql += ' WHERE $whereClause';
    }

    final result = await queryOne(sql, parameters: parameters);
    return result?['count'] ?? 0;
  }

  /// التحقق من وجود سجل
  Future<bool> exists(String table, String whereClause, Map<String, dynamic> parameters) async {
    final count = await this.count(table, whereClause: whereClause, parameters: parameters);
    return count > 0;
  }

  /// إنشاء جداول قاعدة البيانات الأساسية
  Future<void> initializeDatabase() async {
    await _ensureConnection();

    try {
      print('🏗️ إنشاء جداول قاعدة البيانات...');

      // جدول المستخدمين
      await execute('''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          username VARCHAR(50) UNIQUE NOT NULL,
          email VARCHAR(100) UNIQUE NOT NULL,
          password_hash VARCHAR(255) NOT NULL,
          full_name VARCHAR(100) NOT NULL,
          role VARCHAR(20) DEFAULT 'user',
          is_active BOOLEAN DEFAULT true,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // جدول الذهب
      await execute('''
        CREATE TABLE IF NOT EXISTS gold_items (
          id SERIAL PRIMARY KEY,
          item_code VARCHAR(50) UNIQUE NOT NULL,
          name VARCHAR(100) NOT NULL,
          category VARCHAR(50) NOT NULL,
          karat INTEGER NOT NULL,
          weight DECIMAL(10,3) NOT NULL,
          purity DECIMAL(5,2) NOT NULL,
          purchase_price DECIMAL(12,2) NOT NULL,
          selling_price DECIMAL(12,2) NOT NULL,
          status VARCHAR(20) DEFAULT 'available',
          description TEXT,
          image_url VARCHAR(255),
          barcode VARCHAR(100),
          qr_code VARCHAR(100),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // جدول العملاء
      await execute('''
        CREATE TABLE IF NOT EXISTS customers (
          id SERIAL PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          phone VARCHAR(20),
          email VARCHAR(100),
          address TEXT,
          customer_type VARCHAR(20) DEFAULT 'individual',
          credit_limit DECIMAL(12,2) DEFAULT 0,
          current_balance DECIMAL(12,2) DEFAULT 0,
          is_active BOOLEAN DEFAULT true,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // جدول المبيعات
      await execute('''
        CREATE TABLE IF NOT EXISTS sales (
          id SERIAL PRIMARY KEY,
          invoice_number VARCHAR(50) UNIQUE NOT NULL,
          customer_id INTEGER REFERENCES customers(id),
          user_id INTEGER REFERENCES users(id),
          total_amount DECIMAL(12,2) NOT NULL,
          discount DECIMAL(12,2) DEFAULT 0,
          tax DECIMAL(12,2) DEFAULT 0,
          net_amount DECIMAL(12,2) NOT NULL,
          payment_method VARCHAR(20) NOT NULL,
          payment_status VARCHAR(20) DEFAULT 'paid',
          notes TEXT,
          sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // جدول تفاصيل المبيعات
      await execute('''
        CREATE TABLE IF NOT EXISTS sale_items (
          id SERIAL PRIMARY KEY,
          sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
          gold_item_id INTEGER REFERENCES gold_items(id),
          quantity INTEGER NOT NULL DEFAULT 1,
          unit_price DECIMAL(12,2) NOT NULL,
          total_price DECIMAL(12,2) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // جدول المواد الخام
      await execute('''
        CREATE TABLE IF NOT EXISTS raw_materials (
          id SERIAL PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          type VARCHAR(50) NOT NULL,
          quantity DECIMAL(10,3) NOT NULL,
          unit_price DECIMAL(12,2) NOT NULL,
          supplier_id INTEGER,
          status VARCHAR(20) DEFAULT 'available',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // جدول أوامر العمل
      await execute('''
        CREATE TABLE IF NOT EXISTS work_orders (
          id SERIAL PRIMARY KEY,
          order_number VARCHAR(50) UNIQUE NOT NULL,
          customer_id INTEGER REFERENCES customers(id),
          description TEXT NOT NULL,
          status VARCHAR(20) DEFAULT 'pending',
          priority VARCHAR(20) DEFAULT 'normal',
          start_date TIMESTAMP,
          due_date TIMESTAMP,
          completion_date TIMESTAMP,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // جدول المنتجات المكتملة
      await execute('''
        CREATE TABLE IF NOT EXISTS finished_goods (
          id SERIAL PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          category VARCHAR(50) NOT NULL,
          weight DECIMAL(10,3) NOT NULL,
          price DECIMAL(12,2) NOT NULL,
          status VARCHAR(20) DEFAULT 'available',
          work_order_id INTEGER REFERENCES work_orders(id),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      print('✅ تم إنشاء جداول قاعدة البيانات بنجاح');

    } catch (e) {
      print('❌ خطأ في إنشاء جداول قاعدة البيانات: $e');
      rethrow;
    }
  }

  /// التأكد من وجود اتصال صالح
  Future<void> _ensureConnection() async {
    if (!_isConnected || _connection == null) {
      final connected = await connect();
      if (!connected) {
        throw Exception('فشل في الاتصال بقاعدة البيانات');
      }
    }
  }

  /// الخصائص العامة
  bool get isConnected => _isConnected && _connection != null;

  String get connectionInfo =>
      'Host: $_host:$_port, Database: $_database, User: $_username';

  /// تنظيف الموارد عند إغلاق التطبيق
  Future<void> dispose() async {
    await disconnect();
    _instance = null;
  }

  /// معالج الأخطاء المخصص
  void _handleError(String operation, dynamic error) {
    print('❌ خطأ في $operation: $error');

    // إذا كان الخطأ متعلق بالاتصال، قم بإعادة تعيين الحالة
    if (error.toString().contains('connection') ||
        error.toString().contains('Connection')) {
      _isConnected = false;
      _connection = null;
    }
  }

  /// إحصائيات قاعدة البيانات
  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final stats = <String, int>{};

      final tables = ['users', 'gold_items', 'customers', 'sales', 'sale_items'];
      for (final table in tables) {
        stats[table] = await count(table);
      }

      return stats;
    } catch (e) {
      print('❌ خطأ في الحصول على إحصائيات قاعدة البيانات: $e');
      return {};
    }
  }

  // ===== دوال خاصة بالتطبيق =====

  /// الحصول على مبيعات اليوم
  Future<double> getDailySales() async {
    try {
      final result = await queryOne('''
        SELECT COALESCE(SUM(net_amount), 0) as daily_sales
        FROM sales
        WHERE DATE(sale_date) = CURRENT_DATE
      ''');
      return (result?['daily_sales'] ?? 0.0).toDouble();
    } catch (e) {
      print('❌ خطأ في الحصول على مبيعات اليوم: $e');
      return 0.0;
    }
  }

  /// الحصول على إجمالي المخزون
  Future<int> getTotalInventory() async {
    try {
      final result = await queryOne('''
        SELECT COALESCE(COUNT(*), 0) as total_inventory
        FROM gold_items
        WHERE status = 'available'
      ''');
      return (result?['total_inventory'] ?? 0).toInt();
    } catch (e) {
      print('❌ خطأ في الحصول على إجمالي المخزون: $e');
      return 0;
    }
  }

  /// الحصول على عدد الطلبات المعلقة
  Future<int> getPendingWorkOrdersCount() async {
    try {
      return await count('work_orders', whereClause: "status = 'pending'");
    } catch (e) {
      print('❌ خطأ في الحصول على عدد الطلبات المعلقة: $e');
      return 0;
    }
  }

  /// الحصول على بيانات المبيعات الشهرية
  Future<List<FlSpot>> getMonthlySalesData() async {
    try {
      final results = await query('''
        SELECT
          EXTRACT(MONTH FROM sale_date) as month,
          SUM(net_amount) as total_sales
        FROM sales
        WHERE sale_date >= CURRENT_DATE - INTERVAL '12 months'
        GROUP BY EXTRACT(MONTH FROM sale_date)
        ORDER BY month
      ''');
      return results.map((row) {
        return FlSpot((row['month'] as double).toDouble(), (row['total_sales'] as double).toDouble());
      }).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على بيانات المبيعات الشهرية: $e');
      return [];
    }
  }

  /// الحصول على توزيع المخزون
  Future<List<PieChartSectionData>> getInventoryDistribution() async {
    try {
      final results = await query('''
        SELECT
          category,
          COUNT(*) as item_count
        FROM gold_items
        WHERE status = 'available'
        GROUP BY category
        ORDER BY item_count DESC
      ''');
      final List<Color> colors = [AppTheme.primaryGold, AppTheme.accentGold, AppTheme.bronze, AppTheme.copper, AppTheme.info];
      return results.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> row = entry.value;
        return PieChartSectionData(
          color: colors[index % colors.length],
          value: (row['item_count'] as int).toDouble(),
          title: '${row['category']} (${row['item_count']})',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.white),
        );
      }).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على توزيع المخزون: $e');
      return [];
    }
  }

  /// الحصول على المعاملات الأخيرة
  Future<List<Map<String, dynamic>>> getRecentTransactions() async {
    try {
      return await query('''
        SELECT
          s.id,
          s.invoice_number as transaction_number,
          c.name as client_name,
          s.net_amount as amount,
          s.sale_date as created_at
        FROM sales s
        LEFT JOIN customers c ON s.customer_id = c.id
        ORDER BY s.sale_date DESC
        LIMIT 5
      ''');
    } catch (e) {
      print('❌ خطأ في الحصول على المعاملات الأخيرة: $e');
      return [];
    }
  }

  /// الحصول على أكثر الأصناف مبيعاً
  Future<List<Map<String, dynamic>>> getTopSellingItems() async {
    try {
      return await query('''
        SELECT
          gi.name as product_name,
          SUM(si.quantity) as sales_count
        FROM sale_items si
        JOIN gold_items gi ON si.gold_item_id = gi.id
        GROUP BY gi.name
        ORDER BY sales_count DESC
        LIMIT 5
      ''');
    } catch (e) {
      print('❌ خطأ في الحصول على أكثر الأصناف مبيعاً: $e');
      return [];
    }
  }

  /// الحصول على جميع العملاء
  Future<List<Client>> getAllClients() async {
    try {
      final results = await query('SELECT * FROM customers ORDER BY name');
      return results.map((map) => Client.fromMap(map)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على العملاء: $e');
      return [];
    }
  }

  /// إدراج عميل جديد
  Future<int?> insertClient(Client client, String userId) async {
    try {
      final map = client.toMap();
      return await insertAndReturnId(
          'INSERT INTO customers (name, business_name, phone, email, address, commercial_registration, tax_number, contact_person, credit_limit, is_active, created_at) VALUES (@name, @business_name, @phone, @email, @address, @commercial_registration, @tax_number, @contact_person, @credit_limit, @is_active, @created_at) RETURNING id',
          parameters: map);
    } catch (e) {
      print('❌ خطأ في إدراج العميل: $e');
      rethrow;
    }
  }

  /// الحصول على جميع المواد الخام
  Future<List<RawMaterial>> getAllRawMaterials() async {
    try {
      final results = await query('SELECT rm.*, c.name as client_name FROM raw_materials rm LEFT JOIN customers c ON rm.supplier_id = c.id ORDER BY rm.created_at DESC');
      return results.map((map) => RawMaterial.fromMap(map)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على المواد الخام: $e');
      return [];
    }
  }

  /// إدراج مادة خام جديدة
  Future<int?> insertRawMaterial(RawMaterial material, String userId) async {
    try {
      final map = material.toMap();
      return await insertAndReturnId('''
        INSERT INTO raw_materials (client_id, intake_date, material_type, karat, weight, lot_batch_number, purity_percentage, estimated_value, status, notes, created_by, created_at)
        VALUES (@client_id, @intake_date, @material_type, @karat, @weight, @lot_batch_number, @purity_percentage, @estimated_value, @status, @notes, @created_by, @created_at) RETURNING id
      ''', parameters: map);
    } catch (e) {
      print('❌ خطأ في إدراج المادة الخام: $e');
      rethrow;
    }
  }

  /// الحصول على جميع المستخدمين
  Future<List<User>> getAllUsers() async {
    try {
      final results = await query('SELECT * FROM users ORDER BY full_name');
      return results.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على المستخدمين: $e');
      return [];
    }
  }

  /// إدراج مستخدم جديد
  Future<int?> insertUser(User user) async {
    try {
      final map = user.toMap();
      return await insertAndReturnId(
          'INSERT INTO users (username, email, password_hash, full_name, role, is_active, created_at) VALUES (@username, @email, @password_hash, @full_name, @role, @is_active, @created_at) RETURNING id',
          parameters: map);
    } catch (e) {
      print('❌ خطأ في إدراج المستخدم: $e');
      rethrow;
    }
  }

  /// تحديث مستخدم
  Future<int> updateUser(User user, String adminUserId) async {
    try {
      final map = user.toMap();
      return await execute(
          'UPDATE users SET username = @username, email = @email, full_name = @full_name, role = @role, is_active = @is_active, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
          parameters: map);
    } catch (e) {
      print('❌ خطأ في تحديث المستخدم: $e');
      rethrow;
    }
  }

  /// حذف مستخدم
  Future<int> deleteUser(String userId, String adminUserId) async {
    try {
      return await execute(
          'UPDATE users SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
          parameters: {'id': userId});
    } catch (e) {
      print('❌ خطأ في حذف المستخدم: $e');
      rethrow;
    }
  }

  /// الحصول على جميع أوامر العمل
  Future<List<WorkOrder>> getAllWorkOrders() async {
    try {
      final results = await query('SELECT wo.*, c.name as client_name, u.full_name as artisan_name FROM work_orders wo LEFT JOIN customers c ON wo.customer_id = c.id LEFT JOIN users u ON wo.artisan_id = u.id ORDER BY wo.created_at DESC');
      return results.map((map) => WorkOrder.fromMap(map)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على أوامر العمل: $e');
      return [];
    }
  }

  /// إدراج أمر عمل جديد
  Future<int?> insertWorkOrder(WorkOrder workOrder, String userId) async {
    try {
      final map = workOrder.toMap();
      return await insertAndReturnId('''
        INSERT INTO work_orders (order_number, raw_material_id, artisan_id, design_name, assigned_weight, assigned_karat, status, created_by, created_at, updated_at)
        VALUES (@order_number, @raw_material_id, @artisan_id, @design_name, @assigned_weight, @assigned_karat, @status, @created_by, @created_at, @updated_at) RETURNING id
      ''', parameters: map);
    } catch (e) {
      print('❌ خطأ في إدراج أمر العمل: $e');
      rethrow;
    }
  }

  /// تحديث أمر عمل
  Future<int> updateWorkOrder(WorkOrder workOrder, String userId) async {
    try {
      final map = workOrder.toMap();
      return await execute(
          'UPDATE work_orders SET design_name = @design_name, status = @status, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
          parameters: map);
    } catch (e) {
      print('❌ خطأ في تحديث أمر العمل: $e');
      rethrow;
    }
  }

  /// حذف أمر عمل
  Future<int> deleteWorkOrder(String workOrderId, String userId) async {
    try {
      return await execute('DELETE FROM work_orders WHERE id = @id',
          parameters: {'id': workOrderId});
    } catch (e) {
      print('❌ خطأ في حذف أمر العمل: $e');
      rethrow;
    }
  }

  /// الحصول على جميع المنتجات المكتملة
  Future<List<FinishedGood>> getAllFinishedGoods() async {
    try {
      final results = await query('SELECT fg.*, wo.order_number, u.full_name as artisan_name FROM finished_goods fg LEFT JOIN work_orders wo ON fg.work_order_id = wo.id LEFT JOIN users u ON fg.artisan_id = u.id ORDER BY fg.created_at DESC');
      return results.map((map) => FinishedGood.fromMap(map)).toList();
    } catch (e) {
      print('❌ خطأ في الحصول على المنتجات المكتملة: $e');
      return [];
    }
  }

  /// إدراج منتج مكتمل جديد
  Future<int?> insertFinishedGood(FinishedGood finishedGood, String userId) async {
    try {
      final map = finishedGood.toMap();
      return await insertAndReturnId('''
        INSERT INTO finished_goods (work_order_id, product_name, final_weight, karat, artisan_id, status, created_at)
        VALUES (@work_order_id, @product_name, @final_weight, @karat, @artisan_id, @status, @created_at) RETURNING id
      ''', parameters: map);
    } catch (e) {
      print('❌ خطأ في إدراج المنتج المكتمل: $e');
      rethrow;
    }
  }

  /// تحديث منتج مكتمل
  Future<int> updateFinishedGood(FinishedGood finishedGood, String userId) async {
    try {
      final map = finishedGood.toMap();
      return await execute(
          'UPDATE finished_goods SET product_name = @product_name, final_weight = @final_weight, karat = @karat, status = @status, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
          parameters: map);
    } catch (e) {
      print('❌ خطأ في تحديث المنتج المكتمل: $e');
      rethrow;
    }
  }

  /// حذف منتج مكتمل
  Future<int> deleteFinishedGood(String finishedGoodId, String userId) async {
    try {
      return await execute('DELETE FROM finished_goods WHERE id = @id',
          parameters: {'id': finishedGoodId});
    } catch (e) {
      print('❌ خطأ في حذف المنتج المكتمل: $e');
      rethrow;
    }
  }
}