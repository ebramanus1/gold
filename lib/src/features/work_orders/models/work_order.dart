import 'package:flutter/material.dart';
import '../../../services/database/database_service.dart' as db;

enum WorkOrderType {
  manufacturing,
  repair,
  polishing,
  custom
}

enum WorkOrderStatus {
  pending,
  inProgress,
  completed,
  cancelled,
  delayed
}

enum WorkOrderPriority {
  low,
  medium,
  high,
  urgent
}

class WorkOrder {
  final String id;
  final String orderNumber;
  final String clientId;
  final String clientName;
  final WorkOrderType type;
  final WorkOrderStatus status;
  final WorkOrderPriority priority;
  final String description;
  final String? notes;
  final DateTime createdDate;
  final DateTime? startDate;
  final DateTime? expectedCompletionDate;
  final DateTime? actualCompletionDate;
  final double estimatedCost;
  final double actualCost;
  final double laborCost;
  final double materialCost;
  final double additionalCost;
  final String? assignedCraftsman;
  final List<String> attachments;
  final List<WorkOrderItem> items;
  final Map<String, dynamic> customFields;

  WorkOrder({
    required this.id,
    required this.orderNumber,
    required this.clientId,
    required this.clientName,
    required this.type,
    required this.status,
    required this.priority,
    required this.description,
    this.notes,
    required this.createdDate,
    this.startDate,
    this.expectedCompletionDate,
    this.actualCompletionDate,
    required this.estimatedCost,
    this.actualCost = 0.0,
    this.laborCost = 0.0,
    this.materialCost = 0.0,
    this.additionalCost = 0.0,
    this.assignedCraftsman,
    this.attachments = const [],
    this.items = const [],
    this.customFields = const {},
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      id: json['id'],
      orderNumber: json['orderNumber'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      type: WorkOrderType.values[json['type']],
      status: WorkOrderStatus.values[json['status']],
      priority: WorkOrderPriority.values[json['priority']],
      description: json['description'],
      notes: json['notes'],
      createdDate: DateTime.parse(json['createdDate']),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      expectedCompletionDate: json['expectedCompletionDate'] != null 
          ? DateTime.parse(json['expectedCompletionDate']) : null,
      actualCompletionDate: json['actualCompletionDate'] != null 
          ? DateTime.parse(json['actualCompletionDate']) : null,
      estimatedCost: json['estimatedCost'].toDouble(),
      actualCost: json['actualCost']?.toDouble() ?? 0.0,
      laborCost: json['laborCost']?.toDouble() ?? 0.0,
      materialCost: json['materialCost']?.toDouble() ?? 0.0,
      additionalCost: json['additionalCost']?.toDouble() ?? 0.0,
      assignedCraftsman: json['assignedCraftsman'],
      attachments: List<String>.from(json['attachments'] ?? []),
      items: (json['items'] as List?)?.map((item) => WorkOrderItem.fromJson(item)).toList() ?? [],
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
    );
  }

  factory WorkOrder.fromDrift(db.WorkOrder data) {
    return WorkOrder(
      id: data.id,
      orderNumber: data.orderNumber ?? '',
      clientId: data.customerId ?? '',
      clientName: data.clientName ?? '',
      type: WorkOrderType.values[data.type],
      status: WorkOrderStatus.values[data.status],
      priority: WorkOrderPriority.medium, // افتراضي حتى يتم دعم الحقل
      description: data.description ?? '',
      notes: data.notes,
      createdDate: data.createdDate,
      startDate: data.startDate,
      expectedCompletionDate: data.expectedCompletionDate,
      actualCompletionDate: data.actualCompletionDate,
      estimatedCost: data.estimatedCost ?? 0.0,
      actualCost: data.actualCost ?? 0.0,
      laborCost: 0.0,
      materialCost: 0.0,
      additionalCost: 0.0,
      assignedCraftsman: data.assignedCraftsman,
      attachments: const [],
      items: const [],
      customFields: const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'clientId': clientId,
      'clientName': clientName,
      'type': type.index,
      'status': status.index,
      'priority': priority.index,
      'description': description,
      'notes': notes,
      'createdDate': createdDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'expectedCompletionDate': expectedCompletionDate?.toIso8601String(),
      'actualCompletionDate': actualCompletionDate?.toIso8601String(),
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'laborCost': laborCost,
      'materialCost': materialCost,
      'additionalCost': additionalCost,
      'assignedCraftsman': assignedCraftsman,
      'attachments': attachments,
      'items': items.map((item) => item.toJson()).toList(),
      'customFields': customFields,
    };
  }

  WorkOrder copyWith({
    String? id,
    String? orderNumber,
    String? clientId,
    String? clientName,
    WorkOrderType? type,
    WorkOrderStatus? status,
    WorkOrderPriority? priority,
    String? description,
    String? notes,
    DateTime? createdDate,
    DateTime? startDate,
    DateTime? expectedCompletionDate,
    DateTime? actualCompletionDate,
    double? estimatedCost,
    double? actualCost,
    double? laborCost,
    double? materialCost,
    double? additionalCost,
    String? assignedCraftsman,
    List<String>? attachments,
    List<WorkOrderItem>? items,
    Map<String, dynamic>? customFields,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      startDate: startDate ?? this.startDate,
      expectedCompletionDate: expectedCompletionDate ?? this.expectedCompletionDate,
      actualCompletionDate: actualCompletionDate ?? this.actualCompletionDate,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      laborCost: laborCost ?? this.laborCost,
      materialCost: materialCost ?? this.materialCost,
      additionalCost: additionalCost ?? this.additionalCost,
      assignedCraftsman: assignedCraftsman ?? this.assignedCraftsman,
      attachments: attachments ?? this.attachments,
      items: items ?? this.items,
      customFields: customFields ?? this.customFields,
    );
  }

  double get totalCost => laborCost + materialCost + additionalCost;
  
  bool get isOverdue => expectedCompletionDate != null && 
      DateTime.now().isAfter(expectedCompletionDate!) && 
      status != WorkOrderStatus.completed;
  
  Duration? get estimatedDuration => expectedCompletionDate != null && startDate != null
      ? expectedCompletionDate!.difference(startDate!)
      : null;
  
  Duration? get actualDuration => actualCompletionDate != null && startDate != null
      ? actualCompletionDate!.difference(startDate!)
      : null;
}

class WorkOrderItem {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double unitPrice;
  final String? materialType;
  final double? weight;
  final String? specifications;

  WorkOrderItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.materialType,
    this.weight,
    this.specifications,
  });

  factory WorkOrderItem.fromJson(Map<String, dynamic> json) {
    return WorkOrderItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      materialType: json['materialType'],
      weight: json['weight']?.toDouble(),
      specifications: json['specifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'materialType': materialType,
      'weight': weight,
      'specifications': specifications,
    };
  }

  double get totalPrice => quantity * unitPrice;
}

