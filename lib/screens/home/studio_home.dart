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