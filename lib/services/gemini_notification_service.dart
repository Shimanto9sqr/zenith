import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zenith/constants/api_constants.dart';
import 'package:zenith/constants/app_constants.dart';
import 'package:zenith/model/weather_data.dart';

class GeminiNotificationService {
  final GenerativeModel _model;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  GeminiNotificationService({
    GenerativeModel? model,
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  })  : _model = model ??
      GenerativeModel(
        model: ApiConstants.geminiModel,
        apiKey: ApiConstants.geminiApiKey,
      ),
        _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  static const String _systemPrompt = '''
You are a helpful, slightly witty weather assistant named "Weather Buddy". Your job is to create engaging, personalized daily weather notification messages.

Key Guidelines:
- Keep messages concise (2-3 sentences max, under 100 words)
- Be conversational and friendly, with a touch of humor when appropriate
- Provide practical advice based on the weather conditions
- Mention specific temperatures and conditions
- Suggest activities or what to wear/bring
- Use emojis sparingly and naturally (1-2 max)
- Focus on the most important weather aspects for the day
- Be encouraging and positive even when weather is poor

Examples of your style:
- For sunny weather: "Beautiful day ahead at 24°C! Perfect for that outdoor lunch you've been planning. Don't forget sunscreen! ☀️"
- For rain: "Rainy day at 15°C – grab your umbrella and that good book. Evening might clear up for a walk! 🌧️"
- For cold: "Bundle up! Only 2°C today with crisp winds. Hot coffee weather – perfect excuse to visit that new café downtown."

Create ONE notification message based on the weather data provided.
''';

  Future<String> generateNotificationMessage(WeatherData weatherData) async {
    try {
      final weatherContext = _buildWeatherContext(weatherData);
      final prompt = '''
$_systemPrompt

Current Weather Data:
$weatherContext

Generate a personalized weather notification message for today.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!.trim();
      } else {
        return _buildFallbackMessage(weatherData);
      }
    } catch (e) {
      print('Error generating Gemini notification: $e');
      return _buildFallbackMessage(weatherData);
    }
  }

  String _buildWeatherContext(WeatherData weatherData) {
    final current = weatherData.current;
    final forecast = weatherData.forecast;

    final todayForecasts = forecast.where((f) {
      final now = DateTime.now();
      return f.date.day == now.day && f.date.month == now.month;
    }).toList();

    final minTemp = todayForecasts.isEmpty
        ? current.temperature
        : todayForecasts.map((f) => f.minTemp).reduce((a, b) => a < b ? a : b);
    final maxTemp = todayForecasts.isEmpty
        ? current.temperature
        : todayForecasts.map((f) => f.maxTemp).reduce((a, b) => a > b ? a : b);

    return '''
City: ${weatherData.cityName}, ${weatherData.countryCode}
Current Condition: ${current.main} (${current.description})
Current Temperature: ${current.temperature.toStringAsFixed(1)}°C
Feels Like: ${current.feelsLike.toStringAsFixed(1)}°C
Today's Range: ${minTemp.toStringAsFixed(0)}°C - ${maxTemp.toStringAsFixed(0)}°C
Humidity: ${current.humidity}%
Wind Speed: ${current.windSpeed} m/s
''';
  }

  String _buildFallbackMessage(WeatherData weatherData) {
    final temp = weatherData.current.temperature.toStringAsFixed(1);
    final condition = weatherData.current.description;

    return 'Today\'s weather: $condition, $temp°C in ${weatherData.cityName}. Have a great day!';
  }

  Future<void> showNotification({
    required String title,
    required String message,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> sendWeatherNotification(WeatherData weatherData) async {
    try {
      final message = await generateNotificationMessage(weatherData);
      await showNotification(
        title: '${weatherData.cityName} Weather',
        message: message,
        id: DateTime.now().millisecondsSinceEpoch % 100000,
      );
    } catch (e) {
      print('Error sending weather notification: $e');
    }
  }
}