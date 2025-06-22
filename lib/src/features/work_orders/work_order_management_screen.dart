import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../work_orders/models/work_order.dart';
import '../work_orders/services/work_order_service.dart';

class WorkOrderManagementScreen extends ConsumerStatefulWidget {
  const WorkOrderManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkOrderManagementScreen> createState() => _WorkOrderManagementScreenState();
}

class _WorkOrderManagementScreenState extends ConsumerState<WorkOrderManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  WorkOrderStatus? _selectedStatus;
  WorkOrderType? _selectedType;
  List<WorkOrder> _workOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkOrders();
  }

  Future<void> _loadWorkOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final workOrderService = ref.read(workOrderServiceProvider);
      final orders = await workOrderService.getAllWorkOrders();
      setState(() {
        _workOrders = orders;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل أوامر العمل: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<WorkOrder> get _filteredWorkOrders {
    return _workOrders.where((order) {
      final matchesSearch = _searchController.text.isEmpty ||
          order.orderNumber.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          order.clientName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          order.description.toLowerCase().contains(_searchController.text.toLowerCase());
      
      final matchesStatus = _selectedStatus == null || order.status == _selectedStatus;
      final matchesType = _selectedType == null || order.type == _selectedType;
      
      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة أوامر العمل'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkOrders,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWorkOrderDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والفلاتر
          Container(
            padding: const EdgeInsets.all(UIConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // شريط البحث
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'البحث في أوامر العمل...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                // الفلاتر
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<WorkOrderStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'الحالة',
                          border: OutlineInputBorder(),
                        ),
                        items: WorkOrderStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusText(status)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          _selectedStatus = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: UIConstants.paddingMedium),
                    Expanded(
                      child: DropdownButtonFormField<WorkOrderType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'النوع',
                          border: OutlineInputBorder(),
                        ),
                        items: WorkOrderType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getTypeText(type)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          _selectedType = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: UIConstants.paddingMedium),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _selectedStatus = null;
                        _selectedType = null;
                        _searchController.clear();
                      }),
                      child: const Text('مسح الفلاتر'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // قائمة أوامر العمل
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredWorkOrders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off,
                              size: 80,
                              color: AppTheme.grey400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد أوامر عمل',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.grey600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(UIConstants.paddingMedium),
                        itemCount: _filteredWorkOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredWorkOrders[index];
                          return _buildWorkOrderCard(order);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderCard(WorkOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أمر رقم: ${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'العميل: ${order.clientName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            
            Text(
              order.description,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            
            Row(
              children: [
                Icon(
                  _getTypeIcon(order.type),
                  size: 16,
                  color: AppTheme.grey600,
                ),
                const SizedBox(width: 4),
                Text(
                  _getTypeText(order.type),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
                const Spacer(),
                Text(
                  'التكلفة: ${order.estimatedCost.toStringAsFixed(2)} ريال',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            
            Row(
              children: [
                Text(
                  'تاريخ الإنشاء: ${_formatDate(order.createdDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
                const Spacer(),
                Text(
                  'الموعد المتوقع: '
                  '${order.expectedCompletionDate != null ? _formatDate(order.expectedCompletionDate!) : 'غير محدد'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showWorkOrderDetails(order),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('عرض'),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                TextButton.icon(
                  onPressed: () => _showEditWorkOrderDialog(order),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('تعديل'),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                TextButton.icon(
                  onPressed: () => _deleteWorkOrder(order),
                  icon: const Icon(Icons.delete, size: 16, color: AppTheme.error),
                  label: const Text('حذف', style: TextStyle(color: AppTheme.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(WorkOrderStatus status) {
    Color color;
    switch (status) {
      case WorkOrderStatus.pending:
        color = AppTheme.warning;
        break;
      case WorkOrderStatus.inProgress:
        color = AppTheme.info;
        break;
      case WorkOrderStatus.completed:
        color = AppTheme.success;
        break;
      case WorkOrderStatus.cancelled:
        color = AppTheme.error;
        break;
      case WorkOrderStatus.delayed:
        color = AppTheme.grey500;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusText(WorkOrderStatus status) {
    switch (status) {
      case WorkOrderStatus.pending:
        return 'معلق';
      case WorkOrderStatus.inProgress:
        return 'قيد التنفيذ';
      case WorkOrderStatus.completed:
        return 'مكتمل';
      case WorkOrderStatus.cancelled:
        return 'ملغي';
      case WorkOrderStatus.delayed:
        return 'متأخر';
    }
  }

  String _getTypeText(WorkOrderType type) {
    switch (type) {
      case WorkOrderType.manufacturing:
        return 'تصنيع';
      case WorkOrderType.repair:
        return 'إصلاح';
      case WorkOrderType.polishing:
        return 'تلميع';
      case WorkOrderType.custom:
        return 'مخصص';
    }
  }

  IconData _getTypeIcon(WorkOrderType type) {
    switch (type) {
      case WorkOrderType.manufacturing:
        return Icons.build;
      case WorkOrderType.repair:
        return Icons.build_circle;
      case WorkOrderType.polishing:
        return Icons.auto_fix_high;
      case WorkOrderType.custom:
        return Icons.star;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddWorkOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => _WorkOrderDialog(),
    ).then((result) {
      if (result == true) {
        _loadWorkOrders();
      }
    });
  }

  void _showEditWorkOrderDialog(WorkOrder order) {
    showDialog(
      context: context,
      builder: (context) => _WorkOrderDialog(workOrder: order),
    ).then((result) {
      if (result == true) {
        _loadWorkOrders();
      }
    });
  }

  void _showWorkOrderDetails(WorkOrder order) {
    showDialog(
      context: context,
      builder: (context) => _WorkOrderDetailsDialog(workOrder: order),
    );
  }

  void _deleteWorkOrder(WorkOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف أمر العمل رقم ${order.orderNumber}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final workOrderService = ref.read(workOrderServiceProvider);
                await workOrderService.deleteWorkOrder(order.id);
                _loadWorkOrders();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف أمر العمل بنجاح')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في حذف أمر العمل: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _WorkOrderDialog extends ConsumerStatefulWidget {
  final WorkOrder? workOrder;

  const _WorkOrderDialog({this.workOrder});

  @override
  ConsumerState<_WorkOrderDialog> createState() => _WorkOrderDialogState();
}

class _WorkOrderDialogState extends ConsumerState<_WorkOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final _notesController = TextEditingController();
  
  WorkOrderType _selectedType = WorkOrderType.manufacturing;
  WorkOrderStatus _selectedStatus = WorkOrderStatus.pending;
  WorkOrderPriority _selectedPriority = WorkOrderPriority.medium;
  DateTime _expectedCompletionDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    if (widget.workOrder != null) {
      final order = widget.workOrder!;
      _clientNameController.text = order.clientName;
      _descriptionController.text = order.description;
      _estimatedCostController.text = order.estimatedCost.toString();
      _notesController.text = order.notes ?? '';
      _selectedType = order.type;
      _selectedStatus = order.status;
      _selectedPriority = order.priority;
      _expectedCompletionDate = order.expectedCompletionDate ?? DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.workOrder == null ? 'إضافة أمر عمل جديد' : 'تعديل أمر العمل'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم العميل',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم العميل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                DropdownButtonFormField<WorkOrderType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'نوع العمل',
                    border: OutlineInputBorder(),
                  ),
                  items: WorkOrderType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _selectedType = value!;
                  }),
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'وصف العمل',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال وصف العمل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                TextFormField(
                  controller: _estimatedCostController,
                  decoration: const InputDecoration(
                    labelText: 'التكلفة المقدرة (ريال)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال التكلفة المقدرة';
                    }
                    if (double.tryParse(value) == null) {
                      return 'يرجى إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                DropdownButtonFormField<WorkOrderPriority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'الأولوية',
                    border: OutlineInputBorder(),
                  ),
                  items: WorkOrderPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(_getPriorityText(priority)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _selectedPriority = value!;
                  }),
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                
                if (widget.workOrder != null)
                  DropdownButtonFormField<WorkOrderStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'الحالة',
                      border: OutlineInputBorder(),
                    ),
                    items: WorkOrderStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusText(status)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      _selectedStatus = value!;
                    }),
                  ),
                if (widget.workOrder != null)
                  const SizedBox(height: UIConstants.paddingMedium),
                
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveWorkOrder,
          child: Text(widget.workOrder == null ? 'إضافة' : 'حفظ'),
        ),
      ],
    );
  }

  void _saveWorkOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        final workOrderService = ref.read(workOrderServiceProvider);
        
        if (widget.workOrder == null) {
          // إضافة أمر عمل جديد
          final newOrder = WorkOrder(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            orderNumber: 'WO- {DateTime.now().millisecondsSinceEpoch}',
            clientId: '', // أضف clientId المناسب إذا كان متوفرًا
            clientName: _clientNameController.text,
            type: _selectedType,
            description: _descriptionController.text,
            status: WorkOrderStatus.pending,
            priority: _selectedPriority,
            estimatedCost: double.parse(_estimatedCostController.text),
            createdDate: DateTime.now(),
            expectedCompletionDate: _expectedCompletionDate,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            startDate: null,
            actualCompletionDate: null,
            actualCost: 0.0,
            laborCost: 0.0,
            materialCost: 0.0,
            additionalCost: 0.0,
            assignedCraftsman: null,
            attachments: const [],
            items: const [],
            customFields: const {},
          );
          
          await workOrderService.createWorkOrder(newOrder);
        } else {
          // تعديل أمر عمل موجود
          final updatedOrder = widget.workOrder!.copyWith(
            clientName: _clientNameController.text,
            type: _selectedType,
            description: _descriptionController.text,
            status: _selectedStatus,
            priority: _selectedPriority,
            estimatedCost: double.parse(_estimatedCostController.text),
            expectedCompletionDate: _expectedCompletionDate,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            // لا يوجد updatedAt في WorkOrder، تجاهلها
          );
          
          await workOrderService.updateWorkOrder(updatedOrder);
        }
        
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ أمر العمل: $e')),
        );
      }
    }
  }

  String _getTypeText(WorkOrderType type) {
    switch (type) {
      case WorkOrderType.manufacturing:
        return 'تصنيع';
      case WorkOrderType.repair:
        return 'إصلاح';
      case WorkOrderType.polishing:
        return 'تلميع';
      case WorkOrderType.custom:
        return 'مخصص';
    }
  }

  String _getStatusText(WorkOrderStatus status) {
    switch (status) {
      case WorkOrderStatus.pending:
        return 'معلق';
      case WorkOrderStatus.inProgress:
        return 'قيد التنفيذ';
      case WorkOrderStatus.completed:
        return 'مكتمل';
      case WorkOrderStatus.cancelled:
        return 'ملغي';
      case WorkOrderStatus.delayed:
        return 'متأخر';
    }
  }

  String _getPriorityText(WorkOrderPriority priority) {
    switch (priority) {
      case WorkOrderPriority.low:
        return 'منخفضة';
      case WorkOrderPriority.medium:
        return 'متوسطة';
      case WorkOrderPriority.high:
        return 'عالية';
      case WorkOrderPriority.urgent:
        return 'عاجلة';
    }
  }
}

class _WorkOrderDetailsDialog extends StatelessWidget {
  final WorkOrder workOrder;

  const _WorkOrderDetailsDialog({required this.workOrder});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تفاصيل أمر العمل ${workOrder.orderNumber}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('العميل', workOrder.clientName),
            _buildDetailRow('النوع', _getTypeText(workOrder.type)),
            _buildDetailRow('الحالة', _getStatusText(workOrder.status)),
            _buildDetailRow('الأولوية', _getPriorityText(workOrder.priority)),
            _buildDetailRow('التكلفة المقدرة', '${workOrder.estimatedCost.toStringAsFixed(2)} ريال'),
            _buildDetailRow('تاريخ الإنشاء', _formatDate(workOrder.createdDate)),
            _buildDetailRow('الموعد المتوقع', workOrder.expectedCompletionDate != null ? _formatDate(workOrder.expectedCompletionDate!) : 'غير محدد'),
            if (workOrder.actualCompletionDate != null)
              _buildDetailRow('تاريخ الإنجاز', _formatDate(workOrder.actualCompletionDate!)),
            const SizedBox(height: UIConstants.paddingMedium),
            const Text(
              'وصف العمل:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            Text(workOrder.description),
            if (workOrder.notes != null) ...[
              const SizedBox(height: UIConstants.paddingMedium),
              const Text(
                'ملاحظات:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: UIConstants.paddingSmall),
              Text(workOrder.notes!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
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

  String _getTypeText(WorkOrderType type) {
    switch (type) {
      case WorkOrderType.manufacturing:
        return 'تصنيع';
      case WorkOrderType.repair:
        return 'إصلاح';
      case WorkOrderType.polishing:
        return 'تلميع';
      case WorkOrderType.custom:
        return 'مخصص';
    }
  }

  String _getStatusText(WorkOrderStatus status) {
    switch (status) {
      case WorkOrderStatus.pending:
        return 'معلق';
      case WorkOrderStatus.inProgress:
        return 'قيد التنفيذ';
      case WorkOrderStatus.completed:
        return 'مكتمل';
      case WorkOrderStatus.cancelled:
        return 'ملغي';
      case WorkOrderStatus.delayed:
        return 'متأخر';
    }
  }

  String _getPriorityText(WorkOrderPriority priority) {
    switch (priority) {
      case WorkOrderPriority.low:
        return 'منخفضة';
      case WorkOrderPriority.medium:
        return 'متوسطة';
      case WorkOrderPriority.high:
        return 'عالية';
      case WorkOrderPriority.urgent:
        return 'عاجلة';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

