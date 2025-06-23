import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../finished_goods/models/finished_product.dart';
import '../../core/localization/app_localizations.dart';

class FinishedGoodsManagementScreen extends ConsumerStatefulWidget {
  const FinishedGoodsManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FinishedGoodsManagementScreen> createState() => _FinishedGoodsManagementScreenState();
}

class _FinishedGoodsManagementScreenState extends ConsumerState<FinishedGoodsManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProductCategory? _selectedCategory;
  int? _selectedKarat;
  List<FinishedProduct> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _products = _generateSampleProducts();
      _isLoading = false;
    });
  }

  List<FinishedProduct> _generateSampleProducts() {
    return [
      FinishedProduct(
        id: '1',
        code: 'R001',
        name: 'خاتم ذهب عيار 21',
        description: 'خاتم ذهب أصفر عيار 21 قيراط بتصميم كلاسيكي',
        category: ProductCategory.rings,
        status: ProductStatus.available,
        goldKarat: GoldKarat.k21,
        weight: 5.2,
        goldWeight: 5.2,
        stoneWeight: 0.0,
        costPrice: 1000.0,
        sellingPrice: 1250.0,
        laborCost: 0.0,
        stoneCost: 0.0,
        additionalCost: 0.0,
        stockQuantity: 15,
        minStockLevel: 5,
        barcode: '1234567890123',
        createdDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      FinishedProduct(
        id: '2',
        code: 'N001',
        name: 'قلادة ذهب مع دلاية',
        description: 'قلادة ذهب عيار 18 مع دلاية على شكل قلب',
        category: ProductCategory.necklaces,
        status: ProductStatus.available,
        goldKarat: GoldKarat.k18,
        weight: 9.0,
        goldWeight: 8.5,
        stoneWeight: 0.5,
        costPrice: 1800.0,
        sellingPrice: 2100.0,
        laborCost: 0.0,
        stoneCost: 0.0,
        additionalCost: 0.0,
        stockQuantity: 8,
        minStockLevel: 3,
        barcode: '1234567890124',
        createdDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      FinishedProduct(
        id: '3',
        code: 'B001',
        name: 'سوار ذهب نسائي',
        description: 'سوار ذهب عيار 22 بتصميم عصري للنساء',
        category: ProductCategory.bracelets,
        status: ProductStatus.available,
        goldKarat: GoldKarat.k22,
        weight: 12.3,
        goldWeight: 12.3,
        stoneWeight: 0.0,
        costPrice: 2700.0,
        sellingPrice: 3200.0,
        laborCost: 0.0,
        stoneCost: 0.0,
        additionalCost: 0.0,
        stockQuantity: 6,
        minStockLevel: 2,
        barcode: '1234567890125',
        createdDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
      FinishedProduct(
        id: '4',
        code: 'E001',
        name: 'أقراط ذهب مع أحجار',
        description: 'أقراط ذهب عيار 18 مرصعة بأحجار كريمة',
        category: ProductCategory.earrings,
        status: ProductStatus.available,
        goldKarat: GoldKarat.k18,
        weight: 5.0,
        goldWeight: 3.8,
        stoneWeight: 1.2,
        costPrice: 1500.0,
        sellingPrice: 1800.0,
        laborCost: 0.0,
        stoneCost: 0.0,
        additionalCost: 0.0,
        stockQuantity: 12,
        minStockLevel: 4,
        barcode: '1234567890126',
        createdDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  List<FinishedProduct> get _filteredProducts {
    return _products.where((product) {
      final matchesSearch = _searchController.text.isEmpty ||
          product.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          (product.barcode?.contains(_searchController.text) ?? false);
      final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
      final matchesKarat = _selectedKarat == null || _getGoldKaratText(product.goldKarat) == _selectedKarat.toString();
      return matchesSearch && matchesCategory && matchesKarat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(localizations.translate('finished_goods_management') ?? 'إدارة المنتجات النهائية', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(UIConstants.paddingLarge),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'بحث عن منتج...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            // ...existing code for filtering...
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {/* إضافة منتج */},
                      icon: const Icon(Icons.add),
                      label: Text(localizations.translate('add_product') ?? 'إضافة منتج'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Card(
                        elevation: 2,
                        margin: const EdgeInsets.all(UIConstants.paddingLarge),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(UIConstants.paddingLarge),
                          itemCount: _products.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                                child: const Icon(Icons.inventory, color: AppTheme.primaryGold),
                              ),
                              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(product.category.toString()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {/* تعديل */},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {/* حذف */},
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: UIConstants.paddingSmall),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // تعديل حساب الإحصائيات السريعة
  Widget buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'إجمالي المنتجات',
              _products.length.toString(),
              Icons.inventory,
              AppTheme.info,
            ),
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              'منخفض المخزون',
              _products.where((p) => p.stockQuantity <= p.minStockLevel).length.toString(),
              Icons.warning,
              AppTheme.warning,
            ),
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              'القيمة الإجمالية',
              '${_products.fold(0.0, (sum, p) => sum + (p.sellingPrice * p.stockQuantity)).toStringAsFixed(0)} ريال',
              Icons.attach_money,
              AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(FinishedProduct product) {
    final isLowStock = product.stockQuantity <= product.minStockLevel;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج (placeholder)
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.grey200,
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
              ),
              child: const Icon(
                Icons.image,
                size: 40,
                color: AppTheme.grey400,
              ),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            
            // اسم المنتج
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            
            // الفئة والعيار
            Row(
              children: [
                Icon(
                  _getCategoryIcon(product.category),
                  size: 16,
                  color: AppTheme.grey600,
                ),
                const SizedBox(width: 4),
                Text(
                  _getCategoryText(product.category),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'عيار ${_getGoldKaratText(product.goldKarat)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.primaryGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            
            // الوزن والسعر
            Text(
              'الوزن: ${product.weight.toStringAsFixed(1)} جم',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.grey600,
              ),
            ),
            Text(
              'السعر: ${product.sellingPrice.toStringAsFixed(0)} ريال',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            
            // الكمية
            Row(
              children: [
                Text(
                  'الكمية: ${product.stockQuantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLowStock ? AppTheme.error : AppTheme.grey600,
                    fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isLowStock) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.warning,
                    size: 16,
                    color: AppTheme.error,
                  ),
                ],
              ],
            ),
            const Spacer(),
            
            // أزرار العمليات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _showProductDetails(product),
                  icon: const Icon(Icons.visibility, size: 20),
                  tooltip: 'عرض',
                ),
                IconButton(
                  onPressed: () => _showEditProductDialog(product),
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  onPressed: () => _deleteProduct(product),
                  icon: const Icon(Icons.delete, size: 20, color: AppTheme.error),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for converting between GoldKarat and int and text
  int _goldKaratToInt(GoldKarat karat) {
    switch (karat) {
      case GoldKarat.k18:
        return 18;
      case GoldKarat.k21:
        return 21;
      case GoldKarat.k22:
        return 22;
      case GoldKarat.k24:
        return 24;
    }
    // Default fallback
    return 21;
  }

  GoldKarat _intToGoldKarat(int karat) {
    switch (karat) {
      case 18:
        return GoldKarat.k18;
      case 21:
        return GoldKarat.k21;
      case 22:
        return GoldKarat.k22;
      case 24:
        return GoldKarat.k24;
      default:
        return GoldKarat.k21;
    }
  }

  String _getGoldKaratText(GoldKarat karat) {
    switch (karat) {
      case GoldKarat.k18:
        return '18';
      case GoldKarat.k21:
        return '21';
      case GoldKarat.k22:
        return '22';
      case GoldKarat.k24:
        return '24';
    }
  }

  String _getCategoryText(ProductCategory category) {
    switch (category) {
      case ProductCategory.rings:
        return 'خواتم';
      case ProductCategory.necklaces:
        return 'قلائد';
      case ProductCategory.bracelets:
        return 'أساور';
      case ProductCategory.earrings:
        return 'أقراط';
      case ProductCategory.pendants:
        return 'دلايات';
      case ProductCategory.chains:
        return 'سلاسل';
      case ProductCategory.sets:
        return 'طقم';
      case ProductCategory.custom:
        return 'مخصص';
    }
  }

  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.rings:
        return Icons.radio_button_unchecked;
      case ProductCategory.necklaces:
        return Icons.circle_outlined;
      case ProductCategory.bracelets:
        return Icons.watch;
      case ProductCategory.earrings:
        return Icons.hearing;
      case ProductCategory.pendants:
        return Icons.favorite;
      case ProductCategory.chains:
        return Icons.link;
      case ProductCategory.sets:
        return Icons.inventory_2;
      case ProductCategory.custom:
        return Icons.more_horiz;
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(),
    ).then((result) {
      if (result == true) {
        _loadProducts();
      }
    });
  }

  void _showEditProductDialog(FinishedProduct product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(product: product),
    ).then((result) {
      if (result == true) {
        _loadProducts();
      }
    });
  }

  void _showProductDetails(FinishedProduct product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDetailsDialog(product: product),
    );
  }

  void _deleteProduct(FinishedProduct product) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('confirm_delete') ?? 'تأكيد الحذف'),
        content: Text(
          (localizations.translate('confirm_delete_product') ?? 'هل أنت متأكد من حذف المنتج') +
          ' "${product.name}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _products.removeWhere((p) => p.id == product.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(localizations.translate('product_deleted') ?? 'تم حذف المنتج بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final FinishedProduct? product;

  const _ProductDialog({this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goldWeightController = TextEditingController();
  final _stoneWeightController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  ProductCategory _selectedCategory = ProductCategory.rings;
  int _selectedKarat = 21;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final product = widget.product!;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _goldWeightController.text = product.goldWeight.toString();
      _stoneWeightController.text = product.stoneWeight.toString();
      _priceController.text = product.sellingPrice.toString();
      _quantityController.text = product.stockQuantity.toString();
      _minStockController.text = product.minStockLevel.toString();
      _barcodeController.text = product.barcode ?? '';
      _selectedCategory = product.category;
      _selectedKarat = _goldKaratToInt(product.goldKarat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.product == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المنتج';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ProductCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'الفئة',
                          border: OutlineInputBorder(),
                        ),
                        items: ProductCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryText(category)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          _selectedCategory = value!;
                        }),
                      ),
                    ),
                    const SizedBox(width: UIConstants.paddingMedium),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedKarat,
                        decoration: const InputDecoration(
                          labelText: 'العيار',
                          border: OutlineInputBorder(),
                        ),
                        items: [18, 21, 22, 24].map((karat) {
                          return DropdownMenuItem(
                            value: karat,
                            child: Text(localizations.translate('karat') + ' $karat'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          _selectedKarat = value!;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _goldWeightController,
                        decoration: const InputDecoration(
                          labelText: 'وزن الذهب (جم)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'رقم غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: UIConstants.paddingMedium),
                    Expanded(
                      child: TextFormField(
                        controller: _stoneWeightController,
                        decoration: const InputDecoration(
                          labelText: 'وزن الأحجار (جم)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                            return 'رقم غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'السعر (ريال)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'رقم غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: UIConstants.paddingMedium),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'الكمية',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'مطلوب';
                          }
                          if (int.tryParse(value) == null) {
                            return 'رقم غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minStockController,
                        decoration: const InputDecoration(
                          labelText: 'الحد الأدنى للمخزون',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'مطلوب';
                          }
                          if (int.tryParse(value) == null) {
                            return 'رقم غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: UIConstants.paddingMedium),
                    Expanded(
                      child: TextFormField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'الباركود',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel ?? 'إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          child: Text(widget.product == null ? 'إضافة' : 'حفظ'),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product == null ? 'تم إضافة المنتج بنجاح' : 'تم تحديث المنتج بنجاح'),
        ),
      );
    }
  }

  int _goldKaratToInt(GoldKarat karat) {
    switch (karat) {
      case GoldKarat.k18:
        return 18;
      case GoldKarat.k21:
        return 21;
      case GoldKarat.k22:
        return 22;
      case GoldKarat.k24:
        return 24;
    }
    return 21;
  }

  String _getCategoryText(ProductCategory category) {
    switch (category) {
      case ProductCategory.rings:
        return 'خواتم';
      case ProductCategory.necklaces:
        return 'قلائد';
      case ProductCategory.bracelets:
        return 'أساور';
      case ProductCategory.earrings:
        return 'أقراط';
      case ProductCategory.pendants:
        return 'دلايات';
      case ProductCategory.chains:
        return 'سلاسل';
      case ProductCategory.sets:
        return 'طقم';
      case ProductCategory.custom:
        return 'مخصص';
    }
  }

  String _getGoldKaratText(GoldKarat karat) {
    switch (karat) {
      case GoldKarat.k18:
        return '18';
      case GoldKarat.k21:
        return '21';
      case GoldKarat.k22:
        return '22';
      case GoldKarat.k24:
        return '24';
    }
  }
}

class _ProductDetailsDialog extends StatelessWidget {
  final FinishedProduct product;

  const _ProductDetailsDialog({required this.product});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text('${localizations.translate('product_details') ?? 'تفاصيل المنتج'}: ${product.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(localizations.translate('product_name') ?? 'الاسم', product.name),
            _buildDetailRow(localizations.translate('description') ?? 'الوصف', product.description),
            _buildDetailRow(localizations.translate('category') ?? 'الفئة', _getCategoryText(product.category)),
            _buildDetailRow(localizations.translate('karat') ?? 'العيار', '${localizations.translate('karat') ?? 'عيار'} ${_getGoldKaratText(product.goldKarat)}'),
            _buildDetailRow(localizations.translate('gold_weight') ?? 'وزن الذهب', '${product.goldWeight.toStringAsFixed(1)} ${localizations.gram}'),
            _buildDetailRow(localizations.translate('stone_weight') ?? 'وزن الأحجار', '${product.stoneWeight.toStringAsFixed(1)} ${localizations.gram}'),
            _buildDetailRow(localizations.translate('total_weight') ?? 'الوزن الإجمالي', '${product.weight.toStringAsFixed(1)} ${localizations.gram}'),
            _buildDetailRow(localizations.translate('price') ?? 'السعر', '${product.sellingPrice.toStringAsFixed(2)} ${localizations.currency}'),
            _buildDetailRow(localizations.translate('quantity') ?? 'الكمية المتاحة', product.stockQuantity.toString()),
            _buildDetailRow(localizations.translate('min_stock_level') ?? 'الحد الأدنى للمخزون', product.minStockLevel.toString()),
            _buildDetailRow(localizations.translate('barcode') ?? 'الباركود', product.barcode ?? ''),
            _buildDetailRow(localizations.translate('creation_date') ?? 'تاريخ الإضافة', _formatDate(product.createdDate)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.close),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getCategoryText(ProductCategory category) {
    switch (category) {
      case ProductCategory.rings:
        return 'خواتم';
      case ProductCategory.necklaces:
        return 'قلائد';
      case ProductCategory.bracelets:
        return 'أساور';
      case ProductCategory.earrings:
        return 'أقراط';
      case ProductCategory.pendants:
        return 'دلايات';
      case ProductCategory.chains:
        return 'سلاسل';
      case ProductCategory.sets:
        return 'طقم';
      case ProductCategory.custom:
        return 'مخصص';
    }
  }

  String _getGoldKaratText(GoldKarat karat) {
    switch (karat) {
      case GoldKarat.k18:
        return '18';
      case GoldKarat.k21:
        return '21';
      case GoldKarat.k22:
        return '22';
      case GoldKarat.k24:
        return '24';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

