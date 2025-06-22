import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _apiKey = 'YOUR_SENDGRID_API_KEY'; // مفتاح SendGrid API
  static const String _baseUrl = 'https://api.sendgrid.com/v3/mail/send';
  
  // إرسال تقرير عبر البريد الإلكتروني
  static Future<EmailResult> sendReport({
    required String recipientEmail,
    required String recipientName,
    required String subject,
    required String reportContent,
    List<String> attachments = const [],
    String? senderEmail,
    String? senderName,
  }) async {
    try {
      final emailData = {
        'personalizations': [
          {
            'to': [
              {
                'email': recipientEmail,
                'name': recipientName,
              }
            ],
            'subject': subject,
          }
        ],
        'from': {
          'email': senderEmail ?? 'noreply@goldworkshop.com',
          'name': senderName ?? 'Gold Workshop AI',
        },
        'content': [
          {
            'type': 'text/html',
            'value': _generateEmailTemplate(reportContent),
          }
        ],
      };

      // إضافة المرفقات
      if (attachments.isNotEmpty) {
        emailData['attachments'] = await _prepareAttachments(attachments);
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(emailData),
      );

      if (response.statusCode == 202) {
        return EmailResult(
          success: true,
          message: 'تم إرسال التقرير بنجاح',
          recipientEmail: recipientEmail,
        );
      } else {
        return EmailResult(
          success: false,
          message: 'فشل في إرسال التقرير: ${response.body}',
          recipientEmail: recipientEmail,
          error: response.body,
        );
      }
    } catch (e) {
      return EmailResult(
        success: false,
        message: 'خطأ في إرسال البريد الإلكتروني: $e',
        recipientEmail: recipientEmail,
        error: e.toString(),
      );
    }
  }

  // إرسال تقرير مبيعات
  static Future<EmailResult> sendSalesReport({
    required String recipientEmail,
    required String recipientName,
    required Map<String, dynamic> salesData,
    required String period,
    String? pdfPath,
  }) async {
    final subject = 'تقرير المبيعات - $period';
    final content = _generateSalesReportContent(salesData, period);
    final attachments = pdfPath != null ? [pdfPath] : <String>[];

    return await sendReport(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      reportContent: content,
      attachments: attachments,
    );
  }

  // إرسال تقرير المخزون
  static Future<EmailResult> sendInventoryReport({
    required String recipientEmail,
    required String recipientName,
    required Map<String, dynamic> inventoryData,
    String? pdfPath,
  }) async {
    final subject = 'تقرير المخزون - ${DateTime.now().toString().split(' ')[0]}';
    final content = _generateInventoryReportContent(inventoryData);
    final attachments = pdfPath != null ? [pdfPath] : <String>[];

    return await sendReport(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      reportContent: content,
      attachments: attachments,
    );
  }

  // إرسال تقرير الأرباح والخسائر
  static Future<EmailResult> sendProfitLossReport({
    required String recipientEmail,
    required String recipientName,
    required Map<String, dynamic> profitLossData,
    required String period,
    String? pdfPath,
  }) async {
    final subject = 'تقرير الأرباح والخسائر - $period';
    final content = _generateProfitLossReportContent(profitLossData, period);
    final attachments = pdfPath != null ? [pdfPath] : <String>[];

    return await sendReport(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      reportContent: content,
      attachments: attachments,
    );
  }

  // إرسال تنبيه نفاد المخزون
  static Future<EmailResult> sendLowStockAlert({
    required String recipientEmail,
    required String recipientName,
    required List<Map<String, dynamic>> lowStockItems,
  }) async {
    final subject = 'تنبيه: نفاد المخزون';
    final content = _generateLowStockAlertContent(lowStockItems);

    return await sendReport(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      reportContent: content,
    );
  }

  // إرسال تنبيه أوامر العمل المتأخرة
  static Future<EmailResult> sendOverdueWorkOrdersAlert({
    required String recipientEmail,
    required String recipientName,
    required List<Map<String, dynamic>> overdueOrders,
  }) async {
    final subject = 'تنبيه: أوامر عمل متأخرة';
    final content = _generateOverdueOrdersAlertContent(overdueOrders);

    return await sendReport(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      reportContent: content,
    );
  }

  // إرسال تقرير يومي
  static Future<EmailResult> sendDailyReport({
    required String recipientEmail,
    required String recipientName,
    required Map<String, dynamic> dailyData,
  }) async {
    final today = DateTime.now().toString().split(' ')[0];
    final subject = 'التقرير اليومي - $today';
    final content = _generateDailyReportContent(dailyData);

    return await sendReport(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      reportContent: content,
    );
  }

  // إرسال تقرير أسبوعي
  static Future<EmailResult> sendWeeklyReport({
    required String recipientEmail,
    required String recipientName,
    required Map<String, dynamic> weeklyData,
    String? pdfPath,
  }) async {
    final subject = 'التقرير الأسبوعي';
    final content = _generateWeeklyReportContent(weeklyData);
    final attachments = pdfPath != null ? [pdfPath] : <String>[];

    return await sendReport(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      reportContent: content,
      attachments: attachments,
    );
  }

  // إرسال تقرير شهري
  static Future<EmailResult> sendMonthlyReport({
    required String recipientEmail,
    required String recipientName,
    required Map<String, dynamic> monthlyData,
    String? pdfPath,
  }) async {
    final subject = 'التقرير الشهري';
    final content = _generateMonthlyReportContent(monthlyData);
    final attachments = pdfPath != null ? [pdfPath] : <String>[];

    return await sendReport(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      reportContent: content,
      attachments: attachments,
    );
  }

  // إعداد المرفقات
  static Future<List<Map<String, dynamic>>> _prepareAttachments(List<String> attachmentPaths) async {
    final attachments = <Map<String, dynamic>>[];

    for (final path in attachmentPaths) {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final base64Content = base64Encode(bytes);
        final fileName = path.split('/').last;

        attachments.add({
          'content': base64Content,
          'filename': fileName,
          'type': _getMimeType(fileName),
          'disposition': 'attachment',
        });
      }
    }

    return attachments;
  }

  // الحصول على نوع MIME
  static String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'xlsx':
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'csv':
        return 'text/csv';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  // إنشاء قالب البريد الإلكتروني
  static String _generateEmailTemplate(String content) {
    return '''
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>تقرير Gold Workshop AI</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f4f4f4;
            }
            .container {
                background-color: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
            }
            .header {
                text-align: center;
                border-bottom: 3px solid #d4af37;
                padding-bottom: 20px;
                margin-bottom: 30px;
            }
            .header h1 {
                color: #d4af37;
                margin: 0;
                font-size: 28px;
            }
            .header p {
                color: #666;
                margin: 5px 0 0 0;
            }
            .content {
                margin-bottom: 30px;
            }
            .footer {
                text-align: center;
                border-top: 1px solid #eee;
                padding-top: 20px;
                color: #666;
                font-size: 14px;
            }
            .highlight {
                background-color: #fff3cd;
                border: 1px solid #ffeaa7;
                border-radius: 5px;
                padding: 15px;
                margin: 15px 0;
            }
            .table {
                width: 100%;
                border-collapse: collapse;
                margin: 20px 0;
            }
            .table th, .table td {
                border: 1px solid #ddd;
                padding: 12px;
                text-align: right;
            }
            .table th {
                background-color: #f8f9fa;
                font-weight: bold;
            }
            .table tr:nth-child(even) {
                background-color: #f8f9fa;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Gold Workshop AI</h1>
                <p>نظام إدارة ورشة الذهب</p>
            </div>
            <div class="content">
                $content
            </div>
            <div class="footer">
                <p>تم إنشاء هذا التقرير تلقائياً بواسطة نظام Gold Workshop AI</p>
                <p>التاريخ: ${DateTime.now().toString().split(' ')[0]}</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // إنشاء محتوى تقرير المبيعات
  static String _generateSalesReportContent(Map<String, dynamic> salesData, String period) {
    final totalSales = salesData['totalSales'] ?? 0.0;
    final totalTransactions = salesData['totalTransactions'] ?? 0;
    final averageTransaction = salesData['averageTransaction'] ?? 0.0;

    return '''
    <h2>تقرير المبيعات - $period</h2>
    
    <div class="highlight">
        <h3>ملخص المبيعات</h3>
        <p><strong>إجمالي المبيعات:</strong> ${totalSales.toStringAsFixed(2)} ريال</p>
        <p><strong>عدد المعاملات:</strong> $totalTransactions</p>
        <p><strong>متوسط المعاملة:</strong> ${averageTransaction.toStringAsFixed(2)} ريال</p>
    </div>
    
    <h3>تفاصيل المبيعات</h3>
    <p>يرجى مراجعة الملف المرفق للحصول على تفاصيل أكثر.</p>
    ''';
  }

  // إنشاء محتوى تقرير المخزون
  static String _generateInventoryReportContent(Map<String, dynamic> inventoryData) {
    final totalItems = inventoryData['totalItems'] ?? 0;
    final lowStockItems = inventoryData['lowStockItems'] ?? 0;
    final outOfStockItems = inventoryData['outOfStockItems'] ?? 0;
    final totalValue = inventoryData['totalValue'] ?? 0.0;

    return '''
    <h2>تقرير المخزون</h2>
    
    <div class="highlight">
        <h3>ملخص المخزون</h3>
        <p><strong>إجمالي الأصناف:</strong> $totalItems</p>
        <p><strong>قيمة المخزون:</strong> ${totalValue.toStringAsFixed(2)} ريال</p>
        <p><strong>أصناف منخفضة المخزون:</strong> $lowStockItems</p>
        <p><strong>أصناف نفد مخزونها:</strong> $outOfStockItems</p>
    </div>
    
    ${lowStockItems > 0 ? '<div class="highlight" style="background-color: #f8d7da; border-color: #f5c6cb;"><h3>تنبيه</h3><p>يوجد $lowStockItems صنف يحتاج إلى إعادة تخزين.</p></div>' : ''}
    ''';
  }

  // إنشاء محتوى تقرير الأرباح والخسائر
  static String _generateProfitLossReportContent(Map<String, dynamic> profitLossData, String period) {
    final revenue = profitLossData['revenue'] ?? 0.0;
    final costs = profitLossData['costs'] ?? 0.0;
    final grossProfit = profitLossData['grossProfit'] ?? 0.0;
    final netProfit = profitLossData['netProfit'] ?? 0.0;

    return '''
    <h2>تقرير الأرباح والخسائر - $period</h2>
    
    <table class="table">
        <tr>
            <th>البيان</th>
            <th>المبلغ (ريال)</th>
        </tr>
        <tr>
            <td>الإيرادات</td>
            <td>${revenue.toStringAsFixed(2)}</td>
        </tr>
        <tr>
            <td>التكاليف</td>
            <td>${costs.toStringAsFixed(2)}</td>
        </tr>
        <tr>
            <td>الربح الإجمالي</td>
            <td>${grossProfit.toStringAsFixed(2)}</td>
        </tr>
        <tr style="background-color: ${netProfit >= 0 ? '#d4edda' : '#f8d7da'};">
            <td><strong>الربح الصافي</strong></td>
            <td><strong>${netProfit.toStringAsFixed(2)}</strong></td>
        </tr>
    </table>
    ''';
  }

  // إنشاء محتوى تنبيه نفاد المخزون
  static String _generateLowStockAlertContent(List<Map<String, dynamic>> lowStockItems) {
    final itemsHtml = lowStockItems.map((item) {
      return '<tr><td>${item['name']}</td><td>${item['currentStock']}</td><td>${item['minStock']}</td></tr>';
    }).join('');

    return '''
    <h2>تنبيه: نفاد المخزون</h2>
    
    <div class="highlight" style="background-color: #f8d7da; border-color: #f5c6cb;">
        <p><strong>تنبيه:</strong> يوجد ${lowStockItems.length} صنف يحتاج إلى إعادة تخزين فوري.</p>
    </div>
    
    <table class="table">
        <tr>
            <th>اسم المنتج</th>
            <th>المخزون الحالي</th>
            <th>الحد الأدنى</th>
        </tr>
        $itemsHtml
    </table>
    
    <p>يرجى اتخاذ الإجراءات اللازمة لإعادة تخزين هذه الأصناف.</p>
    ''';
  }

  // إنشاء محتوى تنبيه أوامر العمل المتأخرة
  static String _generateOverdueOrdersAlertContent(List<Map<String, dynamic>> overdueOrders) {
    final ordersHtml = overdueOrders.map((order) {
      return '<tr><td>${order['orderNumber']}</td><td>${order['clientName']}</td><td>${order['dueDate']}</td><td>${order['daysOverdue']}</td></tr>';
    }).join('');

    return '''
    <h2>تنبيه: أوامر عمل متأخرة</h2>
    
    <div class="highlight" style="background-color: #f8d7da; border-color: #f5c6cb;">
        <p><strong>تنبيه:</strong> يوجد ${overdueOrders.length} أمر عمل متأخر عن الموعد المحدد.</p>
    </div>
    
    <table class="table">
        <tr>
            <th>رقم الأمر</th>
            <th>العميل</th>
            <th>تاريخ الاستحقاق</th>
            <th>أيام التأخير</th>
        </tr>
        $ordersHtml
    </table>
    
    <p>يرجى متابعة هذه الأوامر لضمان إنجازها في أقرب وقت ممكن.</p>
    ''';
  }

  // إنشاء محتوى التقرير اليومي
  static String _generateDailyReportContent(Map<String, dynamic> dailyData) {
    return '''
    <h2>التقرير اليومي</h2>
    
    <div class="highlight">
        <h3>ملخص اليوم</h3>
        <p><strong>مبيعات اليوم:</strong> ${(dailyData['todaySales'] ?? 0.0).toStringAsFixed(2)} ريال</p>
        <p><strong>عدد المعاملات:</strong> ${dailyData['todayTransactions'] ?? 0}</p>
        <p><strong>أوامر عمل جديدة:</strong> ${dailyData['newWorkOrders'] ?? 0}</p>
        <p><strong>أوامر عمل مكتملة:</strong> ${dailyData['completedWorkOrders'] ?? 0}</p>
    </div>
    ''';
  }

  // إنشاء محتوى التقرير الأسبوعي
  static String _generateWeeklyReportContent(Map<String, dynamic> weeklyData) {
    return '''
    <h2>التقرير الأسبوعي</h2>
    
    <div class="highlight">
        <h3>ملخص الأسبوع</h3>
        <p><strong>مبيعات الأسبوع:</strong> ${(weeklyData['weekSales'] ?? 0.0).toStringAsFixed(2)} ريال</p>
        <p><strong>نمو المبيعات:</strong> ${(weeklyData['salesGrowth'] ?? 0.0).toStringAsFixed(1)}%</p>
        <p><strong>أوامر عمل منجزة:</strong> ${weeklyData['completedOrders'] ?? 0}</p>
        <p><strong>عملاء جدد:</strong> ${weeklyData['newClients'] ?? 0}</p>
    </div>
    ''';
  }

  // إنشاء محتوى التقرير الشهري
  static String _generateMonthlyReportContent(Map<String, dynamic> monthlyData) {
    return '''
    <h2>التقرير الشهري</h2>
    
    <div class="highlight">
        <h3>ملخص الشهر</h3>
        <p><strong>مبيعات الشهر:</strong> ${(monthlyData['monthSales'] ?? 0.0).toStringAsFixed(2)} ريال</p>
        <p><strong>صافي الربح:</strong> ${(monthlyData['netProfit'] ?? 0.0).toStringAsFixed(2)} ريال</p>
        <p><strong>هامش الربح:</strong> ${(monthlyData['profitMargin'] ?? 0.0).toStringAsFixed(1)}%</p>
        <p><strong>أفضل منتج:</strong> ${monthlyData['topProduct'] ?? 'غير محدد'}</p>
    </div>
    ''';
  }
}

// نموذج نتيجة الإرسال
class EmailResult {
  final bool success;
  final String message;
  final String recipientEmail;
  final String? error;
  final DateTime sentAt;

  EmailResult({
    required this.success,
    required this.message,
    required this.recipientEmail,
    this.error,
  }) : sentAt = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'recipientEmail': recipientEmail,
      'error': error,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  factory EmailResult.fromJson(Map<String, dynamic> json) {
    return EmailResult(
      success: json['success'],
      message: json['message'],
      recipientEmail: json['recipientEmail'],
      error: json['error'],
    );
  }
}

// إعدادات البريد الإلكتروني
class EmailSettings {
  final String senderEmail;
  final String senderName;
  final List<String> defaultRecipients;
  final bool enableDailyReports;
  final bool enableWeeklyReports;
  final bool enableMonthlyReports;
  final bool enableAlerts;
  final String reportTime; // HH:mm format

  EmailSettings({
    required this.senderEmail,
    required this.senderName,
    this.defaultRecipients = const [],
    this.enableDailyReports = false,
    this.enableWeeklyReports = false,
    this.enableMonthlyReports = false,
    this.enableAlerts = true,
    this.reportTime = '09:00',
  });

  factory EmailSettings.fromJson(Map<String, dynamic> json) {
    return EmailSettings(
      senderEmail: json['senderEmail'],
      senderName: json['senderName'],
      defaultRecipients: List<String>.from(json['defaultRecipients'] ?? []),
      enableDailyReports: json['enableDailyReports'] ?? false,
      enableWeeklyReports: json['enableWeeklyReports'] ?? false,
      enableMonthlyReports: json['enableMonthlyReports'] ?? false,
      enableAlerts: json['enableAlerts'] ?? true,
      reportTime: json['reportTime'] ?? '09:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderEmail': senderEmail,
      'senderName': senderName,
      'defaultRecipients': defaultRecipients,
      'enableDailyReports': enableDailyReports,
      'enableWeeklyReports': enableWeeklyReports,
      'enableMonthlyReports': enableMonthlyReports,
      'enableAlerts': enableAlerts,
      'reportTime': reportTime,
    };
  }
}

