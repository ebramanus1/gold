import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../dashboard/dashboard_screen.dart';
import '../clients/client_management_screen.dart';
import '../raw_materials/raw_material_management_screen.dart';
import '../users/user_management_screen.dart';
import '../work_orders/work_order_management_screen.dart';
import '../finished_goods/finished_goods_management_screen.dart';
import '../../core/models/user_model.dart'; // Import UserRole enum
import '../../core/localization/app_localizations.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  // Placeholder for the current user's role. In a real app, this would come from authentication.
  final UserRole _currentUserRole = UserRole.admin; // Assuming admin for now to enable all features

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ClientManagementScreen(),
    const RawMaterialManagementScreen(),
    const WorkOrderManagementScreen(),
    const FinishedGoodsManagementScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
    const UserManagementScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'لوحة التحكم',
      route: '/dashboard',
      requiredRoles: [UserRole.admin, UserRole.manager, UserRole.sales, UserRole.accountant, UserRole.viewer],
    ),
    NavigationItem(
      icon: Icons.people,
      label: 'إدارة العملاء',
      route: '/clients',
      requiredRoles: [UserRole.admin, UserRole.manager, UserRole.sales],
    ),
    NavigationItem(
      icon: Icons.inventory_2,
      label: 'المواد الخام',
      route: '/raw-materials',
      requiredRoles: [UserRole.admin, UserRole.manager, UserRole.artisan, UserRole.accountant],
    ),
    NavigationItem(
      icon: Icons.work,
      label: 'أوامر العمل',
      route: '/work-orders',
      requiredRoles: [UserRole.admin, UserRole.manager, UserRole.artisan],
    ),
    NavigationItem(
      icon: Icons.shopping_bag,
      label: 'المنتجات النهائية',
      route: '/finished-goods',
      requiredRoles: [UserRole.admin, UserRole.manager, UserRole.sales, UserRole.artisan],
    ),
    NavigationItem(
      icon: Icons.assessment,
      label: 'التقارير',
      route: '/reports',
      requiredRoles: [UserRole.admin, UserRole.manager, UserRole.accountant, UserRole.viewer],
    ),
    NavigationItem(
      icon: Icons.settings,
      label: 'الإعدادات',
      route: '/settings',
      requiredRoles: [UserRole.admin, UserRole.manager],
    ),
    NavigationItem(
      icon: Icons.manage_accounts,
      label: 'إدارة المستخدمين',
      route: '/users',
      requiredRoles: [UserRole.admin],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(UIConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: AppTheme.primaryGold,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: UIConstants.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ورشة الذهب',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'نظام إدارة شامل',
                              style: TextStyle(
                                color: AppTheme.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingSmall),
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      // Only show navigation item if the current user's role is allowed
                      if (!item.requiredRoles.contains(_currentUserRole)) {
                        return const SizedBox.shrink(); // Hide the item
                      }
                      final isSelected = _selectedIndex == index;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: UIConstants.paddingSmall,
                          vertical: 2,
                        ),
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            color: isSelected ? AppTheme.primaryGold : AppTheme.grey600,
                            size: UIConstants.iconSizeMedium,
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primaryGold : AppTheme.grey700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: AppTheme.primaryGold.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.all(UIConstants.paddingMedium),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.grey300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                      const SizedBox(width: UIConstants.paddingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المدير العام',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'admin@goldworkshop.com',
                              style: TextStyle(
                                color: AppTheme.grey600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'profile':
                              break;
                            case 'logout':
                              _logout();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: ListTile(
                              leading: Icon(Icons.person),
                              title: Text('الملف الشخصي'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: ListTile(
                              leading: Icon(Icons.logout),
                              title: Text('تسجيل الخروج'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;
  final List<UserRole> requiredRoles;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
    this.requiredRoles = const [],
  });
}

// Placeholder screens, now replaced by actual management screens
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

  final Map<String, String> _reportTypes = {
    'sales': 'تقرير المبيعات',
    'inventory': 'تقرير المخزون',
    'workOrders': 'تقرير أوامر العمل',
    'financial': 'التقرير المالي',
    'goldMovement': 'تقرير حركة الذهب',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إعدادات التقرير
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إعدادات التقرير',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.paddingMedium),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedReportType,
                            decoration: const InputDecoration(
                              labelText: 'نوع التقرير',
                              border: OutlineInputBorder(),
                            ),
                            items: _reportTypes.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() {
                              _selectedReportType = value!;
                            }),
                          ),
                        ),
                        const SizedBox(width: UIConstants.paddingMedium),
                        
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'من تاريخ',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  _startDate = date;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: UIConstants.paddingMedium),
                        
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'إلى تاريخ',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  _endDate = date;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: UIConstants.paddingMedium),
                        
                        ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateReport,
                          icon: _isGenerating 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.assessment),
                          label: Text(_isGenerating ? 'جاري الإنشاء...' : 'إنشاء التقرير'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            
            // إحصائيات سريعة
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'إجمالي المبيعات',
                    '125,450 ريال',
                    Icons.trending_up,
                    AppTheme.success,
                  ),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    'أوامر العمل النشطة',
                    '23',
                    Icons.work,
                    AppTheme.info,
                  ),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    'قيمة المخزون',
                    '89,200 ريال',
                    Icons.inventory,
                    AppTheme.warning,
                  ),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    'صافي الربح',
                    '34,120 ريال',
                    Icons.account_balance_wallet,
                    AppTheme.primaryGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            
            // محتوى التقرير
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _reportTypes[_selectedReportType]!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: _exportReport,
                            tooltip: 'تصدير التقرير',
                          ),
                          IconButton(
                            icon: const Icon(Icons.print),
                            onPressed: _printReport,
                            tooltip: 'طباعة التقرير',
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: _buildReportContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
        return const Center(child: Text('اختر نوع التقرير'));
    }
  }

  Widget _buildSalesReport() {
    final salesData = [
      {'date': '2024-01-15', 'customer': 'أحمد محمد', 'amount': 2500.0, 'items': 3},
      {'date': '2024-01-16', 'customer': 'فاطمة علي', 'amount': 1800.0, 'items': 2},
      {'date': '2024-01-17', 'customer': 'محمد سالم', 'amount': 3200.0, 'items': 1},
      {'date': '2024-01-18', 'customer': 'نورا أحمد', 'amount': 1500.0, 'items': 4},
    ];

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('التاريخ')),
          DataColumn(label: Text('العميل')),
          DataColumn(label: Text('المبلغ')),
          DataColumn(label: Text('عدد القطع')),
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
    final inventoryData = [
      {'name': 'خاتم ذهب عيار 21', 'category': 'خواتم', 'quantity': 15, 'value': 18750.0},
      {'name': 'قلادة ذهب مع دلاية', 'category': 'قلائد', 'quantity': 8, 'value': 16800.0},
      {'name': 'سوار ذهب نسائي', 'category': 'أساور', 'quantity': 6, 'value': 19200.0},
      {'name': 'أقراط ذهب مع أحجار', 'category': 'أقراط', 'quantity': 12, 'value': 21600.0},
    ];

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('المنتج')),
          DataColumn(label: Text('الفئة')),
          DataColumn(label: Text('الكمية')),
          DataColumn(label: Text('القيمة')),
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
    final workOrdersData = [
      {'orderNo': 'WO-001', 'client': 'أحمد محمد', 'type': 'تصنيع', 'status': 'قيد التنفيذ', 'cost': 1500.0},
      {'orderNo': 'WO-002', 'client': 'فاطمة علي', 'type': 'إصلاح', 'status': 'مكتمل', 'cost': 300.0},
      {'orderNo': 'WO-003', 'client': 'محمد سالم', 'type': 'تلميع', 'status': 'معلق', 'cost': 150.0},
    ];

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('رقم الأمر')),
          DataColumn(label: Text('العميل')),
          DataColumn(label: Text('النوع')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('التكلفة')),
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
                      const Text('إجمالي الإيرادات', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      const Text('إجمالي المصروفات', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      const Text('صافي الربح', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final goldMovementData = [
      {'date': '2024-01-15', 'type': 'شراء', 'weight': 50.0, 'karat': 24, 'price': 12500.0},
      {'date': '2024-01-16', 'type': 'بيع', 'weight': -15.2, 'karat': 21, 'price': -3800.0},
      {'date': '2024-01-17', 'type': 'تصنيع', 'weight': -8.5, 'karat': 18, 'price': 0.0},
    ];

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('التاريخ')),
          DataColumn(label: Text('النوع')),
          DataColumn(label: Text('الوزن (جم)')),
          DataColumn(label: Text('العيار')),
          DataColumn(label: Text('القيمة')),
        ],
        rows: goldMovementData.map((movement) {
          return DataRow(
            cells: [
              DataCell(Text(movement['date'] as String)),
              DataCell(Text(movement['type'] as String)),
              DataCell(Text((movement['weight'] as double).toStringAsFixed(1))),
              DataCell(Text('عيار ${movement['karat']}')),
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

    // محاكاة إنشاء التقرير
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

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(languageProvider);
    final currentTheme = ref.watch(themeProvider);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الإعدادات العامة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('general_settings'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.paddingLarge),
                    
                    // إعدادات اللغة
                    Row(
                      children: [
                        const Icon(Icons.language, color: AppTheme.primaryGold),
                        const SizedBox(width: UIConstants.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.language,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentLocale.languageCode == 'ar' 
                                    ? localizations.arabic 
                                    : localizations.english,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<String>(
                          value: currentLocale.languageCode,
                          items: [
                            DropdownMenuItem(
                              value: 'ar',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇸🇦'),
                                  const SizedBox(width: 8),
                                  Text(localizations.arabic),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇺🇸'),
                                  const SizedBox(width: 8),
                                  Text(localizations.english),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (String? newLanguage) {
                            if (newLanguage != null) {
                              ref.read(languageProvider.notifier).changeLanguage(newLanguage);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    newLanguage == 'ar' 
                                        ? 'تم تغيير اللغة إلى العربية'
                                        : 'Language changed to English',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    
                    // إعدادات المظهر
                    Row(
                      children: [
                        const Icon(Icons.palette, color: AppTheme.primaryGold),
                        const SizedBox(width: UIConstants.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.theme,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getThemeText(currentTheme, localizations),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<ThemeMode>(
                          value: currentTheme,
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.light_mode, size: 20),
                                  const SizedBox(width: 8),
                                  Text(localizations.lightTheme),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.dark_mode, size: 20),
                                  const SizedBox(width: 8),
                                  Text(localizations.darkTheme),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.settings_system_daydream, size: 20),
                                  const SizedBox(width: 8),
                                  Text(localizations.systemTheme),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (ThemeMode? newTheme) {
                            if (newTheme != null) {
                              ref.read(themeProvider.notifier).changeTheme(newTheme);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localizations.translate('theme_changed') ?? 
                                    (currentLocale.languageCode == 'ar' 
                                        ? 'تم تغيير المظهر'
                                        : 'Theme changed'),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            
            // إعدادات النسخ الاحتياطي
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('backup_settings'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.paddingMedium),
                    
                    ListTile(
                      leading: const Icon(Icons.backup, color: AppTheme.primaryGold),
                      title: Text(localizations.translate('auto_backup') ?? 'النسخ الاحتياطي التلقائي'),
                      subtitle: Text(localizations.translate('backup_description') ?? 'نسخ احتياطي يومي للبيانات'),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // تنفيذ تغيير إعدادات النسخ الاحتياطي
                        },
                      ),
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.cloud_upload, color: AppTheme.primaryGold),
                      title: Text(localizations.translate('cloud_backup') ?? 'النسخ الاحتياطي السحابي'),
                      subtitle: Text(localizations.translate('cloud_backup_description') ?? 'رفع النسخ الاحتياطية للسحابة'),
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {
                          // تنفيذ تغيير إعدادات النسخ السحابي
                        },
                      ),
                    ),
                    
                    const SizedBox(height: UIConstants.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _createBackup();
                            },
                            icon: const Icon(Icons.save),
                            label: Text(localizations.translate('create_backup') ?? 'إنشاء نسخة احتياطية'),
                          ),
                        ),
                        const SizedBox(width: UIConstants.paddingMedium),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _restoreBackup();
                            },
                            icon: const Icon(Icons.restore),
                            label: Text(localizations.translate('restore_backup') ?? 'استعادة نسخة احتياطية'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            
            // إعدادات الإشعارات
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('notification_settings'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.paddingMedium),
                    
                    ListTile(
                      leading: const Icon(Icons.notifications, color: AppTheme.primaryGold),
                      title: Text(localizations.translate('work_order_notifications') ?? 'إشعارات أوامر العمل'),
                      subtitle: Text(localizations.translate('work_order_notifications_desc') ?? 'إشعارات عند تحديث حالة أوامر العمل'),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // تنفيذ تغيير إعدادات الإشعارات
                        },
                      ),
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.inventory, color: AppTheme.primaryGold),
                      title: Text(localizations.translate('stock_notifications') ?? 'إشعارات المخزون'),
                      subtitle: Text(localizations.translate('stock_notifications_desc') ?? 'إشعارات عند انخفاض مستوى المخزون'),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // تنفيذ تغيير إعدادات إشعارات المخزون
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode themeMode, AppLocalizations localizations) {
    switch (themeMode) {
      case ThemeMode.light:
        return localizations.lightTheme;
      case ThemeMode.dark:
        return localizations.darkTheme;
      case ThemeMode.system:
        return localizations.systemTheme;
    }
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.translate('backup_created') ?? 
          'تم إنشاء النسخة الاحتياطية بنجاح',
        ),
      ),
    );
  }

  void _restoreBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('restore_backup') ?? 'استعادة نسخة احتياطية'),
        content: Text(AppLocalizations.of(context)!.translate('restore_backup_warning') ?? 'هل أنت متأكد من استعادة النسخة الاحتياطية؟ سيتم استبدال البيانات الحالية.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.translate('backup_restored') ?? 
                    'تم استعادة النسخة الاحتياطية بنجاح',
                  ),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.translate('restore') ?? 'استعادة'),
          ),
        ],
      ),
    );
  }
}


