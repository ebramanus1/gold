import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedReportType = 'sales';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;

  Map<String, String> _getReportTypes(AppLocalizations localizations) {
    return {
      'sales': localizations.translate('report_sales') ?? 'تقرير المبيعات',
      'inventory': localizations.translate('report_inventory') ?? 'تقرير المخزون',
      'workOrders': localizations.translate('report_work_orders') ?? 'تقرير أوامر العمل',
      'financial': localizations.translate('report_financial') ?? 'التقرير المالي',
      'goldMovement': localizations.translate('report_gold_movement') ?? 'تقرير حركة الذهب',
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    final isArabic = currentLocale.languageCode == 'ar';
    final reportTypes = _getReportTypes(localizations);
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(localizations.reports, style: const TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.all(UIConstants.paddingXXLarge),
              children: [
                Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                              child: const Icon(Icons.insert_chart, color: AppTheme.primaryGold),
                            ),
                            const SizedBox(width: 12),
                            Text(localizations.reports, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          value: _selectedReportType,
                          decoration: InputDecoration(
                            labelText: localizations.translate('select_report_type') ?? 'اختر نوع التقرير',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          items: reportTypes.entries.map((entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedReportType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: localizations.translate('start_date') ?? 'تاريخ البداية',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                controller: TextEditingController(text: _startDate.toString().split(' ')[0]),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _startDate = picked;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: localizations.translate('end_date') ?? 'تاريخ النهاية',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                controller: TextEditingController(text: _endDate.toString().split(' ')[0]),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _endDate = picked;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isGenerating ? null : () {/* تنفيذ توليد التقرير */},
                            icon: const Icon(Icons.analytics),
                            label: Text(localizations.translate('generate_report') ?? 'توليد التقرير'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ... يمكن إضافة عرض النتائج هنا ...
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
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
                fontSize: 14,
                color: AppTheme.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    final localizations = AppLocalizations.of(context)!;
    switch (_selectedReportType) {
      case 'sales':
        return _buildSalesReport();
      case 'inventory':
        return _buildInventoryReport();
      case 'workOrders':
        return _buildWorkOrdersReport();
      case 'financial':
        return _buildFinancialReport();
      case 'goldMovement':
        return _buildGoldMovementReport();
      default:
        return Center(child: Text(localizations.translate('select_report_type') ?? 'اختر نوع التقرير'));
    }
  }

  Widget _buildSalesReport() {
    final localizations = AppLocalizations.of(context)!;
    final salesData = [
      {'date': '2024-01-15', 'customer': 'أحمد محمد', 'amount': 2500.0, 'items': 3},
      {'date': '2024-01-16', 'customer': 'فاطمة علي', 'amount': 1800.0, 'items': 2},
      {'date': '2024-01-17', 'customer': 'محمد سالم', 'amount': 3200.0, 'items': 1},
      {'date': '2024-01-18', 'customer': 'نورا أحمد', 'amount': 1500.0, 'items': 4},
    ];

    return SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: Text(localizations.translate('date') ?? 'التاريخ')),
          DataColumn(label: Text(localizations.translate('customer') ?? 'العميل')),
          DataColumn(label: Text(localizations.translate('amount') ?? 'المبلغ')),
          DataColumn(label: Text(localizations.translate('items_count') ?? 'عدد القطع')),
        ],
        rows: salesData.map((sale) {
          return DataRow(
            cells: [
              DataCell(Text(sale['date'] as String)),
              DataCell(Text(sale['customer'] as String)),
              DataCell(Text('${(sale['amount'] as double).toStringAsFixed(2)} ريال')),
              DataCell(Text((sale['items'] as int).toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInventoryReport() {
    final localizations = AppLocalizations.of(context)!;
    final inventoryData = [
      {'name': 'خاتم ذهب عيار 21', 'category': 'خواتم', 'quantity': 15, 'value': 18750.0},
      {'name': 'قلادة ذهب مع دلاية', 'category': 'قلائد', 'quantity': 8, 'value': 16800.0},
      {'name': 'سوار ذهب نسائي', 'category': 'أساور', 'quantity': 6, 'value': 19200.0},
      {'name': 'أقراط ذهب مع أحجار', 'category': 'أقراط', 'quantity': 12, 'value': 21600.0},
    ];

    return SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: Text(localizations.translate('product') ?? 'المنتج')),
          DataColumn(label: Text(localizations.translate('category') ?? 'الفئة')),
          DataColumn(label: Text(localizations.translate('quantity') ?? 'الكمية')),
          DataColumn(label: Text(localizations.translate('value') ?? 'القيمة')),
        ],
        rows: inventoryData.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item['name'] as String)),
              DataCell(Text(item['category'] as String)),
              DataCell(Text((item['quantity'] as int).toString())),
              DataCell(Text('${(item['value'] as double).toStringAsFixed(2)} ريال')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkOrdersReport() {
    final localizations = AppLocalizations.of(context)!;
    final workOrdersData = [
      {'orderNo': 'WO-001', 'client': 'أحمد محمد', 'type': 'تصنيع', 'status': 'قيد التنفيذ', 'cost': 1500.0},
      {'orderNo': 'WO-002', 'client': 'فاطمة علي', 'type': 'إصلاح', 'status': 'مكتمل', 'cost': 300.0},
      {'orderNo': 'WO-003', 'client': 'محمد سالم', 'type': 'تلميع', 'status': 'معلق', 'cost': 150.0},
    ];

    return SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: Text(localizations.translate('order_number') ?? 'رقم الأمر')),
          DataColumn(label: Text(localizations.translate('client') ?? 'العميل')),
          DataColumn(label: Text(localizations.translate('type') ?? 'النوع')),
          DataColumn(label: Text(localizations.translate('status') ?? 'الحالة')),
          DataColumn(label: Text(localizations.translate('cost') ?? 'التكلفة')),
        ],
        rows: workOrdersData.map((order) {
          return DataRow(
            cells: [
              DataCell(Text(order['orderNo'] as String)),
              DataCell(Text(order['client'] as String)),
              DataCell(Text(order['type'] as String)),
              DataCell(Text(order['status'] as String)),
              DataCell(Text('${(order['cost'] as double).toStringAsFixed(2)} ريال')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFinancialReport() {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الملخص المالي',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: UIConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: Card(
                color: AppTheme.success.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.paddingMedium),
                  child: Column(
                    children: [
                      Text(localizations.translate('total_revenue') ?? 'إجمالي الإيرادات', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '125,450 ريال',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: UIConstants.paddingMedium),
            Expanded(
              child: Card(
                color: AppTheme.error.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.paddingMedium),
                  child: Column(
                    children: [
                      Text(localizations.translate('total_expenses') ?? 'إجمالي المصروفات', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '91,330 ريال',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: UIConstants.paddingMedium),
            Expanded(
              child: Card(
                color: AppTheme.primaryGold.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.paddingMedium),
                  child: Column(
                    children: [
                      Text(localizations.translate('net_profit') ?? 'صافي الربح', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '34,120 ريال',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoldMovementReport() {
    final localizations = AppLocalizations.of(context)!;
    final goldMovementData = [
      {'date': '2024-01-15', 'type': 'شراء', 'weight': 50.0, 'karat': 24, 'price': 12500.0},
      {'date': '2024-01-16', 'type': 'بيع', 'weight': -15.2, 'karat': 21, 'price': -3800.0},
      {'date': '2024-01-17', 'type': 'تصنيع', 'weight': -8.5, 'karat': 18, 'price': 0.0},
    ];

    return SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: Text(localizations.translate('date') ?? 'التاريخ')),
          DataColumn(label: Text(localizations.translate('type') ?? 'النوع')),
          DataColumn(label: Text(localizations.translate('weight_gram') ?? 'الوزن (جم)')),
          DataColumn(label: Text(localizations.translate('karat') ?? 'العيار')),
          DataColumn(label: Text(localizations.translate('value') ?? 'القيمة')),
        ],
        rows: goldMovementData.map((movement) {
          return DataRow(
            cells: [
              DataCell(Text(movement['date'] as String)),
              DataCell(Text(movement['type'] as String)),
              DataCell(Text((movement['weight'] as double).toStringAsFixed(1))),
              DataCell(Text('${localizations.translate('karat') ?? 'عيار'} ${movement['karat']}')),
              DataCell(Text('${(movement['price'] as double).toStringAsFixed(2)} ريال')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isGenerating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء التقرير بنجاح')),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير التقرير'),
        content: const Text('اختر صيغة التصدير:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportToPDF();
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportToExcel();
            },
            child: const Text('Excel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _exportToPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تصدير التقرير بصيغة PDF')),
    );
  }

  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تصدير التقرير بصيغة Excel')),
    );
  }

  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال التقرير للطباعة')),
    );
  }
}