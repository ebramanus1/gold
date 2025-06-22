import 'package:json_annotation/json_annotation.dart';

part 'gold_item_model.g.dart';

@JsonSerializable()
class GoldItemModel {
  final String id;
  final String name;
  final String description;
  final GoldType type;
  final String karat;
  final double weight;
  final double purity;
  final String category;
  final String? subcategory;
  final double costPrice;
  final double sellingPrice;
  final String? barcode;
  final String? qrCode;
  final List<String> images;
  final GoldItemStatus status;
  final String? craftsmanId;
  final String? customerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? specifications;
  final List<GoldItemHistory> history;

  const GoldItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.karat,
    required this.weight,
    required this.purity,
    required this.category,
    this.subcategory,
    required this.costPrice,
    required this.sellingPrice,
    this.barcode,
    this.qrCode,
    required this.images,
    required this.status,
    this.craftsmanId,
    this.customerId,
    required this.createdAt,
    this.updatedAt,
    this.specifications,
    required this.history,
  });

  factory GoldItemModel.fromJson(Map<String, dynamic> json) => _$GoldItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$GoldItemModelToJson(this);

  GoldItemModel copyWith({
    String? id,
    String? name,
    String? description,
    GoldType? type,
    String? karat,
    double? weight,
    double? purity,
    String? category,
    String? subcategory,
    double? costPrice,
    double? sellingPrice,
    String? barcode,
    String? qrCode,
    List<String>? images,
    GoldItemStatus? status,
    String? craftsmanId,
    String? customerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? specifications,
    List<GoldItemHistory>? history,
  }) {
    return GoldItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      karat: karat ?? this.karat,
      weight: weight ?? this.weight,
      purity: purity ?? this.purity,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
      images: images ?? this.images,
      status: status ?? this.status,
      craftsmanId: craftsmanId ?? this.craftsmanId,
      customerId: customerId ?? this.customerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specifications: specifications ?? this.specifications,
      history: history ?? this.history,
    );
  }

  double get totalValue => weight * sellingPrice;
  double get profit => sellingPrice - costPrice;
  double get profitMargin => profit / costPrice * 100;
}

enum GoldType {
  @JsonValue('raw')
  raw, // خام
  @JsonValue('manufactured')
  manufactured, // مصنع
  @JsonValue('used')
  used, // مستعمل
  @JsonValue('repair')
  repair, // للإصلاح
}

enum GoldItemStatus {
  @JsonValue('in_stock')
  inStock, // في المخزن
  @JsonValue('sold')
  sold, // مباع
  @JsonValue('reserved')
  reserved, // محجوز
  @JsonValue('in_progress')
  inProgress, // قيد التصنيع
  @JsonValue('returned')
  returned, // مرتجع
  @JsonValue('damaged')
  damaged, // تالف
}

@JsonSerializable()
class GoldItemHistory {
  final String id;
  final String itemId;
  final String action;
  final String description;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;

  const GoldItemHistory({
    required this.id,
    required this.itemId,
    required this.action,
    required this.description,
    required this.userId,
    required this.timestamp,
    this.oldValues,
    this.newValues,
  });

  factory GoldItemHistory.fromJson(Map<String, dynamic> json) => _$GoldItemHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$GoldItemHistoryToJson(this);
}

@JsonSerializable()
class GoldCategory {
  final String id;
  final String name;
  final String description;
  final String? parentId;
  final List<String> subcategories;
  final bool isActive;

  const GoldCategory({
    required this.id,
    required this.name,
    required this.description,
    this.parentId,
    required this.subcategories,
    required this.isActive,
  });

  factory GoldCategory.fromJson(Map<String, dynamic> json) => _$GoldCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$GoldCategoryToJson(this);
}

