import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationRecord {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;

  NotificationRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory NotificationRecord.fromJson(Map<String, dynamic> json) {
    return NotificationRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }
}

class NotificationHistoryRepository {
  final SharedPreferences _prefs;

  static const String _historyKey = 'notification_history';
  static const int _maxHistorySize = 25;

  NotificationHistoryRepository({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveNotification({
    required String title,
    required String message,
  }) async {
    try {
      final notifications = getNotificationHistory();

      final newNotification = NotificationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        timestamp: DateTime.now(),
      );

      notifications.insert(0, newNotification);

      if (notifications.length > _maxHistorySize) {
        notifications.removeRange(_maxHistorySize, notifications.length);
      }

      final jsonList = notifications.map((n) => n.toJson()).toList();
      await _prefs.setString(_historyKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving notification to history: $e');
    }
  }

  List<NotificationRecord> getNotificationHistory() {
    try {
      final historyJson = _prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> jsonList = json.decode(historyJson);
        return jsonList
            .map((json) => NotificationRecord.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading notification history: $e');
    }

    return [];
  }

  NotificationRecord? getNotificationById(String id) {
    final notifications = getNotificationHistory();
    try {
      return notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      final notifications = getNotificationHistory();
      notifications.removeWhere((n) => n.id == id);

      final jsonList = notifications.map((n) => n.toJson()).toList();
      return await _prefs.setString(_historyKey, json.encode(jsonList));
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  Future<bool> clearHistory() async {
    return await _prefs.remove(_historyKey);
  }

  int getNotificationCount() {
    return getNotificationHistory().length;
  }
  
  List<NotificationRecord> getTodayNotifications() {
    final notifications = getNotificationHistory();
    final now = DateTime.now();

    return notifications.where((n) {
      return n.timestamp.year == now.year &&
          n.timestamp.month == now.month &&
          n.timestamp.day == now.day;
    }).toList();
  }
}