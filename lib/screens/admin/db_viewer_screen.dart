// File: lib/screens/admin/db_viewer_screen.dart

import 'package:flutter/material.dart';
import '../../helpers/db_helper.dart';
import '../../models/user_model.dart';
import '../../models/complaint_model.dart';

class DbViewerScreen extends StatefulWidget {
  const DbViewerScreen({Key? key}) : super(key: key);
  @override
  State<DbViewerScreen> createState() => _DbViewerScreenState();
}

class _DbViewerScreenState extends State<DbViewerScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _authorized = false;

  // Hard-coded supervisor credentials
  static const _supervisorEmail = 'saira@app';
  static const _supervisorPass = 'Pass123';

  void _authenticate() {
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text.trim();
    if (email == _supervisorEmail && pw == _supervisorPass) {
      setState(() => _authorized = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authorized) {
      return Scaffold(
        appBar: AppBar(title: const Text('DB Viewer Login')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Enter supervisor credentials',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pwCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _authenticate, child: const Text('Log In')),
          ]),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Database Tables'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Users'),
            Tab(text: 'Complaints'),
          ]),
        ),
        body: TabBarView(children: [
          _buildUsersTab(),
          _buildComplaintsTab(),
        ]),
      ),
    );
  }

  Widget _buildUsersTab() {
    return FutureBuilder<List<User>>(
      future: DBHelper.getAllUsers(),
      builder: (_, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final users = snap.data!;
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final u = users[i];
            return ListTile(
              title: Text('${u.id}: ${u.name}'),
              subtitle: Text('${u.email} • role=${u.role}'),
              trailing: u.role == 'supervisor'
                  ? null
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit User',
                        onPressed: () => _showEditUserDialog(u),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: 'Delete User',
                        onPressed: () async {
                          await DBHelper.deleteUser(u.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted user #${u.id}')),
                          );
                          setState(() {});
                        },
                      ),
                    ]),
            );
          },
        );
      },
    );
  }

  Widget _buildComplaintsTab() {
    return FutureBuilder<List<Complaint>>(
      future: DBHelper.getAllComplaints(),
      builder: (_, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final c = list[i];
            return ListTile(
              title: Text('#${c.id}: ${c.title}'),
              subtitle: Text(
                  'status=${c.status}, teacher=${c.teacherId}, staff=${c.staffId ?? '-'}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit Complaint',
                  onPressed: () => _showEditComplaintDialog(c),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  tooltip: 'Delete Complaint',
                  onPressed: () async {
                    await DBHelper.deleteComplaint(c.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted complaint #${c.id}')),
                    );
                    setState(() {});
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sync, size: 20),
                  tooltip: 'Change Status',
                  onSelected: (newStatus) async {
                    c.status = newStatus;
                    await DBHelper.updateComplaint(c);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Status updated to "${newStatus.replaceAll('_', ' ')}"')),
                    );
                    setState(() {});
                  },
                  itemBuilder: (_) => [
                    'unassigned',
                    'assigned',
                    'needs_verification',
                    'closed',
                  ]
                      .map((s) => PopupMenuItem(
                            value: s,
                            child: Text(s.replaceAll('_', ' ').toUpperCase()),
                          ))
                      .toList(),
                ),
              ]),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditUserDialog(User u) async {
    final nameCtrl = TextEditingController(text: u.name);
    final emailCtrl = TextEditingController(text: u.email);
    final passwordCtrl = TextEditingController(text: u.password);
    String selectedRole = u.role;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit User #${u.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['admin', 'staff', 'teacher']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child:
                              Text(role[0].toUpperCase() + role.substring(1)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedRole = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = User(
                id: u.id,
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                password: passwordCtrl.text.trim(),
                role: selectedRole,
              );
              await DBHelper.updateUser(updated);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Updated user #${u.id}')),
              );
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditComplaintDialog(Complaint c) async {
    final titleCtrl = TextEditingController(text: c.title);
    final descCtrl = TextEditingController(text: c.description);
    final statusCtrl = TextEditingController(text: c.status);
    final teacherCtrl = TextEditingController(text: c.teacherId.toString());
    final staffCtrl = TextEditingController(text: c.staffId?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Complaint #${c.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              TextField(
                  controller: statusCtrl,
                  decoration: const InputDecoration(labelText: 'Status')),
              const SizedBox(height: 8),
              TextField(
                controller: teacherCtrl,
                decoration: const InputDecoration(labelText: 'Teacher ID'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: staffCtrl,
                decoration: const InputDecoration(labelText: 'Staff ID'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              c.title = titleCtrl.text.trim();
              c.description = descCtrl.text.trim();
              c.status = statusCtrl.text.trim();
              c.teacherId =
                  int.tryParse(teacherCtrl.text.trim()) ?? c.teacherId;
              c.staffId = int.tryParse(staffCtrl.text.trim());
              await DBHelper.updateComplaint(c);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Updated complaint #${c.id}')),
              );
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
