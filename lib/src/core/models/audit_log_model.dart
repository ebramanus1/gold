class AuditLog {
  final String id;
  final String userId;
  final String action;
  final String tableName;
  final String recordId;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? description;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;
  
  // Additional fields from joins
  final String? userName;
  final String? userFullName;

  AuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.tableName,
    required this.recordId,
    this.oldValues,
    this.newValues,
    this.description,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
    this.userName,
    this.userFullName,
  });

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      action: map['action'] ?? '',
      tableName: map['table_name'] ?? '',
      recordId: map['record_id'] ?? '',
      oldValues: map['old_values'] != null 
          ? Map<String, dynamic>.from(map['old_values'] is String 
              ? {} // Handle JSON string case
              : map['old_values'])
          : null,
      newValues: map['new_values'] != null
          ? Map<String, dynamic>.from(map['new_values'] is String
              ? {} // Handle JSON string case
              : map['new_values'])
          : null,
      description: map['description'],
      ipAddress: map['ip_address'],
      userAgent: map['user_agent'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      userName: map['user_name'],
      userFullName: map['user_full_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'table_name': tableName,
      'record_id': recordId,
      'old_values': oldValues,
      'new_values': newValues,
      'description': description,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AuditLog copyWith({
    String? id,
    String? userId,
    String? action,
    String? tableName,
    String? recordId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? description,
    String? ipAddress,
    String? userAgent,
    DateTime? createdAt,
    String? userName,
    String? userFullName,
  }) {
    return AuditLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      oldValues: oldValues ?? this.oldValues,
      newValues: newValues ?? this.newValues,
      description: description ?? this.description,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userFullName: userFullName ?? this.userFullName,
    );
  }

  // التحقق من نوع العملية
  bool get isInsert => action.toUpperCase() == 'INSERT';
  bool get isUpdate => action.toUpperCase() == 'UPDATE';
  bool get isDelete => action.toUpperCase() == 'DELETE';

  // الحصول على وصف العملية بالعربية
  String get actionDescription {
    switch (action.toUpperCase()) {
      case 'INSERT':
        return 'إضافة';
      case 'UPDATE':
        return 'تعديل';
      case 'DELETE':
        return 'حذف';
      case 'LOGIN':
        return 'تسجيل دخول';
      case 'LOGOUT':
        return 'تسجيل خروج';
      default:
        return action;
    }
  }

  // الحصول على اسم الجدول بالعربية
  String get tableNameArabic {
    switch (tableName.toLowerCase()) {
      case 'users':
        return 'المستخدمين';
      case 'clients':
        return 'العملاء';
      case 'raw_materials':
        return 'المواد الخام';
      case 'work_orders':
        return 'أوامر العمل';
      case 'finished_goods':
        return 'المنتجات النهائية';
      case 'transactions':
        return 'المعاملات';
      case 'invoices':
        return 'الفواتير';
      default:
        return tableName;
    }
  }

  // الحصول على ملخص التغييرات
  String get changesSummary {
    if (isInsert) {
      return 'تم إنشاء سجل جديد';
    } else if (isDelete) {
      return 'تم حذف السجل';
    } else if (isUpdate && oldValues != null && newValues != null) {
      final changes = <String>[];
      newValues!.forEach((key, value) {
        if (oldValues![key] != value) {
          changes.add('$key: ${oldValues![key]} → $value');
        }
      });
      return changes.isNotEmpty ? changes.join(', ') : 'لا توجد تغييرات';
    }
    return description ?? 'غير محدد';
  }

  // تحديد مستوى الأهمية
  AuditLogSeverity get severity {
    if (isDelete) return AuditLogSeverity.high;
    if (tableName.toLowerCase() == 'users' || tableName.toLowerCase() == 'clients') {
      return AuditLogSeverity.medium;
    }
    return AuditLogSeverity.low;
  }

  @override
  String toString() {
    return 'AuditLog(id: $id, action: $action, table: $tableName, user: $userFullName, time: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// تعداد أنواع العمليات في سجل التدقيق
enum AuditAction {
  insert('INSERT', 'إضافة'),
  update('UPDATE', 'تعديل'),
  delete('DELETE', 'حذف'),
  login('LOGIN', 'تسجيل دخول'),
  logout('LOGOUT', 'تسجيل خروج'),
  view('VIEW', 'عرض'),
  export('EXPORT', 'تصدير'),
  print('PRINT', 'طباعة');

  const AuditAction(this.value, this.arabicName);
  
  final String value;
  final String arabicName;

  static AuditAction fromString(String value) {
    return AuditAction.values.firstWhere(
      (action) => action.value.toUpperCase() == value.toUpperCase(),
      orElse: () => AuditAction.view,
    );
  }
}

// تعداد مستويات الأهمية
enum AuditLogSeverity {
  low('low', 'منخفض'),
  medium('medium', 'متوسط'),
  high('high', 'عالي'),
  critical('critical', 'حرج');

  const AuditLogSeverity(this.value, this.arabicName);
  
  final String value;
  final String arabicName;

  static AuditLogSeverity fromString(String value) {
    return AuditLogSeverity.values.firstWhere(
      (severity) => severity.value == value,
      orElse: () => AuditLogSeverity.low,
    );
  }
}

// فئة لتصفية سجلات التدقيق
class AuditLogFilter {
  final String? userId;
  final String? action;
  final String? tableName;
  final DateTime? fromDate;
  final DateTime? toDate;
  final AuditLogSeverity? severity;

  AuditLogFilter({
    this.userId,
    this.action,
    this.tableName,
    this.fromDate,
    this.toDate,
    this.severity,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'action': action,
      'table_name': tableName,
      'from_date': fromDate?.toIso8601String(),
      'to_date': toDate?.toIso8601String(),
      'severity': severity?.value,
    };
  }

  bool get hasFilters {
    return userId != null ||
           action != null ||
           tableName != null ||
           fromDate != null ||
           toDate != null ||
           severity != null;
  }
}

// فئة لإحصائيات سجل التدقيق
class AuditLogStats {
  final int totalLogs;
  final int todayLogs;
  final int thisWeekLogs;
  final int thisMonthLogs;
  final Map<String, int> actionCounts;
  final Map<String, int> tableCounts;
  final Map<String, int> userCounts;

  AuditLogStats({
    required this.totalLogs,
    required this.todayLogs,
    required this.thisWeekLogs,
    required this.thisMonthLogs,
    required this.actionCounts,
    required this.tableCounts,
    required this.userCounts,
  });

  factory AuditLogStats.fromMap(Map<String, dynamic> map) {
    return AuditLogStats(
      totalLogs: map['total_logs'] ?? 0,
      todayLogs: map['today_logs'] ?? 0,
      thisWeekLogs: map['this_week_logs'] ?? 0,
      thisMonthLogs: map['this_month_logs'] ?? 0,
      actionCounts: Map<String, int>.from(map['action_counts'] ?? {}),
      tableCounts: Map<String, int>.from(map['table_counts'] ?? {}),
      userCounts: Map<String, int>.from(map['user_counts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_logs': totalLogs,
      'today_logs': todayLogs,
      'this_week_logs': thisWeekLogs,
      'this_month_logs': thisMonthLogs,
      'action_counts': actionCounts,
      'table_counts': tableCounts,
      'user_counts': userCounts,
    };
  }
}

