import 'package:flutter/material.dart';

enum InvoiceType {
  sale,
  purchase,
  salesReturn,
  estimate,
  proforma
}

enum InvoiceStatus {
  draft,
  sent,
  paid,
  partiallyPaid,
  overdue,
  cancelled,
  refunded
}

enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  check,
  installment,
  gold,
  mixed
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final InvoiceType type;
  final InvoiceStatus status;
  final String clientId;
  final String clientName;
  final String? clientPhone;
  final String? clientEmail;
  final String? clientAddress;
  final DateTime issueDate;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountRate;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final PaymentMethod? paymentMethod;
  final String? paymentReference;
  final String? notes;
  final String? terms;
  final String? qrCode;
  final List<String> attachments;
  final Map<String, dynamic> customFields;
  final String? workOrderId;
  final bool isGoldTransaction;
  final double? goldWeight;
  final double? goldPrice;
  final String? goldKarat;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.status,
    required this.clientId,
    required this.clientName,
    this.clientPhone,
    this.clientEmail,
    this.clientAddress,
    required this.issueDate,
    this.dueDate,
    this.paidDate,
    required this.items,
    required this.subtotal,
    this.taxRate = 0.0,
    required this.taxAmount,
    this.discountRate = 0.0,
    required this.discountAmount,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.remainingAmount,
    this.paymentMethod,
    this.paymentReference,
    this.notes,
    this.terms,
    this.qrCode,
    this.attachments = const [],
    this.customFields = const {},
    this.workOrderId,
    this.isGoldTransaction = false,
    this.goldWeight,
    this.goldPrice,
    this.goldKarat,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      type: InvoiceType.values[json['type']],
      status: InvoiceStatus.values[json['status']],
      clientId: json['clientId'],
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      clientEmail: json['clientEmail'],
      clientAddress: json['clientAddress'],
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      items: (json['items'] as List).map((item) => InvoiceItem.fromJson(item)).toList(),
      subtotal: json['subtotal'].toDouble(),
      taxRate: json['taxRate']?.toDouble() ?? 0.0,
      taxAmount: json['taxAmount'].toDouble(),
      discountRate: json['discountRate']?.toDouble() ?? 0.0,
      discountAmount: json['discountAmount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      paidAmount: json['paidAmount']?.toDouble() ?? 0.0,
      remainingAmount: json['remainingAmount'].toDouble(),
      paymentMethod: json['paymentMethod'] != null ? PaymentMethod.values[json['paymentMethod']] : null,
      paymentReference: json['paymentReference'],
      notes: json['notes'],
      terms: json['terms'],
      qrCode: json['qrCode'],
      attachments: List<String>.from(json['attachments'] ?? []),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
      workOrderId: json['workOrderId'],
      isGoldTransaction: json['isGoldTransaction'] ?? false,
      goldWeight: json['goldWeight']?.toDouble(),
      goldPrice: json['goldPrice']?.toDouble(),
      goldKarat: json['goldKarat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'type': type.index,
      'status': status.index,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'clientAddress': clientAddress,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discountRate': discountRate,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'paymentMethod': paymentMethod?.index,
      'paymentReference': paymentReference,
      'notes': notes,
      'terms': terms,
      'qrCode': qrCode,
      'attachments': attachments,
      'customFields': customFields,
      'workOrderId': workOrderId,
      'isGoldTransaction': isGoldTransaction,
      'goldWeight': goldWeight,
      'goldPrice': goldPrice,
      'goldKarat': goldKarat,
    };
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    InvoiceType? type,
    InvoiceStatus? status,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? clientAddress,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? paidDate,
    List<InvoiceItem>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discountRate,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    String? notes,
    String? terms,
    String? qrCode,
    List<String>? attachments,
    Map<String, dynamic>? customFields,
    String? workOrderId,
    bool? isGoldTransaction,
    double? goldWeight,
    double? goldPrice,
    String? goldKarat,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      clientAddress: clientAddress ?? this.clientAddress,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountRate: discountRate ?? this.discountRate,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      qrCode: qrCode ?? this.qrCode,
      attachments: attachments ?? this.attachments,
      customFields: customFields ?? this.customFields,
      workOrderId: workOrderId ?? this.workOrderId,
      isGoldTransaction: isGoldTransaction ?? this.isGoldTransaction,
      goldWeight: goldWeight ?? this.goldWeight,
      goldPrice: goldPrice ?? this.goldPrice,
      goldKarat: goldKarat ?? this.goldKarat,
    );
  }

  // التحقق من تأخر الدفع
  bool get isOverdue => dueDate != null && 
      DateTime.now().isAfter(dueDate!) && 
      status != InvoiceStatus.paid && 
      status != InvoiceStatus.cancelled;

  // التحقق من الدفع الجزئي
  bool get isPartiallyPaid => paidAmount > 0 && paidAmount < totalAmount;

  // حساب نسبة الدفع
  double get paymentPercentage => totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0;

  // حساب عدد أيام التأخير
  int get daysOverdue => isOverdue ? DateTime.now().difference(dueDate!).inDays : 0;
} // <-- إغلاق كلاس Invoice

class InvoiceItem {
  final String id;
  final String productId;
  final String productCode;
  final String productName;
  final String description;
  final int quantity;
  final double unitPrice;
  final double discountRate;
  final double discountAmount;
  final double taxRate;
  final double taxAmount;
  final double totalPrice;
  final String? unit;
  final double? weight;
  final String? goldKarat;
  final double? goldPrice;
  final Map<String, dynamic> customFields;

  InvoiceItem({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discountRate = 0.0,
    required this.discountAmount,
    this.taxRate = 0.0,
    required this.taxAmount,
    required this.totalPrice,
    this.unit,
    this.weight,
    this.goldKarat,
    this.goldPrice,
    this.customFields = const {},
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      productId: json['productId'],
      productCode: json['productCode'],
      productName: json['productName'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      discountRate: json['discountRate']?.toDouble() ?? 0.0,
      discountAmount: json['discountAmount'].toDouble(),
      taxRate: json['taxRate']?.toDouble() ?? 0.0,
      taxAmount: json['taxAmount'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
      unit: json['unit'],
      weight: json['weight']?.toDouble(),
      goldKarat: json['goldKarat'],
      goldPrice: json['goldPrice']?.toDouble(),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productCode': productCode,
      'productName': productName,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discountRate': discountRate,
      'discountAmount': discountAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'totalPrice': totalPrice,
      'unit': unit,
      'weight': weight,
      'goldKarat': goldKarat,
      'goldPrice': goldPrice,
      'customFields': customFields,
    };
  }

  // حساب السعر الإجمالي قبل الخصم والضريبة
  double get subtotal => quantity * unitPrice;

  // حساب السعر بعد الخصم
  double get priceAfterDiscount => subtotal - discountAmount;

  // حساب السعر النهائي
  double get finalPrice => priceAfterDiscount + taxAmount;
} // <-- إغلاق كلاس InvoiceItem

// مذكرة التسليم
class DeliveryNote {
  final String id;
  final String noteNumber;
  final String invoiceId;
  final String clientId;
  final String clientName;
  final DateTime deliveryDate;
  final String deliveryAddress;
  final String? recipientName;
  final String? recipientSignature;
  final List<DeliveryItem> items;
  final String? notes;
  final String? driverName;
  final String? vehicleNumber;
  final DateTime createdDate;
  final bool isDelivered;
  final DateTime? deliveredDate;

  DeliveryNote({
    required this.id,
    required this.noteNumber,
    required this.invoiceId,
    required this.clientId,
    required this.clientName,
    required this.deliveryDate,
    required this.deliveryAddress,
    this.recipientName,
    this.recipientSignature,
    required this.items,
    this.notes,
    this.driverName,
    this.vehicleNumber,
    required this.createdDate,
    this.isDelivered = false,
    this.deliveredDate,
  });

  factory DeliveryNote.fromJson(Map<String, dynamic> json) {
    return DeliveryNote(
      id: json['id'],
      noteNumber: json['noteNumber'],
      invoiceId: json['invoiceId'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      deliveryDate: DateTime.parse(json['deliveryDate']),
      deliveryAddress: json['deliveryAddress'],
      recipientName: json['recipientName'],
      recipientSignature: json['recipientSignature'],
      items: (json['items'] as List).map((item) => DeliveryItem.fromJson(item)).toList(),
      notes: json['notes'],
      driverName: json['driverName'],
      vehicleNumber: json['vehicleNumber'],
      createdDate: DateTime.parse(json['createdDate']),
      isDelivered: json['isDelivered'] ?? false,
      deliveredDate: json['deliveredDate'] != null ? DateTime.parse(json['deliveredDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteNumber': noteNumber,
      'invoiceId': invoiceId,
      'clientId': clientId,
      'clientName': clientName,
      'deliveryDate': deliveryDate.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'recipientName': recipientName,
      'recipientSignature': recipientSignature,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'driverName': driverName,
      'vehicleNumber': vehicleNumber,
      'createdDate': createdDate.toIso8601String(),
      'isDelivered': isDelivered,
      'deliveredDate': deliveredDate?.toIso8601String(),
    };
  }
}

class DeliveryItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final int deliveredQuantity;
  final String? serialNumber;
  final String? condition;

  DeliveryItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    this.deliveredQuantity = 0,
    this.serialNumber,
    this.condition,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      deliveredQuantity: json['deliveredQuantity'] ?? 0,
      serialNumber: json['serialNumber'],
      condition: json['condition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'deliveredQuantity': deliveredQuantity,
      'serialNumber': serialNumber,
      'condition': condition,
    };
  }

  bool get isFullyDelivered => deliveredQuantity >= quantity;
  int get remainingQuantity => quantity - deliveredQuantity;
} // <-- إغلاق كلاس DeliveryItem

// تمديدات مفيدة
extension InvoiceTypeExtension on InvoiceType {
  String get displayName {
    switch (this) {
      case InvoiceType.sale:
        return 'فاتورة بيع';
      case InvoiceType.purchase:
        return 'فاتورة شراء';
      case InvoiceType.salesReturn:
        return 'فاتورة مرتجع';
      case InvoiceType.estimate:
        return 'عرض سعر';
      case InvoiceType.proforma:
        return 'فاتورة أولية';
    }
  }

  Color get color {
    switch (this) {
      case InvoiceType.sale:
        return Colors.green;
      case InvoiceType.purchase:
        return Colors.blue;
      case InvoiceType.salesReturn:
        return Colors.red;
      case InvoiceType.estimate:
        return Colors.orange;
      case InvoiceType.proforma:
        return Colors.purple;
    }
  }
}

extension InvoiceStatusExtension on InvoiceStatus {
  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'مسودة';
      case InvoiceStatus.sent:
        return 'مرسلة';
      case InvoiceStatus.paid:
        return 'مدفوعة';
      case InvoiceStatus.partiallyPaid:
        return 'مدفوعة جزئياً';
      case InvoiceStatus.overdue:
        return 'متأخرة';
      case InvoiceStatus.cancelled:
        return 'ملغية';
      case InvoiceStatus.refunded:
        return 'مسترد';
    }
  }

  Color get color {
    switch (this) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.partiallyPaid:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.red.shade300;
      case InvoiceStatus.refunded:
        return Colors.purple;
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'نقداً';
      case PaymentMethod.card:
        return 'بطاقة';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case PaymentMethod.check:
        return 'شيك';
      case PaymentMethod.installment:
        return 'أقساط';
      case PaymentMethod.gold:
        return 'ذهب';
      case PaymentMethod.mixed:
        return 'مختلط';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.check:
        return Icons.receipt;
      case PaymentMethod.installment:
        return Icons.schedule;
      case PaymentMethod.gold:
        return Icons.star;
      case PaymentMethod.mixed:
        return Icons.multiple_stop;
    }
  }
}

