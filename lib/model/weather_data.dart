import 'package:zenith/model/current_weather.dart';
import 'package:zenith/model/forecast.dart';

class WeatherData {
  final CurrentWeather current;
  final List<ForecastDay> forecast;
  final String cityName;
  final String countryCode;

  WeatherData({
    required this.current,
    required this.forecast,
    required this.cityName,
    required this.countryCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> currentJson, Map<String, dynamic> forecastJson) {
    return WeatherData(
      current: CurrentWeather.fromJson(currentJson),
      forecast: (forecastJson['list'] as List)
          .map((item) => ForecastDay.fromJson(item))
          .toList(),
      cityName: currentJson['name'] ?? '',
      countryCode: currentJson['sys']['country'] ?? '',
    );
  }
}