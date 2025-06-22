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

