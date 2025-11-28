import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zenith/providers/notification_notifier.dart';
import 'package:zenith/providers/settings_notifier.dart';
import 'package:zenith/services/weather_api_service.dart';
import 'package:zenith/services/gemini_notification_service.dart';
import 'package:zenith/repositories/weather_repo.dart';
import 'package:zenith/repositories/settings_repo.dart';
import 'package:zenith/repositories/notification_history_repo.dart';
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

final notificationHistoryRepositoryProvider = Provider<NotificationHistoryRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationHistoryRepository(prefs: prefs);
});

final notificationHistoryProvider = StateNotifierProvider<NotificationHistoryNotifier, List<NotificationRecord>>((ref) {
  final repository = ref.watch(notificationHistoryRepositoryProvider);
  return NotificationHistoryNotifier(repository);
});


final geminiNotificationServiceProvider = Provider<GeminiNotificationService>((ref) {
  final notificationsPlugin = ref.watch(notificationsPluginProvider);
  final historyRepo = ref.watch(notificationHistoryRepositoryProvider);
  return GeminiNotificationService(
    notificationsPlugin: notificationsPlugin,
    historyRepository: historyRepo,
  );
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});
