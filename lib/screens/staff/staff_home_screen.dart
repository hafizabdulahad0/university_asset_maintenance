// File: lib/screens/staff/staff_home_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/notification_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notification_provider.dart';
import '../../helpers/db_helper.dart';
import '../../models/complaint_model.dart';
import '../../auth/profile_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({Key? key}) : super(key: key);
  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  bool _loading = true;
  List<Complaint> _unassigned = [], _assigned = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _loading = true);
    final user = context.read<AuthProvider>().user;
    _unassigned = await DBHelper.getUnassignedComplaints();
    _assigned = user != null
        ? await DBHelper.getAssignedComplaintsByStaff(user.id!)
        : <Complaint>[];
    setState(() => _loading = false);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'unassigned':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'needs_verification':
        return Colors.purple;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme     = context.watch<ThemeProvider>();
    final auth      = context.watch<AuthProvider>();
    final notifProv = context.read<NotificationProvider>();
    final name      = auth.user?.name ?? 'Staff';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          const NotificationBadge(),
          IconButton(
            icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: theme.isDark ? 'Light Mode' : 'Dark Mode',
            onPressed: () => theme.toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadComplaints,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Welcome Banner
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).primaryColorLight,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Text(
                      'Welcome, $name!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 12),
                      children: [
                        // Section: Unassigned Complaints
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Unassigned Complaints',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_unassigned.isEmpty)
                          _emptyCard('No unassigned complaints.')
                        else
                          ..._unassigned.map((c) =>
                              _buildUnassignedCard(c, notifProv, auth.user!)),

                        const Divider(height: 32, thickness: 1),

                        // Section: My Assigned Complaints
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'My Assigned Complaints',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_assigned.isEmpty)
                          _emptyCard('No assigned complaints.')
                        else
                          ..._assigned.map((c) =>
                              _buildAssignedCard(c, notifProv, auth.user!)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _emptyCard(String message) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          color: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );

  Widget _buildUnassignedCard(
      Complaint c, NotificationProvider notifProv, user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _statusColor(c.status).withOpacity(0.4)),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          _buildThumbnail(c),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(c.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        c.status.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _statusColor(c.status),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        c.staffId = user.id;
                        c.status  = 'assigned';
                        await DBHelper.updateComplaint(c);
                        // Notify admin
                        notifProv.add(
                          title: 'Assignment Requested',
                          body: 'Staff ${user.name} requested complaint #${c.id}.',
                        );
                        await _loadComplaints();
                      },
                      child: const Text('Take Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildAssignedCard(
      Complaint c, NotificationProvider notifProv, user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _statusColor(c.status).withOpacity(0.4)),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          _buildThumbnail(c),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(c.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        c.status.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _statusColor(c.status),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        c.status = 'needs_verification';
                        await DBHelper.updateComplaint(c);
                        // Notify admin to verify
                        notifProv.add(
                          title: 'Task Completed',
                          body: 'Staff ${user.name} completed complaint #${c.id}.',
                        );
                        await _loadComplaints();
                      },
                      child: const Text('Mark Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildThumbnail(Complaint c) {
    if (c.mediaPath != null) {
      if (c.mediaIsVideo) {
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Icons.videocam, size: 32, color: Colors.black38),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(c.mediaPath!),
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          const Icon(Icons.description, size: 32, color: Colors.grey),
    );
  }
}
