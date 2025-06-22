import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../models/work_order.dart';
import '../../../services/database/database_service.dart' as db;

class WorkOrderService {
  final db.DatabaseService _databaseService;

  WorkOrderService(this._databaseService);

  // إنشاء أمر عمل جديد
  Future<String> createWorkOrder(WorkOrder workOrder) async {
    try {
      final companion = db.WorkOrdersCompanion.insert(
        id: workOrder.id,
        orderNumber: workOrder.orderNumber,
        clientName: workOrder.clientName,
        customerId: workOrder.clientId,
        createdDate: Value(workOrder.createdDate),
        description: Value(workOrder.description),
        status: Value(workOrder.status.index),
        type: Value(workOrder.type.index),
        assignedCraftsman: Value(workOrder.assignedCraftsman),
        expectedCompletionDate: Value(workOrder.expectedCompletionDate),
        actualCompletionDate: Value(workOrder.actualCompletionDate),
        startDate: Value(workOrder.startDate),
        notes: Value(workOrder.notes),
        estimatedCost: Value(workOrder.estimatedCost),
        actualCost: Value(workOrder.actualCost),
      );
      await _databaseService.into(_databaseService.workOrders).insert(companion);
      return workOrder.id;
    } catch (e) {
      throw Exception('فشل في إنشاء أمر العمل: $e');
    }
  }

  // الحصول على جميع أوامر العمل
  Future<List<WorkOrder>> getAllWorkOrders() async {
    try {
      final rows = await _databaseService.select(_databaseService.workOrders).get();
      return rows.map((row) => WorkOrder.fromDrift(row)).toList();
    } catch (e) {
      throw Exception('فشل في جلب أوامر العمل: $e');
    }
  }

  // الحصول على أمر عمل بالمعرف
  Future<WorkOrder?> getWorkOrderById(String id) async {
    try {
      final row = await (_databaseService.select(_databaseService.workOrders)
        ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      return row != null ? WorkOrder.fromDrift(row) : null;
    } catch (e) {
      throw Exception('فشل في جلب أمر العمل: $e');
    }
  }

  // تحديث أمر العمل
  Future<void> updateWorkOrder(WorkOrder workOrder) async {
    try {
      final companion = db.WorkOrdersCompanion(
        id: Value(workOrder.id),
        orderNumber: Value(workOrder.orderNumber),
        clientName: Value(workOrder.clientName),
        customerId: Value(workOrder.clientId),
        description: Value(workOrder.description),
        status: Value(workOrder.status.index),
        type: Value(workOrder.type.index),
        assignedCraftsman: Value(workOrder.assignedCraftsman),
        createdDate: Value(workOrder.createdDate),
        expectedCompletionDate: Value(workOrder.expectedCompletionDate),
        actualCompletionDate: Value(workOrder.actualCompletionDate),
        startDate: Value(workOrder.startDate),
        notes: Value(workOrder.notes),
        estimatedCost: Value(workOrder.estimatedCost),
        actualCost: Value(workOrder.actualCost),
      );
      await _databaseService.update(_databaseService.workOrders).replace(companion);
    } catch (e) {
      throw Exception('فشل في تحديث أمر العمل: $e');
    }
  }

  // حذف أمر العمل
  Future<void> deleteWorkOrder(String id) async {
    try {
      await (_databaseService.delete(_databaseService.workOrders)
        ..where((tbl) => tbl.id.equals(id))).go();
    } catch (e) {
      throw Exception('فشل في حذف أمر العمل: $e');
    }
  }

  // البحث في أوامر العمل
  Future<List<WorkOrder>> searchWorkOrders(String query) async {
    try {
      final rows = await (_databaseService.select(_databaseService.workOrders)
        ..where((tbl) => tbl.orderNumber.like('%$query%') | tbl.clientName.like('%$query%') | tbl.description.like('%$query%'))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdDate, mode: OrderingMode.desc)])
      ).get();
      return rows.map((row) => WorkOrder.fromDrift(row)).toList();
    } catch (e) {
      throw Exception('فشل في البحث: $e');
    }
  }

  // فلترة أوامر العمل حسب الحالة
  Future<List<WorkOrder>> getWorkOrdersByStatus(WorkOrderStatus status) async {
    try {
      final rows = await (_databaseService.select(_databaseService.workOrders)
        ..where((tbl) => tbl.status.equals(status.index))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdDate, mode: OrderingMode.desc)])
      ).get();
      return rows.map((row) => WorkOrder.fromDrift(row)).toList();
    } catch (e) {
      throw Exception('فشل في جلب أوامر العمل: $e');
    }
  }

  // فلترة أوامر العمل حسب النوع
  Future<List<WorkOrder>> getWorkOrdersByType(WorkOrderType type) async {
    try {
      final rows = await (_databaseService.select(_databaseService.workOrders)
        ..where((tbl) => tbl.type.equals(type.index))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdDate, mode: OrderingMode.desc)])
      ).get();
      return rows.map((row) => WorkOrder.fromDrift(row)).toList();
    } catch (e) {
      throw Exception('فشل في جلب أوامر العمل: $e');
    }
  }

  // الحصول على أوامر العمل المتأخرة
  Future<List<WorkOrder>> getOverdueWorkOrders() async {
    try {
      final now = DateTime.now();
      final rows = await (_databaseService.select(_databaseService.workOrders)
        ..where((tbl) => tbl.expectedCompletionDate.isSmallerThanValue(now) & tbl.status.isNotIn([WorkOrderStatus.completed.index]))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.expectedCompletionDate, mode: OrderingMode.asc)])
      ).get();
      return rows.map((row) => WorkOrder.fromDrift(row)).toList();
    } catch (e) {
      throw Exception('فشل في جلب أوامر العمل المتأخرة: $e');
    }
  }

  // الحصول على أوامر العمل حسب الحرفي
  Future<List<WorkOrder>> getWorkOrdersByCraftsman(String craftsmanId) async {
    try {
      final rows = await (_databaseService.select(_databaseService.workOrders)
        ..where((tbl) => tbl.assignedCraftsman.equals(craftsmanId))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdDate, mode: OrderingMode.desc)])
      ).get();
      return rows.map((row) => WorkOrder.fromDrift(row)).toList();
    } catch (e) {
      throw Exception('فشل في جلب أوامر العمل: $e');
    }
  }

  // تحديث حالة أمر العمل
  Future<void> updateWorkOrderStatus(String id, WorkOrderStatus status) async {
    try {
      final updateData = db.WorkOrdersCompanion(
        status: Value(status.index),
        startDate: status == WorkOrderStatus.inProgress ? Value(DateTime.now()) : const Value.absent(),
        actualCompletionDate: status == WorkOrderStatus.completed ? Value(DateTime.now()) : const Value.absent(),
      );
      await (_databaseService.update(_databaseService.workOrders)
        ..where((tbl) => tbl.id.equals(id))).write(updateData);
    } catch (e) {
      throw Exception('فشل في تحديث حالة أمر العمل: $e');
    }
  }

  // إحصائيات أوامر العمل
  Future<Map<String, int>> getWorkOrderStatistics() async {
    try {
      final total = await _databaseService.workOrders.count().getSingle();
      final pending = await (_databaseService.workOrders.select()..where((tbl) => tbl.status.equals(WorkOrderStatus.pending.index))).get().then((rows) => rows.length);
      final inProgress = await (_databaseService.workOrders.select()..where((tbl) => tbl.status.equals(WorkOrderStatus.inProgress.index))).get().then((rows) => rows.length);
      final completed = await (_databaseService.workOrders.select()..where((tbl) => tbl.status.equals(WorkOrderStatus.completed.index))).get().then((rows) => rows.length);
      final overdue = await (_databaseService.workOrders.select()..where((tbl) => tbl.expectedCompletionDate.isSmallerThanValue(DateTime.now()) & tbl.status.isNotIn([WorkOrderStatus.completed.index]))).get().then((rows) => rows.length);
      return {
        'total': total,
        'pending': pending,
        'inProgress': inProgress,
        'completed': completed,
        'overdue': overdue,
      };
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات أوامر العمل: $e');
    }
  }

  // تصدير أوامر العمل
  Future<List<Map<String, dynamic>>> exportWorkOrders({
    DateTime? startDate,
    DateTime? endDate,
    WorkOrderStatus? status,
    WorkOrderType? type,
  }) async {
    try {
      final query = _databaseService.select(_databaseService.workOrders);
      if (startDate != null) {
        query.where((tbl) => tbl.createdDate.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        query.where((tbl) => tbl.createdDate.isSmallerOrEqualValue(endDate));
      }
      if (status != null) {
        query.where((tbl) => tbl.status.equals(status.index));
      }
      if (type != null) {
        query.where((tbl) => tbl.type.equals(type.index));
      }
      final rows = await query.get();
      return rows.map((row) => row.toJson()).toList();
    } catch (e) {
      throw Exception('فشل في تصدير أوامر العمل: $e');
    }
  }
}

// Provider لخدمة أوامر العمل
final workOrderServiceProvider = Provider<WorkOrderService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return WorkOrderService(databaseService);
});

// Provider لحالة أوامر العمل
final workOrdersProvider = FutureProvider<List<WorkOrder>>((ref) async {
  final workOrderService = ref.watch(workOrderServiceProvider);
  return await workOrderService.getAllWorkOrders();
});

// Provider لإحصائيات أوامر العمل
final workOrderStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final workOrderService = ref.watch(workOrderServiceProvider);
  return await workOrderService.getWorkOrderStatistics();
});

// Provider لأوامر العمل المتأخرة
final overdueWorkOrdersProvider = FutureProvider<List<WorkOrder>>((ref) async {
  final workOrderService = ref.watch(workOrderServiceProvider);
  return await workOrderService.getOverdueWorkOrders();
});

// مزود خدمة قاعدة البيانات
final databaseServiceProvider = Provider<db.DatabaseService>((ref) {
  return db.DatabaseService.instance;
});

