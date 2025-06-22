enum UserRole {
  admin,
  manager,
  artisan,
  sales,
  accountant,
  viewer,
}

class UserSettings {
  final bool receiveNotifications;
  final String theme;
  final String language;

  UserSettings({
    this.receiveNotifications = true,
    this.theme = 'light',
    this.language = 'ar',
  });

  Map<String, dynamic> toMap() {
    return {
      'receive_notifications': receiveNotifications,
      'theme': theme,
      'language': language,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      receiveNotifications: map['receive_notifications'] ?? true,
      theme: map['theme'] ?? 'light',
      language: map['language'] ?? 'ar',
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final String passwordHash;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? profileImageUrl;
  final UserSettings? settings;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.passwordHash,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.profileImageUrl,
    this.settings,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String?,
      role: UserRole.values[map['role'] as int],
      passwordHash: map['password_hash'] as String,
      isActive: map['is_active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'] as String)
          : null,
      profileImageUrl: map['profile_image_url'] as String?,
      settings: map['settings'] != null
          ? UserSettings.fromMap(map['settings'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.index,
      'password_hash': passwordHash,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'settings': settings != null ? settings!.toMap() : null,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    String? passwordHash,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profileImageUrl,
    UserSettings? settings,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      passwordHash: passwordHash ?? this.passwordHash,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      settings: settings ?? this.settings,
    );
  }
}

