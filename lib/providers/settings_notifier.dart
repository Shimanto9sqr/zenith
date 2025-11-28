import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith/model/app_settings.dart';
import 'package:zenith/repositories/settings_repo.dart';

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