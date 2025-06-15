// File: lib/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtl = TextEditingController();
  bool _loading = false;

  Future<void> _continue() async {
    final email = _emailCtl.text.trim();
    if (email.isEmpty) return;
    setState(() => _loading = true);
    // simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    // pass email along to reset screen
    Navigator.pushReplacementNamed(
      context,
      '/reset-password',
      arguments: email,
    );
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Enter your email to reset your password',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _continue,
                    child: const Text('Continue'),
                  ),
          ],
        ),
      ),
    );
  }
}
