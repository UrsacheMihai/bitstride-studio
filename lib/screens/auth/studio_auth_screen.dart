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

// Render the ambient blurred glow orbs behind the auth card.
class _BackgroundOrbs extends StatelessWidget {
  final bool isDark;

  const _BackgroundOrbs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (!isDark) return const SizedBox.shrink();
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(painter: _OrbPainter()),
      ),
    );
  }
}

// Provide interface component for Orb Painter.
class _OrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintCyan = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.06)
      ..style = PaintingStyle.fill;
    final paintPurple = Paint()
      ..color = const Color(0xFF7C4DFF).withOpacity(0.07)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.2), 200, paintPurple);
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.75), 160, paintCyan);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Render the Studio logo and branding header.
class _AuthLogo extends StatelessWidget {
  final bool isDark;

  const _AuthLogo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: StudioTheme.creatorGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: StudioTheme.accentPurple.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.code_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          'BitStride',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -0.8,
            color: isDark ? Colors.white : StudioTheme.darkBg,
          ),
        ),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (bounds) =>
              StudioTheme.creatorGradient.createShader(bounds),
          child: const Text(
            'STUDIO',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Creator platform for coding challenges',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF6B7A99) : const Color(0xFF8B9AB0),
          ),
        ),
      ],
    );
  }
}

// Provide interface component for Auth Tab Bar.
class _AuthTabBar extends StatelessWidget {
  final bool isLogin;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _AuthTabBar({
    required this.isLogin,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? StudioTheme.darkCard : StudioTheme.lightCard;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? StudioTheme.darkBorder : StudioTheme.lightBorder,
        ),
      ),
      child: Row(
        children: [
          _AuthTab(
            label: 'Sign In',
            selected: isLogin,
            isDark: isDark,
            primary: primary,
            onTap: () => onChanged(true),
          ),
          _AuthTab(
            label: 'Sign Up',
            selected: !isLogin,
            isDark: isDark,
            primary: primary,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

// Render a selectable tab chip for toggling between sign in and sign up.
class _AuthTab extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final Color primary;
  final VoidCallback onTap;

  const _AuthTab({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? StudioTheme.darkCard2 : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(
                    color: isDark
                        ? StudioTheme.darkBorder
                        : StudioTheme.lightBorder,
                  )
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? (isDark ? Colors.white : StudioTheme.darkBg)
                  : (isDark
                      ? const Color(0xFF4A5568)
                      : const Color(0xFF8B9AB0)),
            ),
          ),
        ),
      ),
    );
  }
}

// Provide interface component for Auth Field.
class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool isDark;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    required this.isDark,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: suffix,
      ),
    );
  }
}

// Render an error message banner with icon and text.
class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StudioTheme.errorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudioTheme.errorRed.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: StudioTheme.errorRed, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: StudioTheme.errorRed, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Provide interface component for Gradient Button.
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: StudioTheme.creatorGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: StudioTheme.accentPurple.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Render a horizontal rule with an or label in the center.
class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? StudioTheme.darkBorder : StudioTheme.lightBorder;
    return Row(
      children: [
        Expanded(child: Divider(color: color, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF4A5568) : const Color(0xFF8B9AB0),
            ),
          ),
        ),
        Expanded(child: Divider(color: color, height: 1)),
      ],
    );
  }
}

// Provide interface component for Google Button.
class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isDark;

  const _GoogleButton({required this.onPressed, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login_rounded,
            size: 18,
            color: isDark ? Colors.white70 : StudioTheme.darkBg,
          ),
          const SizedBox(width: 10),
          Text(
            'Continue with Google',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : StudioTheme.darkBg,
            ),
          ),
        ],
      ),
    );
  }
}
