import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith/repositories/notification_history_repo.dart';

class NotificationHistoryNotifier extends StateNotifier<List<NotificationRecord>> {
  final NotificationHistoryRepository _repository;

  NotificationHistoryNotifier(this._repository)
      : super(_repository.getNotificationHistory());

  void reload() {
    state = _repository.getNotificationHistory();
  }

  Future<void> deleteNotification(String id) async {
    final success = await _repository.deleteNotification(id);
    if (success) {
      state = _repository.getNotificationHistory();
    }
  }

  Future<void> clearHistory() async {
    final success = await _repository.clearHistory();
    if (success) {
      state = [];
    }
  }
}