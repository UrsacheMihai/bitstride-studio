// Provide widgets for user profile actions in the app bar.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/studio/studio_state.dart';

// Define the data structure and initialize the Studio User Actions.
class StudioUserActions extends StatelessWidget {
  const StudioUserActions({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<StudioState>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.translate_rounded, size: 20),
          tooltip: 'Language',
          onSelected: (lang) => context.read<StudioState>().setLanguage(lang),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
}
