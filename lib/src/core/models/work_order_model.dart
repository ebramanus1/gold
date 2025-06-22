class WorkOrder {
  final String id;
  final String orderNumber;
  final String rawMaterialId;
  final String artisanId;
  final String? designId;
  final String designName;
  final double assignedWeight;
  final String assignedKarat;
  final String status;
  final DateTime? startDate;
  final DateTime? expectedCompletionDate;
  final DateTime? actualCompletionDate;
  final double? finishedWeight;
  final double? returnedScrapWeight;
  final double? wasteLoss;
  final double? wastePercentage;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields from joins
  final String? lotBatchNumber;
  final String? artisanName;
  final String? createdByName;

  WorkOrder({
    required this.id,
    required this.orderNumber,
    required this.rawMaterialId,
    required this.artisanId,
    this.designId,
    required this.designName,
    required this.assignedWeight,
    required this.assignedKarat,
    this.status = 'assigned',
    this.startDate,
    this.expectedCompletionDate,
    this.actualCompletionDate,
    this.finishedWeight,
    this.returnedScrapWeight,
    this.wasteLoss,
    this.wastePercentage,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lotBatchNumber,
    this.artisanName,
    this.createdByName,
  });

  factory WorkOrder.fromMap(Map<String, dynamic> map) {
    return WorkOrder(
      id: map['id'] ?? '',
      orderNumber: map['order_number'] ?? '',
      rawMaterialId: map['raw_material_id'] ?? '',
      artisanId: map['artisan_id'] ?? '',
      designId: map['design_id'],
      designName: map['design_name'] ?? '',
      assignedWeight: (map['assigned_weight'] ?? 0.0).toDouble(),
      assignedKarat: map['assigned_karat'] ?? '',
      status: map['status'] ?? 'assigned',
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      expectedCompletionDate: map['expected_completion_date'] != null 
          ? DateTime.parse(map['expected_completion_date']) 
          : null,
      actualCompletionDate: map['actual_completion_date'] != null 
          ? DateTime.parse(map['actual_completion_date']) 
          : null,
      finishedWeight: map['finished_weight']?.toDouble(),
      returnedScrapWeight: map['returned_scrap_weight']?.toDouble(),
      wasteLoss: map['waste_loss']?.toDouble(),
      wastePercentage: map['waste_percentage']?.toDouble(),
      notes: map['notes'],
      createdBy: map['created_by'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
      lotBatchNumber: map['lot_batch_number'],
      artisanName: map['artisan_name'],
      createdByName: map['created_by_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'raw_material_id': rawMaterialId,
      'artisan_id': artisanId,
      'design_id': designId,
      'design_name': designName,
      'assigned_weight': assignedWeight,
      'assigned_karat': assignedKarat,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'expected_completion_date': expectedCompletionDate?.toIso8601String(),
      'actual_completion_date': actualCompletionDate?.toIso8601String(),
      'finished_weight': finishedWeight,
      'returned_scrap_weight': returnedScrapWeight,
      'waste_loss': wasteLoss,
      'waste_percentage': wastePercentage,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WorkOrder copyWith({
    String? id,
    String? orderNumber,
    String? rawMaterialId,
    String? artisanId,
    String? designId,
    String? designName,
    double? assignedWeight,
    String? assignedKarat,
    String? status,
    DateTime? startDate,
    DateTime? expectedCompletionDate,
    DateTime? actualCompletionDate,
    double? finishedWeight,
    double? returnedScrapWeight,
    double? wasteLoss,
    double? wastePercentage,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lotBatchNumber,
    String? artisanName,
    String? createdByName,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      rawMaterialId: rawMaterialId ?? this.rawMaterialId,
      artisanId: artisanId ?? this.artisanId,
      designId: designId ?? this.designId,
      designName: designName ?? this.designName,
      assignedWeight: assignedWeight ?? this.assignedWeight,
      assignedKarat: assignedKarat ?? this.assignedKarat,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      expectedCompletionDate: expectedCompletionDate ?? this.expectedCompletionDate,
      actualCompletionDate: actualCompletionDate ?? this.actualCompletionDate,
      finishedWeight: finishedWeight ?? this.finishedWeight,
      returnedScrapWeight: returnedScrapWeight ?? this.returnedScrapWeight,
      wasteLoss: wasteLoss ?? this.wasteLoss,
      wastePercentage: wastePercentage ?? this.wastePercentage,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lotBatchNumber: lotBatchNumber ?? this.lotBatchNumber,
      artisanName: artisanName ?? this.artisanName,
      createdByName: createdByName ?? this.createdByName,
    );
  }

  // التحقق من حالات أمر العمل
  bool get isAssigned => status == 'assigned';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  // حساب المدة المتوقعة للإنجاز
  Duration? get expectedDuration {
    if (startDate != null && expectedCompletionDate != null) {
      return expectedCompletionDate!.difference(startDate!);
    }
    return null;
  }

  // حساب المدة الفعلية للإنجاز
  Duration? get actualDuration {
    if (startDate != null && actualCompletionDate != null) {
      return actualCompletionDate!.difference(startDate!);
    }
    return null;
  }

  // حساب نسبة الإنجاز
  double get completionPercentage {
    if (isCompleted) return 100.0;
    if (isInProgress) {
      if (startDate != null && expectedCompletionDate != null) {
        final now = DateTime.now();
        final totalDuration = expectedCompletionDate!.difference(startDate!);
        final elapsedDuration = now.difference(startDate!);
        
        if (elapsedDuration.inMilliseconds <= 0) return 0.0;
        if (elapsedDuration >= totalDuration) return 95.0; // تقريباً مكتمل
        
        return (elapsedDuration.inMilliseconds / totalDuration.inMilliseconds) * 100;
      }
    }
    return 0.0;
  }

  // التحقق من تأخر أمر العمل
  bool get isOverdue {
    if (expectedCompletionDate == null || isCompleted) return false;
    return DateTime.now().isAfter(expectedCompletionDate!);
  }

  // حساب كفاءة الحرفي (عكس نسبة الهدر)
  double get artisanEfficiency {
    if (wastePercentage == null) return 0.0;
    return 100.0 - wastePercentage!;
  }

  @override
  String toString() {
    return 'WorkOrder(id: $id, orderNumber: $orderNumber, artisan: $artisanName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// تعداد حالات أوامر العمل
enum WorkOrderStatus {
  assigned('assigned', 'مخصص'),
  inProgress('in_progress', 'قيد التنفيذ'),
  completed('completed', 'مكتمل'),
  cancelled('cancelled', 'ملغي');

  const WorkOrderStatus(this.value, this.arabicName);
  
  final String value;
  final String arabicName;

  static WorkOrderStatus fromString(String value) {
    return WorkOrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => WorkOrderStatus.assigned,
    );
  }
}

// فئة لتتبع تقدم أمر العمل
class WorkOrderProgress {
  final String workOrderId;
  final DateTime timestamp;
  final String status;
  final String? notes;
  final String updatedBy;

  WorkOrderProgress({
    required this.workOrderId,
    required this.timestamp,
    required this.status,
    this.notes,
    required this.updatedBy,
  });

  factory WorkOrderProgress.fromMap(Map<String, dynamic> map) {
    return WorkOrderProgress(
      workOrderId: map['work_order_id'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? '',
      notes: map['notes'],
      updatedBy: map['updated_by'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'work_order_id': workOrderId,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'notes': notes,
      'updated_by': updatedBy,
    };
  }
}

