// File: lib/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  String _role = 'teacher';
  bool _loading = false;
  String? _error;

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final newUser = User(
      name: _nameCtl.text.trim(),
      email: _emailCtl.text.trim(),
      password: _passCtl.text.trim(),
      role: _role,
    );

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await context
        .read<AuthProvider>()
        .register(newUser.name, newUser.email, newUser.password, newUser.role);

    setState(() => _loading = false);

    if (res != null) {
      setState(() => _error = res);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Create Account',
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
                        controller: _emailCtl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtl,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _role,
                        items: const [
                          DropdownMenuItem(
                              value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(
                              value: 'staff', child: Text('Staff')),
                          DropdownMenuItem(
                              value: 'teacher', child: Text('Teacher')),
                        ],
                        onChanged: (v) => setState(() => _role = v!),
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group_outlined),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _onRegister,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Register'),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text("Already have an account? Log In"),
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
