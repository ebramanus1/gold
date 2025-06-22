class RawMaterial {
  final String id;
  final String clientId;
  final DateTime intakeDate;
  final String materialType; // Scrap, Bullion, Coins, etc.
  final String karat;
  final double weight;
  final String lotBatchNumber;
  final double? purityPercentage;
  final double? estimatedValue;
  final String status; // available, assigned, consumed
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  
  // Additional fields from joins
  final String? clientName;
  final String? createdByName;

  RawMaterial({
    required this.id,
    required this.clientId,
    required this.intakeDate,
    required this.materialType,
    required this.karat,
    required this.weight,
    required this.lotBatchNumber,
    this.purityPercentage,
    this.estimatedValue,
    this.status = 'available',
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.clientName,
    this.createdByName,
  });

  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      id: map['id'] ?? '',
      clientId: map['client_id'] ?? '',
      intakeDate: DateTime.parse(map['intake_date'] ?? DateTime.now().toIso8601String()),
      materialType: map['material_type'] ?? '',
      karat: map['karat'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      lotBatchNumber: map['lot_batch_number'] ?? '',
      purityPercentage: map['purity_percentage']?.toDouble(),
      estimatedValue: map['estimated_value']?.toDouble(),
      status: map['status'] ?? 'available',
      notes: map['notes'],
      createdBy: map['created_by'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      clientName: map['client_name'],
      createdByName: map['created_by_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'intake_date': intakeDate.toIso8601String(),
      'material_type': materialType,
      'karat': karat,
      'weight': weight,
      'lot_batch_number': lotBatchNumber,
      'purity_percentage': purityPercentage,
      'estimated_value': estimatedValue,
      'status': status,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RawMaterial copyWith({
    String? id,
    String? clientId,
    DateTime? intakeDate,
    String? materialType,
    String? karat,
    double? weight,
    String? lotBatchNumber,
    double? purityPercentage,
    double? estimatedValue,
    String? status,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    String? clientName,
    String? createdByName,
  }) {
    return RawMaterial(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      intakeDate: intakeDate ?? this.intakeDate,
      materialType: materialType ?? this.materialType,
      karat: karat ?? this.karat,
      weight: weight ?? this.weight,
      lotBatchNumber: lotBatchNumber ?? this.lotBatchNumber,
      purityPercentage: purityPercentage ?? this.purityPercentage,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      clientName: clientName ?? this.clientName,
      createdByName: createdByName ?? this.createdByName,
    );
  }

  // التحقق من توفر المادة الخام للتخصيص
  bool get isAvailable => status == 'available';

  // التحقق من كون المادة الخام مخصصة لأمر عمل
  bool get isAssigned => status == 'assigned';

  // التحقق من كون المادة الخام مستهلكة
  bool get isConsumed => status == 'consumed';

  // حساب القيمة المقدرة بناءً على الوزن والنقاء
  double calculateEstimatedValue(double goldPricePerGram) {
    final purity = purityPercentage ?? 100.0;
    return weight * (purity / 100.0) * goldPricePerGram;
  }

  @override
  String toString() {
    return 'RawMaterial(id: $id, lotBatchNumber: $lotBatchNumber, weight: $weight, karat: $karat, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RawMaterial && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// تعداد أنواع المواد الخام
enum MaterialType {
  scrap('Scrap', 'خردة'),
  bullion('Bullion', 'سبائك'),
  coins('Coins', 'عملات'),
  jewelry('Jewelry', 'مجوهرات'),
  other('Other', 'أخرى');

  const MaterialType(this.englishName, this.arabicName);
  
  final String englishName;
  final String arabicName;

  static MaterialType fromString(String value) {
    return MaterialType.values.firstWhere(
      (type) => type.englishName.toLowerCase() == value.toLowerCase(),
      orElse: () => MaterialType.other,
    );
  }
}

// تعداد حالات المواد الخام
enum RawMaterialStatus {
  available('available', 'متاح'),
  assigned('assigned', 'مخصص'),
  consumed('consumed', 'مستهلك');

  const RawMaterialStatus(this.value, this.arabicName);
  
  final String value;
  final String arabicName;

  static RawMaterialStatus fromString(String value) {
    return RawMaterialStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => RawMaterialStatus.available,
    );
  }
}

