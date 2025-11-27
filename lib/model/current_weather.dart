class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String main;
  final String icon;
  final int pressure;
  final DateTime timestamp;

  CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.main,
    required this.icon,
    required this.pressure,
    required this.timestamp,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    return CurrentWeather(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: weather['description'] ?? '',
      main: weather['main'] ?? '',
      icon: weather['icon'] ?? '',
      pressure: json['main']['pressure'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
    );
  }
  
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}