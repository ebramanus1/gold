class Client {
  final String id;
  final String name;
  final String? businessName;
  final String phone;
  final String? email;
  final String? address;
  final String? commercialRegistration;
  final String? taxNumber;
  final String? contactPerson;
  final double creditLimit;
  final double currentBalance24k;
  final double currentBalance22k;
  final double currentBalance21k;
  final double currentBalance18k;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTransactionAt;
  final String? notes;

  Client({
    required this.id,
    required this.name,
    this.businessName,
    required this.phone,
    this.email,
    this.address,
    this.commercialRegistration,
    this.taxNumber,
    this.contactPerson,
    this.creditLimit = 0.0,
    this.currentBalance24k = 0.0,
    this.currentBalance22k = 0.0,
    this.currentBalance21k = 0.0,
    this.currentBalance18k = 0.0,
    this.isActive = true,
    required this.createdAt,
    this.lastTransactionAt,
    this.notes,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      businessName: map['business_name'],
      phone: map['phone'] ?? '',
      email: map['email'],
      address: map['address'],
      commercialRegistration: map['commercial_registration'],
      taxNumber: map['tax_number'],
      contactPerson: map['contact_person'],
      creditLimit: (map['credit_limit'] ?? 0.0).toDouble(),
      currentBalance24k: (map['current_balance_24k'] ?? 0.0).toDouble(),
      currentBalance22k: (map['current_balance_22k'] ?? 0.0).toDouble(),
      currentBalance21k: (map['current_balance_21k'] ?? 0.0).toDouble(),
      currentBalance18k: (map['current_balance_18k'] ?? 0.0).toDouble(),
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      lastTransactionAt: map['last_transaction_at'] != null 
          ? DateTime.parse(map['last_transaction_at']) 
          : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'business_name': businessName,
      'phone': phone,
      'email': email,
      'address': address,
      'commercial_registration': commercialRegistration,
      'tax_number': taxNumber,
      'contact_person': contactPerson,
      'credit_limit': creditLimit,
      'current_balance_24k': currentBalance24k,
      'current_balance_22k': currentBalance22k,
      'current_balance_21k': currentBalance21k,
      'current_balance_18k': currentBalance18k,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_transaction_at': lastTransactionAt?.toIso8601String(),
      'notes': notes,
    };
  }

  Client copyWith({
    String? id,
    String? name,
    String? businessName,
    String? phone,
    String? email,
    String? address,
    String? commercialRegistration,
    String? taxNumber,
    String? contactPerson,
    double? creditLimit,
    double? currentBalance24k,
    double? currentBalance22k,
    double? currentBalance21k,
    double? currentBalance18k,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTransactionAt,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      commercialRegistration: commercialRegistration ?? this.commercialRegistration,
      taxNumber: taxNumber ?? this.taxNumber,
      contactPerson: contactPerson ?? this.contactPerson,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance24k: currentBalance24k ?? this.currentBalance24k,
      currentBalance22k: currentBalance22k ?? this.currentBalance22k,
      currentBalance21k: currentBalance21k ?? this.currentBalance21k,
      currentBalance18k: currentBalance18k ?? this.currentBalance18k,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
      notes: notes ?? this.notes,
    );
  }

  // حساب إجمالي الرصيد بجميع العيارات
  double get totalBalance => currentBalance24k + currentBalance22k + currentBalance21k + currentBalance18k;

  // الحصول على رصيد عيار معين
  double getBalanceByKarat(String karat) {
    switch (karat.toLowerCase()) {
      case '24k':
        return currentBalance24k;
      case '22k':
        return currentBalance22k;
      case '21k':
        return currentBalance21k;
      case '18k':
        return currentBalance18k;
      default:
        return 0.0;
    }
  }

  @override
  String toString() {
    return 'Client(id: $id, name: $name, phone: $phone, totalBalance: $totalBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

