import 'package:flutter_test/flutter_test.dart';
import 'package:gold_workshop_ai/src/services/gold_management/gold_management_service.dart';
import 'package:gold_workshop_ai/src/core/models/gold_item_model.dart';

void main() {
  group('GoldManagementService Tests', () {
    late GoldManagementService goldService;

    setUp(() {
      goldService = GoldManagementService();
    });

    test('should add gold item successfully', () async {
      final itemId = await goldService.addGoldItem(
        name: 'خاتم ذهب',
        description: 'خاتم ذهب عيار 21',
        type: GoldType.manufactured,
        karat: '21K',
        weight: 5.5,
        purity: 87.5,
        category: 'خواتم',
        costPrice: 1000.0,
        sellingPrice: 1200.0,
      );

      expect(itemId, isNotEmpty);
      expect(itemId.length, 36); // UUID length
    });

    test('should retrieve gold item by id', () async {
      // إضافة عنصر أولاً
      final itemId = await goldService.addGoldItem(
        name: 'سوار ذهب',
        description: 'سوار ذهب عيار 18',
        type: GoldType.manufactured,
        karat: '18K',
        weight: 12.0,
        purity: 75.0,
        category: 'أساور',
        costPrice: 2000.0,
        sellingPrice: 2400.0,
      );

      // استرجاع العنصر
      final item = await goldService.getGoldItemById(itemId);

      expect(item, isNotNull);
      expect(item!.id, itemId);
      expect(item.name, 'سوار ذهب');
      expect(item.karat, '18K');
      expect(item.weight, 12.0);
      expect(item.status, GoldItemStatus.inStock);
    });

    test('should update gold item successfully', () async {
      // إضافة عنصر أولاً
      final itemId = await goldService.addGoldItem(
        name: 'قلادة ذهب',
        description: 'قلادة ذهب عيار 24',
        type: GoldType.raw,
        karat: '24K',
        weight: 8.0,
        purity: 99.9,
        category: 'قلائد',
        costPrice: 1500.0,
        sellingPrice: 1800.0,
      );

      // تحديث العنصر
      await goldService.updateGoldItem(
        id: itemId,
        name: 'قلادة ذهب محدثة',
        sellingPrice: 2000.0,
        status: GoldItemStatus.reserved,
      );

      // التحقق من التحديث
      final updatedItem = await goldService.getGoldItemById(itemId);

      expect(updatedItem, isNotNull);
      expect(updatedItem!.name, 'قلادة ذهب محدثة');
      expect(updatedItem.sellingPrice, 2000.0);
      expect(updatedItem.status, GoldItemStatus.reserved);
    });

    test('should delete gold item successfully', () async {
      // إضافة عنصر أولاً
      final itemId = await goldService.addGoldItem(
        name: 'حلق ذهب',
        description: 'حلق ذهب عيار 21',
        type: GoldType.manufactured,
        karat: '21K',
        weight: 3.0,
        purity: 87.5,
        category: 'حلق',
        costPrice: 500.0,
        sellingPrice: 600.0,
      );

      // التأكد من وجود العنصر
      var item = await goldService.getGoldItemById(itemId);
      expect(item, isNotNull);

      // حذف العنصر
      await goldService.deleteGoldItem(itemId);

      // التأكد من حذف العنصر
      item = await goldService.getGoldItemById(itemId);
      expect(item, isNull);
    });

    test('should search gold items by name', () async {
      // إضافة عدة عناصر
      await goldService.addGoldItem(
        name: 'خاتم ذهب أبيض',
        description: 'خاتم ذهب أبيض عيار 18',
        type: GoldType.manufactured,
        karat: '18K',
        weight: 4.0,
        purity: 75.0,
        category: 'خواتم',
        costPrice: 800.0,
        sellingPrice: 1000.0,
      );

      await goldService.addGoldItem(
        name: 'خاتم ذهب أصفر',
        description: 'خاتم ذهب أصفر عيار 21',
        type: GoldType.manufactured,
        karat: '21K',
        weight: 5.0,
        purity: 87.5,
        category: 'خواتم',
        costPrice: 1000.0,
        sellingPrice: 1200.0,
      );

      await goldService.addGoldItem(
        name: 'سوار فضة',
        description: 'سوار فضة',
        type: GoldType.manufactured,
        karat: '925',
        weight: 10.0,
        purity: 92.5,
        category: 'أساور',
        costPrice: 300.0,
        sellingPrice: 400.0,
      );

      // البحث عن "خاتم"
      final searchResults = await goldService.searchGoldItems(query: 'خاتم');

      expect(searchResults.length, 2);
      expect(searchResults.every((item) => item.name.contains('خاتم')), true);
    });

    test('should filter gold items by category', () async {
      // إضافة عناصر من فئات مختلفة
      await goldService.addGoldItem(
        name: 'خاتم 1',
        description: 'خاتم ذهب',
        type: GoldType.manufactured,
        karat: '21K',
        weight: 5.0,
        purity: 87.5,
        category: 'خواتم',
        costPrice: 1000.0,
        sellingPrice: 1200.0,
      );

      await goldService.addGoldItem(
        name: 'سوار 1',
        description: 'سوار ذهب',
        type: GoldType.manufactured,
        karat: '18K',
        weight: 8.0,
        purity: 75.0,
        category: 'أساور',
        costPrice: 1500.0,
        sellingPrice: 1800.0,
      );

      // البحث بالفئة
      final ringsResults = await goldService.searchGoldItems(category: 'خواتم');
      final braceletsResults = await goldService.searchGoldItems(category: 'أساور');

      expect(ringsResults.length, greaterThanOrEqualTo(1));
      expect(ringsResults.every((item) => item.category == 'خواتم'), true);
      
      expect(braceletsResults.length, greaterThanOrEqualTo(1));
      expect(braceletsResults.every((item) => item.category == 'أساور'), true);
    });

    test('should update item status', () async {
      // إضافة عنصر
      final itemId = await goldService.addGoldItem(
        name: 'دبلة ذهب',
        description: 'دبلة ذهب عيار 18',
        type: GoldType.manufactured,
        karat: '18K',
        weight: 6.0,
        purity: 75.0,
        category: 'دبل',
        costPrice: 1200.0,
        sellingPrice: 1500.0,
      );

      // التأكد من الحالة الأولية
      var item = await goldService.getGoldItemById(itemId);
      expect(item!.status, GoldItemStatus.inStock);

      // تغيير الحالة إلى مباع
      await goldService.updateItemStatus(itemId, GoldItemStatus.sold);

      // التحقق من التغيير
      item = await goldService.getGoldItemById(itemId);
      expect(item!.status, GoldItemStatus.sold);
    });

    test('should calculate inventory stats correctly', () async {
      // إضافة عدة عناصر بحالات مختلفة
      final item1Id = await goldService.addGoldItem(
        name: 'عنصر 1',
        description: 'وصف 1',
        type: GoldType.manufactured,
        karat: '21K',
        weight: 5.0,
        purity: 87.5,
        category: 'خواتم',
        costPrice: 1000.0,
        sellingPrice: 1200.0,
      );

      final item2Id = await goldService.addGoldItem(
        name: 'عنصر 2',
        description: 'وصف 2',
        type: GoldType.manufactured,
        karat: '18K',
        weight: 8.0,
        purity: 75.0,
        category: 'أساور',
        costPrice: 1500.0,
        sellingPrice: 1800.0,
      );

      // تغيير حالة أحد العناصر
      await goldService.updateItemStatus(item1Id, GoldItemStatus.sold);

      // الحصول على الإحصائيات
      final stats = await goldService.getInventoryStats();

      expect(stats.totalItems, greaterThanOrEqualTo(2));
      expect(stats.soldItems, greaterThanOrEqualTo(1));
      expect(stats.inStockItems, greaterThanOrEqualTo(1));
      expect(stats.totalWeight, greaterThan(0));
      expect(stats.totalValue, greaterThan(0));
    });

    test('should handle invalid item id gracefully', () async {
      final item = await goldService.getGoldItemById('invalid-id');
      expect(item, isNull);
    });

    test('should throw exception when updating non-existent item', () async {
      expect(
        () => goldService.updateGoldItem(id: 'non-existent-id', name: 'New Name'),
        throwsException,
      );
    });

    test('should throw exception when deleting non-existent item', () async {
      expect(
        () => goldService.deleteGoldItem('non-existent-id'),
        throwsException,
      );
    });
  });
}

