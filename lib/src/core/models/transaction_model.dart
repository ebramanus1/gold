import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final String id;
  final String transactionNumber;
  final TransactionType type;
  final TransactionStatus status;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String salesPersonId;
  final List<TransactionItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final PaymentMethod paymentMethod;
  final List<PaymentRecord> payments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const TransactionModel({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.salesPersonId,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentMethod,
    required this.payments,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.notes,
    this.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  // Add toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionNumber': transactionNumber,
      'type': type.toJson(),
      'status': status.toJson(),
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'salesPersonId': salesPersonId,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'paymentMethod': paymentMethod.toJson(),
      'payments': payments.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Add fromMap method
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      transactionNumber: map['transactionNumber'] as String,
      type: TransactionTypeExtension.fromJson(map['type'] as String),
      status: TransactionStatusExtension.fromJson(map['status'] as String),
      customerId: map['customerId'] as String?,
      customerName: map['customerName'] as String?,
      customerPhone: map['customerPhone'] as String?,
      salesPersonId: map['salesPersonId'] as String,
      items: (map['items'] as List<dynamic>)
          .map((e) => TransactionItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      subtotal: map['subtotal'] as double,
      taxAmount: map['taxAmount'] as double,
      discountAmount: map['discountAmount'] as double,
      totalAmount: map['totalAmount'] as double,
      paidAmount: map['paidAmount'] as double,
      remainingAmount: map['remainingAmount'] as double,
      paymentMethod: PaymentMethodExtension.fromJson(map['paymentMethod'] as String),
      payments: (map['payments'] as List<dynamic>)
          .map((e) => PaymentRecord.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      notes: map['notes'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? transactionNumber,
    TransactionType? type,
    TransactionStatus? status,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? salesPersonId,
    List<TransactionItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    PaymentMethod? paymentMethod,
    List<PaymentRecord>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      salesPersonId: salesPersonId ?? this.salesPersonId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending => status == TransactionStatus.pending;
  bool get isCancelled => status == TransactionStatus.cancelled;
  bool get hasRemainingAmount => remainingAmount > 0;
}

enum TransactionType {
  @JsonValue('sale')
  sale, // بيع
  @JsonValue('purchase')
  purchase, // شراء
  @JsonValue('return')
  return_, // إرجاع
  @JsonValue('exchange')
  exchange, // استبدال
  @JsonValue('repair')
  repair, // إصلاح
  @JsonValue('manufacturing')
  manufacturing, // تصنيع
}

extension TransactionTypeExtension on TransactionType {
  String toJson() => name;
  static TransactionType fromJson(String name) =>
      TransactionType.values.firstWhere((e) => e.name == name);
}

enum TransactionStatus {
  @JsonValue('draft')
  draft, // مسودة
  @JsonValue('pending')
  pending, // معلق
  @JsonValue('completed')
  completed, // مكتمل
  @JsonValue('cancelled')
  cancelled, // ملغي
  @JsonValue('refunded')
  refunded, // مسترد
}

extension TransactionStatusExtension on TransactionStatus {
  String toJson() => name;
  static TransactionStatus fromJson(String name) =>
      TransactionStatus.values.firstWhere((e) => e.name == name);
}

enum PaymentMethod {
  @JsonValue('cash')
  cash, // نقدي
  @JsonValue('card')
  card, // بطاقة
  @JsonValue('bank_transfer')
  bankTransfer, // تحويل بنكي
  @JsonValue('installment')
  installment, // تقسيط
  @JsonValue('gold_exchange')
  goldExchange, // مقايضة ذهب
}

extension PaymentMethodExtension on PaymentMethod {
  String toJson() => name;
  static PaymentMethod fromJson(String name) =>
      PaymentMethod.values.firstWhere((e) => e.name == name);
}

@JsonSerializable()
class TransactionItem {
  final String id;
  final String itemId;
  final String itemName;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final double weight;
  final String karat;
  final double? discountAmount;
  final Map<String, dynamic>? specifications;

  const TransactionItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.weight,
    required this.karat,
    this.discountAmount,
    this.specifications,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) => _$TransactionItemFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionItemToJson(this);

  // Add toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'weight': weight,
      'karat': karat,
      'discountAmount': discountAmount,
      'specifications': specifications,
    };
  }

  // Add fromMap method
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as String,
      itemId: map['itemId'] as String,
      itemName: map['itemName'] as String,
      quantity: map['quantity'] as double,
      unitPrice: map['unitPrice'] as double,
      totalPrice: map['totalPrice'] as double,
      weight: map['weight'] as double,
      karat: map['karat'] as String,
      discountAmount: map['discountAmount'] as double?,
      specifications: map['specifications'] as Map<String, dynamic>?,
    );
  }
}

@JsonSerializable()
class PaymentRecord {
  final String id;
  final String transactionId;
  final double amount;
  final PaymentMethod method;
  final DateTime paymentDate;
  final String? reference;
  final String? notes;
  final String recordedBy;

  const PaymentRecord({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.method,
    required this.paymentDate,
    this.reference,
    this.notes,
    required this.recordedBy,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => _$PaymentRecordFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRecordToJson(this);

  // Add toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'amount': amount,
      'method': method.toJson(),
      'paymentDate': paymentDate.toIso8601String(),
      'reference': reference,
      'notes': notes,
      'recordedBy': recordedBy,
    };
  }

  // Add fromMap method
  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'] as String,
      transactionId: map['transactionId'] as String,
      amount: map['amount'] as double,
      method: PaymentMethodExtension.fromJson(map['method'] as String),
      paymentDate: DateTime.parse(map['paymentDate'] as String),
      reference: map['reference'] as String?,
      notes: map['notes'] as String?,
      recordedBy: map['recordedBy'] as String,
    );
  }
}

@JsonSerializable()
class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? nationalId;
  final CustomerType type;
  final double creditLimit;
  final double currentBalance;
  final List<String> transactionHistory;
  final DateTime createdAt;
  final DateTime? lastTransactionAt;
  final bool isActive;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.nationalId,
    required this.type,
    required this.creditLimit,
    required this.currentBalance,
    required this.transactionHistory,
    required this.createdAt,
    this.lastTransactionAt,
    required this.isActive,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  // Add toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'nationalId': nationalId,
      'type': type.toJson(),
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'transactionHistory': transactionHistory,
      'createdAt': createdAt.toIso8601String(),
      'lastTransactionAt': lastTransactionAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Add fromMap method
  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      nationalId: map['nationalId'] as String?,
      type: CustomerTypeExtension.fromJson(map['type'] as String),
      creditLimit: map['creditLimit'] as double,
      currentBalance: map['currentBalance'] as double,
      transactionHistory: (map['transactionHistory'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastTransactionAt: map['lastTransactionAt'] != null
          ? DateTime.parse(map['lastTransactionAt'] as String)
          : null,
      isActive: map['isActive'] as bool,
    );
  }
}

enum CustomerType {
  @JsonValue('individual')
  individual, // فرد
  @JsonValue('business')
  business, // تجاري
  @JsonValue('vip')
  vip, // مميز
}

extension CustomerTypeExtension on CustomerType {
  String toJson() => name;
  static CustomerType fromJson(String name) =>
      CustomerType.values.firstWhere((e) => e.name == name);
}