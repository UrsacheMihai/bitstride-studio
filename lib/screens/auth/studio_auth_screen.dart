import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/studio/studio_state.dart';
import '../../theme/studio_theme.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Render layout and manage state for Studio Auth Screen.
class StudioAuthScreen extends StatefulWidget {
  const StudioAuthScreen({super.key});

  @override
  State<StudioAuthScreen> createState() => _StudioAuthScreenState();
}

// Manage state and provide providers for Studio Auth Screen State.
class _StudioAuthScreenState extends State<StudioAuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String? _error;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward().whenComplete(() {
      if (mounted) _animCtrl.stop();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final state = context.read<StudioState>();
      String email = _emailCtrl.text.trim();
      if (email == 'admin') email = 'admin@ursachemihaibitstride.bitstride';
      if (_isLogin) {
        await state.signInWithEmail(email, _passCtrl.text);
      } else {
        await state.signUpWithEmail(
            email, _passCtrl.text, _nameCtrl.text.trim());
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        decoration: StudioTheme.meshBackground(isDark: isDark),
        child: Stack(
          children: [
            _BackgroundOrbs(isDark: isDark),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AuthLogo(isDark: isDark),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: StudioTheme.solidCard(
                              isDark: isDark,
                              borderRadius: 28,
                              accentColor: StudioTheme.accentPurple,
                              elevated: true,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _AuthTabBar(
                                  isLogin: _isLogin,
                                  isDark: isDark,
                                  onChanged: (v) =>
                                      setState(() => _isLogin = v),
                                ),
                                const SizedBox(height: 28),
                                if (!_isLogin) ...[
                                  _AuthField(
                                    controller: _nameCtrl,
                                    label: 'Display Name',
                                    icon: Icons.person_outline_rounded,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                RepaintBoundary(
                                  child: Column(
                                    children: [
                                      _AuthField(
                                        controller: _emailCtrl,
                                        label: 'Email',
                                        icon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 14),
                                      _AuthField(
                                        controller: _passCtrl,
                                        label: 'Password',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText: _obscurePassword,
                                        isDark: isDark,
                                        suffix: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 18,
                                            color: isDark
                                                ? const Color(0xFF6B7A99)
                                                : const Color(0xFF8B9AB0),
                                          ),
                                          onPressed: () => setState(() =>
                                              _obscurePassword =
                                                  !_obscurePassword),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 16),
                                  _ErrorBanner(message: _error!),
                                ],
                                const SizedBox(height: 24),
                                _loading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5),
                                        ),
                                      )
                                    : _GradientButton(
                                        label: _isLogin
                                            ? 'Sign In'
                                            : 'Create Account',
                                        onPressed: _submit,
                                      ),
                                if (kIsWeb ||
                                    defaultTargetPlatform ==
                                        TargetPlatform.android ||
                                    defaultTargetPlatform ==
                                        TargetPlatform.iOS) ...[
                                  const SizedBox(height: 12),
                                  _Divider(isDark: isDark),
                                  const SizedBox(height: 12),
                                  _GoogleButton(
                                    onPressed: _loading ? null : _googleSignIn,
                                    isDark: isDark,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () =>
                                  setState(() => _isLogin = !_isLogin),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? const Color(0xFF6B7A99)
                                        : const Color(0xFF8B9AB0),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _isLogin
                                          ? "Don't have an account? "
                                          : 'Already have an account? ',
                                    ),
                                    TextSpan(
                                      text: _isLogin ? 'Sign Up' : 'Sign In',
                                      style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}