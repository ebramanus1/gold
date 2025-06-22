import 'package:flutter/material.dart';

enum ProductCategory {
  rings,
  necklaces,
  bracelets,
  earrings,
  pendants,
  chains,
  sets,
  custom
}

enum ProductStatus {
  available,
  outOfStock,
  discontinued,
  preOrder
}

enum GoldKarat {
  k18,
  k21,
  k22,
  k24
}

class FinishedProduct {
  final String id;
  final String code;
  final String name;
  final String description;
  final ProductCategory category;
  final ProductStatus status;
  final GoldKarat goldKarat;
  final double weight;
  final double goldWeight;
  final double stoneWeight;
  final String? mainImage;
  final List<String> images;
  final double costPrice;
  final double sellingPrice;
  final double laborCost;
  final double stoneCost;
  final double additionalCost;
  final int stockQuantity;
  final int minStockLevel;
  final String? barcode;
  final String? qrCode;
  final DateTime createdDate;
  final DateTime? lastModified;
  final String? supplier;
  final String? craftsman;
  final List<ProductStone> stones;
  final Map<String, String> specifications;
  final List<String> tags;
  final double? length;
  final double? width;
  final double? height;
  final String? size;
  final bool isCustomizable;
  final double? customizationCost;
  final int? productionTime;
  final String? notes;

  FinishedProduct({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.goldKarat,
    required this.weight,
    required this.goldWeight,
    this.stoneWeight = 0.0,
    this.mainImage,
    this.images = const [],
    required this.costPrice,
    required this.sellingPrice,
    this.laborCost = 0.0,
    this.stoneCost = 0.0,
    this.additionalCost = 0.0,
    this.stockQuantity = 0,
    this.minStockLevel = 1,
    this.barcode,
    this.qrCode,
    required this.createdDate,
    this.lastModified,
    this.supplier,
    this.craftsman,
    this.stones = const [],
    this.specifications = const {},
    this.tags = const [],
    this.length,
    this.width,
    this.height,
    this.size,
    this.isCustomizable = false,
    this.customizationCost,
    this.productionTime,
    this.notes,
  });

  factory FinishedProduct.fromJson(Map<String, dynamic> json) {
    return FinishedProduct(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      category: ProductCategory.values[json['category']],
      status: ProductStatus.values[json['status']],
      goldKarat: GoldKarat.values[json['goldKarat']],
      weight: json['weight'].toDouble(),
      goldWeight: json['goldWeight'].toDouble(),
      stoneWeight: json['stoneWeight']?.toDouble() ?? 0.0,
      mainImage: json['mainImage'],
      images: List<String>.from(json['images'] ?? []),
      costPrice: json['costPrice'].toDouble(),
      sellingPrice: json['sellingPrice'].toDouble(),
      laborCost: json['laborCost']?.toDouble() ?? 0.0,
      stoneCost: json['stoneCost']?.toDouble() ?? 0.0,
      additionalCost: json['additionalCost']?.toDouble() ?? 0.0,
      stockQuantity: json['stockQuantity'] ?? 0,
      minStockLevel: json['minStockLevel'] ?? 1,
      barcode: json['barcode'],
      qrCode: json['qrCode'],
      createdDate: DateTime.parse(json['createdDate']),
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified']) : null,
      supplier: json['supplier'],
      craftsman: json['craftsman'],
      stones: (json['stones'] as List?)?.map((stone) => ProductStone.fromJson(stone)).toList() ?? [],
      specifications: Map<String, String>.from(json['specifications'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      length: json['length']?.toDouble(),
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      size: json['size'],
      isCustomizable: json['isCustomizable'] ?? false,
      customizationCost: json['customizationCost']?.toDouble(),
      productionTime: json['productionTime'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'category': category.index,
      'status': status.index,
      'goldKarat': goldKarat.index,
      'weight': weight,
      'goldWeight': goldWeight,
      'stoneWeight': stoneWeight,
      'mainImage': mainImage,
      'images': images,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'laborCost': laborCost,
      'stoneCost': stoneCost,
      'additionalCost': additionalCost,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'barcode': barcode,
      'qrCode': qrCode,
      'createdDate': createdDate.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'supplier': supplier,
      'craftsman': craftsman,
      'stones': stones.map((stone) => stone.toJson()).toList(),
      'specifications': specifications,
      'tags': tags,
      'length': length,
      'width': width,
      'height': height,
      'size': size,
      'isCustomizable': isCustomizable,
      'customizationCost': customizationCost,
      'productionTime': productionTime,
      'notes': notes,
    };
  }

  FinishedProduct copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    ProductCategory? category,
    ProductStatus? status,
    GoldKarat? goldKarat,
    double? weight,
    double? goldWeight,
    double? stoneWeight,
    String? mainImage,
    List<String>? images,
    double? costPrice,
    double? sellingPrice,
    double? laborCost,
    double? stoneCost,
    double? additionalCost,
    int? stockQuantity,
    int? minStockLevel,
    String? barcode,
    String? qrCode,
    DateTime? createdDate,
    DateTime? lastModified,
    String? supplier,
    String? craftsman,
    List<ProductStone>? stones,
    Map<String, String>? specifications,
    List<String>? tags,
    double? length,
    double? width,
    double? height,
    String? size,
    bool? isCustomizable,
    double? customizationCost,
    int? productionTime,
    String? notes,
  }) {
    return FinishedProduct(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      goldKarat: goldKarat ?? this.goldKarat,
      weight: weight ?? this.weight,
      goldWeight: goldWeight ?? this.goldWeight,
      stoneWeight: stoneWeight ?? this.stoneWeight,
      mainImage: mainImage ?? this.mainImage,
      images: images ?? this.images,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      laborCost: laborCost ?? this.laborCost,
      stoneCost: stoneCost ?? this.stoneCost,
      additionalCost: additionalCost ?? this.additionalCost,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
      createdDate: createdDate ?? this.createdDate,
      lastModified: lastModified ?? this.lastModified,
      supplier: supplier ?? this.supplier,
      craftsman: craftsman ?? this.craftsman,
      stones: stones ?? this.stones,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      size: size ?? this.size,
      isCustomizable: isCustomizable ?? this.isCustomizable,
      customizationCost: customizationCost ?? this.customizationCost,
      productionTime: productionTime ?? this.productionTime,
      notes: notes ?? this.notes,
    );
  }

  // حساب إجمالي التكلفة
  double get totalCost => laborCost + stoneCost + additionalCost + (goldWeight * getCurrentGoldPrice());
  
  // حساب هامش الربح
  double get profitMargin => sellingPrice - totalCost;
  
  // حساب نسبة الربح
  double get profitPercentage => totalCost > 0 ? (profitMargin / totalCost) * 100 : 0;
  
  // التحقق من نفاد المخزون
  bool get isLowStock => stockQuantity <= minStockLevel;
  
  // التحقق من توفر المنتج
  bool get isAvailable => status == ProductStatus.available && stockQuantity > 0;
  
  // الحصول على سعر الذهب الحالي (يجب ربطه بخدمة أسعار الذهب)
  double getCurrentGoldPrice() {
    // هذه قيمة افتراضية، يجب ربطها بخدمة أسعار الذهب الفعلية
    switch (goldKarat) {
      case GoldKarat.k18:
        return 200.0; // سعر الجرام للذهب عيار 18
      case GoldKarat.k21:
        return 230.0; // سعر الجرام للذهب عيار 21
      case GoldKarat.k22:
        return 240.0; // سعر الجرام للذهب عيار 22
      case GoldKarat.k24:
        return 260.0; // سعر الجرام للذهب عيار 24
    }
  }
}

class ProductStone {
  final String id;
  final String name;
  final String type;
  final double weight;
  final String? color;
  final String? clarity;
  final String? cut;
  final double? size;
  final double cost;
  final String? origin;
  final String? certificate;

  ProductStone({
    required this.id,
    required this.name,
    required this.type,
    required this.weight,
    this.color,
    this.clarity,
    this.cut,
    this.size,
    required this.cost,
    this.origin,
    this.certificate,
  });

  factory ProductStone.fromJson(Map<String, dynamic> json) {
    return ProductStone(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      weight: json['weight'].toDouble(),
      color: json['color'],
      clarity: json['clarity'],
      cut: json['cut'],
      size: json['size']?.toDouble(),
      cost: json['cost'].toDouble(),
      origin: json['origin'],
      certificate: json['certificate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'weight': weight,
      'color': color,
      'clarity': clarity,
      'cut': cut,
      'size': size,
      'cost': cost,
      'origin': origin,
      'certificate': certificate,
    };
  }
}

// تمديدات مفيدة للتصنيفات
extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.rings:
        return 'خواتم';
      case ProductCategory.necklaces:
        return 'قلائد';
      case ProductCategory.bracelets:
        return 'أساور';
      case ProductCategory.earrings:
        return 'أقراط';
      case ProductCategory.pendants:
        return 'دلايات';
      case ProductCategory.chains:
        return 'سلاسل';
      case ProductCategory.sets:
        return 'طقم';
      case ProductCategory.custom:
        return 'مخصص';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.rings:
        return Icons.radio_button_unchecked;
      case ProductCategory.necklaces:
        return Icons.circle_outlined;
      case ProductCategory.bracelets:
        return Icons.watch;
      case ProductCategory.earrings:
        return Icons.hearing;
      case ProductCategory.pendants:
        return Icons.favorite;
      case ProductCategory.chains:
        return Icons.link;
      case ProductCategory.sets:
        return Icons.inventory_2;
      case ProductCategory.custom:
        return Icons.build;
    }
  }
}

extension ProductStatusExtension on ProductStatus {
  String get displayName {
    switch (this) {
      case ProductStatus.available:
        return 'متوفر';
      case ProductStatus.outOfStock:
        return 'نفد المخزون';
      case ProductStatus.discontinued:
        return 'متوقف';
      case ProductStatus.preOrder:
        return 'طلب مسبق';
    }
  }

  Color get color {
    switch (this) {
      case ProductStatus.available:
        return Colors.green;
      case ProductStatus.outOfStock:
        return Colors.red;
      case ProductStatus.discontinued:
        return Colors.grey;
      case ProductStatus.preOrder:
        return Colors.orange;
    }
  }
}

extension GoldKaratExtension on GoldKarat {
  String get displayName {
    switch (this) {
      case GoldKarat.k18:
        return 'عيار 18';
      case GoldKarat.k21:
        return 'عيار 21';
      case GoldKarat.k22:
        return 'عيار 22';
      case GoldKarat.k24:
        return 'عيار 24';
    }
  }

  int get karatValue {
    switch (this) {
      case GoldKarat.k18:
        return 18;
      case GoldKarat.k21:
        return 21;
      case GoldKarat.k22:
        return 22;
      case GoldKarat.k24:
        return 24;
    }
  }
}

