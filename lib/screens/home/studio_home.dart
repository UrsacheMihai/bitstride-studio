import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/studio/studio_state.dart';
import '../../theme/studio_theme.dart';
import '../../widgets/glass/glass_nav_bar.dart';
import '../challenge/create_screen.dart';
import '../challenge/my_challenges_screen.dart';
import '../challenge/review_screen.dart';
import '../course/course_manager_screen.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';

// Routes to the admin or user shell based on the current user role.
class StudioHome extends StatelessWidget {
  const StudioHome({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    return state.isAdmin ? const _AdminShell() : const _UserShell();
  }
}

// Render the main shell for regular (non-admin) users.
class _UserShell extends StatefulWidget {
  const _UserShell();

  @override
  State<_UserShell> createState() => _UserShellState();
}

// Manage state and provide providers for User Shell State.
class _UserShellState extends State<_UserShell> {
  int _tab = 0;

  // Switch the active tab and skip rebuild if already on the same tab.
  void _setTab(int i) {
    if (i == _tab) return;
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          CreateScreen(),
          MyChallengesScreen(),
        ],
      ),
      floatingActionButton: _tab == 1
          ? _StudioFab(
              label: l.newChallenge,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateScreen()),
              ),
            )
          : null,
      bottomNavigationBar: GlassNavBar(
        selectedIndex: _tab,
        onTap: _setTab,
        items: [
          GlassNavItem(
            icon: _tab == 0 ? Icons.add_box_rounded : Icons.add_box_outlined,
            label: l.create,
          ),
          GlassNavItem(
            icon: _tab == 1 ? Icons.folder_rounded : Icons.folder_outlined,
            label: l.myChallenges,
          ),
        ],
      ),
    );
  }
}

// Render the main shell for admin users with extra tabs.
class _AdminShell extends StatefulWidget {
  const _AdminShell();

  @override
  State<_AdminShell> createState() => _AdminShellState();
}

// Manage state and provide providers for Admin Shell State.
class _AdminShellState extends State<_AdminShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    final l = AppLocalizations.of(context)!;
    final pending = state.allChallenges.where((c) => !c.approved).length;

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          CreateScreen(),
          ReviewScreen(),
          MyChallengesScreen(),
          CourseManagerScreen(),
        ],
      ),
      floatingActionButton: _tab == 2
          ? _StudioFab(
              label: l.newChallenge,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateScreen()),
              ),
            )
          : null,
      bottomNavigationBar: GlassNavBar(
        selectedIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: [
          GlassNavItem(
            icon: _tab == 0 ? Icons.add_box_rounded : Icons.add_box_outlined,
            label: l.create,
          ),
          GlassNavItem(
            icon: _tab == 1
                ? Icons.rate_review_rounded
                : Icons.rate_review_outlined,
            label: l.reviewTab,
            badge: pending,
          ),
          GlassNavItem(
            icon: _tab == 2 ? Icons.folder_rounded : Icons.folder_outlined,
            label: l.mineTab,
          ),
          GlassNavItem(
            icon: _tab == 3 ? Icons.school_rounded : Icons.school_outlined,
            label: l.coursesTab,
          ),
        ],
      ),
    );
  }
}

// Render a gradient floating action button for creating a new challenge.
class _StudioFab extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _StudioFab({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: StudioTheme.creatorGradient,
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
