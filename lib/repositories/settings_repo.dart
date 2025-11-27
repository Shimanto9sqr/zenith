import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:zenith/model/weather_data.dart';
import 'package:zenith/constants/api_constants.dart';
import 'package:zenith/model/app_settings.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  static const String _settingsKey = 'app_settings';

  SettingsRepository({required SharedPreferences prefs}) : _prefs = prefs;

  AppSettings loadSettings() {
    try {
      final settingsJson = _prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final json = jsonDecode(settingsJson) as Map<String, dynamic>;
        return AppSettings.fromJson(json);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }

    return AppSettings(
      city: ApiConstants.defaultCity,
      countryCode: ApiConstants.defaultCountryCode,
      notificationsEnabled: false,
      notificationHour: 8,
    );
  }

  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final json = jsonEncode(settings.toJson());
      return await _prefs.setString(_settingsKey, json);
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }


  Future<bool> updateCity(String city, String countryCode) async {
    final currentSettings = loadSettings();
    final updatedSettings = currentSettings.copyWith(
      city: city,
      countryCode: countryCode,
    );
    return await saveSettings(updatedSettings);
  }

  Future<bool> toggleNotifications(bool enabled) async {
    final currentSettings = loadSettings();
    final updatedSettings = currentSettings.copyWith(
      notificationsEnabled: enabled,
    );
    return await saveSettings(updatedSettings);
  }

  Future<bool> updateNotificationHour(int hour) async {
    if (hour < 0 || hour > 23) {
      throw ArgumentError('Hour must be between 0 and 23');
    }

    final currentSettings = loadSettings();
    final updatedSettings = currentSettings.copyWith(
      notificationHour: hour,
    );
    return await saveSettings(updatedSettings);
  }
  
  Future<bool> clearSettings() async {
    return await _prefs.remove(_settingsKey);
  }
}