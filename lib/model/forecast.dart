class ForecastDay {
  final DateTime date;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String main;
  final String icon;
  final int humidity;
  final double windSpeed;

  ForecastDay({
    required this.date,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.main,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      description: weather['description'] ?? '',
      main: weather['main'] ?? '',
      icon: weather['icon'] ?? '',
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
