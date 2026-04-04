import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/studio_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class StudioAuthScreen extends StatefulWidget {
  const StudioAuthScreen({super.key});

  @override
  State<StudioAuthScreen> createState() => _StudioAuthScreenState();
}

class _StudioAuthScreenState extends State<StudioAuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final state = context.read<StudioState>();
      String email = _emailCtrl.text.trim();
      if (email == 'admin') email = 'admin@bitstride.com';
      
      if (_isLogin) {
        await state.signInWithEmail(email, _passCtrl.text);
      } else {
        await state.signUpWithEmail(
            email, _passCtrl.text, _nameCtrl.text.trim());
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<StudioState>().signInWithGoogle();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.code,
                            color: theme.colorScheme.primary, size: 32),
                        const SizedBox(width: 10),
                        Text(
                          'BitStride Studio',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Creator platform for coding challenges',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    if (!_isLogin)
                      TextField(
                        controller: _nameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Display Name'),
                      ),
                    if (!_isLogin) const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(
                              color: theme.colorScheme.error, fontSize: 12)),
                    ],
                    const SizedBox(height: 20),
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submit,
                            child: Text(_isLogin ? 'Sign In' : 'Sign Up'),
                          ),
                    const SizedBox(height: 12),
                    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) ...[
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _googleSignIn,
                        icon: const Icon(Icons.login),
                        label: const Text('Continue with Google'),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextButton(
                      onPressed: () =>
                          setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin
                          ? "Don't have an account? Sign Up"
                          : 'Already have an account? Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
