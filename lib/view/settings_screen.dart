import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith/providers/provider.dart';
import 'package:zenith/viewmodel/home_view_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _cityController = TextEditingController(text: settings.city);
    _countryController = TextEditingController(text: settings.countryCode);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Location',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country Code',
                      hintText: 'e.g., US, GB, JP',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 2,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _saveLocation(settingsNotifier),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Location'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Daily Weather Notifications'),
                    subtitle: const Text('Receive personalized weather updates'),
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      settingsNotifier.toggleNotifications(value);
                      if (value) {
                        _showNotificationInfo(context);
                      }
                    },
                  ),
                  if (settings.notificationsEnabled) ...[
                    const Divider(),
                    ListTile(
                      title: const Text('Notification Time'),
                      subtitle: Text(_formatNotificationTime(settings.notificationHour)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectNotificationTime(context, settingsNotifier, settings.notificationHour),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _sendTestNotification(context),
                      icon: const Icon(Icons.send),
                      label: const Text('Send Test Notification'),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'About',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    title: Text('App Version'),
                    subtitle: Text('1.0.0'),
                    leading: Icon(Icons.info_outline),
                  ),
                  const ListTile(
                    title: Text('Weather Data'),
                    subtitle: Text('Powered by OpenWeatherMap'),
                    leading: Icon(Icons.cloud),
                  ),
                  const ListTile(
                    title: Text('AI Notifications'),
                    subtitle: Text('Powered by Google Gemini'),
                    leading: Icon(Icons.auto_awesome),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveLocation(SettingsNotifier settingsNotifier) async {
    final city = _cityController.text.trim();
    final countryCode = _countryController.text.trim().toUpperCase();

    if (city.isEmpty) {
      _showSnackBar('Please enter a city name');
      return;
    }

    if (countryCode.isEmpty) {
      _showSnackBar('Please enter a country code');
      return;
    }

    if (countryCode.length != 2) {
      _showSnackBar('Country code must be 2 characters (e.g., US, GB, JP)');
      return;
    }

    await settingsNotifier.updateCity(city, countryCode);

    ref.invalidate(homeViewModelProvider);

    _showSnackBar('Location saved successfully');
  }

  String _formatNotificationTime(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  Future<void> _selectNotificationTime(
      BuildContext context,
      SettingsNotifier settingsNotifier,
      int currentHour,
      ) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      await settingsNotifier.updateNotificationHour(selectedTime.hour);
      _showSnackBar('Notification time updated to ${_formatNotificationTime(selectedTime.hour)}');
    }
  }

  void _sendTestNotification(BuildContext context) async {
    try {
      final viewModel = ref.read(homeViewModelProvider.notifier);
      await viewModel.sendTestNotification();
      _showSnackBar('Test notification sent! Check your notifications.');
    } catch (e) {
      _showSnackBar('Failed to send notification: $e');
    }
  }

  void _showNotificationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Notifications'),
        content: const Text(
          'You\'ll receive a personalized weather notification each day at your selected time. '
              'Our AI will analyze the weather and provide helpful tips!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}