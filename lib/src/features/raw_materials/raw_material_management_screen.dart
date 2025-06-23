import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/raw_material_model.dart';
import '../../core/models/client_model.dart';
import '../../services/database/postgresql_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';

class RawMaterialManagementScreen extends ConsumerStatefulWidget {
  const RawMaterialManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RawMaterialManagementScreen> createState() => _RawMaterialManagementScreenState();
}

class _RawMaterialManagementScreenState extends ConsumerState<RawMaterialManagementScreen> {
  final _searchController = TextEditingController();
  List<RawMaterial> _rawMaterials = [];
  List<RawMaterial> _filteredRawMaterials = [];
  List<Client> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rawMaterials = await PostgreSQLService.instance.getAllRawMaterials();
      final clients = await PostgreSQLService.instance.getAllClients();
      
      setState(() {
        _rawMaterials = rawMaterials;
        _filteredRawMaterials = rawMaterials;
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
    }
  }

  void _filterRawMaterials(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      _selectedStatus = status;
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = _rawMaterials.where((material) {
      final matchesSearch = _searchQuery.isEmpty ||
          material.lotBatchNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (material.clientName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          material.materialType.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _selectedStatus == 'all' || material.status == _selectedStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();

    setState(() {
      _filteredRawMaterials = filtered;
    });
  }

  void _showAddRawMaterialDialog() {
    showDialog(
      context: context,
      builder: (context) => AddRawMaterialDialog(
        clients: _clients,
        onSave: (rawMaterial) async {
          try {
            await PostgreSQLService.instance.insertRawMaterial(rawMaterial, 'current_user_id');
            _loadData();
            _showSuccessSnackBar('تم إضافة المادة الخام بنجاح');
          } catch (e) {
            _showErrorSnackBar('خطأ في إضافة المادة الخام: $e');
          }
        },
      ),
    );
  }

  void _showRawMaterialDetails(RawMaterial rawMaterial) {
    showDialog(
      context: context,
      builder: (context) => RawMaterialDetailsDialog(rawMaterial: rawMaterial),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('إدارة المواد الخام', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          hintText: 'بحث عن مادة خام...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _filteredRawMaterials = _rawMaterials.where((c) => c.materialType.contains(value)).toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {/* إضافة مادة خام */},
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة مادة خام'),
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
                          itemCount: _filteredRawMaterials.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _filteredRawMaterials[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                                child: const Icon(Icons.widgets, color: AppTheme.primaryGold),
                              ),
                              title: Text(item.materialType, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item.status),
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

  Widget _buildSearchAndFilters(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Column(
        children: [
          // شريط البحث
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: localizations.translate('search_raw_materials') ?? 'البحث في المواد الخام',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: _filterRawMaterials,
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          // فلتر الحالة
          Row(
            children: [
              Text(localizations.translate('status') ?? 'الحالة: '),
              const SizedBox(width: UIConstants.paddingSmall),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(localizations.translate('all') ?? 'جميع الحالات')),
                    DropdownMenuItem(value: 'available', child: Text(localizations.translate('available') ?? 'متاح')),
                    DropdownMenuItem(value: 'assigned', child: Text(localizations.translate('assigned') ?? 'مخصص')),
                    DropdownMenuItem(value: 'consumed', child: Text(localizations.translate('consumed') ?? 'مستهلك')),
                  ],
                  onChanged: (value) {
                    if (value != null) _filterByStatus(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalWeight = _rawMaterials.fold<double>(0, (sum, material) => sum + material.weight);
    final availableWeight = _rawMaterials
        .where((m) => m.status == 'available')
        .fold<double>(0, (sum, material) => sum + material.weight);
    final assignedWeight = _rawMaterials
        .where((m) => m.status == 'assigned')
        .fold<double>(0, (sum, material) => sum + material.weight);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConstants.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'إجمالي الوزن',
              value: '${totalWeight.toStringAsFixed(3)} جرام',
              icon: Icons.scale,
              color: AppTheme.primaryGold,
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: _buildStatCard(
              title: 'المتاح',
              value: '${availableWeight.toStringAsFixed(3)} جرام',
              icon: Icons.check_circle,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: _buildStatCard(
              title: 'المخصص',
              value: '${assignedWeight.toStringAsFixed(3)} جرام',
              icon: Icons.assignment,
              color: AppTheme.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingSmall),
        child: Column(
          children: [
            Icon(icon, color: color, size: UIConstants.iconSizeMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppTheme.grey400,
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          Text(
            _searchQuery.isEmpty ? (localizations.translate('no_raw_materials') ?? 'لا توجد مواد خام مسجلة') : (localizations.translate('no_results') ?? 'لا توجد نتائج للبحث'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: _showAddRawMaterialDialog,
              icon: const Icon(Icons.add),
              label: Text(localizations.translate('add_new_raw_material') ?? 'إضافة مادة خام جديدة'),
            ),
        ],
      ),
    );
  }

  Widget _buildRawMaterialsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      itemCount: _filteredRawMaterials.length,
      itemBuilder: (context, index) {
        final rawMaterial = _filteredRawMaterials[index];
        return _buildRawMaterialCard(rawMaterial);
      },
    );
  }

  Widget _buildRawMaterialCard(RawMaterial rawMaterial) {
    Color statusColor;
    String statusText;
    
    switch (rawMaterial.status) {
      case 'available':
        statusColor = AppTheme.success;
        statusText = 'متاح';
        break;
      case 'assigned':
        statusColor = AppTheme.warning;
        statusText = 'مخصص';
        break;
      case 'consumed':
        statusColor = AppTheme.grey600;
        statusText = 'مستهلك';
        break;
      default:
        statusColor = AppTheme.grey400;
        statusText = rawMaterial.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.paddingSmall),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2,
            color: statusColor,
            size: UIConstants.iconSizeMedium,
          ),
        ),
        title: Text(
          'رقم الدفعة: ${rawMaterial.lotBatchNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('العميل: ${rawMaterial.clientName ?? 'غير محدد'}'),
            Text('النوع: ${rawMaterial.materialType} - العيار: ${rawMaterial.karat}'),
            Text('الوزن: ${rawMaterial.weight.toStringAsFixed(3)} جرام'),
            Text('تاريخ الاستلام: ${rawMaterial.intakeDate.toString().split(' ')[0]}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showRawMaterialDetails(rawMaterial);
                    break;
                  case 'assign':
                    // TODO: Navigate to work order creation
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('عرض التفاصيل'),
                  ),
                ),
                if (rawMaterial.isAvailable)
                  const PopupMenuItem(
                    value: 'assign',
                    child: ListTile(
                      leading: Icon(Icons.assignment_add),
                      title: Text('إنشاء أمر عمل'),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _showRawMaterialDetails(rawMaterial),
      ),
    );
  }
}

// حوار إضافة مادة خام جديدة
class AddRawMaterialDialog extends StatefulWidget {
  final List<Client> clients;
  final Function(RawMaterial) onSave;

  const AddRawMaterialDialog({
    Key? key,
    required this.clients,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddRawMaterialDialog> createState() => _AddRawMaterialDialogState();
}

class _AddRawMaterialDialogState extends State<AddRawMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _purityController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedClientId;
  String _selectedMaterialType = 'Scrap';
  String _selectedKarat = '21K';
  DateTime _intakeDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _purityController.dispose();
    _estimatedValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _generateLotBatchNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'LOT${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }

  void _saveRawMaterial() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار العميل')),
      );
      return;
    }

    final rawMaterial = RawMaterial(
      id: 'rm_${DateTime.now().millisecondsSinceEpoch}',
      clientId: _selectedClientId!,
      intakeDate: _intakeDate,
      materialType: _selectedMaterialType,
      karat: _selectedKarat,
      weight: double.parse(_weightController.text),
      lotBatchNumber: _generateLotBatchNumber(),
      purityPercentage: _purityController.text.isNotEmpty 
          ? double.parse(_purityController.text) 
          : null,
      estimatedValue: _estimatedValueController.text.isNotEmpty 
          ? double.parse(_estimatedValueController.text) 
          : null,
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
      createdBy: 'current_user', // TODO: Get from auth service
      createdAt: DateTime.now(),
    );

    widget.onSave(rawMaterial);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('add_new_raw_material') ?? 'إضافة مادة خام جديدة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UIConstants.paddingLarge),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // اختيار العميل
                      DropdownButtonFormField<String>(
                        value: _selectedClientId,
                        decoration: const InputDecoration(
                          labelText: 'العميل *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: widget.clients.map((client) {
                          return DropdownMenuItem(
                            value: client.id,
                            child: Text(client.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClientId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'يرجى اختيار العميل';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // نوع المادة
                      DropdownButtonFormField<String>(
                        value: _selectedMaterialType,
                        decoration: const InputDecoration(
                          labelText: 'نوع المادة *',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Scrap', child: Text('خردة')),
                          DropdownMenuItem(value: 'Bullion', child: Text('سبائك')),
                          DropdownMenuItem(value: 'Coins', child: Text('عملات')),
                          DropdownMenuItem(value: 'Jewelry', child: Text('مجوهرات')),
                          DropdownMenuItem(value: 'Other', child: Text('أخرى')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMaterialType = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // العيار
                      DropdownButtonFormField<String>(
                        value: _selectedKarat,
                        decoration: const InputDecoration(
                          labelText: 'العيار *',
                          prefixIcon: Icon(Icons.star),
                        ),
                        items: const [
                          DropdownMenuItem(value: '24K', child: Text('24 قيراط')),
                          DropdownMenuItem(value: '22K', child: Text('22 قيراط')),
                          DropdownMenuItem(value: '21K', child: Text('21 قيراط')),
                          DropdownMenuItem(value: '18K', child: Text('18 قيراط')),
                          DropdownMenuItem(value: '14K', child: Text('14 قيراط')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedKarat = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // الوزن
                      TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'الوزن (جرام) *',
                          prefixIcon: Icon(Icons.scale),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال الوزن';
                          }
                          if (double.tryParse(value) == null) {
                            return 'يرجى إدخال رقم صحيح';
                          }
                          if (double.parse(value) <= 0) {
                            return 'يجب أن يكون الوزن أكبر من صفر';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // نسبة النقاء
                      TextFormField(
                        controller: _purityController,
                        decoration: const InputDecoration(
                          labelText: 'نسبة النقاء (%)',
                          prefixIcon: Icon(Icons.percent),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final purity = double.tryParse(value);
                            if (purity == null) {
                              return 'يرجى إدخال رقم صحيح';
                            }
                            if (purity < 0 || purity > 100) {
                              return 'يجب أن تكون النسبة بين 0 و 100';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // القيمة المقدرة
                      TextFormField(
                        controller: _estimatedValueController,
                        decoration: const InputDecoration(
                          labelText: 'القيمة المقدرة (ريال)',
                          prefixIcon: Icon(Icons.monetization_on),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'يرجى إدخال رقم صحيح';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // تاريخ الاستلام
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('تاريخ الاستلام'),
                        subtitle: Text(_intakeDate.toString().split(' ')[0]),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _intakeDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _intakeDate = date;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // الملاحظات
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'ملاحظات',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: UIConstants.paddingLarge),
              
              // أزرار الحفظ والإلغاء
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: UIConstants.paddingSmall),
                  ElevatedButton(
                    onPressed: _saveRawMaterial,
                    child: const Text('إضافة'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// حوار عرض تفاصيل المادة الخام
class RawMaterialDetailsDialog extends StatelessWidget {
  final RawMaterial rawMaterial;

  const RawMaterialDetailsDialog({
    Key? key,
    required this.rawMaterial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: AppTheme.primaryGold,
                    size: 30,
                  ),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رقم الدفعة: ${rawMaterial.lotBatchNumber}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        rawMaterial.materialType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: UIConstants.paddingLarge),
            
            // معلومات أساسية
            _buildInfoSection(
              context,
              localizations.translate('basic_info') ?? 'المعلومات الأساسية',
              [
                _buildInfoRow(localizations.translate('client') ?? 'العميل', rawMaterial.clientName ?? 'غير محدد'),
                _buildInfoRow(localizations.translate('material_type') ?? 'نوع المادة', rawMaterial.materialType),
                _buildInfoRow(localizations.translate('karat') ?? 'العيار', rawMaterial.karat),
                _buildInfoRow(localizations.translate('weight') ?? 'الوزن', '${rawMaterial.weight.toStringAsFixed(3)} جرام'),
                _buildInfoRow(localizations.translate('status') ?? 'الحالة', _getStatusText(rawMaterial.status)),
              ],
            ),
            
            const SizedBox(height: UIConstants.paddingMedium),
            
            // معلومات إضافية
            _buildInfoSection(
              context,
              localizations.translate('additional_info') ?? 'معلومات إضافية',
              [
                _buildInfoRow(localizations.translate('intake_date') ?? 'تاريخ الاستلام', rawMaterial.intakeDate.toString().split(' ')[0]),
                if (rawMaterial.purityPercentage != null)
                  _buildInfoRow(localizations.translate('purity_percentage') ?? 'نسبة النقاء', '${rawMaterial.purityPercentage!.toStringAsFixed(2)}%'),
                if (rawMaterial.estimatedValue != null)
                  _buildInfoRow(localizations.translate('estimated_value') ?? 'القيمة المقدرة', '${rawMaterial.estimatedValue!.toStringAsFixed(2)} ريال'),
                _buildInfoRow(localizations.translate('created_at') ?? 'تاريخ الإدخال', rawMaterial.createdAt.toString().split(' ')[0]),
                if (rawMaterial.createdByName != null)
                  _buildInfoRow(localizations.translate('created_by') ?? 'أدخل بواسطة', rawMaterial.createdByName!),
              ],
            ),
            
            if (rawMaterial.notes != null) ...[
              const SizedBox(height: UIConstants.paddingMedium),
              _buildInfoSection(
                context,
                localizations.translate('notes') ?? 'ملاحظات',
                [
                  Text(rawMaterial.notes!),
                ],
              ),
            ],
            
            const SizedBox(height: UIConstants.paddingLarge),
            
            // زر الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGold,
          ),
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.grey600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'متاح';
      case 'assigned':
        return 'مخصص';
      case 'consumed':
        return 'مستهلك';
      default:
        return status;
    }
  }
}

