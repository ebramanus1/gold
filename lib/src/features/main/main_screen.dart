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
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

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
    const ReportsScreen(), // تم نقلها إلى ملف منفصل
    const SettingsScreen(),
    const UserManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<NavigationItem> _navigationItems = [
      NavigationItem(
        icon: Icons.dashboard,
        label: localizations.dashboard,
        route: '/dashboard',
        requiredRoles: [UserRole.admin, UserRole.manager, UserRole.sales, UserRole.accountant, UserRole.viewer],
      ),
      NavigationItem(
        icon: Icons.people,
        label: localizations.clients,
        route: '/clients',
        requiredRoles: [UserRole.admin, UserRole.manager, UserRole.sales],
      ),
      NavigationItem(
        icon: Icons.inventory_2,
        label: localizations.rawMaterials,
        route: '/raw-materials',
        requiredRoles: [UserRole.admin, UserRole.manager, UserRole.artisan, UserRole.accountant],
      ),
      NavigationItem(
        icon: Icons.work,
        label: localizations.workOrders,
        route: '/work-orders',
        requiredRoles: [UserRole.admin, UserRole.manager, UserRole.artisan],
      ),
      NavigationItem(
        icon: Icons.shopping_bag,
        label: localizations.finishedGoods,
        route: '/finished-goods',
        requiredRoles: [UserRole.admin, UserRole.manager, UserRole.sales, UserRole.artisan],
      ),
      NavigationItem(
        icon: Icons.assessment,
        label: localizations.reports,
        route: '/reports',
        requiredRoles: [UserRole.admin, UserRole.manager, UserRole.accountant, UserRole.viewer],
      ),
      NavigationItem(
        icon: Icons.settings,
        label: localizations.settings,
        route: '/settings',
        requiredRoles: [UserRole.admin, UserRole.manager],
      ),
      NavigationItem(
        icon: Icons.people_alt,
        label: localizations.users,
        route: '/users',
        requiredRoles: [UserRole.admin],
      ),
    ];

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


