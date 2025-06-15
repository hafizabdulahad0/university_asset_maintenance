// File: lib/screens/teacher/teacher_home_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/notification_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/theme_provider.dart';
import 'add_complaint_screen.dart';
import 'package:university_asset_maintenance/auth/profile_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({Key? key}) : super(key: key);

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  late ComplaintProvider _cp;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _cp = context.read<ComplaintProvider>();
      _cp.loadComplaintsForTeacher(user.id!).then((_) {
        setState(() => _loading = false);
      });
    }
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
    final theme       = context.watch<ThemeProvider>();
    final auth        = context.watch<AuthProvider>();
    final complaintP  = context.watch<ComplaintProvider>();
    final teacherName = auth.user?.name ?? 'Teacher';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Home'),
        actions: [
          const NotificationBadge(),
          IconButton(
            icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: theme.isDark ? 'Switch to Light' : 'Switch to Dark',
            onPressed: () => theme.toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final user = auth.user;
            if (user != null) {
              setState(() => _loading = true);
              await _cp.loadComplaintsForTeacher(user.id!);
              setState(() => _loading = false);
            }
          },
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Welcome banner
                    Container(
                      width: double.infinity,
                      color: Theme.of(context).primaryColorLight,
                      padding:
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Text(
                        'Welcome, $teacherName!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Complaints list or empty state
                    Expanded(
                      child: complaintP.myComplaints.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 100),
                                Icon(Icons.inbox,
                                    size: 64,
                                    color:
                                        Theme.of(context).disabledColor),
                                const SizedBox(height: 16),
                                Center(
                                  child: Text(
                                    'No complaints yet.\nTap the + button below to create one.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).disabledColor),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              itemCount:
                                  complaintP.myComplaints.length,
                              itemBuilder: (ctx, i) {
                                final c =
                                    complaintP.myComplaints[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: _statusColor(c.status)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  elevation: 2,
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    onTap: () {
                                      // maybe show details in future
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Thumbnail
                                          if (c.mediaPath != null &&
                                              !c.mediaIsVideo)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8),
                                              child: Image.file(
                                                File(c.mediaPath!),
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          else if (c.mediaPath != null &&
                                              c.mediaIsVideo)
                                            Container(
                                              width: 64,
                                              height: 64,
                                              decoration:
                                                  BoxDecoration(
                                                color: Colors.black12,
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.videocam,
                                                size: 32,
                                                color: Colors.black38,
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 64,
                                              height: 64,
                                              decoration:
                                                  BoxDecoration(
                                                color: Colors
                                                    .grey.shade200,
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.description,
                                                size: 32,
                                                color: Colors.grey,
                                              ),
                                            ),

                                          const SizedBox(width: 16),

                                          // Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  c.title,
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 8),
                                                Text(
                                                  c.description,
                                                  maxLines: 2,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                                const SizedBox(
                                                    height: 12),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Chip(
                                                      label: Text(
                                                        c.status
                                                            .replaceAll('_',
                                                                ' ')
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white),
                                                      ),
                                                      backgroundColor:
                                                          _statusColor(
                                                              c.status),
                                                    ),
                                                    Text(
                                                      'ID: ${c.id}',
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Report New Complaint'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddComplaintScreen()),
          );
          final user = auth.user;
          if (user != null) {
            setState(() => _loading = true);
            await _cp.loadComplaintsForTeacher(user.id!);
            setState(() => _loading = false);
          }
        },
      ),
    );
  }
}
