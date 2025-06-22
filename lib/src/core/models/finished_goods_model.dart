class FinishedGood {
  final String id;
  final String workOrderId;
  final String? productDesignId;
  final String productName;
  final double finalWeight;
  final String karat;
  final String artisanId;
  final String? barcode;
  final String? qrCode;
  final String status;
  final double? manufacturingCost;
  final double? estimatedSellingPrice;
  final List<String>? images;
  final Map<String, dynamic>? specifications;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? deliveredToClient;
  
  // Additional fields from joins
  final String? orderNumber;
  final String? artisanName;

  FinishedGood({
    required this.id,
    required this.workOrderId,
    this.productDesignId,
    required this.productName,
    required this.finalWeight,
    required this.karat,
    required this.artisanId,
    this.barcode,
    this.qrCode,
    this.status = 'in_stock',
    this.manufacturingCost,
    this.estimatedSellingPrice,
    this.images,
    this.specifications,
    required this.createdAt,
    this.deliveredAt,
    this.deliveredToClient,
    this.orderNumber,
    this.artisanName,
  });

  factory FinishedGood.fromMap(Map<String, dynamic> map) {
    return FinishedGood(
      id: map['id'] ?? '',
      workOrderId: map['work_order_id'] ?? '',
      productDesignId: map['product_design_id'],
      productName: map['product_name'] ?? '',
      finalWeight: (map['final_weight'] ?? 0.0).toDouble(),
      karat: map['karat'] ?? '',
      artisanId: map['artisan_id'] ?? '',
      barcode: map['barcode'],
      qrCode: map['qr_code'],
      status: map['status'] ?? 'in_stock',
      manufacturingCost: map['manufacturing_cost']?.toDouble(),
      estimatedSellingPrice: map['estimated_selling_price']?.toDouble(),
      images: map['images'] != null 
          ? List<String>.from(map['images'] is String 
              ? [] // Handle JSON string case
              : map['images'])
          : null,
      specifications: map['specifications'] != null
          ? Map<String, dynamic>.from(map['specifications'] is String
              ? {} // Handle JSON string case
              : map['specifications'])
          : null,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      deliveredAt: map['delivered_at'] != null ? DateTime.parse(map['delivered_at']) : null,
      deliveredToClient: map['delivered_to_client'],
      orderNumber: map['order_number'],
      artisanName: map['artisan_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'work_order_id': workOrderId,
      'product_design_id': productDesignId,
      'product_name': productName,
      'final_weight': finalWeight,
      'karat': karat,
      'artisan_id': artisanId,
      'barcode': barcode,
      'qr_code': qrCode,
      'status': status,
      'manufacturing_cost': manufacturingCost,
      'estimated_selling_price': estimatedSellingPrice,
      'images': images,
      'specifications': specifications,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'delivered_to_client': deliveredToClient,
    };
  }

  FinishedGood copyWith({
    String? id,
    String? workOrderId,
    String? productDesignId,
    String? productName,
    double? finalWeight,
    String? karat,
    String? artisanId,
    String? barcode,
    String? qrCode,
    String? status,
    double? manufacturingCost,
    double? estimatedSellingPrice,
    List<String>? images,
    Map<String, dynamic>? specifications,
    DateTime? createdAt,
    DateTime? deliveredAt,
    String? deliveredToClient,
    String? orderNumber,
    String? artisanName,
  }) {
    return FinishedGood(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      productDesignId: productDesignId ?? this.productDesignId,
      productName: productName ?? this.productName,
      finalWeight: finalWeight ?? this.finalWeight,
      karat: karat ?? this.karat,
      artisanId: artisanId ?? this.artisanId,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      manufacturingCost: manufacturingCost ?? this.manufacturingCost,
      estimatedSellingPrice: estimatedSellingPrice ?? this.estimatedSellingPrice,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      deliveredToClient: deliveredToClient ?? this.deliveredToClient,
      orderNumber: orderNumber ?? this.orderNumber,
      artisanName: artisanName ?? this.artisanName,
    );
  }

  // التحقق من حالات المنتج النهائي
  bool get isInStock => status == 'in_stock';
  bool get isReserved => status == 'reserved';
  bool get isDelivered => status == 'delivered';

  // حساب هامش الربح
  double get profitMargin {
    if (manufacturingCost == null || estimatedSellingPrice == null) return 0.0;
    if (manufacturingCost! <= 0) return 0.0;
    
    return ((estimatedSellingPrice! - manufacturingCost!) / manufacturingCost!) * 100;
  }

  // حساب القيمة الإجمالية للمنتج
  double get totalValue => estimatedSellingPrice ?? 0.0;

  // توليد باركود فريد
  String generateBarcode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'FG${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }

  // توليد رمز QR
  String generateQRCode() {
    return 'FG:$id:$productName:${finalWeight}g:$karat';
  }

  // الحصول على معلومات المنتج للطباعة
  Map<String, String> getPrintableInfo() {
    return {
      'اسم المنتج': productName,
      'الوزن': '${finalWeight.toStringAsFixed(3)} جرام',
      'العيار': karat,
      'الحرفي': artisanName ?? 'غير محدد',
      'رقم أمر العمل': orderNumber ?? 'غير محدد',
      'تاريخ الإنتاج': createdAt.toString().split(' ')[0],
      'الباركود': barcode ?? 'غير محدد',
    };
  }

  @override
  String toString() {
    return 'FinishedGood(id: $id, productName: $productName, weight: ${finalWeight}g, karat: $karat, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinishedGood && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// تعداد حالات المنتجات النهائية
enum FinishedGoodStatus {
  inStock('in_stock', 'في المخزون'),
  reserved('reserved', 'محجوز'),
  delivered('delivered', 'مسلم');

  const FinishedGoodStatus(this.value, this.arabicName);
  
  final String value;
  final String arabicName;

  static FinishedGoodStatus fromString(String value) {
    return FinishedGoodStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FinishedGoodStatus.inStock,
    );
  }
}

// فئة لمعلومات الباركود
class BarcodeInfo {
  final String code;
  final String type; // EAN13, CODE128, QR, etc.
  final DateTime generatedAt;
  final String generatedBy;

  BarcodeInfo({
    required this.code,
    required this.type,
    required this.generatedAt,
    required this.generatedBy,
  });

  factory BarcodeInfo.fromMap(Map<String, dynamic> map) {
    return BarcodeInfo(
      code: map['code'] ?? '',
      type: map['type'] ?? 'CODE128',
      generatedAt: DateTime.parse(map['generated_at'] ?? DateTime.now().toIso8601String()),
      generatedBy: map['generated_by'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'type': type,
      'generated_at': generatedAt.toIso8601String(),
      'generated_by': generatedBy,
    };
  }
}

// فئة لمواصفات المنتج
class ProductSpecifications {
  final String? design;
  final String? style;
  final String? gemstones;
  final String? finish;
  final Map<String, String>? dimensions;
  final Map<String, dynamic>? customAttributes;

  ProductSpecifications({
    this.design,
    this.style,
    this.gemstones,
    this.finish,
    this.dimensions,
    this.customAttributes,
  });

  factory ProductSpecifications.fromMap(Map<String, dynamic> map) {
    return ProductSpecifications(
      design: map['design'],
      style: map['style'],
      gemstones: map['gemstones'],
      finish: map['finish'],
      dimensions: map['dimensions'] != null 
          ? Map<String, String>.from(map['dimensions'])
          : null,
      customAttributes: map['custom_attributes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'design': design,
      'style': style,
      'gemstones': gemstones,
      'finish': finish,
      'dimensions': dimensions,
      'custom_attributes': customAttributes,
    };
  }
}

