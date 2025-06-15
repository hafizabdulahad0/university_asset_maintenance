// File: lib/auth/reset_password_screen.dart

import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passCtl = TextEditingController();
  bool _saving = false;
  String? _error;

  Future<void> _reset() async {
    final pw = _passCtl.text.trim();
    if (pw.length < 6) return;

    final email = ModalRoute.of(context)!.settings.arguments as String;
    setState(() {
      _saving = true;
      _error = null;
    });

    final user = await DBHelper.getUserByEmail(email);
    if (user == null) {
      setState(() {
        _error = 'User not found';
        _saving = false;
      });
      return;
    }

    user.password = pw;
    await DBHelper.updateUser(user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset successful.')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _passCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Enter a new password',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtl,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            _saving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _reset, child: const Text('Reset Password')),
          ],
        ),
      ),
    );
  }
}
