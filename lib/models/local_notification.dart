// File: lib/models/local_notification.dart

class LocalNotification {
  int? id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool read;

  LocalNotification({
    this.id,
    required this.title,
    required this.body,
    DateTime? timestamp,
    this.read = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'read': read ? 1 : 0,
      };

  factory LocalNotification.fromMap(Map<String, dynamic> m) => LocalNotification(
        id: m['id'] as int?,
        title: m['title'] as String,
        body: m['body'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        read: (m['read'] as int) == 1,
      );
}
