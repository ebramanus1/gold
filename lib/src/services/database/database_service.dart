import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/models/user_model.dart';
import '../../core/models/gold_item_model.dart';
import '../../core/models/transaction_model.dart';
import '../../core/constants/network_constants.dart';
import '../network/network_config_service.dart';
import '../network/network_discovery_service.dart';

part 'database_service.g.dart';

// جداول قاعدة البيانات
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().withLength(min: 3, max: 50)();
  TextColumn get email => text()();
  TextColumn get fullName => text()();
  TextColumn get phone => text()();
  IntColumn get role => intEnum<UserRole>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  TextColumn get profileImageUrl => text().nullable()();
  TextColumn get permissions => text().nullable()(); // JSON
  TextColumn get settings => text().nullable()(); // JSON

  @override
  Set<Column> get primaryKey => {id};
}

class GoldItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get type => intEnum<GoldType>()();
  TextColumn get karat => text()();
  RealColumn get weight => real()();
  RealColumn get purity => real()();
  TextColumn get category => text()();
  TextColumn get subcategory => text().nullable()();
  RealColumn get costPrice => real()();
  RealColumn get sellingPrice => real()();
  TextColumn get barcode => text().nullable()();
  TextColumn get qrCode => text().nullable()();
  TextColumn get images => text()(); // JSON array
  IntColumn get status => intEnum<GoldItemStatus>()();
  TextColumn get craftsmanId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get specifications => text().nullable()(); // JSON

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get transactionNumber => text().unique()();
  IntColumn get type => intEnum<TransactionType>()();
  IntColumn get status => intEnum<TransactionStatus>()();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get salesPersonId => text()();
  RealColumn get subtotal => real()();
  RealColumn get taxAmount => real()();
  RealColumn get discountAmount => real()();
  RealColumn get totalAmount => real()();
  RealColumn get paidAmount => real()();
  RealColumn get remainingAmount => real()();
  IntColumn get paymentMethod => intEnum<PaymentMethod>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get metadata => text().nullable()(); // JSON

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionItems extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  TextColumn get itemId => text()();
  TextColumn get itemName => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get totalPrice => real()();
  RealColumn get weight => real()();
  TextColumn get karat => text()();
  RealColumn get discountAmount => real().nullable()();
  TextColumn get specifications => text().nullable()(); // JSON

  @override
  Set<Column> get primaryKey => {id};
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get nationalId => text().nullable()();
  IntColumn get type => intEnum<CustomerType>()();
  RealColumn get creditLimit => real().withDefault(const Constant(0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastTransactionAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class GoldItemHistory extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get action => text()();
  TextColumn get description => text()();
  TextColumn get userId => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get oldValues => text().nullable()(); // JSON
  TextColumn get newValues => text().nullable()(); // JSON

  @override
  Set<Column> get primaryKey => {id};
}

class PaymentRecords extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  RealColumn get amount => real()();
  IntColumn get method => intEnum<PaymentMethod>()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get recordedBy => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// جدول أوامر العمل Work Orders
class WorkOrders extends Table {
  TextColumn get id => text()();
  TextColumn get orderNumber => text().unique()();
  TextColumn get clientName => text()();
  TextColumn get customerId => text()();
  TextColumn get description => text().nullable()();
  IntColumn get type => integer().withDefault(const Constant(0))(); // نوع أمر العمل
  IntColumn get status => integer().withDefault(const Constant(0))(); // 0: pending, 1: in progress, 2: completed
  TextColumn get assignedCraftsman => text().nullable()();
  DateTimeColumn get createdDate => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get expectedCompletionDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get actualCompletionDate => dateTime().nullable()();
  RealColumn get estimatedCost => real().nullable()();
  RealColumn get actualCost => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// جدول جديد لمزامنة البيانات
class SyncLog extends Table {
  TextColumn get id => text()();
  TextColumn get syncTableName => text()(); // تم تغيير الاسم لتفادي التعارض
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // INSERT, UPDATE, DELETE
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get data => text().nullable()(); // JSON data
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Users,
  GoldItems,
  Transactions,
  TransactionItems,
  Customers,
  GoldItemHistory,
  PaymentRecords,
  WorkOrders, // تمت الإضافة هنا
  SyncLog,
])
class DatabaseService extends _$DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  
  DatabaseService._() : super(_openConnection());

  @override
  int get schemaVersion => 2; // زيادة رقم الإصدار لإضافة جدول المزامنة

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _insertInitialData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1 && to == 2) {
        await m.createTable(syncLog);
      }
    },
  );

  // إدراج البيانات الأولية
  Future<void> _insertInitialData() async {
    // إنشاء مستخدم إداري افتراضي
    await into(users).insert(UsersCompanion.insert(
      id: 'admin-001',
      username: 'admin',
      email: 'admin@goldworkshop.com',
      fullName: 'مدير النظام',
      phone: '+966500000000',
      role: UserRole.admin,
    ));

    // إضافة فئات الذهب الأساسية
    final goldCategories = [
      'خواتم',
      'أساور',
      'قلائد',
      'حلق',
      'دبل',
      'مجوهرات أخرى',
    ];

    // إضافة بعض عناصر الذهب التجريبية
    for (int i = 0; i < 10; i++) {
      await into(goldItems).insert(GoldItemsCompanion.insert(
        id: 'item-${i.toString().padLeft(3, '0')}',
        name: 'صنف ذهبي ${i + 1}',
        description: 'وصف الصنف الذهبي رقم ${i + 1}',
        type: GoldType.manufactured,
        karat: '21K',
        weight: 10.0 + (i * 2.5),
        purity: 87.5,
        category: goldCategories[i % goldCategories.length],
        costPrice: 1000.0 + (i * 100),
        sellingPrice: 1200.0 + (i * 120),
        images: '[]',
        status: GoldItemStatus.inStock,
      ));
    }
  }

  // طرق للمستخدمين
  Future<List<User>> getAllUsers() => select(users).get();
  
  Future<User?> getUserById(String id) =>
      (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  
  Future<User?> getUserByUsername(String username) =>
      (select(users)..where((u) => u.username.equals(username))).getSingleOrNull();

  Future<int> insertUser(UsersCompanion user) async {
    final result = await into(users).insert(user);
    await _logSync('users', user.id.value, 'INSERT', null);
    return result;
  }
  
  Future<bool> updateUser(UsersCompanion user) async {
    final result = await update(users).replace(user);
    await _logSync('users', user.id.value, 'UPDATE', null);
    return result;
  }
  
  Future<int> deleteUser(String id) async {
    final result = await (delete(users)..where((u) => u.id.equals(id))).go();
    await _logSync('users', id, 'DELETE', null);
    return result;
  }

  // طرق لعناصر الذهب
  Future<List<GoldItem>> getAllGoldItems() => select(goldItems).get();
  
  Future<List<GoldItem>> getGoldItemsByStatus(GoldItemStatus status) =>
      (select(goldItems)..where((g) => g.status.equals(status.index))).get();
  
  Future<GoldItem?> getGoldItemById(String id) =>
      (select(goldItems)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<int> insertGoldItem(GoldItemsCompanion item) async {
    final result = await into(goldItems).insert(item);
    await _logSync('gold_items', item.id.value, 'INSERT', null);
    return result;
  }
  
  Future<bool> updateGoldItem(GoldItemsCompanion item) async {
    final result = await update(goldItems).replace(item);
    await _logSync('gold_items', item.id.value, 'UPDATE', null);
    return result;
  }
  
  Future<int> deleteGoldItem(String id) async {
    final result = await (delete(goldItems)..where((g) => g.id.equals(id))).go();
    await _logSync('gold_items', id, 'DELETE', null);
    return result;
  }

  // طرق للمعاملات
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();
  
  Future<List<Transaction>> getTransactionsByDateRange(DateTime from, DateTime to) =>
      (select(transactions)..where((t) => t.createdAt.isBetweenValues(from, to))).get();
  
  Future<Transaction?> getTransactionById(String id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTransaction(TransactionsCompanion transaction) async {
    final result = await into(transactions).insert(transaction);
    await _logSync('transactions', transaction.id.value, 'INSERT', null);
    return result;
  }
  
  Future<bool> updateTransaction(TransactionsCompanion transaction) async {
    final result = await update(transactions).replace(transaction);
    await _logSync('transactions', transaction.id.value, 'UPDATE', null);
    return result;
  }

  // طرق للعملاء
  Future<List<Customer>> getAllCustomers() => select(customers).get();
  
  Future<Customer?> getCustomerById(String id) =>
      (select(customers)..where((c) => c.id.equals(id))).getSingleOrNull();
  
  Future<Customer?> getCustomerByPhone(String phone) =>
      (select(customers)..where((c) => c.phone.equals(phone))).getSingleOrNull();

  Future<int> insertCustomer(CustomersCompanion customer) async {
    final result = await into(customers).insert(customer);
    await _logSync('customers', customer.id.value, 'INSERT', null);
    return result;
  }
  
  Future<bool> updateCustomer(CustomersCompanion customer) async {
    final result = await update(customers).replace(customer);
    await _logSync('customers', customer.id.value, 'UPDATE', null);
    return result;
  }

  // طرق المزامنة
  Future<void> _logSync(String tableName, String recordId, String operation, Map<String, dynamic>? data) async {
    await into(syncLog).insert(SyncLogCompanion.insert(
      id: 'sync-{DateTime.now().millisecondsSinceEpoch}-${recordId}',
      syncTableName: tableName, // تم التغيير هنا
      recordId: recordId,
      operation: operation,
      data: data != null ? Value(data.toString()) : const Value.absent(),
    ));
  }

  Future<List<SyncLogData>> getUnsyncedRecords() =>
      (select(syncLog)..where((s) => s.synced.equals(false))).get();

  Future<void> markAsSynced(String syncId) async {
    await (update(syncLog)..where((s) => s.id.equals(syncId)))
        .write(const SyncLogCompanion(synced: Value(true)));
  }

  Future<void> incrementRetryCount(String syncId) async {
    final record = await (select(syncLog)..where((s) => s.id.equals(syncId))).getSingleOrNull();
    if (record != null) {
      await (update(syncLog)..where((s) => s.id.equals(syncId)))
          .write(SyncLogCompanion(retryCount: Value(record.retryCount + 1)));
    }
  }

  // طرق للتقارير والإحصائيات
  Future<double> getTotalSalesToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final query = selectOnly(transactions)
      ..addColumns([transactions.totalAmount.sum()])
      ..where(transactions.createdAt.isBetweenValues(startOfDay, endOfDay))
      ..where(transactions.status.equals(TransactionStatus.completed.index));
    
    final result = await query.getSingleOrNull();
    return result?.read(transactions.totalAmount.sum()) ?? 0.0;
  }

  Future<int> getTotalItemsInStock() async {
    final query = selectOnly(goldItems)
      ..addColumns([goldItems.id.count()])
      ..where(goldItems.status.equals(GoldItemStatus.inStock.index));
    
    final result = await query.getSingleOrNull();
    return result?.read(goldItems.id.count()) ?? 0;
  }

  Future<int> getPendingOrdersCount() async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.id.count()])
      ..where(transactions.status.equals(TransactionStatus.pending.index));
    
    final result = await query.getSingleOrNull();
    return result?.read(transactions.id.count()) ?? 0;
  }

  // فحص حالة الاتصال بالشبكة
  Future<bool> isNetworkAvailable() async {
    final networkService = NetworkDiscoveryService.instance;
    final status = await networkService.getNetworkStatus();
    return status == NetworkStatus.connectedToServer;
  }

  // مزامنة البيانات مع الخادم المركزي
  Future<bool> syncWithServer() async {
    try {
      if (!await isNetworkAvailable()) {
        return false;
      }

      final unsyncedRecords = await getUnsyncedRecords();
      
      for (final record in unsyncedRecords) {
        try {
          // هنا يمكن إضافة منطق إرسال البيانات للخادم المركزي
          // مثل استخدام HTTP API أو قاعدة بيانات مشتركة
          
          await markAsSynced(record.id);
        } catch (e) {
          await incrementRetryCount(record.id);
          
          // إذا فشلت المحاولة أكثر من 3 مرات، تسجيل خطأ
          if (record.retryCount >= 3) {
            print('فشل في مزامنة السجل ${record.id} بعد ${record.retryCount} محاولات');
          }
        }
      }
      
      return true;
    } catch (e) {
      print('خطأ في مزامنة البيانات: $e');
      return false;
    }
  }

  // إغلاق قاعدة البيانات
  @override
  Future<void> close() {
    return super.close();
  }
}

// فتح اتصال قاعدة البيانات
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'gold_workshop.db'));
    return NativeDatabase(file);
  });
}

