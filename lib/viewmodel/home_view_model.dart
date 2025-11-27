import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith/model/weather_data.dart';
import 'package:zenith/repositories/weather_repo.dart';
import 'package:zenith/services/gemini_notification_service.dart';
import 'package:zenith/providers/provider.dart';

class WeatherState {
  final WeatherData? data;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const WeatherState({
    this.data,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  WeatherState copyWith({
    WeatherData? data,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return WeatherState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, WeatherState>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  final geminiService = ref.watch(geminiNotificationServiceProvider);
  final settings = ref.watch(settingsProvider);

  return HomeViewModel(
    repository: repository,
    geminiService: geminiService,
    city: settings.city,
    countryCode: settings.countryCode,
  );
});

class HomeViewModel extends StateNotifier<WeatherState> {
  final WeatherRepository _repository;
  final GeminiNotificationService _geminiService;
  final String _city;
  final String _countryCode;

  HomeViewModel({
    required WeatherRepository repository,
    required GeminiNotificationService geminiService,
    required String city,
    required String countryCode,
  })  : _repository = repository,
        _geminiService = geminiService,
        _city = city,
        _countryCode = countryCode,
        super(const WeatherState()) {
    //initial data loading
    loadWeather();
  }

  Future<void> loadWeather({bool forceRefresh = false}) async {
    // Setting loading state
    state = state.copyWith(isLoading: true, error: null);

    try {
      final weatherData = await _repository.getWeatherData(
        _city,
        countryCode: _countryCode,
        forceRefresh: forceRefresh,
      );

      state = WeatherState(
        data: weatherData,
        isLoading: false,
        error: null,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
  }

  Future<void> refreshWeather() async {
    await loadWeather(forceRefresh: true);
  }

  Future<void> sendTestNotification() async {
    if (state.data == null) {
      return;
    }

    try {
      await _geminiService.sendWeatherNotification(state.data!);
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  String getWeatherSummary() {
    if (state.data == null) {
      return 'Weather data not available';
    }

    final current = state.data!.current;
    return '${current.description}, ${current.temperature.toStringAsFixed(1)}°C';
  }

  String _parseError(Object error) {
    final errorString = error.toString();

    if (errorString.contains('City not found')) {
      return 'City not found. Please check the city name in settings.';
    } else if (errorString.contains('Invalid API key')) {
      return 'Invalid API key. Please check your configuration.';
    } else if (errorString.contains('Connection timeout') ||
        errorString.contains('SocketException')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('FormatException')) {
      return 'Unable to parse weather data. Please try again.';
    } else {
      return 'Failed to load weather data. Please try again.';
    }
  }

  String getLastUpdatedText() {
    if (state.lastUpdated == null) {
      return 'Never updated';
    }

    final now = DateTime.now();
    final difference = now.difference(state.lastUpdated!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  bool isDataStale() {
    if (state.lastUpdated == null) {
      return true;
    }

    final now = DateTime.now();
    final difference = now.difference(state.lastUpdated!);
    return difference.inMinutes > 30;
  }
}