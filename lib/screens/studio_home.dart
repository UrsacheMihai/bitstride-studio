import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/studio_state.dart';
import '../studio_theme.dart';
import 'create_screen.dart';
import 'my_challenges_screen.dart';
import 'review_screen.dart';
import 'course_manager_screen.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
class StudioHome extends StatelessWidget {
  const StudioHome({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    return state.isAdmin ? const _AdminShell() : const _UserShell();
  }
}
PreferredSizeWidget _buildStudioAppBar(
    BuildContext context, String title, IconData titleIcon) {
  final state = context.read<StudioState>();
  final user = state.user;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    title: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: StudioTheme.creatorGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(titleIcon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(title),
      ],
    ),
    actions: [
      if (user != null)
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_rounded,
                    size: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  user.displayName ?? user.email ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.translate_rounded, size: 20),
        tooltip: 'Language',
        onSelected: (lang) => context.read<StudioState>().setLanguage(lang),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'en', child: Text('English')),
          PopupMenuItem(value: 'ro', child: Text('Română')),
          PopupMenuItem(value: 'fr', child: Text('Français')),
          PopupMenuItem(value: 'es', child: Text('Español')),
          PopupMenuItem(value: 'pt', child: Text('Português')),
        ],
      ),
      IconButton(
        icon: const Icon(Icons.logout_rounded, size: 20),
        tooltip: 'Sign out',
        onPressed: () => state.signOut(),
      ),
    ],
  );
}
class _UserShell extends StatefulWidget {
  const _UserShell();
  @override
  State<_UserShell> createState() => _UserShellState();
}
class _UserShellState extends State<_UserShell> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: _buildStudioAppBar(context, l.appTitle, Icons.code_rounded),
      body: _tab == 0 ? const CreateScreen() : const MyChallengesScreen(),
      floatingActionButton: _tab == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreateScreen())),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.newChallenge),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.add_box_outlined),
            selectedIcon: const Icon(Icons.add_box_rounded),
            label: l.create,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt_rounded),
            label: l.myChallenges,
          ),
        ],
      ),
    );
  }
}
class _AdminShell extends StatefulWidget {
  const _AdminShell();
  @override
  State<_AdminShell> createState() => _AdminShellState();
}
class _AdminShellState extends State<_AdminShell> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final state = context.read<StudioState>();
    final l = AppLocalizations.of(context)!;
    final pending = state.allChallenges.where((c) => !c.approved).length;
    final screens = const [
      CreateScreen(),
      ReviewScreen(),
      MyChallengesScreen(),
      CourseManagerScreen(),
    ];
    return Scaffold(
      appBar: _buildStudioAppBar(context, l.studioAdmin, Icons.admin_panel_settings_rounded),
      body: screens[_tab],
      floatingActionButton: _tab == 2
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreateScreen())),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.newChallenge),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.add_box_outlined),
            selectedIcon: const Icon(Icons.add_box_rounded),
            label: l.create,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              backgroundColor: StudioTheme.warningOrange,
              child: const Icon(Icons.rate_review_outlined),
            ),
            selectedIcon: const Icon(Icons.rate_review_rounded),
            label: l.reviewTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder_rounded),
            label: l.mineTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school_rounded),
            label: l.coursesTab,
          ),
        ],
      ),
    );
  }
}

