import 'package:flutter/material.dart';

enum ManufacturingType {
  ring,
  necklace,
  bracelet,
  earrings,
  pendant,
  chain,
  custom
}

enum ComplexityLevel {
  simple,
  medium,
  complex,
  veryComplex
}

enum FinishType {
  polished,
  matte,
  brushed,
  hammered,
  textured,
  engraved
}

class ManufacturingCostCalculator {
  // أسعار العمالة لكل نوع (ريال سعودي لكل جرام)
  static const Map<ManufacturingType, double> baseLaborCosts = {
    ManufacturingType.ring: 15.0,
    ManufacturingType.necklace: 12.0,
    ManufacturingType.bracelet: 14.0,
    ManufacturingType.earrings: 18.0,
    ManufacturingType.pendant: 16.0,
    ManufacturingType.chain: 10.0,
    ManufacturingType.custom: 20.0,
  };

  // معاملات التعقيد
  static const Map<ComplexityLevel, double> complexityMultipliers = {
    ComplexityLevel.simple: 1.0,
    ComplexityLevel.medium: 1.5,
    ComplexityLevel.complex: 2.0,
    ComplexityLevel.veryComplex: 3.0,
  };

  // معاملات نوع التشطيب
  static const Map<FinishType, double> finishMultipliers = {
    FinishType.polished: 1.0,
    FinishType.matte: 1.1,
    FinishType.brushed: 1.2,
    FinishType.hammered: 1.3,
    FinishType.textured: 1.4,
    FinishType.engraved: 1.8,
  };

  // حساب تكلفة التصنيع
  static ManufacturingCost calculateCost({
    required ManufacturingType type,
    required double goldWeight,
    required int goldKarat,
    required ComplexityLevel complexity,
    required FinishType finish,
    double stoneWeight = 0.0,
    int numberOfStones = 0,
    bool hasEngraving = false,
    String? engravingText,
    double customLaborRate = 0.0,
    int estimatedHours = 0,
    double additionalMaterialCost = 0.0,
    Map<String, double> customCosts = const {},
  }) {
    // التكلفة الأساسية للعمالة
    double baseCost = customLaborRate > 0 
        ? customLaborRate 
        : baseLaborCosts[type] ?? 15.0;

    // حساب تكلفة العمالة الأساسية
    double laborCost = baseCost * goldWeight;

    // تطبيق معامل التعقيد
    laborCost *= complexityMultipliers[complexity] ?? 1.0;

    // تطبيق معامل التشطيب
    laborCost *= finishMultipliers[finish] ?? 1.0;

    // تكلفة إضافية للأحجار الكريمة
    double stoneCost = 0.0;
    if (numberOfStones > 0) {
      stoneCost = numberOfStones * 25.0; // 25 ريال لكل حجر
      if (stoneWeight > 0) {
        stoneCost += stoneWeight * 50.0; // 50 ريال لكل قيراط
      }
    }

    // تكلفة النقش
    double engravingCost = 0.0;
    if (hasEngraving && engravingText != null) {
      engravingCost = engravingText.length * 5.0; // 5 ريال لكل حرف
      engravingCost = engravingCost < 50.0 ? 50.0 : engravingCost; // حد أدنى 50 ريال
    }

    // تكلفة إضافية حسب عيار الذهب
    double karatMultiplier = _getKaratMultiplier(goldKarat);
    laborCost *= karatMultiplier;

    // تكلفة إضافية للوقت المقدر
    double timeCost = 0.0;
    if (estimatedHours > 0) {
      timeCost = estimatedHours * 30.0; // 30 ريال لكل ساعة
    }

    // التكاليف المخصصة
    double customCostTotal = customCosts.values.fold(0.0, (sum, cost) => sum + cost);

    // إجمالي التكلفة
    double totalCost = laborCost + stoneCost + engravingCost + 
                      timeCost + additionalMaterialCost + customCostTotal;

    return ManufacturingCost(
      type: type,
      goldWeight: goldWeight,
      goldKarat: goldKarat,
      complexity: complexity,
      finish: finish,
      baseLaborCost: baseCost,
      laborCost: laborCost,
      stoneCost: stoneCost,
      engravingCost: engravingCost,
      timeCost: timeCost,
      additionalMaterialCost: additionalMaterialCost,
      customCosts: customCosts,
      totalCost: totalCost,
      estimatedHours: estimatedHours,
      numberOfStones: numberOfStones,
      stoneWeight: stoneWeight,
      hasEngraving: hasEngraving,
      engravingText: engravingText,
    );
  }

  // حساب معامل عيار الذهب
  static double _getKaratMultiplier(int karat) {
    switch (karat) {
      case 18:
        return 1.0;
      case 21:
        return 1.1;
      case 22:
        return 1.15;
      case 24:
        return 1.2;
      default:
        return 1.0;
    }
  }

  // حساب تكلفة الإصلاح
  static RepairCost calculateRepairCost({
    required RepairType repairType,
    required double itemWeight,
    required int goldKarat,
    required ComplexityLevel complexity,
    double additionalGoldWeight = 0.0,
    double currentGoldPrice = 0.0,
    bool needsReplacement = false,
    String? description,
    int estimatedHours = 0,
  }) {
    // التكلفة الأساسية للإصلاح
    double baseCost = _getRepairBaseCost(repairType);
    
    // حساب تكلفة العمالة
    double laborCost = baseCost * itemWeight;
    
    // تطبيق معامل التعقيد
    laborCost *= complexityMultipliers[complexity] ?? 1.0;
    
    // تكلفة الذهب الإضافي
    double goldCost = 0.0;
    if (additionalGoldWeight > 0 && currentGoldPrice > 0) {
      goldCost = additionalGoldWeight * currentGoldPrice;
    }
    
    // تكلفة الوقت
    double timeCost = estimatedHours * 25.0; // 25 ريال لكل ساعة للإصلاح
    
    // تكلفة إضافية للاستبدال
    double replacementCost = needsReplacement ? laborCost * 0.5 : 0.0;
    
    double totalCost = laborCost + goldCost + timeCost + replacementCost;
    
    return RepairCost(
      repairType: repairType,
      itemWeight: itemWeight,
      goldKarat: goldKarat,
      complexity: complexity,
      laborCost: laborCost,
      goldCost: goldCost,
      timeCost: timeCost,
      replacementCost: replacementCost,
      totalCost: totalCost,
      additionalGoldWeight: additionalGoldWeight,
      estimatedHours: estimatedHours,
      needsReplacement: needsReplacement,
      description: description,
    );
  }

  static double _getRepairBaseCost(RepairType type) {
    switch (type) {
      case RepairType.resize:
        return 20.0;
      case RepairType.polish:
        return 8.0;
      case RepairType.solder:
        return 25.0;
      case RepairType.stoneReplacement:
        return 30.0;
      case RepairType.chainRepair:
        return 15.0;
      case RepairType.claspRepair:
        return 18.0;
      case RepairType.engraving:
        return 35.0;
      case RepairType.restoration:
        return 40.0;
    }
  }
}

class ManufacturingCost {
  final ManufacturingType type;
  final double goldWeight;
  final int goldKarat;
  final ComplexityLevel complexity;
  final FinishType finish;
  final double baseLaborCost;
  final double laborCost;
  final double stoneCost;
  final double engravingCost;
  final double timeCost;
  final double additionalMaterialCost;
  final Map<String, double> customCosts;
  final double totalCost;
  final int estimatedHours;
  final int numberOfStones;
  final double stoneWeight;
  final bool hasEngraving;
  final String? engravingText;

  ManufacturingCost({
    required this.type,
    required this.goldWeight,
    required this.goldKarat,
    required this.complexity,
    required this.finish,
    required this.baseLaborCost,
    required this.laborCost,
    required this.stoneCost,
    required this.engravingCost,
    required this.timeCost,
    required this.additionalMaterialCost,
    required this.customCosts,
    required this.totalCost,
    required this.estimatedHours,
    required this.numberOfStones,
    required this.stoneWeight,
    required this.hasEngraving,
    this.engravingText,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'goldWeight': goldWeight,
      'goldKarat': goldKarat,
      'complexity': complexity.index,
      'finish': finish.index,
      'baseLaborCost': baseLaborCost,
      'laborCost': laborCost,
      'stoneCost': stoneCost,
      'engravingCost': engravingCost,
      'timeCost': timeCost,
      'additionalMaterialCost': additionalMaterialCost,
      'customCosts': customCosts,
      'totalCost': totalCost,
      'estimatedHours': estimatedHours,
      'numberOfStones': numberOfStones,
      'stoneWeight': stoneWeight,
      'hasEngraving': hasEngraving,
      'engravingText': engravingText,
    };
  }

  factory ManufacturingCost.fromJson(Map<String, dynamic> json) {
    return ManufacturingCost(
      type: ManufacturingType.values[json['type']],
      goldWeight: json['goldWeight'].toDouble(),
      goldKarat: json['goldKarat'],
      complexity: ComplexityLevel.values[json['complexity']],
      finish: FinishType.values[json['finish']],
      baseLaborCost: json['baseLaborCost'].toDouble(),
      laborCost: json['laborCost'].toDouble(),
      stoneCost: json['stoneCost'].toDouble(),
      engravingCost: json['engravingCost'].toDouble(),
      timeCost: json['timeCost'].toDouble(),
      additionalMaterialCost: json['additionalMaterialCost'].toDouble(),
      customCosts: Map<String, double>.from(json['customCosts']),
      totalCost: json['totalCost'].toDouble(),
      estimatedHours: json['estimatedHours'],
      numberOfStones: json['numberOfStones'],
      stoneWeight: json['stoneWeight'].toDouble(),
      hasEngraving: json['hasEngraving'],
      engravingText: json['engravingText'],
    );
  }
}

enum RepairType {
  resize,
  polish,
  solder,
  stoneReplacement,
  chainRepair,
  claspRepair,
  engraving,
  restoration
}

class RepairCost {
  final RepairType repairType;
  final double itemWeight;
  final int goldKarat;
  final ComplexityLevel complexity;
  final double laborCost;
  final double goldCost;
  final double timeCost;
  final double replacementCost;
  final double totalCost;
  final double additionalGoldWeight;
  final int estimatedHours;
  final bool needsReplacement;
  final String? description;

  RepairCost({
    required this.repairType,
    required this.itemWeight,
    required this.goldKarat,
    required this.complexity,
    required this.laborCost,
    required this.goldCost,
    required this.timeCost,
    required this.replacementCost,
    required this.totalCost,
    required this.additionalGoldWeight,
    required this.estimatedHours,
    required this.needsReplacement,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'repairType': repairType.index,
      'itemWeight': itemWeight,
      'goldKarat': goldKarat,
      'complexity': complexity.index,
      'laborCost': laborCost,
      'goldCost': goldCost,
      'timeCost': timeCost,
      'replacementCost': replacementCost,
      'totalCost': totalCost,
      'additionalGoldWeight': additionalGoldWeight,
      'estimatedHours': estimatedHours,
      'needsReplacement': needsReplacement,
      'description': description,
    };
  }

  factory RepairCost.fromJson(Map<String, dynamic> json) {
    return RepairCost(
      repairType: RepairType.values[json['repairType']],
      itemWeight: json['itemWeight'].toDouble(),
      goldKarat: json['goldKarat'],
      complexity: ComplexityLevel.values[json['complexity']],
      laborCost: json['laborCost'].toDouble(),
      goldCost: json['goldCost'].toDouble(),
      timeCost: json['timeCost'].toDouble(),
      replacementCost: json['replacementCost'].toDouble(),
      totalCost: json['totalCost'].toDouble(),
      additionalGoldWeight: json['additionalGoldWeight'].toDouble(),
      estimatedHours: json['estimatedHours'],
      needsReplacement: json['needsReplacement'],
      description: json['description'],
    );
  }
}

// تمديدات مفيدة
extension ManufacturingTypeExtension on ManufacturingType {
  String get displayName {
    switch (this) {
      case ManufacturingType.ring:
        return 'خاتم';
      case ManufacturingType.necklace:
        return 'قلادة';
      case ManufacturingType.bracelet:
        return 'سوار';
      case ManufacturingType.earrings:
        return 'أقراط';
      case ManufacturingType.pendant:
        return 'دلاية';
      case ManufacturingType.chain:
        return 'سلسلة';
      case ManufacturingType.custom:
        return 'مخصص';
    }
  }
}

extension ComplexityLevelExtension on ComplexityLevel {
  String get displayName {
    switch (this) {
      case ComplexityLevel.simple:
        return 'بسيط';
      case ComplexityLevel.medium:
        return 'متوسط';
      case ComplexityLevel.complex:
        return 'معقد';
      case ComplexityLevel.veryComplex:
        return 'معقد جداً';
    }
  }

  Color get color {
    switch (this) {
      case ComplexityLevel.simple:
        return Colors.green;
      case ComplexityLevel.medium:
        return Colors.orange;
      case ComplexityLevel.complex:
        return Colors.red;
      case ComplexityLevel.veryComplex:
        return Colors.purple;
    }
  }
}

extension FinishTypeExtension on FinishType {
  String get displayName {
    switch (this) {
      case FinishType.polished:
        return 'مصقول';
      case FinishType.matte:
        return 'مطفي';
      case FinishType.brushed:
        return 'مفروش';
      case FinishType.hammered:
        return 'مطروق';
      case FinishType.textured:
        return 'منقوش';
      case FinishType.engraved:
        return 'محفور';
    }
  }
}

extension RepairTypeExtension on RepairType {
  String get displayName {
    switch (this) {
      case RepairType.resize:
        return 'تغيير المقاس';
      case RepairType.polish:
        return 'تلميع';
      case RepairType.solder:
        return 'لحام';
      case RepairType.stoneReplacement:
        return 'استبدال حجر';
      case RepairType.chainRepair:
        return 'إصلاح سلسلة';
      case RepairType.claspRepair:
        return 'إصلاح قفل';
      case RepairType.engraving:
        return 'نقش';
      case RepairType.restoration:
        return 'ترميم';
    }
  }
}

