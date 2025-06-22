import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fl_chart/fl_chart.dart';

enum ReportType {
  sales,
  inventory,
  profitLoss,
  goldMovement,
  workOrders,
  clients,
  craftsmen,
  custom
}

enum ReportPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
  custom
}

enum ReportFormat {
  pdf,
  excel,
  csv,
  json
}

class ReportService {
  // إنشاء تقرير المبيعات
  static Future<SalesReport> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    String? clientId,
    String? productCategory,
    String? paymentMethod,
  }) async {
    try {
      // جلب بيانات المبيعات من قاعدة البيانات
      final salesData = await _fetchSalesData(startDate, endDate, clientId, productCategory, paymentMethod);
      
      // حساب الإحصائيات
      final totalSales = salesData.fold(0.0, (sum, sale) => sum + sale.totalAmount);
      final totalTransactions = salesData.length;
      final averageTransaction = totalTransactions > 0 ? totalSales / totalTransactions : 0.0;
      
      // تجميع البيانات حسب التاريخ
      final dailySales = <DateTime, double>{};
      for (final sale in salesData) {
        final date = DateTime(sale.date.year, sale.date.month, sale.date.day);
        dailySales[date] = (dailySales[date] ?? 0.0) + sale.totalAmount;
      }
      
      // تجميع البيانات حسب المنتج
      final productSales = <String, double>{};
      for (final sale in salesData) {
        for (final item in sale.items) {
          productSales[item.productName] = (productSales[item.productName] ?? 0.0) + item.totalPrice;
        }
      }
      
      // تجميع البيانات حسب طريقة الدفع
      final paymentMethodSales = <String, double>{};
      for (final sale in salesData) {
        final method = sale.paymentMethod ?? 'غير محدد';
        paymentMethodSales[method] = (paymentMethodSales[method] ?? 0.0) + sale.totalAmount;
      }
      
      return SalesReport(
        startDate: startDate,
        endDate: endDate,
        totalSales: totalSales,
        totalTransactions: totalTransactions,
        averageTransaction: averageTransaction,
        dailySales: dailySales,
        productSales: productSales,
        paymentMethodSales: paymentMethodSales,
        salesData: salesData,
        generatedAt: DateTime.now(),
      );
      
    } catch (e) {
      throw Exception('فشل في إنشاء تقرير المبيعات: $e');
    }
  }
  
  // إنشاء تقرير المخزون
  static Future<InventoryReport> generateInventoryReport({
    String? category,
    bool lowStockOnly = false,
    bool includeOutOfStock = true,
  }) async {
    try {
      // جلب بيانات المخزون
      final inventoryData = await _fetchInventoryData(category, lowStockOnly, includeOutOfStock);
      
      // حساب الإحصائيات
      final totalItems = inventoryData.length;
      final totalValue = inventoryData.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
      final lowStockItems = inventoryData.where((item) => item.quantity <= item.minStockLevel).length;
      final outOfStockItems = inventoryData.where((item) => item.quantity == 0).length;
      
      // تجميع البيانات حسب الفئة
      final categoryBreakdown = <String, int>{};
      final categoryValue = <String, double>{};
      for (final item in inventoryData) {
        categoryBreakdown[item.category] = (categoryBreakdown[item.category] ?? 0) + item.quantity;
        categoryValue[item.category] = (categoryValue[item.category] ?? 0.0) + (item.quantity * item.unitPrice);
      }
      
      return InventoryReport(
        totalItems: totalItems,
        totalValue: totalValue,
        lowStockItems: lowStockItems,
        outOfStockItems: outOfStockItems,
        categoryBreakdown: categoryBreakdown,
        categoryValue: categoryValue,
        inventoryData: inventoryData,
        generatedAt: DateTime.now(),
      );
      
    } catch (e) {
      throw Exception('فشل في إنشاء تقرير المخزون: $e');
    }
  }
  
  // إنشاء تقرير الأرباح والخسائر
  static Future<ProfitLossReport> generateProfitLossReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // جلب بيانات الإيرادات
      final revenue = await _calculateRevenue(startDate, endDate);
      
      // جلب بيانات التكاليف
      final costs = await _calculateCosts(startDate, endDate);
      
      // حساب الربح الإجمالي
      final grossProfit = revenue.totalSales - costs.costOfGoodsSold;
      
      // حساب الربح الصافي
      final netProfit = grossProfit - costs.operatingExpenses;
      
      // حساب الهوامش
      final grossMargin = revenue.totalSales > 0 ? (grossProfit / revenue.totalSales) * 100 : 0.0;
      final netMargin = revenue.totalSales > 0 ? (netProfit / revenue.totalSales) * 100 : 0.0;
      
      return ProfitLossReport(
        startDate: startDate,
        endDate: endDate,
        revenue: revenue,
        costs: costs,
        grossProfit: grossProfit,
        netProfit: netProfit,
        grossMargin: grossMargin,
        netMargin: netMargin,
        generatedAt: DateTime.now(),
      );
      
    } catch (e) {
      throw Exception('فشل في إنشاء تقرير الأرباح والخسائر: $e');
    }
  }
  
  // إنشاء تقرير حركة الذهب
  static Future<GoldMovementReport> generateGoldMovementReport({
    required DateTime startDate,
    required DateTime endDate,
    int? goldKarat,
  }) async {
    try {
      // جلب بيانات حركة الذهب
      final movements = await _fetchGoldMovements(startDate, endDate, goldKarat);
      
      // حساب الإحصائيات
      final totalIncoming = movements
          .where((m) => m.type == GoldMovementType.incoming)
          .fold(0.0, (sum, m) => sum + m.weight);
      
      final totalOutgoing = movements
          .where((m) => m.type == GoldMovementType.outgoing)
          .fold(0.0, (sum, m) => sum + m.weight);
      
      final netMovement = totalIncoming - totalOutgoing;
      
      // تجميع البيانات حسب العيار
      final karatBreakdown = <int, double>{};
      for (final movement in movements) {
        karatBreakdown[movement.karat] = (karatBreakdown[movement.karat] ?? 0.0) + movement.weight;
      }
      
      // تجميع البيانات حسب النوع
      final typeBreakdown = <GoldMovementType, double>{};
      for (final movement in movements) {
        typeBreakdown[movement.type] = (typeBreakdown[movement.type] ?? 0.0) + movement.weight;
      }
      
      return GoldMovementReport(
        startDate: startDate,
        endDate: endDate,
        totalIncoming: totalIncoming,
        totalOutgoing: totalOutgoing,
        netMovement: netMovement,
        karatBreakdown: karatBreakdown,
        typeBreakdown: typeBreakdown,
        movements: movements,
        generatedAt: DateTime.now(),
      );
      
    } catch (e) {
      throw Exception('فشل في إنشاء تقرير حركة الذهب: $e');
    }
  }
  
  // تصدير التقرير إلى PDF
  static Future<String> exportToPDF(dynamic report, String filePath) async {
    final pdf = pw.Document();
    
    if (report is SalesReport) {
      await _addSalesReportToPDF(pdf, report);
    } else if (report is InventoryReport) {
      await _addInventoryReportToPDF(pdf, report);
    } else if (report is ProfitLossReport) {
      await _addProfitLossReportToPDF(pdf, report);
    } else if (report is GoldMovementReport) {
      await _addGoldMovementReportToPDF(pdf, report);
    }
    
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return filePath;
  }
  
  // تصدير التقرير إلى Excel
  static Future<String> exportToExcel(dynamic report, String filePath) async {
    // تنفيذ تصدير Excel
    // يمكن استخدام مكتبة excel أو syncfusion_flutter_xlsio
    return filePath;
  }
  
  // تصدير التقرير إلى CSV
  static Future<String> exportToCSV(dynamic report, String filePath) async {
    final buffer = StringBuffer();
    
    if (report is SalesReport) {
      buffer.writeln('التاريخ,المبلغ,العميل,طريقة الدفع');
      for (final sale in report.salesData) {
        buffer.writeln('${sale.date},${sale.totalAmount},${sale.clientName},${sale.paymentMethod}');
      }
    } else if (report is InventoryReport) {
      buffer.writeln('المنتج,الكمية,السعر,القيمة,الفئة');
      for (final item in report.inventoryData) {
        buffer.writeln('${item.name},${item.quantity},${item.unitPrice},${item.quantity * item.unitPrice},${item.category}');
      }
    }
    
    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    
    return filePath;
  }
  
  // الطرق المساعدة
  static Future<List<SaleData>> _fetchSalesData(DateTime startDate, DateTime endDate, String? clientId, String? productCategory, String? paymentMethod) async {
    // جلب بيانات المبيعات من قاعدة البيانات
    return [];
  }
  
  static Future<List<InventoryData>> _fetchInventoryData(String? category, bool lowStockOnly, bool includeOutOfStock) async {
    // جلب بيانات المخزون من قاعدة البيانات
    return [];
  }
  
  static Future<RevenueData> _calculateRevenue(DateTime startDate, DateTime endDate) async {
    // حساب الإيرادات
    return RevenueData(totalSales: 0.0, totalTax: 0.0, totalDiscount: 0.0);
  }
  
  static Future<CostData> _calculateCosts(DateTime startDate, DateTime endDate) async {
    // حساب التكاليف
    return CostData(costOfGoodsSold: 0.0, operatingExpenses: 0.0, laborCosts: 0.0);
  }
  
  static Future<List<GoldMovement>> _fetchGoldMovements(DateTime startDate, DateTime endDate, int? goldKarat) async {
    // جلب بيانات حركة الذهب
    return [];
  }
  
  static Future<void> _addSalesReportToPDF(pw.Document pdf, SalesReport report) async {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('تقرير المبيعات', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('الفترة: ${report.startDate.toString().split(' ')[0]} - ${report.endDate.toString().split(' ')[0]}'),
              pw.SizedBox(height: 10),
              pw.Text('إجمالي المبيعات: ${report.totalSales.toStringAsFixed(2)} ريال'),
              pw.Text('عدد المعاملات: ${report.totalTransactions}'),
              pw.Text('متوسط المعاملة: ${report.averageTransaction.toStringAsFixed(2)} ريال'),
              pw.SizedBox(height: 20),
              // إضافة جدول البيانات
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('التاريخ')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('العميل')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('المبلغ')),
                    ],
                  ),
                  ...report.salesData.map((sale) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(sale.date.toString().split(' ')[0])),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(sale.clientName)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(sale.totalAmount.toStringAsFixed(2))),
                    ],
                  )),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  static Future<void> _addInventoryReportToPDF(pw.Document pdf, InventoryReport report) async {
    // إضافة تقرير المخزون إلى PDF
  }
  
  static Future<void> _addProfitLossReportToPDF(pw.Document pdf, ProfitLossReport report) async {
    // إضافة تقرير الأرباح والخسائر إلى PDF
  }
  
  static Future<void> _addGoldMovementReportToPDF(pw.Document pdf, GoldMovementReport report) async {
    // إضافة تقرير حركة الذهب إلى PDF
  }
}

// نماذج البيانات للتقارير
class SalesReport {
  final DateTime startDate;
  final DateTime endDate;
  final double totalSales;
  final int totalTransactions;
  final double averageTransaction;
  final Map<DateTime, double> dailySales;
  final Map<String, double> productSales;
  final Map<String, double> paymentMethodSales;
  final List<SaleData> salesData;
  final DateTime generatedAt;

  SalesReport({
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalTransactions,
    required this.averageTransaction,
    required this.dailySales,
    required this.productSales,
    required this.paymentMethodSales,
    required this.salesData,
    required this.generatedAt,
  });
}

class InventoryReport {
  final int totalItems;
  final double totalValue;
  final int lowStockItems;
  final int outOfStockItems;
  final Map<String, int> categoryBreakdown;
  final Map<String, double> categoryValue;
  final List<InventoryData> inventoryData;
  final DateTime generatedAt;

  InventoryReport({
    required this.totalItems,
    required this.totalValue,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.categoryBreakdown,
    required this.categoryValue,
    required this.inventoryData,
    required this.generatedAt,
  });
}

class ProfitLossReport {
  final DateTime startDate;
  final DateTime endDate;
  final RevenueData revenue;
  final CostData costs;
  final double grossProfit;
  final double netProfit;
  final double grossMargin;
  final double netMargin;
  final DateTime generatedAt;

  ProfitLossReport({
    required this.startDate,
    required this.endDate,
    required this.revenue,
    required this.costs,
    required this.grossProfit,
    required this.netProfit,
    required this.grossMargin,
    required this.netMargin,
    required this.generatedAt,
  });
}

class GoldMovementReport {
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncoming;
  final double totalOutgoing;
  final double netMovement;
  final Map<int, double> karatBreakdown;
  final Map<GoldMovementType, double> typeBreakdown;
  final List<GoldMovement> movements;
  final DateTime generatedAt;

  GoldMovementReport({
    required this.startDate,
    required this.endDate,
    required this.totalIncoming,
    required this.totalOutgoing,
    required this.netMovement,
    required this.karatBreakdown,
    required this.typeBreakdown,
    required this.movements,
    required this.generatedAt,
  });
}

class SaleData {
  final DateTime date;
  final String clientName;
  final double totalAmount;
  final String? paymentMethod;
  final List<SaleItem> items;

  SaleData({
    required this.date,
    required this.clientName,
    required this.totalAmount,
    this.paymentMethod,
    required this.items,
  });
}

class SaleItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  SaleItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class InventoryData {
  final String name;
  final String category;
  final int quantity;
  final double unitPrice;
  final int minStockLevel;

  InventoryData({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.minStockLevel,
  });
}

class RevenueData {
  final double totalSales;
  final double totalTax;
  final double totalDiscount;

  RevenueData({
    required this.totalSales,
    required this.totalTax,
    required this.totalDiscount,
  });
}

class CostData {
  final double costOfGoodsSold;
  final double operatingExpenses;
  final double laborCosts;

  CostData({
    required this.costOfGoodsSold,
    required this.operatingExpenses,
    required this.laborCosts,
  });
}

enum GoldMovementType {
  incoming,
  outgoing,
  transfer
}

class GoldMovement {
  final DateTime date;
  final GoldMovementType type;
  final double weight;
  final int karat;
  final String description;
  final String? reference;

  GoldMovement({
    required this.date,
    required this.type,
    required this.weight,
    required this.karat,
    required this.description,
    this.reference,
  });
}

// مولد الرسوم البيانية
class ChartGenerator {
  static Widget generateSalesChart(Map<DateTime, double> dailySales) {
    final spots = dailySales.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  static Widget generatePieChart(Map<String, double> data) {
    final sections = data.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 100,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  static Widget generateBarChart(Map<String, double> data) {
    final barGroups = data.entries.map((entry) {
      return BarChartGroupData(
        x: data.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 20,
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}

