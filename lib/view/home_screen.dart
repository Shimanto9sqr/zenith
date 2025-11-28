import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zenith/providers/provider.dart';
import 'package:zenith/viewmodel/home_view_model.dart';
import 'package:zenith/model/weather_data.dart';
import 'package:zenith/model/forecast.dart';
import 'package:zenith/view/settings_screen.dart';
import 'package:zenith/view/notification_history_screen.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final notificationHistory = ref.watch(notificationHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_)=>const NotificationHistoryScreen()
                      ),
                    );
                  },
                ),
              if(notificationHistory.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      notificationHistory.length>9?'9+' :notificationHistory.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context, weatherState, viewModel),
      floatingActionButton: FloatingActionButton(
        onPressed: weatherState.isLoading ? null : () => viewModel.refreshWeather(),
        child: weatherState.isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherState state, HomeViewModel viewModel) {
    if (state.error != null) {
      return _buildErrorView(context, state.error!, viewModel);
    }

    if (state.isLoading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.data == null) {
      return _buildEmptyView(context, viewModel);
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshWeather(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentWeather(context, state.data!),
            const SizedBox(height: 24),
            _buildForecast(context, state.data!),
            const SizedBox(height: 16),
            _buildLastUpdated(context, viewModel),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(BuildContext context, WeatherData data) {
    final current = data.current;
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${data.cityName}, ${data.countryCode}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMM d').format(current.timestamp),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  current.iconUrl,
                  width: 100,
                  height: 100,
                  errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 100),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperature.toStringAsFixed(1)}°C',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      current.description.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  context,
                  Icons.thermostat,
                  'Feels Like',
                  '${current.feelsLike.toStringAsFixed(1)}°C',
                ),
                _buildWeatherDetail(
                  context,
                  Icons.water_drop,
                  'Humidity',
                  '${current.humidity}%',
                ),
                _buildWeatherDetail(
                  context,
                  Icons.air,
                  'Wind',
                  '${current.windSpeed.toStringAsFixed(1)} m/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildForecast(BuildContext context, WeatherData data) {
    final theme = Theme.of(context);

    // Group forecasts by day
    final Map<String, List<ForecastDay>> groupedForecasts = {};
    for (final forecast in data.forecast) {
      final dateKey = DateFormat('yyyy-MM-dd').format(forecast.date);
      groupedForecasts.putIfAbsent(dateKey, () => []).add(forecast);
    }

    // Get next 5 days
    final dailyForecasts = groupedForecasts.entries.take(5).map((entry) {
      final forecasts = entry.value;
      final date = forecasts.first.date;
      final minTemp = forecasts.map((f) => f.minTemp).reduce((a, b) => a < b ? a : b);
      final maxTemp = forecasts.map((f) => f.maxTemp).reduce((a, b) => a > b ? a : b);

      // Use midday forecast for icon/description
      final middayForecast = forecasts.length > 4 ? forecasts[4] : forecasts.first;

      return {
        'date': date,
        'minTemp': minTemp,
        'maxTemp': maxTemp,
        'icon': middayForecast.icon,
        'description': middayForecast.description,
      };
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '5-Day Forecast',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...dailyForecasts.map((forecast) => _buildForecastItem(context, forecast)),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(BuildContext context, Map<String, dynamic> forecast) {
    final theme = Theme.of(context);
    final date = forecast['date'] as DateTime;
    final isToday = DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              isToday ? 'Today' : DateFormat('EEE').format(date),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Image.network(
            'https://openweathermap.org/img/wn/${forecast['icon']}@2x.png',
            width: 50,
            height: 50,
            errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 50),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              (forecast['description'] as String).capitalize(),
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${forecast['minTemp'].toStringAsFixed(0)}° / ${forecast['maxTemp'].toStringAsFixed(0)}°',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(BuildContext context, HomeViewModel viewModel) {
    return Center(
      child: Text(
        'Last updated: ${viewModel.getLastUpdatedText()}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error, HomeViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => viewModel.refreshWeather(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, HomeViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No weather data',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or tap the button below',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => viewModel.loadWeather(),
            icon: const Icon(Icons.refresh),
            label: const Text('Load Weather'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}