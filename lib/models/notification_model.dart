// File: lib/models/notification_model.dart

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    DateTime? timestamp,
    this.read = false,
  }) : timestamp = timestamp ?? DateTime.now();
}
