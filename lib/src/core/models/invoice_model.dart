import 'package:json_annotation/json_annotation.dart';

part 'invoice_model.g.dart';

@JsonSerializable()
class Invoice {
  final String id;
  final String invoiceNumber;
  final InvoiceType type;
  final String clientId;
  final double totalWeight24k;
  final double totalWeight22k;
  final double totalWeight21k;
  final double totalWeight18k;
  final double manufacturingFeeAmount;
  final Map<String, dynamic> clientBalanceAfter;
  final List<Map<String, dynamic>> items;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? printedAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.clientId,
    required this.totalWeight24k,
    required this.totalWeight22k,
    required this.totalWeight21k,
    required this.totalWeight18k,
    required this.manufacturingFeeAmount,
    required this.clientBalanceAfter,
    required this.items,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.printedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'type': type.toJson(),
      'client_id': clientId,
      'total_weight_24k': totalWeight24k,
      'total_weight_22k': totalWeight22k,
      'total_weight_21k': totalWeight21k,
      'total_weight_18k': totalWeight18k,
      'manufacturing_fee_amount': manufacturingFeeAmount,
      'client_balance_after': clientBalanceAfter,
      'items': items,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'printed_at': printedAt?.toIso8601String(),
    };
  }

  static Invoice fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as String,
      invoiceNumber: map['invoice_number'] as String,
      type: InvoiceTypeExtension.fromJson(map['type'] as String),
      clientId: map['client_id'] as String,
      totalWeight24k: (map['total_weight_24k'] as num).toDouble(),
      totalWeight22k: (map['total_weight_22k'] as num).toDouble(),
      totalWeight21k: (map['total_weight_21k'] as num).toDouble(),
      totalWeight18k: (map['total_weight_18k'] as num).toDouble(),
      manufacturingFeeAmount: (map['manufacturing_fee_amount'] as num).toDouble(),
      clientBalanceAfter: Map<String, dynamic>.from(map['client_balance_after'] as Map),
      items: List<Map<String, dynamic>>.from(map['items'] as List),
      notes: map['notes'] as String?,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      printedAt: map['printed_at'] != null
          ? DateTime.parse(map['printed_at'] as String)
          : null,
    );
  }
}

enum InvoiceType {
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

extension InvoiceTypeExtension on InvoiceType {
  String toJson() => name;
  static InvoiceType fromJson(String name) =>
      InvoiceType.values.firstWhere((e) => e.name == name);
}