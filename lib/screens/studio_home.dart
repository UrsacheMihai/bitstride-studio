import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/studio_state.dart';
import 'create_screen.dart';
import 'my_challenges_screen.dart';
import 'review_screen.dart';
import 'course_manager_screen.dart';
import 'sync_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudioHome extends StatelessWidget {
  const StudioHome({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    return state.isAdmin ? const _AdminShell() : const _UserShell();
  }
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
    final state = context.read<StudioState>();
    final user = state.user;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.code, size: 24),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
          actions: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                    child: Text(user.displayName ?? user.email ?? '',
                        style: const TextStyle(fontSize: 13))),
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.language),
              tooltip: 'Language',
              onSelected: (lang) => context.read<StudioState>().setLanguage(lang),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'en', child: Text('English')),
                PopupMenuItem(value: 'ro', child: Text('Română')),
                PopupMenuItem(value: 'fr', child: Text('Français')),
                PopupMenuItem(value: 'es', child: Text('Español')),
                PopupMenuItem(value: 'pt', child: Text('Português')),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () => state.signOut(),
            ),
          ],
      ),
      body: _tab == 0
          ? const CreateScreen()
          : const MyChallengesScreen(),
      floatingActionButton: _tab == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreateScreen())),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.newChallenge),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.add_box_outlined),
            selectedIcon: const Icon(Icons.add_box),
            label: AppLocalizations.of(context)!.create,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: AppLocalizations.of(context)!.myChallenges,
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
    final pending =
        state.allChallenges.where((c) => !c.approved).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 24),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.studioAdmin,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: 'Language',
            onSelected: (lang) => context.read<StudioState>().setLanguage(lang),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'ro', child: Text('Română')),
              PopupMenuItem(value: 'fr', child: Text('Français')),
              PopupMenuItem(value: 'es', child: Text('Español')),
              PopupMenuItem(value: 'pt', child: Text('Português')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => state.signOut(),
          ),
        ],
      ),
      body: [
        const CreateScreen(),
        const ReviewScreen(),
        const MyChallengesScreen(),
        const CourseManagerScreen(),
        const SyncScreen(),
      ][_tab],
      floatingActionButton: _tab == 2
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreateScreen())),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.newChallenge),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.add_box_outlined),
            selectedIcon: const Icon(Icons.add_box),
            label: AppLocalizations.of(context)!.create,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.rate_review_outlined),
            ),
            selectedIcon: const Icon(Icons.rate_review),
            label: AppLocalizations.of(context)!.reviewTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: AppLocalizations.of(context)!.mineTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
            label: AppLocalizations.of(context)!.coursesTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.sync_outlined),
            selectedIcon: const Icon(Icons.sync),
            label: AppLocalizations.of(context)!.dataSync,
          ),
        ],
      ),
    );
  }
}
