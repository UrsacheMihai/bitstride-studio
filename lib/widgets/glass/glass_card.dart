// Create a custom container card with solid styling and animations.

import 'package:flutter/material.dart';
import '../../theme/studio_theme.dart';

// Provide interface component for Glass Card.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? glowColor;
  final double glowOpacity;
  final VoidCallback? onTap;
  final bool animate;
  final bool elevated;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.glowColor,
    this.glowOpacity = 0.15,
    this.onTap,
    this.animate = false,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      padding: padding,
      decoration: StudioTheme.solidCard(
        isDark: isDark,
        borderRadius: borderRadius,
        accentColor: glowColor,
        elevated: elevated,
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: (glowColor ?? StudioTheme.primaryCyan).withOpacity(0.08),
          highlightColor:
              (glowColor ?? StudioTheme.primaryCyan).withOpacity(0.04),
          child: card,
        ),
      );
    }

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        ),
        child: card,
      );
    }

    return card;
  }
}
