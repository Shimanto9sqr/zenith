import 'package:dio/dio.dart';
import 'package:zenith/constants/api_constants.dart';

class WeatherApiService {
  final Dio _dio;

  WeatherApiService({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: ApiConstants.weatherBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

  Future<Map<String, dynamic>> getCurrentWeather(
      String city, {
        String? countryCode,
      }) async {
    try {
      final query = countryCode != null ? '$city,$countryCode' : city;

      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': query,
          'appid': ApiConstants.weatherApiKey,
          'units': 'metric', // Use Celsius
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch weather data',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('City not found. Please check the city name.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to fetch weather data: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> getForecast(
      String city, {
        String? countryCode,
      }) async {
    try {
      final query = countryCode != null ? '$city,$countryCode' : city;

      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'q': query,
          'appid': ApiConstants.weatherApiKey,
          'units': 'metric', // Use Celsius
          'cnt': 40, // 5 days * 8 (3-hour intervals)
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch forecast data',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('City not found. Please check the city name.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to fetch forecast data: ${e.message}');
      }
    }
  }

  Future<(Map<String, dynamic>, Map<String, dynamic>)> getWeatherAndForecast(
      String city, {
        String? countryCode,
      }) async {
    final results = await Future.wait([
      getCurrentWeather(city, countryCode: countryCode),
      getForecast(city, countryCode: countryCode),
    ]);

    return (results[0], results[1]);
  }
}