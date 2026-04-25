import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/studio_theme.dart';

// Provide interface component for Glass App Bar.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double blur;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.blur = 20,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

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
              bottom: BorderSide(
                color:
                    isDark ? StudioTheme.darkBorder : StudioTheme.lightBorder,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: kToolbarHeight,
                  child: NavigationToolbar(
                    leading: leading ??
                        (Navigator.canPop(context)
                            ? IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20,
                                  color: isDark
                                      ? Colors.white
                                      : StudioTheme.darkBg,
                                ),
                                onPressed: () => Navigator.maybePop(context),
                              )
                            : null),
                    middle: title != null
                        ? DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : StudioTheme.darkBg,
                              letterSpacing: -0.4,
                            ),
                            child: title!,
                          )
                        : null,
                    trailing: actions != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actions!,
                          )
                        : null,
                    centerMiddle: centerTitle,
                    middleSpacing: NavigationToolbar.kMiddleSpacing,
                  ),
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
