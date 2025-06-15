import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtl      = TextEditingController();
  String? _message;
  String _role        = '';
  bool _saving        = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final u = context.read<AuthProvider>().user;
    if (u != null) {
      _nameCtl.text = u.name;
      _role = u.role;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _message = null; });
    final auth = context.read<AuthProvider>();
    final updated = User(
      id:       auth.user!.id,
      name:     _nameCtl.text.trim(),
      email:    auth.user!.email,
      password: auth.user!.password,
      role:     _role,
    );
    final res = await auth.updateProfile(updated);
    setState(() { _saving = false; _message = res; });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);
    if (user == null) {
      return Scaffold(body: Center(child: Text('No user found')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('Your Profile',
                        style: theme.textTheme.headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameCtl,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: user.email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: _saving
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Save Changes'),
                            ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                        ),
                        child: const Text('Change Password'),
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 12),
                        Text(_message!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
