import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/gold_item_model.dart';
import '../hardware/weight_scale_widget.dart';
import '../hardware/barcode_scanner_widget.dart';
import '../gold_price/gold_price_widget.dart';

class GoldItemFormScreen extends ConsumerStatefulWidget {
  final GoldItemModel? existingItem;
  
  const GoldItemFormScreen({
    Key? key,
    this.existingItem,
  }) : super(key: key);

  @override
  ConsumerState<GoldItemFormScreen> createState() => _GoldItemFormScreenState();
}

class _GoldItemFormScreenState extends ConsumerState<GoldItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  String _selectedKarat = '21K';
  String _selectedCategory = 'خواتم';
  GoldType _selectedType = GoldType.manufactured;
  GoldItemStatus _selectedStatus = GoldItemStatus.inStock;

  final List<String> _karatOptions = ['18K', '21K', '22K', '24K'];
  final List<String> _categoryOptions = [
    'خواتم',
    'أساور',
    'قلائد',
    'حلق',
    'دبل',
    'مجوهرات أخرى',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _populateFormWithExistingItem();
    }
  }

  void _populateFormWithExistingItem() {
    final item = widget.existingItem!;
    _nameController.text = item.name;
    _descriptionController.text = item.description;
    _weightController.text = item.weight.toString();
    _costPriceController.text = item.costPrice.toString();
    _sellingPriceController.text = item.sellingPrice.toString();
    _barcodeController.text = item.barcode ?? '';
    _selectedKarat = item.karat;
    _selectedCategory = item.category;
    _selectedType = item.type;
    _selectedStatus = item.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingItem != null ? 'تعديل صنف ذهبي' : 'إضافة صنف ذهبي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          children: [
            // نموذج البيانات الأساسية
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingMedium),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'البيانات الأساسية',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // اسم الصنف
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم الصنف',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال اسم الصنف';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // الوصف
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'الوصف',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // نوع الذهب والعيار والفئة
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<GoldType>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'نوع الذهب',
                                border: OutlineInputBorder(),
                              ),
                              items: GoldType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getGoldTypeLabel(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: UIConstants.paddingMedium),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedKarat,
                              decoration: const InputDecoration(
                                labelText: 'العيار',
                                border: OutlineInputBorder(),
                              ),
                              items: _karatOptions.map((karat) {
                                return DropdownMenuItem(
                                  value: karat,
                                  child: Text(karat),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedKarat = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // الفئة والحالة
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'الفئة',
                                border: OutlineInputBorder(),
                              ),
                              items: _categoryOptions.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: UIConstants.paddingMedium),
                          Expanded(
                            child: DropdownButtonFormField<GoldItemStatus>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'الحالة',
                                border: OutlineInputBorder(),
                              ),
                              items: GoldItemStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(_getStatusLabel(status)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // الوزن والأسعار
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: 'الوزن (جرام)',
                                border: OutlineInputBorder(),
                                suffixText: 'جرام',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال الوزن';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'يرجى إدخال رقم صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: UIConstants.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _costPriceController,
                              decoration: const InputDecoration(
                                labelText: 'سعر التكلفة',
                                border: OutlineInputBorder(),
                                suffixText: 'ر.س',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال سعر التكلفة';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'يرجى إدخال رقم صحيح';
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
                              controller: _sellingPriceController,
                              decoration: const InputDecoration(
                                labelText: 'سعر البيع',
                                border: OutlineInputBorder(),
                                suffixText: 'ر.س',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال سعر البيع';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'يرجى إدخال رقم صحيح';
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
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: UIConstants.paddingMedium),
            
            // أدوات الأجهزة
            Row(
              children: [
                Expanded(
                  child: WeightScaleWidget(
                    onWeightChanged: (weight) {
                      _weightController.text = weight.toStringAsFixed(3);
                    },
                  ),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                Expanded(
                  child: BarcodeScannerWidget(
                    onBarcodeScanned: (barcode) {
                      _barcodeController.text = barcode;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: UIConstants.paddingMedium),
            
            // عرض أسعار الذهب
            const GoldPriceWidget(),
            
            const SizedBox(height: UIConstants.paddingLarge),
            
            // أزرار الحفظ والإلغاء
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                    ),
                    child: const Text('حفظ'),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGoldTypeLabel(GoldType type) {
    switch (type) {
      case GoldType.raw:
        return 'خام';
      case GoldType.manufactured:
        return 'مصنع';
      case GoldType.used:
        return 'مستعمل';
      case GoldType.repair:
        return 'للإصلاح';
    }
  }

  String _getStatusLabel(GoldItemStatus status) {
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

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      // هنا يمكن إضافة منطق حفظ البيانات
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ البيانات بنجاح'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }
}

