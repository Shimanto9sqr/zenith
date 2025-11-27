import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zenith/services/weather_api_service.dart';
import 'package:zenith/services/gemini_notification_service.dart';
import 'package:zenith/repositories/weather_repo.dart';
import 'package:zenith/repositories/settings_repo.dart';
import 'package:zenith/model/app_settings.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final notificationsPluginProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  throw UnimplementedError('FlutterLocalNotificationsPlugin must be overridden in main.dart');
});

final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService();
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final apiService = ref.watch(weatherApiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return WeatherRepository(apiService: apiService, prefs: prefs);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs: prefs);
});

final geminiNotificationServiceProvider = Provider<GeminiNotificationService>((ref) {
  final notificationsPlugin = ref.watch(notificationsPluginProvider);
  return GeminiNotificationService(notificationsPlugin: notificationsPlugin);
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.loadSettings());

  Future<void> updateCity(String city, String countryCode) async {
    final success = await _repository.updateCity(city, countryCode);
    if (success) {
      state = state.copyWith(city: city, countryCode: countryCode);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    final success = await _repository.toggleNotifications(enabled);
    if (success) {
      state = state.copyWith(notificationsEnabled: enabled);
    }
  }

  Future<void> updateNotificationHour(int hour) async {
    final success = await _repository.updateNotificationHour(hour);
    if (success) {
      state = state.copyWith(notificationHour: hour);
    }
  }
  
  void reload() {
    state = _repository.loadSettings();
  }
}