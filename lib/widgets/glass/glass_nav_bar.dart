// Render the bottom navigation bar widget for the studio.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/studio_theme.dart';

// Provide interface component for Glass Nav Bar.
class GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;
  final double blur;

  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
    this.blur = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? StudioTheme.darkSurface.withOpacity(0.88)
                : StudioTheme.lightSurface.withOpacity(0.90),
            border: Border(
              top: BorderSide(
                color:
                    isDark ? StudioTheme.darkBorder : StudioTheme.lightBorder,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final isSelected = i == selectedIndex;
                  return _GlassNavTile(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    badge: item.badge,
                    onTap: () => onTap(i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Provide interface component for Glass Nav Item.
class GlassNavItem {
  final IconData icon;
  final String label;
  final int badge;

  const GlassNavItem({
    required this.icon,
    required this.label,
    this.badge = 0,
  });
}

// Provide interface component for Glass Nav Tile.
class _GlassNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badge;
  final VoidCallback onTap;

  const _GlassNavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final inactive = isDark ? const Color(0xFF4A5568) : const Color(0xFF8B9AB0);
    final color = isSelected ? primary : inactive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withOpacity(isDark ? 0.16 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: primary.withOpacity(0.25),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: badge > 0,
              label: Text('$badge'),
              backgroundColor: StudioTheme.warningOrange,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 22,
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: -0.2,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
