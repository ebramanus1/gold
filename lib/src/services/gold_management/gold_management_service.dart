import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import '../../core/models/gold_item_model.dart';

class GoldManagementService {
  static final GoldManagementService _instance = GoldManagementService._internal();
  factory GoldManagementService() => _instance;
  GoldManagementService._internal();

  final DatabaseService _database = DatabaseService();
  final Uuid _uuid = const Uuid();

  // الحصول على جميع عناصر الذهب
  Future<List<GoldItemModel>> getAllGoldItems() async {
    try {
      final items = await _database.getAllGoldItems();
      return items.map((item) => _convertToModel(item)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب عناصر الذهب: ${e.toString()}');
    }
  }

  // الحصول على عناصر الذهب حسب الحالة
  Future<List<GoldItemModel>> getGoldItemsByStatus(GoldItemStatus status) async {
    try {
      final items = await _database.getGoldItemsByStatus(status);
      return items.map((item) => _convertToModel(item)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب عناصر الذهب حسب الحالة: ${e.toString()}');
    }
  }

  // الحصول على عنصر ذهب بالمعرف
  Future<GoldItemModel?> getGoldItemById(String id) async {
    try {
      final item = await _database.getGoldItemById(id);
      return item != null ? _convertToModel(item) : null;
    } catch (e) {
      throw Exception('خطأ في جلب عنصر الذهب: ${e.toString()}');
    }
  }

  // إضافة عنصر ذهب جديد
  Future<String> addGoldItem({
    required String name,
    required String description,
    required GoldType type,
    required String karat,
    required double weight,
    required double purity,
    required String category,
    String? subcategory,
    required double costPrice,
    required double sellingPrice,
    String? barcode,
    String? qrCode,
    List<String>? images,
    String? craftsmanId,
    Map<String, dynamic>? specifications,
  }) async {
    try {
      final itemId = _uuid.v4();
      
      final item = GoldItemsCompanion.insert(
        id: itemId,
        name: name,
        description: description,
        type: type,
        karat: karat,
        weight: weight,
        purity: purity,
        category: category,
        subcategory: Value(subcategory),
        costPrice: costPrice,
        sellingPrice: sellingPrice,
        barcode: Value(barcode),
        qrCode: Value(qrCode),
        images: jsonEncode(images ?? []),
        status: GoldItemStatus.inStock,
        craftsmanId: Value(craftsmanId),
        specifications: Value(specifications != null ? jsonEncode(specifications) : null),
      );

      await _database.insertGoldItem(item);
      
      // تسجيل في التاريخ
      await _addToHistory(
        itemId: itemId,
        action: 'CREATE',
        description: 'تم إنشاء عنصر ذهب جديد: $name',
        userId: 'system', // يجب الحصول على معرف المستخدم الحالي
      );

      return itemId;
    } catch (e) {
      throw Exception('خطأ في إضافة عنصر الذهب: ${e.toString()}');
    }
  }

  // تحديث عنصر ذهب
  Future<void> updateGoldItem({
    required String id,
    String? name,
    String? description,
    GoldType? type,
    String? karat,
    double? weight,
    double? purity,
    String? category,
    String? subcategory,
    double? costPrice,
    double? sellingPrice,
    String? barcode,
    String? qrCode,
    List<String>? images,
    GoldItemStatus? status,
    String? craftsmanId,
    String? customerId,
    Map<String, dynamic>? specifications,
  }) async {
    try {
      // الحصول على العنصر الحالي
      final currentItem = await _database.getGoldItemById(id);
      if (currentItem == null) {
        throw Exception('عنصر الذهب غير موجود');
      }

      // إنشاء نسخة محدثة
      final updatedItem = currentItem.copyWith(
        name: name,
        description: description,
        type: type != null ? Value(type) : const Value.absent(),
        karat: karat,
        weight: weight,
        purity: purity,
        category: category,
        subcategory: Value(subcategory),
        costPrice: costPrice,
        sellingPrice: sellingPrice,
        barcode: Value(barcode),
        qrCode: Value(qrCode),
        images: images != null ? jsonEncode(images) : null,
        status: status != null ? Value(status) : const Value.absent(),
        craftsmanId: Value(craftsmanId),
        customerId: Value(customerId),
        updatedAt: Value(DateTime.now()),
        specifications: Value(specifications != null ? jsonEncode(specifications) : null),
      );

      await _database.updateGoldItem(updatedItem);
      
      // تسجيل في التاريخ
      await _addToHistory(
        itemId: id,
        action: 'UPDATE',
        description: 'تم تحديث عنصر الذهب: ${name ?? currentItem.name}',
        userId: 'system',
        oldValues: _itemToJson(currentItem),
        newValues: _itemToJson(updatedItem as GoldItem),
      );
    } catch (e) {
      throw Exception('خطأ في تحديث عنصر الذهب: ${e.toString()}');
    }
  }

  // حذف عنصر ذهب
  Future<void> deleteGoldItem(String id) async {
    try {
      final item = await _database.getGoldItemById(id);
      if (item == null) {
        throw Exception('عنصر الذهب غير موجود');
      }

      await _database.deleteGoldItem(id);
      
      // تسجيل في التاريخ
      await _addToHistory(
        itemId: id,
        action: 'DELETE',
        description: 'تم حذف عنصر الذهب: ${item.name}',
        userId: 'system',
      );
    } catch (e) {
      throw Exception('خطأ في حذف عنصر الذهب: ${e.toString()}');
    }
  }

  // تحديث حالة عنصر الذهب
  Future<void> updateItemStatus(String id, GoldItemStatus newStatus) async {
    try {
      final item = await _database.getGoldItemById(id);
      if (item == null) {
        throw Exception('عنصر الذهب غير موجود');
      }

      final oldStatus = item.status;
      
      final updatedItem = item.copyWith(
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      );

      await _database.updateGoldItem(updatedItem);
      
      // تسجيل في التاريخ
      await _addToHistory(
        itemId: id,
        action: 'STATUS_CHANGE',
        description: 'تم تغيير حالة العنصر من ${_getStatusName(oldStatus)} إلى ${_getStatusName(newStatus)}',
        userId: 'system',
      );
    } catch (e) {
      throw Exception('خطأ في تحديث حالة عنصر الذهب: ${e.toString()}');
    }
  }

  // البحث في عناصر الذهب
  Future<List<GoldItemModel>> searchGoldItems({
    String? query,
    String? category,
    String? karat,
    GoldType? type,
    GoldItemStatus? status,
    double? minWeight,
    double? maxWeight,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      // في تطبيق حقيقي، يجب تنفيذ البحث في قاعدة البيانات
      // هنا نحصل على جميع العناصر ونقوم بالتصفية
      final allItems = await getAllGoldItems();
      
      return allItems.where((item) {
        if (query != null && query.isNotEmpty) {
          final searchQuery = query.toLowerCase();
          if (!item.name.toLowerCase().contains(searchQuery) &&
              !item.description.toLowerCase().contains(searchQuery) &&
              !item.category.toLowerCase().contains(searchQuery)) {
            return false;
          }
        }
        
        if (category != null && item.category != category) return false;
        if (karat != null && item.karat != karat) return false;
        if (type != null && item.type != type) return false;
        if (status != null && item.status != status) return false;
        if (minWeight != null && item.weight < minWeight) return false;
        if (maxWeight != null && item.weight > maxWeight) return false;
        if (minPrice != null && item.sellingPrice < minPrice) return false;
        if (maxPrice != null && item.sellingPrice > maxPrice) return false;
        
        return true;
      }).toList();
    } catch (e) {
      throw Exception('خطأ في البحث: ${e.toString()}');
    }
  }

  // الحصول على إحصائيات المخزون
  Future<InventoryStats> getInventoryStats() async {
    try {
      final allItems = await getAllGoldItems();
      
      final totalItems = allItems.length;
      final inStockItems = allItems.where((item) => item.status == GoldItemStatus.inStock).length;
      final soldItems = allItems.where((item) => item.status == GoldItemStatus.sold).length;
      final reservedItems = allItems.where((item) => item.status == GoldItemStatus.reserved).length;
      final inProgressItems = allItems.where((item) => item.status == GoldItemStatus.inProgress).length;
      
      final totalWeight = allItems.fold<double>(0, (sum, item) => sum + item.weight);
      final totalValue = allItems.fold<double>(0, (sum, item) => sum + item.totalValue);
      
      // تجميع حسب الفئة
      final categoryStats = <String, int>{};
      for (final item in allItems) {
        categoryStats[item.category] = (categoryStats[item.category] ?? 0) + 1;
      }
      
      // تجميع حسب العيار
      final karatStats = <String, int>{};
      for (final item in allItems) {
        karatStats[item.karat] = (karatStats[item.karat] ?? 0) + 1;
      }

      return InventoryStats(
        totalItems: totalItems,
        inStockItems: inStockItems,
        soldItems: soldItems,
        reservedItems: reservedItems,
        inProgressItems: inProgressItems,
        totalWeight: totalWeight,
        totalValue: totalValue,
        categoryStats: categoryStats,
        karatStats: karatStats,
      );
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات المخزون: ${e.toString()}');
    }
  }

  // الحصول على تاريخ عنصر الذهب
  Future<List<GoldItemHistory>> getItemHistory(String itemId) async {
    try {
      // في تطبيق حقيقي، يجب جلب التاريخ من قاعدة البيانات
      return [];
    } catch (e) {
      throw Exception('خطأ في جلب تاريخ العنصر: ${e.toString()}');
    }
  }

  // طرق مساعدة خاصة
  GoldItemModel _convertToModel(GoldItem item) {
    return GoldItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      type: item.type,
      karat: item.karat,
      weight: item.weight,
      purity: item.purity,
      category: item.category,
      subcategory: item.subcategory,
      costPrice: item.costPrice,
      sellingPrice: item.sellingPrice,
      barcode: item.barcode,
      qrCode: item.qrCode,
      images: List<String>.from(jsonDecode(item.images)),
      status: item.status,
      craftsmanId: item.craftsmanId,
      customerId: item.customerId,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      specifications: item.specifications != null 
          ? Map<String, dynamic>.from(jsonDecode(item.specifications!))
          : null,
      history: [], // يجب جلبه من قاعدة البيانات
    );
  }

  Future<void> _addToHistory({
    required String itemId,
    required String action,
    required String description,
    required String userId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  }) async {
    final historyId = _uuid.v4();
    
    final history = GoldItemHistoryCompanion.insert(
      id: historyId,
      itemId: itemId,
      action: action,
      description: description,
      userId: userId,
      oldValues: Value(oldValues != null ? jsonEncode(oldValues) : null),
      newValues: Value(newValues != null ? jsonEncode(newValues) : null),
    );

    // في تطبيق حقيقي، يجب إدراج السجل في قاعدة البيانات
    // await _database.insertGoldItemHistory(history);
  }

  Map<String, dynamic> _itemToJson(GoldItem item) {
    return {
      'name': item.name,
      'description': item.description,
      'type': item.type.toString(),
      'karat': item.karat,
      'weight': item.weight,
      'purity': item.purity,
      'category': item.category,
      'subcategory': item.subcategory,
      'costPrice': item.costPrice,
      'sellingPrice': item.sellingPrice,
      'status': item.status.toString(),
    };
  }

  String _getStatusName(GoldItemStatus status) {
    switch (status) {
      case GoldItemStatus.inStock:
        return 'في المخزن';
      case GoldItemStatus.sold:
        return 'مباع';
      case GoldItemStatus.reserved:
        return 'محجوز';
      case GoldItemStatus.inProgress:
        return 'قيد التصنيع';
      case GoldItemStatus.returned:
        return 'مرتجع';
      case GoldItemStatus.damaged:
        return 'تالف';
    }
  }
}

// فئة إحصائيات المخزون
class InventoryStats {
  final int totalItems;
  final int inStockItems;
  final int soldItems;
  final int reservedItems;
  final int inProgressItems;
  final double totalWeight;
  final double totalValue;
  final Map<String, int> categoryStats;
  final Map<String, int> karatStats;

  InventoryStats({
    required this.totalItems,
    required this.inStockItems,
    required this.soldItems,
    required this.reservedItems,
    required this.inProgressItems,
    required this.totalWeight,
    required this.totalValue,
    required this.categoryStats,
    required this.karatStats,
  });
}

