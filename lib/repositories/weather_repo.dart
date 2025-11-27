import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:zenith/model/weather_data.dart';
import 'package:zenith/services/weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService _apiService;
  final SharedPreferences _prefs;

  static const String _cacheKeyPrefix = 'weather_cache_';
  static const String _cacheTimestampPrefix = 'weather_timestamp_';
  static const Duration _cacheDuration = Duration(minutes: 30);

  WeatherRepository({
    required WeatherApiService apiService,
    required SharedPreferences prefs,
  })  : _apiService = apiService,
        _prefs = prefs;

  Future<WeatherData> getWeatherData(
      String city, {
        String? countryCode,
        bool forceRefresh = false,
      }) async {
    final cacheKey = _buildCacheKey(city, countryCode);

    if (!forceRefresh) {
      final cachedData = _loadFromCache(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }
    }

    try {
      final (currentJson, forecastJson) = await _apiService.getWeatherAndForecast(
        city,
        countryCode: countryCode,
      );

      final weatherData = WeatherData.fromJson(currentJson, forecastJson);

      await _saveToCache(cacheKey, currentJson, forecastJson);

      return weatherData;
    } catch (e) {

      final staleData = _loadFromCache(cacheKey, ignoreExpiry: true);
      if (staleData != null) {
        print('Using stale cache due to API error: $e');
        return staleData;
      }
      rethrow;
    }
  }

  String _buildCacheKey(String city, String? countryCode) {
    return countryCode != null ? '${city}_$countryCode' : city;
  }

  WeatherData? _loadFromCache(String cacheKey, {bool ignoreExpiry = false}) {
    try {
      final cachedCurrent = _prefs.getString('$_cacheKeyPrefix${cacheKey}_current');
      final cachedForecast = _prefs.getString('$_cacheKeyPrefix${cacheKey}_forecast');
      final timestamp = _prefs.getInt('$_cacheTimestampPrefix$cacheKey');

      if (cachedCurrent == null || cachedForecast == null || timestamp == null) {
        return null;
      }

      if (!ignoreExpiry) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        if (now.difference(cacheTime) > _cacheDuration) {
          return null; // Cache expired
        }
      }

      final currentJson = json.decode(cachedCurrent) as Map<String, dynamic>;
      final forecastJson = json.decode(cachedForecast) as Map<String, dynamic>;

      return WeatherData.fromJson(currentJson, forecastJson);
    } catch (e) {
      print('Error loading from cache: $e');
      return null;
    }
  }

  Future<void> _saveToCache(
      String cacheKey,
      Map<String, dynamic> currentJson,
      Map<String, dynamic> forecastJson,
      ) async {
    try {
      await _prefs.setString(
        '$_cacheKeyPrefix${cacheKey}_current',
        json.encode(currentJson),
      );
      await _prefs.setString(
        '$_cacheKeyPrefix${cacheKey}_forecast',
        json.encode(forecastJson),
      );
      await _prefs.setInt(
        '$_cacheTimestampPrefix$cacheKey',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cacheKeyPrefix) || key.startsWith(_cacheTimestampPrefix)) {
        await _prefs.remove(key);
      }
    }
  }
  bool hasCacheFor(String city, {String? countryCode}) {
    final cacheKey = _buildCacheKey(city, countryCode);
    return _prefs.containsKey('$_cacheKeyPrefix${cacheKey}_current');
  }
}