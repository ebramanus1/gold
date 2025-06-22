import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/gold_price_service.dart';
import '../../services/database/postgresql_service.dart'; // Import PostgreSQLService

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الصفحة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'لوحة التحكم',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        // عرض الإشعارات
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        // تحديث البيانات
                        setState(() {}); // Trigger rebuild to refresh data
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: UIConstants.paddingLarge),

            // بطاقات الإحصائيات الرئيسية
            Consumer(
              builder: (context, ref, child) {
                final goldPriceAsyncValue = ref.watch(goldPriceProvider);
                final salesDataFuture = PostgreSQLService.instance.getDailySales();
                final inventoryDataFuture = PostgreSQLService.instance.getTotalInventory();
                final pendingOrdersDataFuture = PostgreSQLService.instance.getPendingWorkOrdersCount();

                return FutureBuilder<
                    List<dynamic>>(
                  future: Future.wait([
                    goldPriceAsyncValue.when(
                      data: (data) => Future.value(data),
                      loading: () => Future.value(null),
                      error: (err, stack) => Future.value(null),
                    ),
                    salesDataFuture,
                    inventoryDataFuture,
                    pendingOrdersDataFuture,
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildStatsCards(null, null, null, null);
                    } else if (snapshot.hasError) {
                      return Center(child: Text('خطأ في تحميل البيانات: ${snapshot.error}'));
                    } else {
                      final goldPrice = snapshot.data?[0] as double?;
                      final dailySales = snapshot.data?[1] as double?;
                      final totalInventory = snapshot.data?[2] as int?;
                      final pendingOrders = snapshot.data?[3] as int?;
                      return _buildStatsCards(goldPrice, dailySales, totalInventory, pendingOrders);
                    }
                  },
                );
              },
            ),

            const SizedBox(height: UIConstants.paddingLarge),

            // الرسوم البيانية
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildSalesChart(),
                      ),
                      const SizedBox(width: UIConstants.paddingMedium),
                      Expanded(
                        child: _buildInventoryChart(),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildSalesChart(),
                      const SizedBox(height: UIConstants.paddingLarge),
                      _buildInventoryChart(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: UIConstants.paddingLarge),

            // المعاملات الأخيرة والأصناف الأكثر مبيعاً
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildRecentTransactions(),
                      ),
                      const SizedBox(width: UIConstants.paddingMedium),
                      Expanded(
                        child: _buildTopSellingItems(),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildRecentTransactions(),
                      const SizedBox(height: UIConstants.paddingLarge),
                      _buildTopSellingItems(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(double? goldPrice, double? dailySales, int? totalInventory, int? pendingOrders) {
    final goldPriceValue = goldPrice != null ? '${goldPrice.toStringAsFixed(2)} ر.س/جرام' : 'جاري التحميل...';
    final goldPricePercentage = goldPrice != null ? '+2%' : 'N/A'; // Placeholder, actual percentage change needs calculation

    final dailySalesValue = dailySales != null ? '${dailySales.toStringAsFixed(2)} ر.س' : 'لا توجد بيانات';
    final totalInventoryValue = totalInventory != null ? '$totalInventory قطعة' : 'لا توجد بيانات';
    final pendingOrdersValue = pendingOrders != null ? '$pendingOrders طلبات' : 'لا توجد بيانات';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isLargeScreen ? 4 : 2,
          crossAxisSpacing: UIConstants.paddingMedium,
          mainAxisSpacing: UIConstants.paddingMedium,
          children: [
            _buildStatCard(
              title: 'مبيعات اليوم',
              value: dailySalesValue,
              icon: Icons.trending_up,
              color: AppTheme.success,
              percentage: '+0%', // Placeholder
            ),
            _buildStatCard(
              title: 'إجمالي المخزون',
              value: totalInventoryValue,
              icon: Icons.inventory,
              color: AppTheme.info,
              percentage: '+0%', // Placeholder
            ),
            _buildStatCard(
              title: 'الطلبات المعلقة',
              value: pendingOrdersValue,
              icon: Icons.pending_actions,
              color: AppTheme.warning,
              percentage: '+0%', // Placeholder
            ),
            _buildStatCard(
              title: 'سعر الذهب',
              value: goldPriceValue,
              icon: Icons.monetization_on,
              color: AppTheme.primaryGold,
              percentage: goldPricePercentage,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String percentage,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: UIConstants.iconSizeLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: percentage.startsWith('+')
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                  ),
                  child: Text(
                    percentage,
                    style: TextStyle(
                      color: percentage.startsWith('+')
                          ? AppTheme.success
                          : AppTheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: UIConstants.fontSizeSmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.grey600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المبيعات الشهرية',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<FlSpot>>(
                future: PostgreSQLService.instance.getMonthlySalesData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('خطأ في تحميل بيانات المبيعات: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا توجد بيانات مبيعات لعرضها.'));
                  } else {
                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
                                return SideTitleWidget(
                                  axisSide: meta.axisSide, // إضافة axisSide بدل meta إذا كان meta غير مدعوم
                                  space: 8.0,
                                  child: Text(
                                    months[(value.toInt() - 1).clamp(0, 11)],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: snapshot.data!,
                            isCurved: true,
                            color: AppTheme.primaryGold,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryGold.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توزيع المخزون',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<PieChartSectionData>>(
                future: PostgreSQLService.instance.getInventoryDistribution(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('خطأ في تحميل بيانات المخزون: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا توجد بيانات مخزون لعرضها.'));
                  } else {
                    return PieChart(
                      PieChartData(
                        sections: snapshot.data!,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المعاملات الأخيرة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // عرض جميع المعاملات
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: PostgreSQLService.instance.getRecentTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('خطأ في تحميل المعاملات: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد معاملات أخيرة لعرضها.'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final transaction = snapshot.data![index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                        title: Text('معاملة #${transaction['transaction_number']}'),
                        subtitle: Text('عميل ${transaction['client_name']}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(transaction['amount'] as double).toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.success,
                              ),
                            ),
                            Text(
                              '${(DateTime.now().difference(transaction['created_at']).inHours)} ساعة مضت',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأصناف الأكثر مبيعاً',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // عرض جميع الأصناف
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: PostgreSQLService.instance.getTopSellingItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('خطأ في تحميل الأصناف الأكثر مبيعاً: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد أصناف أكثر مبيعاً لعرضها.'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(item['product_name']),
                        subtitle: Text('${item['sales_count']} قطعة مباعة'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.paddingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                          ),
                          child: Text(
                            '${item['sales_count']}',
                            style: const TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
                              fontSize: UIConstants.fontSizeSmall,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}