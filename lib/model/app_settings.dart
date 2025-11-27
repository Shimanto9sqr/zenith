class AppSettings {
  final String city;
  final String countryCode;
  final bool notificationsEnabled;
  final int notificationHour; // 0-23

  AppSettings({
    required this.city,
    required this.countryCode,
    this.notificationsEnabled = false,
    this.notificationHour = 8, // 8 AM default
  });

  AppSettings copyWith({
    String? city,
    String? countryCode,
    bool? notificationsEnabled,
    int? notificationHour,
  }) {
    return AppSettings(
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'countryCode': countryCode,
      'notificationsEnabled': notificationsEnabled,
      'notificationHour': notificationHour,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      city: json['city'] as String,
      countryCode: json['countryCode'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      notificationHour: json['notificationHour'] as int? ?? 8,
    );
  }
}