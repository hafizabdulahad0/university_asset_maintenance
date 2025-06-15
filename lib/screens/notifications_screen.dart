// File: lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notif.unreadCount > 0)
            TextButton(
              onPressed: () => notif.markAllRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: notif.all.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.separated(
              itemCount: notif.all.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final n = notif.all[i];
                return ListTile(
                  tileColor: n.read ? null : Colors.blue.shade50,
                  leading: Icon(
                    n.read ? Icons.notifications : Icons.notifications_active,
                    color: n.read ? Colors.grey : Colors.blue,
                  ),
                  title: Text(n.title,
                      style: TextStyle(
                        fontWeight: n.read ? FontWeight.normal : FontWeight.bold,
                      )),
                  subtitle: Text(n.body),
                  trailing: Text(
                    '${n.timestamp.hour.toString().padLeft(2, '0')}:'
                    '${n.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () => notif.markRead(n.id),
                );
              },
            ),
    );
  }
}
