// File: lib/providers/notification_provider.dart

import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  /// All notifications (most‐recent first)
  List<AppNotification> get all =>
      List.unmodifiable(_notifications);

  /// How many are still unread
  int get unreadCount =>
      _notifications.where((n) => !n.read).length;

  /// Add a new notification
  void add({
    required String title,
    required String body,
  }) {
    // Use a timestamp string as a unique ID
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _notifications.insert(
      0,
      AppNotification(id: id, title: title, body: body),
    );
    notifyListeners();
  }

  /// Mark one notification as read
  void markRead(String id) {
    final n = _notifications.firstWhere((n) => n.id == id, orElse: () => throw '');
    if (!n.read) {
      n.read = true;
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllRead() {
    bool changed = false;
    for (var n in _notifications) {
      if (!n.read) {
        n.read = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}
