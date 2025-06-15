import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _oldCtl     = TextEditingController();
  final _newCtl     = TextEditingController();
  bool _changing    = false;
  String? _error;

  Future<void> _change() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _changing = true; _error = null; });
    final res = await context
        .read<AuthProvider>()
        .changePassword(_oldCtl.text.trim(), _newCtl.text.trim());
    setState(() => _changing = false);
    if (res != null) {
      setState(() => _error = res);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
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
                      Text('Update Your Password',
                        style: theme.textTheme.headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _oldCtl,
                        decoration: const InputDecoration(
                          labelText: 'Old Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter old password' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newCtl,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) =>
                            v == null || v.length < 6 ? 'Min 6 chars' : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: _changing
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _change,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Change Password'),
                            ),
                      ),
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
